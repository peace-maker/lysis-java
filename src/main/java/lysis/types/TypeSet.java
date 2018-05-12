package lysis.types;

import java.util.LinkedList;

public class TypeSet {
	private LinkedList<TypeUnit> types_ = null;

    public int numTypes()
    {
        return types_ == null ? 0 : types_.size();
    }
    public TypeUnit types(int i)
    {
        return types_.get(i);
    }

    public void addType(TypeUnit tu)
    {
        if (types_ == null)
        {
            types_ = new LinkedList<TypeUnit>();
        }
        else
        {
            for (int i = 0; i < types_.size(); i++)
            {
                if (types_.get(i).equalTo(tu))
                    return;
            }
        }
        types_.add(tu);
    }
    public void addTypes(TypeSet other)
    {
        for (int i = 0; i < other.numTypes(); i++)
            addType(other.types(i));
    }
}
