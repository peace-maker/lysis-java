package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LLoadLocal extends LInstructionRegStack {

	public LLoadLocal(long offset, Register reg) {
		super(reg, offset);
	}

	@Override
	public Opcode op() {
		return Opcode.LoadLocal;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("load.s." + RegisterName(reg()) + " " + offset());
	}

}
