package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LPushGlobal extends LInstruction {

	private long address_;

	public LPushGlobal(long address) {
		address_ = address;
	}

	public long address() {
		return address_;
	}

	@Override
	public Opcode op() {
		return Opcode.PushGlobal;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("push " + address());
	}

}
