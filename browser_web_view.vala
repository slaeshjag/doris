public class BrowserWebView : Gtk.ScrolledWindow {
	private WebKit.WebView webview;
	private Soup.CookieJar cookies;
	private string home_subdir;
	
	public signal void title_changed(string title);
	public signal void new_uri(string uri);


	public bool go_forward() {
		this.webview.go_forward();
		return true;
	}

	public bool go_back() {
		this.webview.go_back();
		return true;
	}

	public void go_uri(string uri) {
		this.webview.load_uri(uri);
	}

	private void new_title(string title) {
		this.title_changed(title);
	}

	private void load_commit(WebKit.WebFrame wf) {
		this.new_uri(wf.uri);
		return;
	}

	private bool navigate_policy(WebKit.WebFrame frame, WebKit.NetworkRequest req, WebKit.WebNavigationAction action, WebKit.WebPolicyDecision dec) {
		if (action.reason == WebKit.WebNavigationReason.LINK_CLICKED)
			return false;
	//	this.new_uri(req.uri);
		return false;
	}

	public BrowserWebView() {
		this.home_subdir = DorisConfig.get_dir();
		DirUtils.create(this.home_subdir, 0700);
		
		this.cookies = new Soup.CookieJarText(Path.build_filename(this.home_subdir, "cookies.txt"), false);
		WebKit.get_default_session().add_feature(this.cookies);

		this.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
		this.webview = new WebKit.WebView();
		this.webview.navigation_policy_decision_requested.connect(this.navigate_policy);
		this.webview.load_committed.connect(this.load_commit);
		this.add(this.webview);
		this.show_all();

		this.webview.load_uri("http://google.se");
		this.webview.get_main_frame().title_changed.connect(this.new_title);
	}
}

