package lysis.instructions;

import java.io.DataOutputStream;

public class LTrackerPopSetHeap extends LInstruction {

	@Override
	public Opcode op() {
		return Opcode.DebugBreak;
	}

	@Override
	public void print(DataOutputStream tw) throws Exception {
		tw.writeBytes("tracker.pop.setheap");
	}

	
}
