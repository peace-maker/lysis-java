package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LDebugBreak extends LInstruction {

	public LDebugBreak()
    {
    }
	
	@Override
	public Opcode op() {
		return Opcode.DebugBreak;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("break");
	}

}
