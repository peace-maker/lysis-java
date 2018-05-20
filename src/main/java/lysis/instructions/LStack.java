package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LStack extends LInstruction {
	private long val_;

	public LStack(long val) {
		val_ = val;
	}

	public long amount() {
		return val_;
	}

	@Override
	public Opcode op() {
		return Opcode.Stack;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("stack " + amount());
	}
}
