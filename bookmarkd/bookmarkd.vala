[DBus (name = "se.rdw.Bookmarkd")]
public class BookmarkRequest {
	public string[] fetch_updates(int64 fingerprint, out int64 new_fingerprint) {
		string[] arne = {};
		new_fingerprint = fingerprint;
		return arne;
	}

	public void push(string bookmark)
}
