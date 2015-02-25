[DBus (name = "org.slaeshjag.doris")]
public class DorisInterface {
	public static DorisInterface bus;

	public void go_uri(uint wid, string uri) {
		DorisWindow dw;

		dw = DorisWindow.find_window(wid);
		if (dw == null)
			return;
		dw.goto_uri(uri);
	}

	public DorisInterface() {
		bus = this;
	}
}
