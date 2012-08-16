package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LStoreLocal extends LInstructionRegStack {

	public LStoreLocal(Register reg, long offset) {
		super(reg, offset);
	}

	@Override
	public Opcode op() {
		return Opcode.StoreLocal;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("stor.s." + RegisterName(reg()) + " " + offset());
	}

}
