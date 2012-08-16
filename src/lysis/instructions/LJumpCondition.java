package lysis.instructions;

import java.io.DataOutputStream;

import lysis.lstructure.LBlock;
import lysis.sourcepawn.SPOpcode;

public class LJumpCondition extends LInstructionJump {

	private SPOpcode op_;

    public LJumpCondition(SPOpcode op, LBlock true_target, LBlock false_target, long target_offs)
    {
    	super(target_offs, true_target, false_target);
        op_ = op;
    }


    public SPOpcode spop()
    {
        return op_;
    }
    public LBlock trueTarget()
    {
        return getSuccessor(0);
    }
    public LBlock falseTarget()
    {
        return getSuccessor(1);
    }

    
	@Override
	public Opcode op() {
		return Opcode.JumpCondition;
	}

	@Override
	public void print(DataOutputStream tw) throws Exception {
		switch (op_)
        {
            case jnz:
                tw.writeBytes("jnz ");
                break;
            case jzer:
                tw.writeBytes("jzero ");
                break;
            case jsgeq:
                tw.writeBytes("jsgeq ");
                break;
            case jsgrtr:
                tw.writeBytes("jsgrtr ");
                break;
            case jsleq:
                tw.writeBytes("jsleq ");
                break;
            case jsless:
                tw.writeBytes("jsless ");
                break;
            case jeq:
                tw.writeBytes("jeq ");
                break;
            case jneq:
                tw.writeBytes("jneq ");
                break;
            default:
                throw new Exception("unrecognized spop");
        }
        tw.writeBytes("block" + trueTarget().id() + " (block" + falseTarget().id() + ")");
	}

}
