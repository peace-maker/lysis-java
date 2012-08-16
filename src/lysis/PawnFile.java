package lysis;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;

import lysis.lstructure.Function;
import lysis.lstructure.Variable;
import lysis.sourcepawn.SourcePawnFile;

public abstract class PawnFile {
	protected Function[] functions_;
    protected Public[] publics_;
    protected Variable[] globals_;
    
    public static PawnFile FromFile(String path) throws Exception
    {
        FileInputStream fs = new FileInputStream(path);
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        int b;
        while ((b = fs.read()) >= 0)
        	bytes.write(b);
        byte[] vec = bytes.toByteArray();
        long magic = BitConverter.ToUInt32(vec, 0);
        if (magic == SourcePawnFile.MAGIC)
            return new SourcePawnFile(vec);
        //if (magic == AMXModXFile.MAGIC2)
        //    return new AMXModXFile(vec);
        throw new Exception("not a .amxx or .smx file!");
    }
    
    public abstract String stringFromData(long address);
    public abstract float floatFromData(long address);
    public abstract int int32FromData(long address);
    
    public Function lookupFunction(long pc)
    {
        for (int i = 0; i < functions_.length; i++)
        {
            Function f = functions_[i];
            if (pc >= f.codeStart() && pc < f.codeEnd())
                return f;
        }
        return null;
    }
    public Public lookupPublic(String name)
    {
        for (int i = 0; i < publics_.length; i++)
        {
            if (publics_[i].name() == name)
                return publics_[i];
        }
        return null;
    }

    public Public lookupPublic(long addr)
    {
        for (int i = 0; i < publics_.length; i++)
        {
            if (publics_[i].address() == addr)
                return publics_[i];
        }
        return null;
    }
    
    public Function[] functions()
    {
        return functions_;
    }
    public Public[] publics()
    {
        return publics_;
    }
    public Variable[] globals()
    {
        return globals_;
    }
    public abstract byte[] DAT();
}
