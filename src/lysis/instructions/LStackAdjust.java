package lysis.instructions;

import java.io.DataOutputStream;

public class LStackAdjust extends LInstruction {

    private int value_;
    
    public LStackAdjust(int value)
    {
        this.value_ = value;
    }
    
	@Override
	public Opcode op() {
		return Opcode.DebugBreak;
	}

	@Override
	public void print(DataOutputStream tw) throws Exception {
		tw.writeBytes("stackadjust " + value_);
	}

}
