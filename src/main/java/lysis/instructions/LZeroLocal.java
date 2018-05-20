package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LZeroLocal extends LInstruction {

	private long address_;

	public LZeroLocal(long address) {
		address_ = address;
	}

	public long address() {
		return address_;
	}

	@Override
	public Opcode op() {
		return Opcode.ZeroLocal;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("zero.s " + address());
	}

}
