#include <gtk/gtk.h>
#include <pty.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>

// ---------------- PTY → GTK ----------------

// gboolean on_pty_readable(GIOChannel *source, GIOCondition cond, gpointer data) {
//     g_print("on_pty_readable\n");

//     GtkTextBuffer *buffer = data;

//     if (cond & (G_IO_HUP | G_IO_ERR)) {
//         return FALSE;
//     }

//     char buf[1024];
//     gsize bytes_read = 0;
//     GError *err = NULL;

//     GIOStatus status = g_io_channel_read_chars(source, buf, sizeof(buf), &bytes_read, &err);

//     if (status == G_IO_STATUS_NORMAL && bytes_read > 0) {
//         gtk_text_buffer_insert_at_cursor(buffer, buf, bytes_read);
//     }

//     if (err) {
//         g_error_free(err);
//     }

//     // return TRUE;
//     return GDK_EVENT_STOP;

// }

gboolean on_pty_readable(GIOChannel *source, GIOCondition cond, gpointer data) {
    // g_print("PTY readable\n");

    GtkTextBuffer *buffer = data;

    if (cond & (G_IO_HUP | G_IO_ERR)) {
        return FALSE;
    }

    int fd = g_io_channel_unix_get_fd(source);

    char buf[1024];
    int n = read(fd, buf, sizeof(buf));

    if (n > 0) {
        // g_print("Wrote %d bytes\n", n);
        gtk_text_buffer_insert_at_cursor(buffer, buf, n);
    }

    return TRUE;
}

// ---------------- GTK → PTY ----------------

gboolean on_key(GtkEventControllerKey *controller,
                guint keyval,
                guint keycode,
                GdkModifierType state,
                gpointer user_data) {
    // g_print("key pressed\n");

    int master = *(int *)user_data;

    char buf[32];
    int len = 0;

    if (keyval == GDK_KEY_Return) {
        buf[0] = '\n'; len = 1;
    } else if (keyval == GDK_KEY_BackSpace) {
        buf[0] = 0x7f; len = 1;
    } else {
        gunichar c = gdk_keyval_to_unicode(keyval);
        if (c != 0) {
            len = g_unichar_to_utf8(c, buf);
        }
    }

    if (len > 0) {
        write(master, buf, len);
    }

    // return TRUE; // prevent default handling
    return GDK_EVENT_STOP;
}

// ---------------- Main ----------------

static void activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "GTK Terminal");
    gtk_window_set_default_size(GTK_WINDOW(window), 800, 600);

    GtkWidget *view = gtk_text_view_new();
    // gtk_widget_grab_focus(view);
    gtk_text_view_set_editable(GTK_TEXT_VIEW(view), FALSE);
    gtk_text_view_set_cursor_visible(GTK_TEXT_VIEW(view), TRUE);

    gtk_window_set_child(GTK_WINDOW(window), view);

    GtkTextBuffer *buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(view));

    // ---- Create PTY ----
    // int slave_fd_wtf;
    // pid_t is_slave = forkpty(&slave_fd_wtf, NULL, NULL, NULL);
    // int *slave_fd = g_malloc(sizeof(int));
    // *slave_fd = slave_fd_wtf;

    int *slave_fd = g_malloc(sizeof(int));
    pid_t is_slave = forkpty(slave_fd, NULL, NULL, NULL);

    if (is_slave == 0) {
        execlp("bash", "bash", NULL);
        exit(1);
    }

    // ---- Watch PTY ----
    GIOChannel *channel = g_io_channel_unix_new(*slave_fd);
    g_io_channel_set_encoding(channel, NULL, NULL); // raw bytes
    g_io_channel_set_flags(channel, G_IO_FLAG_NONBLOCK, NULL);

    g_io_add_watch(channel, G_IO_IN | G_IO_HUP | G_IO_ERR, on_pty_readable, buffer);

    // ---- Keyboard input ----
    GtkEventController *controller = gtk_event_controller_key_new();
    g_signal_connect(controller, "key-pressed", G_CALLBACK(on_key), slave_fd);
    gtk_widget_add_controller(view, controller);

    gtk_widget_set_visible(window, TRUE);
}

int main(int argc, char **argv) {
    GtkApplication *app = gtk_application_new("com.example.GtkTerminal", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);

    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    return status;
}