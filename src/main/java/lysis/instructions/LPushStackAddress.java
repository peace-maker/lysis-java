package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LPushStackAddress extends LInstructionStack {

	public LPushStackAddress(long offset)
	{
		super(offset);
	}
	
	@Override
	public Opcode op() {
		return Opcode.PushStackAddress;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("push.adr " + offset());
	}

}
