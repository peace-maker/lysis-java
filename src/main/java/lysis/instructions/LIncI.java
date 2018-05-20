package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LIncI extends LInstruction {

	public LIncI() {
	}

	@Override
	public Opcode op() {
		return Opcode.IncI;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("inc.i    ; [pri] = [pri] + 1");
	}

}
