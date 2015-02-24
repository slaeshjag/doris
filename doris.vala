void main(string[] args) {
	DorisWindow win;
	Gtk.init(ref args);
	Notify.init("Doris");
	win = new DorisWindow();

	Gtk.main();
}
