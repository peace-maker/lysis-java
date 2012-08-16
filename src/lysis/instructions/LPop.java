package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LPop extends LInstructionReg {
	public LPop(Register reg)
	{
		super(reg);
	}
	
	@Override
	public Opcode op()
	{
	    return Opcode.Pop;
	}
	
	@Override
	public void print(DataOutputStream tw) throws IOException
	{
	    tw.writeBytes("pop." + RegisterName(reg()));
	}
}
