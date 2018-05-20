package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LDecGlobal extends LInstruction {

	private long address_;

	public LDecGlobal(long address) {
		address_ = address;
	}

	public long address() {
		return address_;
	}

	@Override
	public Opcode op() {
		return Opcode.DecGlobal;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("dec " + address());
	}

}
