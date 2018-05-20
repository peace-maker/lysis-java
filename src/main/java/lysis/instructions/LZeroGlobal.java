package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LZeroGlobal extends LInstruction {

	private long address_;

	public LZeroGlobal(long address) {
		address_ = address;
	}

	public long address() {
		return address_;
	}

	@Override
	public Opcode op() {
		return Opcode.ZeroGlobal;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("zero " + address());
	}

}
