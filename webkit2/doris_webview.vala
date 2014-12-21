public class DorisWebView : Gtk.ScrolledWindow {
	private WebKit.WebView webview;
	private string uri_hovered;
//	private Soup.CookieJar cookies;

	public signal void mouse_link_hover(string uri);

	private void link_hover_handler(WebKit.HitTestResult ht, uint modifiers) {
		if (ht.context_is_link())
			uri_hovered = ht.link_uri;
		else
			uri_hovered = null;
		this.mouse_link_hover(uri_hovered);
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
			return true;
		}

		pd.use();

		return true;
	}

	public bool go_back() {
		webview.go_back();
		return true;
	}

	public bool go_forward() {
		webview.go_forward();
		return true;
	}

	public void go_uri(string uri) {
		this.webview.load_uri(uri);
	}

	public string get_uri() {
		return this.webview.get_uri();
	}

	public string? hover_uri() {
		return this.uri_hovered;
	}

	public string? get_title() {
		return this.webview.get_title();
	}

	public DorisWebView() {
		this.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
		this.webview = new WebKit.WebView();
		this.add(this.webview);
		this.show_all();
		this.uri_hovered = null;
		this.webview.mouse_target_changed.connect(link_hover_handler);
		this.webview.decide_policy.connect(decide_policy_handler);

		this.webview.load_uri("http://google.se");
	}

}
