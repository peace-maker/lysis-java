package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LAddConstant extends LInstruction {

	private long amount_;

	public LAddConstant(long amount) {
		amount_ = amount;
	}

	public long amount() {
		return amount_;
	}

	@Override
	public Opcode op() {
		return Opcode.AddConstant;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("add.pri " + amount());
	}

}
