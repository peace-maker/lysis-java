package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LPushLocal extends LInstruction {

	private long offset_;

    public LPushLocal(long offset)
    {
        offset_ = offset;
    }

    public long offset()
    {
        return offset_;
    }
	
	@Override
	public Opcode op() {
		return Opcode.PushLocal;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("push.s " + offset());
	}

}
