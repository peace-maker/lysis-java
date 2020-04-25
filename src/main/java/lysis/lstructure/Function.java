package lysis.lstructure;

import lysis.types.rtti.RttiType;

public class Function extends Signature {
	long addr_;
	long codeStart_;
	long codeEnd_;

	short state_id_;
	long state_addr_;

	public Function(long addr, long codeStart, long codeEnd, String name) {
		super(name);
		addr_ = addr;
		codeStart_ = codeStart;
		codeEnd_ = codeEnd;
		tag_ = null;
		state_id_ = -1;
		state_addr_ = -1;
		rtti_type_ = null;
	}
	
	public Function(long addr, long codeStart, long codeEnd, String name, Tag tag) {
		super(name);
		addr_ = addr;
		codeStart_ = codeStart;
		codeEnd_ = codeEnd;
		tag_ = tag;
		state_id_ = -1;
		state_addr_ = -1;
		rtti_type_ = null;
	}

	public Function(long addr, long codeStart, long codeEnd, String name, long tag_id) {
		super(name);
		addr_ = addr;
		codeStart_ = codeStart;
		codeEnd_ = codeEnd;
		tag_id_ = tag_id;
		state_id_ = -1;
		state_addr_ = -1;
		rtti_type_ = null;
	}
	
	public Function(long addr, long codeStart, long codeEnd, String name, RttiType rttiType) {
		super(name);
		addr_ = addr;
		codeStart_ = codeStart;
		codeEnd_ = codeEnd;
		state_id_ = -1;
		state_addr_ = -1;
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

	public short stateId() {
		return state_id_;
	}

	public long stateAddr() {
		return state_addr_;
	}

	public void setCodeEnd(long codeEnd) {
		codeEnd_ = codeEnd;
	}

	public void setStateId(short state_id) {
		this.state_id_ = state_id;
	}

	public void setStateAddr(long state_addr) {
		this.state_addr_ = state_addr;
	}
}
