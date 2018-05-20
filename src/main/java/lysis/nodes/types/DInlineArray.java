package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DInlineArray extends DNullaryNode {
	private long address_;
	private long size_;

	public DInlineArray(long address, long size) {
		address_ = address;
		size_ = size;
	}

	@Override
	public NodeType type() {
		return NodeType.InlineArray;
	}

	@Override
	public void accept(NodeVisitor visitor) {
		visitor.visit(this);
	}

	public long address() {
		return address_;
	}

	public long size() {
		return size_;
	}
}
