package lysis;

public class Public {
	private long address_;
	private String name_;
	
	public Public(String name, long address) {
		name_ = name;
		address_ = address;
	}
	
	public String name() {
		return name_;
	}
	
	public long address() {
		return address_;
	}
}
