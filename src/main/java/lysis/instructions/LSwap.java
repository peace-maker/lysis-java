package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LSwap extends LInstructionReg {

	public LSwap(Register reg) {
		super(reg);
	}

	@Override
	public Opcode op() {
		return Opcode.Swap;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("swap." + RegisterName(reg()));
	}

}
