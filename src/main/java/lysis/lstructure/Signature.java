package lysis.lstructure;

public class Signature {
	protected String name_;
    protected long tag_id_;
    protected Tag tag_;
    protected Argument[] args_;

    public Signature(String name)
    {
        name_ = name;
    }

    public Tag returnType()
    {
        return tag_;
    }
    public long tag_id()
    {
        return tag_id_;
    }
    public String name()
    {
        return name_;
    }
    public Argument[] args()
    {
        return args_;
    }
    public void setTag(Tag tag)
    {
        tag_ = tag;
    }
    public void setTagId(long tag_id)
    {
    	tag_id_ = tag_id;
    }
    public void setName(String name)
    {
    	name_ = name;
    }
}
