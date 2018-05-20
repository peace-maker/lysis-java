package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LMemCopy extends LInstruction {

	private long bytes_;

	public LMemCopy(long bytes) {
		bytes_ = bytes;
	}

	public long bytes() {
		return bytes_;
	}

	@Override
	public Opcode op() {
		return Opcode.MemCopy;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("movs " + bytes());
	}

}
