public class DorisNavigate : Gtk.HBox {
	Gtk.Entry uri_field;

	public void changed_uri(string uri) {
		this.uri_field.buffer.set_text(uri.data);
	}

	public DorisNavigate() {
		this.homogeneous = false;
		this.uri_field = new Gtk.Entry();
		this.add(this.uri_field);
//		this.HBox(false, 5);
	}
}
