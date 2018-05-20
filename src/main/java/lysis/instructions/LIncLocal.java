package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LIncLocal extends LInstructionStack {

	public LIncLocal(long offset) {
		super(offset);
	}

	@Override
	public Opcode op() {
		return Opcode.IncLocal;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("inc.s " + offset());
	}

}
