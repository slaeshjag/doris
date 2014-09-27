public class DorisWindow : Gtk.Window {
	static uint count = 0;
	BrowserWebView webview;
	public Gtk.AccelGroup acc;
	Gtk.VBox vbox;
	DorisNavigate nav;

	private void destroy_handle() {
		this.count--;
	
		if (this.count == 0) {
			Gtk.main_quit();
		}
	}

	private void set_window_title(string title) {
		this.title = title;
	}

	private void changed_uri(string new_uri) {
		this.nav.changed_uri(new_uri);
	}

	private void add_accelerators() {
		this.acc.connect(Gdk.keyval_from_name("L"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => webview.go_forward());
		this.acc.connect(Gdk.keyval_from_name("H"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => webview.go_back());
	}

	public DorisWindow() {
		this.count++;
		this.webview = new BrowserWebView();
		this.nav = new DorisNavigate();
		this.webview.new_uri.connect(this.changed_uri);
		this.title = "Doris";
		this.destroy.connect(destroy_handle);

		/* Use a vbox to prepend stuff above the webview */
		/* TODO: Replace with Gtk.Grid when we go GTK3-only. */
		this.vbox = new Gtk.VBox(false, 0);
		this.add(this.vbox);


		/* Add everything that goes above the webview here */
		this.vbox.pack_start(this.nav, false, true, 0);

		this.vbox.add(this.webview);
		this.show_all();

		this.acc = new Gtk.AccelGroup();
		this.add_accel_group(this.acc);
		this.add_accelerators();
		this.webview.title_changed.connect(set_window_title);
	}
}
