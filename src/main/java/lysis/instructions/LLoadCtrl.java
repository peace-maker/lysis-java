package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

public class LLoadCtrl extends LInstruction {

	// 0=COD, 1=DAT, 2=HEA, 3=STP, 4=STK, 5=FRM, 6=CIP (of the next instruction)
	int ctrl_reg_index_;

	String[] ctrl_reg_name = { "COD", "DAT", "HEA", "STP", "STK", "FRM", "CIP" };

	public LLoadCtrl(int index) {
		ctrl_reg_index_ = index;
	}

	public int ctrlregindex() {
		return ctrl_reg_index_;
	}

	@Override
	public Opcode op() {
		return Opcode.LoadCtrl;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("lctrl " + ctrl_reg_index_ + "   ; PRI = " + ctrl_reg_name[ctrl_reg_index_]);
	}

}
