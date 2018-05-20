package lysis.lstructure;

public class Tag {
	private long tag_id_;
	private String name_;

	public Tag(String name, long tag_id) {
		tag_id_ = tag_id;
		name_ = name;
	}

	public long tag_id() {
		return tag_id_;
	}

	public String name() {
		return name_;
	}

	public String toString() {
		return String.format("Tag %x (%s)", tag_id_, name_);
	}
}
