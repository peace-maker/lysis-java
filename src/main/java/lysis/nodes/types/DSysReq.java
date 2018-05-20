package lysis.nodes.types;

import lysis.lstructure.Native;
import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DSysReq extends DCallNode {
	private Native native_;

	public DSysReq(Native nativeX, DNode[] arguments) throws Exception {
		super(arguments);
		native_ = nativeX;
	}

	public Native nativeX() {
		return native_;
	}

	@Override
	public NodeType type() {
		return NodeType.SysReq;
	}

	@Override
	public void accept(NodeVisitor visitor) throws Exception {
		visitor.visit(this);
	}
}
