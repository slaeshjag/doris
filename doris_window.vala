public class DorisWindow : Gtk.Window {
	static uint count = 0;
	BrowserWebView webview;
	public Gtk.AccelGroup acc;
	Gtk.VBox vbox;
	DorisNavigate nav;

	public WebKit.WebView get_webview() {
		return this.webview.get_webview();
	}

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

	private void goto_uri(string new_uri) {
		this.webview.go_uri(new_uri);
	}

	private void toggle_hide_nav() {
		this.nav.visible = !this.nav.visible;
		if (this.nav.visible)
			this.nav.gain_focus();
	}

	private void clipboard_push_uri() {
		string uri = this.webview.hover_uri;
		Gtk.Clipboard cb;

		if (uri == null)
			uri = this.webview.get_uri();
		cb = Gtk.Clipboard.get_for_display(Gdk.Display.get_default(), Gdk.Atom.intern("PRIMARY", true));
		cb.set_text(uri, -1);
		cb = Gtk.Clipboard.get_for_display(Gdk.Display.get_default(), Gdk.Atom.intern("CLIPBOARD", true));
		cb.set_text(uri, -1);
		cb.store();
	}
		

	private void add_accelerators() {
		this.acc.connect(Gdk.keyval_from_name("L"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => webview.go_forward());
		this.acc.connect(Gdk.keyval_from_name("H"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => webview.go_back());
		this.acc.connect(Gdk.keyval_from_name("G"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.toggle_hide_nav(); return false;});
		this.acc.connect(Gdk.keyval_from_name("Y"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.clipboard_push_uri(); return false;});
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
		this.nav.goto_uri.connect(goto_uri);
	}
}
