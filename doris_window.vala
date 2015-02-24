public class DorisWindow : Gtk.Window {
	static uint count = 0;
	BrowserWebView webview;
	public Gtk.AccelGroup acc;
	Gtk.VBox vbox;
	Gtk.HBox hbox;
	DorisNavigate nav;
	DorisDownloadList ddl;

	public WebKit.WebView get_webview() {
		return this.webview.get_webview();
	}

	private void destroy_handle() {
		DorisWindow.count--;
	
		if (DorisWindow.count == 0) {
			Gtk.main_quit();
		}
	}

	private void set_window_title(string title) {
		this.title = title;
	}

	private void changed_uri(string new_uri) {
		this.nav.changed_uri(new_uri);
	}

	private void new_download(DorisDownload dd) {
		this.ddl.vbox.pack_end(dd, false, false, 0);

	}

	private void goto_uri(string new_uri) {
		this.webview.go_uri(new_uri);
	}

	private void toggle_hide_nav() {
		this.nav.visible = !this.nav.visible;
		if (this.nav.visible)
			this.nav.gain_focus();
	}

	private void toggle_hide_download() {
		this.ddl.visible = !this.ddl.visible;
	}

	private void clipboard_callback(Gtk.Clipboard cb, string? uri) {
		Gtk.Clipboard ncb;
		string? new_uri;
		new_uri = this.webview.make_uri(uri);
		if (new_uri != null) {
			this.goto_uri(new_uri);
			return;
		}
	
		ncb = Gtk.Clipboard.get_for_display(Gdk.Display.get_default(), Gdk.Atom.intern("CLIPBOARD", true));
		if (ncb != cb)
			ncb.request_text(clipboard_callback);

	}

	private void clipboard_go_uri() {
		Gtk.Clipboard cb;
		cb = Gtk.Clipboard.get_for_display(Gdk.Display.get_default(), Gdk.Atom.intern("PRIMARY", true));
		cb.request_text(clipboard_callback);
		
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
		this.acc.connect(Gdk.keyval_from_name("G"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.toggle_hide_nav(); return true;});
		this.acc.connect(Gdk.keyval_from_name("Y"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.clipboard_push_uri(); return true;});
		this.acc.connect(Gdk.keyval_from_name("P"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.clipboard_go_uri(); return true;});
		this.acc.connect(Gdk.keyval_from_name("Q"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.toggle_hide_download(); return true;});
	}

	public DorisWindow() {
		DorisWindow.count++;
		this.webview = new BrowserWebView();
		this.nav = new DorisNavigate();
		this.webview.new_uri.connect(this.changed_uri);
		this.title = "Doris";
		this.ddl = new DorisDownloadList();
		this.destroy.connect(destroy_handle);

		/* Use a vbox to prepend stuff above the webview */
		/* TODO: Replace with Gtk.Grid when we go GTK3-only. */
		this.vbox = new Gtk.VBox(false, 0);
		this.add(this.vbox);
		this.hbox = new Gtk.HBox(false, 0);


		/* Add everything that goes above the webview here */
		this.vbox.pack_start(this.nav, false, true, 0);
	
		this.vbox.add(this.hbox);
		this.hbox.add(this.webview);
		this.hbox.pack_start(this.ddl, false, true, 0);
		this.show_all();

		this.acc = new Gtk.AccelGroup();
		this.add_accel_group(this.acc);
		this.add_accelerators();
		this.webview.title_changed.connect(set_window_title);
		this.webview.new_download.connect(new_download);
		this.nav.goto_uri.connect(goto_uri);
		this.ddl.visible = false;
	}
}
