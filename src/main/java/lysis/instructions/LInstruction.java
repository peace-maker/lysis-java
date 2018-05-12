package lysis.instructions;

import java.io.*;

import lysis.lstructure.Register;

public abstract class LInstruction {
	private long pc_;

    public LInstruction()
    {
    }

    public abstract Opcode op();

    public abstract void print(DataOutputStream tw) throws Exception;

    public boolean isControl()
    {
        return false;
    }

    public void setPc(long pc)
    {
        pc_ = pc;
    }

    public long pc()
    {
        return pc_;
    }

    public static String RegisterName(Register reg)
    {
        return (reg == Register.Pri) ? "pri" : "alt";
    }
}
