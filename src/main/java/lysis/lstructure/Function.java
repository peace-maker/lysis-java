package lysis.lstructure;

import java.util.LinkedList;

public class Function extends Signature {
	long addr_;
	long codeStart_;
	long codeEnd_;

    public Function(long addr, long codeStart, long codeEnd, String name, Tag tag)
    {
    	super(name);
        addr_ = addr;
        codeStart_ = codeStart;
        codeEnd_ = codeEnd;
        tag_ = tag;
    }
    
    public Function(long addr, long codeStart, long codeEnd, String name, long tag_id)
    {
    	super(name);
        addr_ = addr;
        codeStart_ = codeStart;
        codeEnd_ = codeEnd;
        tag_id_ = tag_id;
    }

    public void setArguments(LinkedList<Argument> from)
    {
    	args_ = from.toArray(new Argument[0]);
    }
    public long address()
    {
        return addr_;
    }
    public long codeStart()
    {
        return codeStart_;
    }
    public long codeEnd()
    {
        return codeEnd_;
    }
    
    public void setCodeEnd(long codeEnd)
    {
        codeEnd_ = codeEnd;
    }
}
