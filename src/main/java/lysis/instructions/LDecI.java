package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LDecI extends LInstruction {

	public LDecI() {
	}

	@Override
	public Opcode op() {
		return Opcode.DecI;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("dec.i    ; [pri] = [pri] + 1");
	}
}
