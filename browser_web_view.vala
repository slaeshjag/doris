public class BrowserWebView : Gtk.ScrolledWindow {
	private WebKit.WebView webview;
	private Soup.CookieJar cookies;
	private string home_subdir;
	public string hover_uri;
	
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

	public string get_uri() {
		return this.webview.get_main_frame().uri;
	}

	private void new_title(string title) {
		this.title_changed(title);
	}

	private void load_commit(WebKit.WebFrame wf) {
		this.new_uri(wf.uri);
		return;
	}

	private WebKit.WebView open_new_window(WebKit.WebFrame wf) {
		DorisWindow win = new DorisWindow();
		return win.get_webview();
	}

	private void link_hover(string? title, string? uri) {
		this.hover_uri = uri;
	}

	public WebKit.WebView get_webview() {
		return this.webview;
	}


	public BrowserWebView() {
		this.home_subdir = DorisConfig.get_dir();
		DirUtils.create(this.home_subdir, 0700);
		
		this.cookies = new Soup.CookieJarText(Path.build_filename(this.home_subdir, "cookies.txt"), false);
		WebKit.get_default_session().add_feature(this.cookies);

		this.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
		this.webview = new WebKit.WebView();
		this.webview.load_committed.connect(this.load_commit);
		this.webview.create_web_view.connect(open_new_window);
		this.webview.hovering_over_link.connect(link_hover);
		this.add(this.webview);
		this.show_all();

		this.webview.load_uri("http://google.se");
		this.webview.get_main_frame().title_changed.connect(this.new_title);
	}
}

