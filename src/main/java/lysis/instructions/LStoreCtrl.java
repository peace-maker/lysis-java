package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LStoreCtrl extends LInstruction {

	// 2=HEA, 4=STK, 5=FRM, 6=CIP
	int ctrl_reg_index_;
	
	String[] ctrl_reg_name = {"COD", "DAT", "HEA", "STP", "STK", "FRM", "CIP"};
	
	public LStoreCtrl(int index)
    {
		ctrl_reg_index_ = index;
    }
	
	public int ctrlregindex()
	{
		return ctrl_reg_index_;
	}
	
	@Override
	public Opcode op() {
		return Opcode.StoreCtrl;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("sctrl " + ctrl_reg_index_ + "   ; " + ctrl_reg_name[ctrl_reg_index_] + " = PRI");
	}

}
