package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LLoadGlobal extends LInstructionReg {

	private long address_;

    public LLoadGlobal(long address, Register reg)
    {
    	super(reg);
        address_ = address;
    }

    public long address()
    {
        return address_;
    }
	
	@Override
	public Opcode op() {
		return Opcode.LoadGlobal;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("load." + RegisterName(reg()) + " " + address());
	}

}
