package lysis.instructions;

import java.util.LinkedList;

import lysis.lstructure.LBlock;

public class SwitchCase {
	private LinkedList<Long> values_ = new LinkedList<Long>();
    public LBlock target;

    public SwitchCase(long value, LBlock target)
    {
        values_.add(value);
        this.target = target;
    }

    public long value(int i)
    {
        return values_.get(i);
    }
    
    public void addValue(long value) {
    	values_.add(value);
    }
    
    public int numValues()
    {
    	return values_.size();
    }

	public LinkedList<Long> values() {
		return values_;
	}
}
