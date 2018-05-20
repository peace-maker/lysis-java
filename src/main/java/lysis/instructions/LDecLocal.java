package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LDecLocal extends LInstructionStack {

	public LDecLocal(long offset) {
		super(offset);
	}

	@Override
	public Opcode op() {
		return Opcode.DecLocal;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("dec.s " + offset());
	}

}
