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

	private void new_title(string title) {
		this.title_changed(title);
	}

	private void changed_uri(WebKit.WebFrame wf) {
		this.new_uri(wf.uri);
	}

	public BrowserWebView() {
		this.home_subdir = DorisConfig.get_dir();
		DirUtils.create(this.home_subdir, 0700);
		
		this.cookies = new Soup.CookieJarText(Path.build_filename(this.home_subdir, "cookies.txt"), false);
		WebKit.get_default_session().add_feature(this.cookies);

		this.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
		this.webview = new WebKit.WebView();
		this.webview.load_started.connect(this.changed_uri);
		this.add(this.webview);
		this.show_all();

		this.webview.load_uri("http://google.se");
		this.webview.get_main_frame().title_changed.connect(this.new_title);
	}
}

