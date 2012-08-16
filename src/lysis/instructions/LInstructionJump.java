package lysis.instructions;

import lysis.lstructure.LBlock;

public abstract class LInstructionJump extends LControlInstruction {

	private long target_offs_;

    public LInstructionJump(long target_offs, LBlock... targets)
    {
    	super(targets);
        target_offs_ = target_offs;
    }

	public long target_offs()
    {
        return target_offs_;
    }
}
