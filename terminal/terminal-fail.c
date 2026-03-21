#include <pty.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/select.h>
#include <termios.h>
#include <gtk/gtk.h>

// static void print_hello(GtkWidget *widget, gpointer data) {
//     g_print("Hello World\n");
// }

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

static void on_activate(GtkApplication *app) {
    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Terminal");
    gtk_window_set_default_size(GTK_WINDOW(window), 800, 800);

    // GtkWidget *button = gtk_button_new_with_label("Hello, World!");
    // gtk_widget_set_halign(button, GTK_ALIGN_CENTER);
    // gtk_widget_set_valign(button, GTK_ALIGN_CENTER);
    // g_signal_connect(button, "clicked", G_CALLBACK(print_hello), NULL);

    GtkWidget *view = gtk_text_view_new();
    gtk_text_view_set_editable(GTK_TEXT_VIEW(view), FALSE);
    gtk_text_view_set_cursor_visible(GTK_TEXT_VIEW(view), TRUE);
    // gtk_text_buffer_set_text(buffer, "Hello, this is some text", -1);
    gtk_window_set_child (GTK_WINDOW (window), view);
    GtkTextBuffer *text_buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW (view));

    gtk_window_present (GTK_WINDOW (window));

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
        // handle_master(shell_fd);
        g_unix_fd_add(shell_fd, G_IO_IN, on_pty_readable, text_buffer);
    }
}

gboolean on_pty_readable(gint fd, GIOCondition condition, gpointer data) {
    char buf[1024];
    int n = read(fd, buf, sizeof(buf));

    if (n > 0) {
        GtkTextBuffer *buffer = data;
        gtk_text_buffer_insert_at_cursor(buffer, buf, n);
    }

    return TRUE; // keep watching
}

int main(int argc, char *argv[]) { 
    // Create a new application
    GtkApplication *app = gtk_application_new(
        "jarmo.terminal",
        G_APPLICATION_DEFAULT_FLAGS
    );

    g_signal_connect(app, "activate", G_CALLBACK(on_activate), NULL);

    return g_application_run(G_APPLICATION(app), argc, argv);
}