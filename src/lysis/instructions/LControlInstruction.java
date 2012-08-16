package lysis.instructions;

import lysis.lstructure.LBlock;

public abstract class LControlInstruction extends LInstruction {

	protected LBlock[] successors_;

    public LControlInstruction(LBlock... blocks)
    {
        successors_ = blocks;
    }

	public void replaceSuccessor(int i, LBlock block)
    {
        successors_[i] = block;
    }

    public int numSuccessors()
    {
        return successors_.length;
    }

    public LBlock getSuccessor(int i)
    {
        return successors_[i];
    }

    @Override
    public boolean isControl()
    {
        return true;
    }
}
