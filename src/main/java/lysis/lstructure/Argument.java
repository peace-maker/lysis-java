package lysis.lstructure;

public class Argument {
	VariableType type_;
	String name_;
	int tag_id_;
	Tag tag_;
	Dimension[] dims_;
	boolean generated_;

	public Argument(VariableType type, String name, int tag_id, Tag tag, Dimension[] dims) {
		type_ = type;
		name_ = name;
		tag_id_ = tag_id;
		tag_ = tag;
		dims_ = dims;
	}

	public VariableType type() {
		return type_;
	}

	public String name() {
		return name_;
	}

	public Tag tag() {
		return tag_;
	}

	public Dimension[] dimensions() {
		return dims_;
	}

	public boolean generated() {
		return generated_;
	}

	public void markGenerated() {
		generated_ = true;
	}
}
