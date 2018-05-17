package lysis.instructions;

import java.io.DataOutputStream;

public class LStackAdjust extends LInstruction {

	// Always negative
    private int value_;
    
    public LStackAdjust(int value)
    {
        this.value_ = value;
    }
    
    public int value()
    {
    	return value_;
    }
    
	@Override
	public Opcode op() {
		return Opcode.StackAdjust;
	}

	@Override
	public void print(DataOutputStream tw) throws Exception {
		tw.writeBytes("stackadjust " + value_);
	}

}
