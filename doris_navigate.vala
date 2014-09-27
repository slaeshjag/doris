public class DorisNavigate : Gtk.HBox {
	Gtk.Entry uri_field;

	public signal void goto_uri(string uri);

	public void changed_uri(string uri) {
		this.uri_field.buffer.set_text(uri.data);
		this.visible = false;
	}

	public void gain_focus() {
		this.uri_field.grab_focus();
	}

	public DorisNavigate() {
		this.homogeneous = false;
		this.uri_field = new Gtk.Entry();
		this.add(this.uri_field);
		this.uri_field.activate.connect(() => this.goto_uri(this.uri_field.buffer.text));
//		this.HBox(false, 5);
	}
}
