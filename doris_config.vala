public class DorisConfig {
	const string home_dir_subdir = ".doris";
	public static string get_dir() {
		return Path.build_filename(GLib.Environment.get_variable("HOME"), home_dir_subdir);
	}
}
