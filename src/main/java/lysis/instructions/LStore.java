package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LStore extends LInstruction {

	private long bytes_;

	public LStore(long bytes) {
		bytes_ = bytes;
	}

	public long bytes() {
		return bytes_;
	}

	@Override
	public Opcode op() {
		return Opcode.Store;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("stor.i." + bytes() + "   ; [alt] = pri");
	}

}
