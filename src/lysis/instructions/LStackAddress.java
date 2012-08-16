package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LStackAddress extends LInstructionRegStack {

	public LStackAddress(long offset, Register reg) {
		super(reg, offset);
	}

	@Override
	public Opcode op() {
		return Opcode.StackAddress;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("addr." + RegisterName(reg()) + " " + offset());
	}

}
