package lysis.lstructure;

public class Tag {
	private long tag_id_;
	private String name_;
	
	public final static int FIXED = 0x40000000;
	public final static int FUNC = 0x20000000;
	public final static int OBJECT = 0x10000000;
	public final static int ENUM = 0x08000000;
	public final static int METHODMAP = 0x04000000;
	public final static int STRUCT = 0x02000000;
	public final static int FLAGMASK = FIXED | FUNC | OBJECT | ENUM | METHODMAP | STRUCT;

	public Tag(String name, long tag_id) {
		tag_id_ = tag_id;
		name_ = name;
	}

	public long tag_id() {
		return tag_id_;
	}
	
	public long id() {
		return tag_id_ & ~FLAGMASK;
	}
	
	public long flags() {
		return tag_id_ & FLAGMASK;
	}

	public String name() {
		return name_;
	}

	public boolean isFunction() {
		return (flags() & FUNC) > 0;
	}
	
	public boolean isFloat() {
		return name_ != null && name_.equals("Float");
	}
	
	public boolean isBoolean() {
		return name_ != null && name_.equals("bool");
	}
	
	public boolean isString() {
		return name_ != null && name_.equals("String");
	}
	
	public String toString() {
		return String.format("Tag %x (%s)", tag_id_, name_);
	}
}
