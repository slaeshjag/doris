public class DorisNavigate : Gtk.Box {
	Gtk.Entry uri_field;

	public signal void goto_uri(string uri);
	public signal void lost_focus();

	public void changed_uri(string uri) {
		this.uri_field.buffer.set_text(uri.data);
		if (this.visible)
			this.lost_focus();
		this.visible = false;

	}

	public void gain_focus() {
		this.uri_field.grab_focus();
	}

	public DorisNavigate() {
		this.set_orientation(Gtk.Orientation.HORIZONTAL);
		this.homogeneous = false;
		this.uri_field = new Gtk.Entry();
		this.uri_field.set_hexpand(true);
		this.add(this.uri_field);
		this.uri_field.activate.connect(() => this.goto_uri(this.uri_field.buffer.text));
		this.uri_field.grab_focus();
	}
}
