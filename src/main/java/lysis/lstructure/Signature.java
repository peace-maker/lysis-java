package lysis.lstructure;

import java.util.List;

import lysis.types.rtti.RttiType;

public class Signature {
	protected String name_;
	protected long tag_id_;
	protected Tag tag_;
	protected RttiType rtti_type_;
	protected Argument[] args_;

	public Signature(String name) {
		name_ = name;
	}

	public Tag returnTag() {
		return tag_;
	}
	
	public RttiType returnType() {
		return rtti_type_;
	}

	public long tag_id() {
		return tag_id_;
	}

	public String name() {
		return name_;
	}

	public Argument[] args() {
		return args_;
	}

	public void setTag(Tag tag) {
		tag_ = tag;
	}

	public void setTagId(long tag_id) {
		tag_id_ = tag_id;
	}

	public void setName(String name) {
		name_ = name;
	}

	public void setArguments(List<Argument> from) {
		args_ = from.toArray(new Argument[0]);
	}
	
	public boolean isStringReturn() {
		if (tag_ != null && tag_.isString())
			return true;
		if (rtti_type_ != null && rtti_type_.isString())
			return true;
		return false;
	}
}
