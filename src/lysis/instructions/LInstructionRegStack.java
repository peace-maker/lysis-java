package lysis.instructions;

import lysis.lstructure.Register;

public abstract class LInstructionRegStack extends LInstruction {

	private Register reg_;
    private long offs_;

    public LInstructionRegStack(Register reg, long offset)
    {
        reg_ = reg;
        offs_ = offset;
    }

    public Register reg()
    {
        return reg_;
    }

    public long offset()
    {
        return offs_;
    }

}
