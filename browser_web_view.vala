public class BrowserWebView : Gtk.ScrolledWindow {
	private WebKit.WebView webview;
	private string home_subdir;
	public string hover_uri;
	
	public signal void title_changed(string title);
	public signal void new_uri(string uri);
	public signal void new_download(DorisDownload dd);
	public signal void close();

	public string? make_uri(string? uri) {
		string clean = "";
		int i;

		if (uri == null)
			return null;

		for (i = 0; i < uri.length; i++) {
			if (uri[i] != '\n' && uri[i] != ' ')
				clean = clean + uri[i].to_string();
		}

		if (!clean.has_prefix("http://") && !clean.has_prefix("https://")) {
			return null;
		}
		return clean;
	}

	private bool decide_policy_handler(WebKit.PolicyDecision pd, WebKit.PolicyDecisionType type) {
		WebKit.ResponsePolicyDecision rpd;

		if (type != WebKit.PolicyDecisionType.RESPONSE) {
			pd.use();
			return true;
		}

		rpd = (WebKit.ResponsePolicyDecision) pd;
		if (!rpd.is_mime_type_supported()) {
			stdout.printf("Downloading %s\n", rpd.get_request().uri);
			pd.download();
			if (this.webview.get_back_forward_list().get_length() == 0)
				this.webview.close();
			return true;
		}

		pd.use();
		return true;
	}

	public bool go_forward() {
		this.webview.go_forward();
		return true;
	}

	public bool go_back() {
		this.webview.go_back();
		return true;
	}

	public void go_uri(string uri) {
		string new_uri;
		if (!uri.contains("://"))
			new_uri = "http://" + uri;
		else
			new_uri = uri;
		this.webview.load_uri(new_uri);
	}

	public string get_uri() {
		return this.webview.uri;
	}

	private void new_title(string? title) {
		if (title == null)
			title = this.webview.title;
		this.title_changed(title);
	}

	private void load_commit(WebKit.LoadEvent le) {
		this.new_uri(this.webview.uri);
		return;
	}

	private WebKit.WebView open_new_window(WebKit.NavigationAction na) {
		DorisWindow win = new DorisWindow(na.get_request().get_uri(), na.get_request());
		return win.get_webview();
	}

	private void link_hover(WebKit.HitTestResult htr, uint modifiers) {
		if (htr.context_is_link())
			this.hover_uri = htr.link_uri;
		else
			this.hover_uri = null;
		this.new_title(this.hover_uri != null ? this.hover_uri : this.webview.title);
	}

	public WebKit.WebView get_webview() {
		return this.webview;
	}


	public BrowserWebView(string uri, WebKit.URIRequest? uri_req) {
		this.home_subdir = DorisConfig.get_dir();
		DirUtils.create(this.home_subdir, 0700);
	
		this.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
		this.webview = new WebKit.WebView.with_user_content_manager(DorisWindow.ucm);
		this.webview.web_context.get_cookie_manager().set_persistent_storage(Path.build_filename(this.home_subdir, "cookies.txt"), WebKit.CookiePersistentStorage.TEXT);
		this.webview.load_changed.connect(this.load_commit);
		this.webview.create.connect(open_new_window);
		this.webview.mouse_target_changed.connect(link_hover);
		this.webview.decide_policy.connect(decide_policy_handler);
		this.add(this.webview);
		this.show_all();

		if (uri_req != null) {
			this.webview.load_request(uri_req);
		} else {
			this.webview.load_uri(uri);
		}
		this.webview.notify["title"].connect((s, p) => {
			new_title(null);
		});

		this.webview.web_context.download_started.connect((download) => { this.new_download(new DorisDownload(download)); });
	}
}

