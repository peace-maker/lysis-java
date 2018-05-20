package lysis.lstructure;

public class Dimension {
	int tag_id_;
	Tag tag_;
	int size_;

	public Dimension(int tag_id, Tag tag, int size) {
		tag_id_ = tag_id;
		tag_ = tag;
		size_ = size;
	}

	public Tag tag() {
		return tag_;
	}

	public int size() {
		return size_;
	}
}
