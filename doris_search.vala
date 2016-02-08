public class DorisSearch : Gtk.Box {
	Gtk.Button prev;
	Gtk.Button next;
	Gtk.Entry search_field;

	public signal void search_string(string search);
	public signal void search_next();
	public signal void search_prev();
	public signal void search_done();

	public void toggle_visible() {
		this.visible = !this.visible;
		if (this.visible)
			gain_focus();
		else
			this.search_done();
	}

	public void gain_focus() {
		this.search_field.grab_focus();
	}

	private void hide_search() {
		this.visible = false;
	}

	public void new_string(string search) {
		this.search_field.set_text(search);
		this.visible = true;
		this.gain_focus();
	}

	public DorisSearch() {
		this.set_orientation(Gtk.Orientation.HORIZONTAL);
		this.homogeneous = false;
		this.search_field = new Gtk.Entry();
		this.search_field.set_hexpand(true);
		this.add(this.search_field);
		this.search_field.changed.connect(() => this.search_string(this.search_field.text));
		this.search_done.connect(hide_search);
		this.search_field.grab_focus();

		this.prev = new Gtk.Button.from_stock(Gtk.Stock.GO_BACK);
		this.next = new Gtk.Button.from_stock(Gtk.Stock.GO_FORWARD);
		this.add(this.prev);
		this.add(this.next);
		this.prev.set_always_show_image(true);
		this.next.set_always_show_image(true);

		this.prev.clicked.connect(() => this.search_prev());
		this.next.clicked.connect(() => this.search_next());
		this.visible = false;
	}
}
