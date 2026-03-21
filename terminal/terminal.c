#include <gtk/gtk.h>

static void print_hello(GtkWidget *widget, gpointer   data) {
  g_print("Hello World\n");
}

static void on_activate(GtkApplication *app)
{
  GtkWidget *window = gtk_application_window_new(app);
  gtk_window_set_title(GTK_WINDOW(window), "Terminal");
  gtk_window_set_default_size(GTK_WINDOW(window), 800, 800);

  GtkWidget *button = gtk_button_new_with_label("Hello, World!");
  gtk_widget_set_halign(button, GTK_ALIGN_CENTER);
  gtk_widget_set_valign(button, GTK_ALIGN_CENTER);

  g_signal_connect_swapped (button, "clicked", G_CALLBACK(print_hello), window);
  gtk_window_set_child (GTK_WINDOW (window), button);
  gtk_window_present (GTK_WINDOW (window));
}

int main(int argc, char *argv[])
{
  // Create a new application
  GtkApplication *app = gtk_application_new(
    "com.example.GtkApplication",
    G_APPLICATION_DEFAULT_FLAGS
  );

  g_signal_connect(app, "activate", G_CALLBACK(on_activate), NULL);
  return g_application_run(G_APPLICATION(app), argc, argv);
}