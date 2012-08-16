package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LStoreLocalRef extends LInstructionRegStack {

	public LStoreLocalRef(Register reg, long offset) {
		super(reg, offset);
	}

	@Override
	public Opcode op() {
		return Opcode.StoreLocalRef;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("sref.s." + RegisterName(reg()) + " " + offset());
	}

}
