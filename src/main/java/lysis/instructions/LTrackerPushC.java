package lysis.instructions;

import java.io.DataOutputStream;

public class LTrackerPushC extends LInstruction {

	private int value_;

	public LTrackerPushC(int value_) {
		this.value_ = value_;
	}

	@Override
	public Opcode op() {
		return Opcode.DebugBreak;
	}

	@Override
	public void print(DataOutputStream tw) throws Exception {
		tw.writeBytes("tracker.push.c " + value_);
	}

}
