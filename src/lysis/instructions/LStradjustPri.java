package lysis.instructions;

import java.io.DataOutputStream;

public class LStradjustPri extends LInstruction {

	@Override
	public Opcode op() {
		return Opcode.DebugBreak;
	}

	@Override
	public void print(DataOutputStream tw) throws Exception {
		tw.writeBytes("stradjust.pri");
	}

}
