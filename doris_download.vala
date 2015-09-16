public class DorisDownload : Gtk.Frame {
	WebKit.Download download;
	Gtk.VBox vbox;
	Gtk.HBox button_hbox;
	Gtk.Button stop;
	new Gtk.Button remove;

	new Gtk.Label label;
	uint download_rate;
	int64 timestamp;
	uint downloaded_this_second;
	uint64 downloaded;
	bool failed;

	Gtk.ProgressBar pbar;

	
	private void download_failed(void *ptr) {
		this.pbar.set_text("Failed");
		this.failed = true;
	}

	private void download_finished() {
		string comment;
		Notify.Notification notification;

		if (!this.failed) {
			comment = "complete";
			this.pbar.set_text("Finished");
			this.pbar.set_fraction(1.0);
		} else
			comment = "failed";

		this.stop.visible = false;
		this.remove.visible = true;
		
		try {
			notification = new Notify.Notification("File Download", "Download of " + this.label.get_text() + " " + comment, "gtk-network");
			notification.show();
		} catch (Error e) {
			stdout.printf("Error: %s\n", e.message);
		}


	}

	private void download_stop() {
		this.download.cancel();
	}

	private void download_remove() {
		this.visible = false;
	}

	private bool download_decide_destination(string suggested_filename) {
		string dir, path, file;
		int i;

		dir = Environment.get_user_special_dir(UserDirectory.DOWNLOAD);
		for (i = 0; i < 256; i++) {
			if (i == 0)
				file = suggested_filename;
			else
				file = suggested_filename + "." + i.to_string();
			path = Path.build_filename(dir, file, null);
			if (!FileUtils.test(path, FileTest.EXISTS)) {
				this.label.set_text(file);
				this.download.set_destination("file://" + path);
				return true;
			}
		}

		return false;
	}


	private void progress(uint64 data) {
		int64 time_now;
		uint64 downloaded_kb;
		uint64 size_kb;
		uint rate_kb;

		time_now = get_real_time() / 1000000;
		this.downloaded += data;
		downloaded_kb = this.downloaded / 1024;
		size_kb = this.download.response.content_length / 1024;
		rate_kb = this.download_rate / 1024;


		if (time_now == this.timestamp) {
			this.downloaded_this_second = (uint) data + this.downloaded_this_second;
		} else {
			this.download_rate = this.downloaded_this_second;
			this.downloaded_this_second = 0;
			this.timestamp = time_now;
			
			if (size_kb == 0) {
				this.pbar.pulse();
				this.pbar.set_text(downloaded_kb.to_string() + " kB");
			} else {
				this.pbar.set_fraction(this.download.estimated_progress);
				this.pbar.set_text(downloaded_kb.to_string() + " kB / " + size_kb.to_string() + " kB (" + rate_kb.to_string() + " kB/s)");
			}
		}
	}

	public DorisDownload(WebKit.Download download) {
		this.download = download;
		this.download.received_data.connect(this.progress);
		this.timestamp = get_real_time() / 1000000;
		this.downloaded_this_second = 0;
		this.downloaded = 0;

		this.vbox = new Gtk.VBox(false, 0);
		this.button_hbox = new Gtk.HBox(false, 0);
		this.add(this.button_hbox);
		this.button_hbox.add(this.vbox);

		this.label = new Gtk.Label(null);
		this.vbox.pack_start(this.label, false, false, 0);
		this.stop = new Gtk.Button.from_icon_name("gtk-cancel", Gtk.IconSize.SMALL_TOOLBAR);
		this.stop.set_always_show_image(true);
		this.margin = 0;
		this.button_hbox.pack_end(this.stop, false, false, 0);
		this.remove = new Gtk.Button.from_icon_name("gtk-delete", Gtk.IconSize.SMALL_TOOLBAR);
		this.remove.set_always_show_image(true);
		this.button_hbox.pack_end(this.remove, false, false, 0);

		this.pbar = new Gtk.ProgressBar();
		this.pbar.set_fraction(0.0);
		this.pbar.set_show_text(true);
		this.vbox.pack_start(this.pbar, false, false, 0);
		this.failed = false;

		this.download.failed.connect(download_failed);
		this.download.finished.connect(download_finished);
		this.download.decide_destination.connect(download_decide_destination);

		this.stop.clicked.connect(download_stop);
		this.remove.clicked.connect(download_remove);

		this.show_all();
		this.remove.visible = false;
	}
}


public class DorisDownloadList : Gtk.ScrolledWindow {
	public Gtk.Box vbox;

	public DorisDownloadList() {
		Gtk.Label label = new Gtk.Label("Downloads");
		this.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		this.vbox = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
		this.add(this.vbox);
		this.vbox.pack_start(label, false, false, 10);
		this.show_all();
	}
}
