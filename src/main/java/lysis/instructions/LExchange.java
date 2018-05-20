package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LExchange extends LInstruction {

	public LExchange() {
	}

	@Override
	public Opcode op() {
		return Opcode.Exchange;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("xchg");
	}

}
