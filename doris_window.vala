public class DorisWindow : Gtk.Window {
	static uint count = 0;
	static uint id_count = 0;

	uint id;
	bool insecure;
	bool ssl;
	BrowserWebView webview;
	public Gtk.AccelGroup acc;
	Gtk.VBox vbox;
	Gtk.HBox hbox;
	DorisNavigate nav;
	DorisDownloadList ddl;
	DorisProgressBar pb;
	static List<DorisWindow> windows = null;

	public static DorisWindow? find_window(uint id) {
		DorisWindow result = null;
		windows.foreach((entry) => {
			if (entry.id == id)
				result = entry;
		});
		
		return result;
	}

	public WebKit.WebView get_webview() {
		return this.webview.get_webview();
	}

	private void destroy_handle() {
		DorisWindow.count--;
		DorisWindow.windows.remove(this);
	
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

	public void goto_uri(string new_uri) {
		this.webview.go_uri(new_uri);
	}

	private void toggle_hide_nav() {
		this.nav.visible = !this.nav.visible;
		if (this.nav.visible)
			this.nav.gain_focus();
	}

	private Gdk.FilterReturn gdk_handle_filter(Gdk.XEvent xe, Gdk.Event ge) {
		X.Event *e = (void *) xe;
		X.Atom type;
		int format;
		ulong nitems, bytes;
		unowned string *data;
		string atom_value;
		void *vptr;


		if (e->type == X.EventType.PropertyNotify) {
			if (Gdk.X11.get_xatom_name(e->xproperty.atom) == "_DORIS_URI_GO") {
				Gdk.X11.get_default_xdisplay().get_window_property(Gdk.X11Window.get_xid(this.get_window()), e->xproperty.atom, 0, 512, false, X.XA_STRING, out type, out format, out nitems, out bytes, out vptr);
				if (vptr == null)
					return Gdk.FilterReturn.CONTINUE;
				data = vptr;
				atom_value = data;
				this.goto_uri(atom_value);
			}
		}

		return Gdk.FilterReturn.CONTINUE;
	}

	private void reset_progressbar(WebKit.LoadEvent le) {
		if (le == WebKit.LoadEvent.STARTED || le == WebKit.LoadEvent.REDIRECTED) {
			this.insecure = false;
			this.ssl = false;
			this.pb.set_fraction(0.0f);
			this.pb.set_ssl(false, false);
		} else if (le == WebKit.LoadEvent.COMMITTED) {
			TlsCertificate cert;
			TlsCertificateFlags errors;

			if (!this.get_webview().get_tls_info(out cert, out errors))
				this.ssl = false;
			else
				this.ssl = ((errors & TlsCertificateFlags.VALIDATE_ALL) == 0);
		}
			
		
		fraction_changed();
	}

	private void insecure_content(WebKit.InsecureContentEvent event) {
		this.insecure = true;
	}

	private void res_load_started(WebKit.WebResource res, WebKit.URIRequest req) {
		fraction_changed();
	}

	private void toggle_hide_download() {
		this.ddl.visible = !this.ddl.visible;
	}

	private void fraction_changed() {
		this.pb.set_ssl(this.ssl, !this.insecure);
		this.pb.set_fraction((float) this.get_webview().estimated_load_progress);

	}

//	private void bad_cert() {
//		this.
//	}

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
		this.acc.connect(Gdk.keyval_from_name("P"), Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK, Gtk.AccelFlags.VISIBLE, () => {this.webview.get_webview().run_javascript.begin("print();", null); return true;});
	}

	public DorisWindow(string uri, WebKit.URIRequest? uri_req) {
		DorisWindow.count++;
		this.id = DorisWindow.id_count++;
		if (DorisWindow.windows == null)
			DorisWindow.windows = new List<DorisWindow>();

		this.webview = new BrowserWebView(uri, uri_req);
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
		
		this.ddl.visible = false;
		this.pb = new DorisProgressBar();
		this.vbox.pack_start(this.pb, false, false, 0);

		this.show_all();

		this.acc = new Gtk.AccelGroup();
		this.add_accel_group(this.acc);
		this.add_accelerators();
		this.webview.title_changed.connect(set_window_title);
		this.webview.new_download.connect(new_download);
		this.get_webview().get_settings().set_user_agent_with_application_details("Doris", "0.1");
		this.get_webview().load_changed.connect(reset_progressbar);
		this.get_webview().insecure_content_detected.connect(insecure_content);
		this.get_webview().resource_load_started.connect(res_load_started);
		this.nav.goto_uri.connect(goto_uri);
		
		DorisWindow.windows.append(this);
		this.get_window().add_filter(gdk_handle_filter);
	}
}
