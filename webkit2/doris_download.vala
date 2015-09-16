public class DorisDownload : Gtk.Window {
	static bool open = false;
	public static bool already_open() {
		return open;
	}
	public DorisDownload() {
//		if (
		this.title = "Doris Download Manager";
		this.visible = false;
	}
}
