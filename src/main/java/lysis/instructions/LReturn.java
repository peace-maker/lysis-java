package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LReturn extends LControlInstruction {

	public LReturn() {
		super();
	}

	@Override
	public Opcode op() {
		return Opcode.Return;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException {
		tw.writeBytes("return");
	}

}
