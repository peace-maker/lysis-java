package lysis.nodes.types;

import lysis.nodes.NodeType;
import lysis.nodes.NodeVisitor;

public class DSentinel extends DNullaryNode {
	@Override
	public NodeType type()
    {
        return NodeType.Sentinel;
    }
	
	@Override
    public void accept(NodeVisitor visitor)
    {
    }
}
