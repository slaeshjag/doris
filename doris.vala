void main(string[] args) {
	DorisWindow win;
	Gtk.init(ref args);
	Notify.init("Doris");
	win = new DorisWindow("http://google.se", null);

	/* Register on dbus */
	try {
		var bus = Bus.get_sync(BusType.SESSION, null);
		bus.register_object("/org/slaeshjag/Doris", new DorisInterface());
	} catch (Error e) {
		stderr.printf("error: %s\n", e.message);
	}

	Gtk.main();
}
