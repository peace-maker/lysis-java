package lysis.builder.structure;

import lysis.nodes.NodeBlock;

public abstract class ControlBlock {
	NodeBlock source_;
    public abstract ControlType type();

    public ControlBlock(NodeBlock source)
    {
        source_ = source;
    }

    public NodeBlock source()
    {
        return source_;
    }
}
