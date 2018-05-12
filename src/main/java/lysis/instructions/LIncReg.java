package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LIncReg extends LInstructionReg {

	public LIncReg(Register reg) {
		super(reg);
	}

	@Override
	public Opcode op() {
		return Opcode.IncReg;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("inc." + RegisterName(reg()));
	}

}
