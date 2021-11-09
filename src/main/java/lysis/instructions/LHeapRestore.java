package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LHeapRestore extends LInstruction {

	@Override
	public Opcode op() {
		return Opcode.DebugBreak;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("heap.restore");
	}

}
