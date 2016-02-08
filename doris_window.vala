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
	DorisSearch search;
	DorisDownloadList ddl;
	DorisProgressBar pb;
	public static WebKit.UserContentManager ucm = null;
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

	private void refresh_page(bool cache) {
		if (cache)
			this.get_webview().reload();
		else
			this.get_webview().reload_bypass_cache();
	}

	public void goto_uri(string new_uri) {
		this.webview.go_uri(new_uri);
	}

	private void focus_webview() {
		this.get_webview().grab_focus();
	}

	private void toggle_hide_nav() {
		this.nav.visible = !this.nav.visible;
		if (this.nav.visible)
			this.nav.gain_focus();
		else
			focus_webview();
	}

	private void search_string(string search) {
		this.get_webview().get_find_controller().search(search, WebKit.FindOptions.CASE_INSENSITIVE | WebKit.FindOptions.WRAP_AROUND, uint.MAX);
	}

	private void search_next() {
		this.get_webview().get_find_controller().search_next();
	}

	private void search_prev() {
		this.get_webview().get_find_controller().search_previous();
	}

	private void search_done() {
		this.get_webview().get_find_controller().search_finish();
		focus_webview();
	}

	private void launch_mediaplayer(bool hover) {
		string uri = null;
		if (hover)
			uri = this.webview.hover_uri;
		if (uri == null)
			uri = this.webview.get_uri();

		try {
			string args[2] = { "totem", null};
			args[1] = uri;
			Pid pid;
			Process.spawn_async(null, args, null, SpawnFlags.SEARCH_PATH, null, out pid);
		} catch (Error e) {
			stderr.printf("Error: %s\n", e.message);
		}
	}

	private void spawn_bookmark_selection() {
		string id;

		id = ((uint) Gdk.X11Window.get_xid(this.get_window())).to_string();
		try {
			Pid pid;
			string args[3] = { "bookmark_select", null, null };
			args[1] = id;
			Process.spawn_async(null, args, null, SpawnFlags.SEARCH_PATH, null, out pid);
		} catch (Error e) {
			stderr.printf("Error: %s\n", e.message);
		}
	}

	private void spawn_bookmark_add() {
		try {
			Pid pid;
			string args[3] = { "bookmark_add", null, null };
			args[1] = this.webview.get_uri();
			Process.spawn_async(null, args, null, SpawnFlags.SEARCH_PATH, null, out pid);
		} catch (Error e) {
			stderr.printf("Error: %s\n", e.message);
		}
	}
	
	private void spawn_bookmark_delete() {
		try {
			Pid pid;
			string args[2] = { "bookmark_delete", null};
			Process.spawn_async(null, args, null, SpawnFlags.SEARCH_PATH, null, out pid);
		} catch (Error e) {
			stderr.printf("Error: %s\n", e.message);
		}
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
			} else if (Gdk.X11.get_xatom_name(e->xproperty.atom) == "_DORIS_FIND") {
				Gdk.X11.get_default_xdisplay().get_window_property(Gdk.X11Window.get_xid(this.get_window()), e->xproperty.atom, 0, 512, false, X.XA_STRING, out type, out format, out nitems, out bytes, out vptr);
				if (vptr == null)
					return Gdk.FilterReturn.CONTINUE;
				data = vptr;
				atom_value = data;
				this.search.search_string(atom_value);
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
		this.acc.connect(Gdk.keyval_from_name("R"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.refresh_page(true); return true;});
		this.acc.connect(Gdk.keyval_from_name("R"), Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK, Gtk.AccelFlags.VISIBLE, () => {this.refresh_page(false); return true;});
		this.acc.connect(Gdk.keyval_from_name("G"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.focus_webview(); this.toggle_hide_nav(); return true;});
		this.acc.connect(Gdk.keyval_from_name("Y"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.clipboard_push_uri(); return true;});
		this.acc.connect(Gdk.keyval_from_name("P"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.clipboard_go_uri(); return true;});
		this.acc.connect(Gdk.keyval_from_name("Q"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.focus_webview(); this.toggle_hide_download(); return true;});
		this.acc.connect(Gdk.keyval_from_name("P"), Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK, Gtk.AccelFlags.VISIBLE, () => {this.webview.get_webview().run_javascript.begin("print();", null); return true;});
		this.acc.connect(Gdk.keyval_from_name("W"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.focus_webview(); this.search.toggle_visible(); return true;});
		this.acc.connect(Gdk.keyval_from_name("J"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.search.search_prev(); return true;});
		this.acc.connect(Gdk.keyval_from_name("K"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.search.search_next(); return true;});
		this.acc.connect(Gdk.keyval_from_name("M"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.launch_mediaplayer(false); return true;});
		this.acc.connect(Gdk.keyval_from_name("M"), Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.SHIFT_MASK, Gtk.AccelFlags.VISIBLE, () => {this.launch_mediaplayer(true); return true;});
		this.acc.connect(Gdk.keyval_from_name("T"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {spawn_bookmark_selection(); return true;});
		this.acc.connect(Gdk.keyval_from_name("S"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {spawn_bookmark_add(); return true;});
		this.acc.connect(Gdk.keyval_from_name("D"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {spawn_bookmark_delete(); return true;});
		this.acc.connect(Gdk.keyval_from_name("space"), Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE, () => {this.focus_webview(); return true;});
	}

	public DorisWindow(string uri, WebKit.URIRequest? uri_req) {
		DorisWindow.count++;
		this.id = DorisWindow.id_count++;
		if (DorisWindow.windows == null) {
			DorisWindow.windows = new List<DorisWindow>();
		}

		if (DorisWindow.ucm == null) {
			DorisWindow.ucm = new WebKit.UserContentManager();
			string early_script, late_script;

			try {
				FileUtils.get_contents(DorisConfig.get_path("early_script.js"), out early_script);
				var euscr = new WebKit.UserScript(early_script, WebKit.UserContentInjectedFrames.TOP_FRAME, WebKit.UserScriptInjectionTime.START, null, null);
				DorisWindow.ucm.add_script(euscr);
			} catch (Error e) {
			}

			try {
				FileUtils.get_contents(DorisConfig.get_path("late_script.js"), out late_script);
				var luscr = new WebKit.UserScript(late_script, WebKit.UserContentInjectedFrames.TOP_FRAME, WebKit.UserScriptInjectionTime.END, null, null);
				DorisWindow.ucm.add_script(luscr);
			} catch (Error e) {
			}
		}

		this.webview = new BrowserWebView(uri, uri_req);
		this.nav = new DorisNavigate();
		this.search = new DorisSearch();
		this.webview.new_uri.connect(this.changed_uri);
		this.title = "Doris";
		this.ddl = new DorisDownloadList();
		this.destroy.connect(destroy_handle);
		this.webview.close.connect(destroy_handle);

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
		
		this.pb = new DorisProgressBar();
		this.vbox.pack_start(this.search, false, false, 0);
		this.vbox.pack_start(this.pb, false, false, 0);

		this.show_all();
		this.ddl.visible = false;
		this.search.visible = false;

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

		this.search.search_string.connect(this.search_string);
		this.search.search_next.connect(this.search_next);
		this.search.search_prev.connect(this.search_prev);
		this.search.search_done.connect(this.search_done);

		this.nav.lost_focus.connect(this.focus_webview);

			
	}
}
