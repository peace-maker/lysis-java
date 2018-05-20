package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LHeap extends LInstruction {

	private long amount_;

	public LHeap(long amount) {
		amount_ = amount;
	}

	public long amount() {
		return amount_;
	}

	@Override
	public Opcode op() {
		return Opcode.Heap;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("heap " + amount());
	}

}
