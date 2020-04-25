package lysis.lstructure;

import lysis.types.rtti.RttiType;

public class Argument {
	VariableType type_;
	String name_;
	int tag_id_;
	Tag tag_;
	Dimension[] dims_;
	RttiType rtti_type_;
	boolean generated_;

	public Argument(VariableType type, String name, int tag_id, Tag tag, Dimension[] dims) {
		type_ = type;
		name_ = name;
		tag_id_ = tag_id;
		tag_ = tag;
		dims_ = dims;
		rtti_type_ = null;
	}
	
	public Argument(VariableType type, String name, RttiType rttiType, Dimension[] dims) {
		type_ = type;
		name_ = name;
		tag_id_ = -1;
		tag_ = null;
		dims_ = dims;
		rtti_type_ = rttiType;
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
	
	public RttiType rttiType() {
		return rtti_type_;
	}
	
	public boolean isString() {
		if (tag_ != null && tag_.isString())
			return true;
		if (rtti_type_ != null && rtti_type_.isString())
			return true;
		return false;
	}
}
