public class DorisWindow : Gtk.Window {
	/* Track the number of open windows in this instance */
	static uint count = 0;

	private DorisWebView wv;
	private Gtk.AccelGroup acc;
	
	public void go_uri(string uri) {
		this.wv.go_uri(uri);
	}

	private void clipboard_result(Gtk.Clipboard cb, string? uri) {
		if (uri != null)
			go_uri(uri);
	}

	private void uri_hover_update(string? uri) {
		if (uri != null)
			this.title = "Doris - " + uri;
		else
			this.title = "Doris - " + wv.get_title();
	}

	public bool clipboard_pull_uri() {
		Gtk.Clipboard cb;

		cb = Gtk.Clipboard.get_for_display(Gdk.Display.get_default(), Gdk.Atom.intern("PRIMARY", true));
		cb.request_text(clipboard_result);
		return true;
	}

	private void destroy_handle() {
		count--;
		if (count == 0)
			Gtk.main_quit();
	}

	public bool clipboard_push_uri() {
		string uri = this.wv.hover_uri();
		Gtk.Clipboard cb;

		if (uri == null)
			uri = this.wv.get_uri();
		cb = Gtk.Clipboard.get_for_display(Gdk.Display.get_default(), Gdk.Atom.intern("PRIMARY", true));
		cb.set_text(uri, -1);
		cb = Gtk.Clipboard.get_for_display(Gdk.Display.get_default(), Gdk.Atom.intern("CLIPBOARD", true));
		cb.set_text(uri, -1);
		cb.store();
		return true;
	}

	private void add_accelerators() {
		/* Back in history */
		this.acc.connect(Gdk.keyval_from_name("H"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => this.wv.go_back());
		/* Forward in history */
		this.acc.connect(Gdk.keyval_from_name("L"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => this.wv.go_forward());
		/* Go to URI in selection buffer */
		this.acc.connect(Gdk.keyval_from_name("P"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => this.clipboard_pull_uri());
		/* Put the current URI (or the one you're hilighting with the mouse cursor) in the selection buffer AND in the clipboard */
		this.acc.connect(Gdk.keyval_from_name("Y"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => this.clipboard_push_uri());
	}

	public DorisWindow() {
		count++;
		this.title = "Doris";
		this.default_height = 400;
		this.default_width = 780;

		wv = new DorisWebView();
		this.add(wv);
		this.show_all();

		this.acc = new Gtk.AccelGroup();
		this.add_accel_group(this.acc);
		add_accelerators();

		this.destroy.connect(destroy_handle);
		this.wv.mouse_link_hover.connect(uri_hover_update);
	}
}
