package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LPushConstant extends LInstruction {
	private long val_;

    public LPushConstant(long val)
    {
        val_ = val;
    }

    public long val()
    {
        return val_;
    }

    @Override
    public Opcode op()
    {
        return Opcode.PushConstant;
    }

    @Override
    public void print(DataOutputStream tw) throws IOException
    {
        tw.writeBytes("push.c " + val());
    }
}
