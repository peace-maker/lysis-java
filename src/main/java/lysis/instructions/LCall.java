package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LCall extends LInstruction {

	private long address_;

	public LCall(long address) {
		address_ = address;
	}

	public long address() {
		return address_;
	}

	@Override
	public Opcode op() {
		return Opcode.Call;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("call");
	}

}
