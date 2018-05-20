package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LLoad extends LInstruction {

	private long bytes_;

	public LLoad(long bytes) {
		bytes_ = bytes;
	}

	private long bytes() {
		return bytes_;
	}

	@Override
	public Opcode op() {
		return Opcode.Load;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("load.i." + bytes() + "   ; pri = [pri]");
	}

}
