package lysis.lstructure;

import lysis.types.rtti.RttiType;

public class Variable {
	long addr_;
	long tag_id_;
	Tag tag_;
	long codeStart_;
	long codeEnd_;
	VariableType type_;
	Scope scope_;
	String name_;
	Dimension[] dims_;
	boolean statevar_;
	RttiType rtti_type_;

	public Variable(long addr, int tag_id, Tag tag, long codeStart, long codeEnd, VariableType type, Scope scope,
			String name, Dimension[] dims) {
		addr_ = addr;
		tag_id_ = (long) tag_id;
		tag_ = tag;
		codeStart_ = codeStart;
		codeEnd_ = codeEnd;
		type_ = type;
		scope_ = scope;
		name_ = name;
		dims_ = dims;
		statevar_ = false;
		rtti_type_ = null;
	}
	
	public Variable(long addr, int tag_id, Tag tag, long codeStart, long codeEnd, VariableType type, Scope scope,
			String name) {
		this(addr, tag_id, tag, codeStart, codeEnd, type, scope, name, null);
	}

	public Variable(long addr, long codeStart, long codeEnd, VariableType type, Scope scope,
			String name, Dimension[] dims, RttiType rttiType) {
		this(addr, -1, null, codeStart, codeEnd, type, scope, name, dims);
		rtti_type_ = rttiType;
	}

	public long address() {
		return addr_;
	}

	public long codeStart() {
		return codeStart_;
	}

	public long codeEnd() {
		return codeEnd_;
	}

	public String name() {
		return name_;
	}

	public VariableType type() {
		return type_;
	}

	public Scope scope() {
		return scope_;
	}

	public Tag tag() {
		return tag_;
	}

	public long tag_id() {
		return tag_id_;
	}

	public Dimension[] dims() {
		return dims_;
	}

	public boolean isStateVariable() {
		return statevar_;
	}

	public void setTag(Tag tag) {
		tag_ = tag;
		tag_id_ = tag.tag_id();
	}

	public void setTagId(long tag_id) {
		tag_id_ = tag_id;
	}

	public void setName(String name) {
		name_ = name;
	}

	public void markAsStateVariable() {
		statevar_ = true;
	}
	
	public RttiType rttiType() {
		return rtti_type_;
	}
	
	public void updateByRef() {
		rtti_type_.setByRef();
		type_ = rtti_type_.toVariableType();
	}
	
	public boolean isString() {
		if (tag_ != null && tag_.isString())
			return true;
		if (rtti_type_ != null && rtti_type_.isString())
			return true;
		return false;
	}
	
	public boolean isFloat() {
		if (tag_ != null && tag_.isFloat())
			return true;
		if (rtti_type_ != null && rtti_type_.isFloat())
			return true;
		return false;
	}
}
