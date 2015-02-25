public class DorisProgressBar : Gtk.DrawingArea {
	float fraction;
	bool secure;
	bool ssl;

	public override bool draw(Cairo.Context cr) {
		int w, h;
		float wf;

		w = this.get_allocated_width();
		h = this.get_allocated_height();
		wf = this.fraction * w;

		if (!this.ssl)
			cr.set_source_rgb(1, 0, 0);
		else {
			if (this.secure)
				cr.set_source_rgb(0, 1, 0);
			else
				cr.set_source_rgb(1, 1, 0);
		}

		cr.rectangle(0, 0, wf, h);
		cr.fill();

		return false;
	}

	private void redraw_canvas() {
		Gdk.Window w;
		Cairo.Region r;

		if ((w = this.get_window()) == null)
			return;
		r = w.get_clip_region();
		w.invalidate_region(r, true);
		w.process_updates(true);
	}

	public void set_ssl(bool ssl, bool secure) {
		this.ssl = ssl;
		this.secure = secure;
		this.redraw_canvas();
	}

	public void set_fraction(float fraction) {
		this.fraction = fraction;
		this.redraw_canvas();
	}

	public DorisProgressBar() {
		this.set_size_request(100, 4);
	}
}
