#include <pty.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/select.h>
#include <termios.h>

struct termios orig;

void enable_raw_mode() {
    struct termios raw;

    tcgetattr(STDIN_FILENO, &orig);
    raw = orig;

    raw.c_lflag &= ~(ECHO | ICANON);  // disable echo + line buffering

    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}

// void disable_raw_mode() {
//     tcsetattr(STDIN_FILENO, TCSAFLUSH, &orig);
// }

static void handle_slave() {
    /**
     * Replace the currently executing program with bash (for the slave process).
     * The lines after execve are reached only if execve fails. 
     * 
     * ChatGPT recommended execlp which is a little bit more concise `execlp("bash", "bash", NULL)`, 
     * but I prefer using the raw syscall, execve.
     */
    #define program "/bin/bash"
    static char *argv[] = { program, NULL };
    static char *envp[] = { NULL };
    execve(program, argv, envp);
    perror("execve");
    exit(1);
}

static void handle_master(int shell_fd) {
    // Parent: relay data
    char buf[1024];
    fd_set fds;

    while (1) {
        FD_ZERO(&fds);
        FD_SET(STDIN_FILENO, &fds);
        FD_SET(shell_fd, &fds);

        // Listens for events in the specified fds.
        select(shell_fd + 1, &fds, NULL, NULL, NULL);

        // Input from the user, pass it to the shell
        if (FD_ISSET(STDIN_FILENO, &fds)) {
            int n = read(STDIN_FILENO, buf, sizeof(buf));
            write(shell_fd, buf, n);
        }

        // Input from the shell, pass it to the user
        if (FD_ISSET(shell_fd, &fds)) {
            int n = read(shell_fd, buf, sizeof(buf));
            write(STDOUT_FILENO, buf, n);
        }
    }
}

int main() {
    enable_raw_mode();
    /**
     * The fd shared between the master and the slave. We'll only use it in the 
     * master process, so the name is representing the master's point of view.
     */
    int shell_fd;

    /**
     * Creates a slave process. Master and slave both execute the lines after the fork. 
     * In the master process the return value (pid) is the process id of the slave.
     * In the slave process the return value (pid) is 0.
     */
    int is_slave = forkpty(&shell_fd, NULL, NULL, NULL) == 0;

    if (is_slave) {
        handle_slave();
    } else {
        handle_master(shell_fd);
    }

    // disable_raw_mode();
}