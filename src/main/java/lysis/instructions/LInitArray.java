package lysis.instructions;

import java.io.DataOutputStream;
import java.io.IOException;

import lysis.lstructure.Register;

public class LInitArray extends LInstruction {
	private Register reg_;
	private int template_;
	private int ivcount_;
	private int copycount_;
	private int fillcount_;
	private int fillvalue_;

	public LInitArray(Register reg, int templateAddr, int ivCellCount, int dataCopyCount, int dataFillCount, int fillValue) {
		reg_ = reg;
		template_ = templateAddr;
		ivcount_ = ivCellCount;
		copycount_ = dataCopyCount;
		fillcount_ = dataFillCount;
		fillvalue_ = fillValue;
	}
	
	public Register reg() {
		return reg_;
	}
	
	public int template() {
		return template_;
	}
	
	public int ivcount() {
		return ivcount_;
	}
	
	public int copycount() {
		return copycount_;
	}
	
	public int fillcount() {
		return fillcount_;
	}
	
	public int fillvalue() {
		return fillvalue_;
	}

	@Override
	public Opcode op() {
		return Opcode.InitArray;
	}

	@Override
	public void print(DataOutputStream tw) throws IOException, Exception {
		tw.writeBytes("initarray." + RegisterName(reg()) + " " + template() + " " + ivcount() + " " + copycount() + " " + fillcount() + " " + fillvalue());
	}
}
