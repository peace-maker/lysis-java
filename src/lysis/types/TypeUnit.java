package lysis.types;

import lysis.lstructure.Argument;
import lysis.lstructure.Tag;
import lysis.lstructure.Variable;

public class TypeUnit {
	public enum Kind
    {
        Cell,
        Reference,
        Array
    };

    private Kind kind_;
    private PawnType type_;         // kind_ == Cell or Array
    private int dims_;              // kind_ == Array
    private TypeUnit ref_;          // kind_ == Reference

    public TypeUnit(PawnType type)
    {
        kind_ = Kind.Cell;
        type_ = type;
    }
    public TypeUnit(PawnType type, int dims)
    {
        kind_ = Kind.Array;
        type_ = type;
        dims_ = dims;
    }
    public TypeUnit(TypeUnit other)
    {
        kind_ = Kind.Reference;
        ref_ = other;
    }
    public Kind kind()
    {
        return kind_;
    }
    public int dims()
    {
        assert(kind_ == Kind.Array);
        return dims_;
    }
    public PawnType type()
    {
        assert(kind_ == Kind.Cell || kind_ == Kind.Array);
        return type_;
    }
    public TypeUnit inner()
    {
        assert(kind_ == Kind.Reference);
        return ref_;
    }

    public TypeUnit load()
    {
        if (kind_ == Kind.Cell)
            return null;
        if (kind_ == Kind.Reference)
        {
            if (ref_.kind() == Kind.Array)
                return ref_.load();
            return ref_;
        }
        assert(kind_ == Kind.Array);
        if (dims_ == 1)
        {
            if (type_.isString())
                return new TypeUnit(new PawnType(CellType.Character));
            return new TypeUnit(type_);
        }
        return new TypeUnit(new TypeUnit(type_, dims_ - 1));
    }

    public boolean equalTo(TypeUnit other)
    {
        if (kind_ != other.kind_)
            return false;
        if (kind_ == Kind.Array && dims_ != other.dims_)
            return false;
        if (kind_ == Kind.Reference)
        {
            if ((ref_ == null) != (other.ref_ == null))
                return false;
            if (ref_ != null && !ref_.equalTo(other.ref_))
                return false;
        }
        else
        {
            if (!type_.equalTo(other.type_))
                return false;
        }
        return true;
    }

    public static TypeUnit FromTag(Tag tag)
    {
        return new TypeUnit(new PawnType(tag));
    }

    public static TypeUnit FromVariable(Variable var)
    {
        switch (var.type())
        {
            case Normal:
                return FromTag(var.tag());
            case Array:
                return new TypeUnit(new PawnType(var.tag()), var.dims().length);
            case Reference:
            {
                TypeUnit tu = new TypeUnit(new PawnType(var.tag()));
                return new TypeUnit(tu);
            }
            case ArrayReference:
            {
                TypeUnit tu = new TypeUnit(new PawnType(var.tag()), var.dims().length);
                return new TypeUnit(tu);
            }
        }
        return null;
    }

    public static TypeUnit FromArgument(Argument arg)
    {
        switch (arg.type())
        {
            case Normal:
                return FromTag(arg.tag());
            case Array:
            case ArrayReference:
                return new TypeUnit(new PawnType(arg.tag()), arg.dimensions().length);
        }
        return null;
    }
}
