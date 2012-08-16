package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LPushReg extends LInstructionReg {

	public LPushReg(Register reg) {
		super(reg);
	}

	@Override
	public Opcode op() {
		return Opcode.PushReg;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("push." + RegisterName(reg()));
	}

}
