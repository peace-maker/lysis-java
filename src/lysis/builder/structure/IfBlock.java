package lysis.builder.structure;

import lysis.nodes.NodeBlock;

public class IfBlock extends ControlBlock {
	ControlBlock trueArm_;
    ControlBlock falseArm_;
    ControlBlock join_;
    LogicChain logic_;
    boolean invert_;

    public IfBlock(NodeBlock source, boolean invert, ControlBlock trueArm, ControlBlock join)
    {
    	super(source);
        trueArm_ = trueArm;
        falseArm_ = null;
        join_ = join;
        invert_ = invert;
    }

    public IfBlock(NodeBlock source, boolean invert, ControlBlock trueArm, ControlBlock falseArm, ControlBlock join)
    {
    	super(source);
        trueArm_ = trueArm;
        falseArm_ = falseArm;
        join_ = join;
        invert_ = invert;
    }
    public IfBlock(NodeBlock source, LogicChain chain, ControlBlock trueArm, ControlBlock join)
    {
    	super(source);
        trueArm_ = trueArm;
        falseArm_ = null;
        join_ = join;
        invert_ = false;
        logic_ = chain;
    }

    public IfBlock(NodeBlock source, LogicChain chain, ControlBlock trueArm, ControlBlock falseArm, ControlBlock join)
    {
    	super(source);
        trueArm_ = trueArm;
        falseArm_ = falseArm;
        join_ = join;
        invert_ = false;
        logic_ = chain;
    }

    @Override
    public ControlType type()
    {
        return ControlType.If;
    }
    public ControlBlock trueArm()
    {
        return trueArm_;
    }
    public ControlBlock falseArm()
    {
        return falseArm_;
    }
    public ControlBlock join()
    {
        return join_;
    }
    public boolean invert()
    {
        return invert_;
    }
    public LogicChain logic()
    {
        return logic_;
    }
}
