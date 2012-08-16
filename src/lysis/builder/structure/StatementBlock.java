package lysis.builder.structure;

import lysis.nodes.NodeBlock;

public class StatementBlock extends ControlBlock {
	ControlBlock next_;

    public StatementBlock(NodeBlock source, ControlBlock next)
    {
    	super(source);
        next_ = next;
    }

    @Override
    public ControlType type()
    {
        return ControlType.Statement;
    }
    public ControlBlock next()
    {
        return next_;
    }
}
