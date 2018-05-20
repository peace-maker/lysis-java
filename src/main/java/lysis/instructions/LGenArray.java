package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LGenArray extends LInstruction {
	private boolean autozero_;
	private int dims_;

	public LGenArray(int dims, boolean autozero) {
		dims_ = dims;
		autozero_ = autozero;
	}

	public boolean autozero() {
		return autozero_;
	}

	public int dims() {
		return dims_;
	}

	@Override
	public Opcode op() {
		return Opcode.GenArray;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("genarray" + (autozero_ ? ".z " : " ") + dims_);
	}
}
