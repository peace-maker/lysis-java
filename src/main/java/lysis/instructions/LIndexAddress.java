package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LIndexAddress extends LInstruction {

	private long shift_;

	public LIndexAddress(long shift) {
		shift_ = shift;
	}

	public long shift() {
		return shift_;
	}

	@Override
	public Opcode op() {
		return Opcode.IndexAddress;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("idxaddr " + shift() + " ; pri=alt+(pri<<" + shift() + ")");
	}

}
