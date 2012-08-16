package lysis;

import java.io.DataOutputStream;

import lysis.lstructure.LBlock;

public class DebugSpew {
	public static void DumpGraph(LBlock[] blocks, DataOutputStream tw) throws Exception
    {
        for (int i = 0; i < blocks.length; i++)
        {
            tw.writeBytes("Block " + i + ": (" + blocks[i].pc() + ")\n");
            for (int j = 0; j < blocks[i].instructions().length; j++)
            {
                tw.writeBytes("  ");
                blocks[i].instructions()[j].print(tw);
                tw.writeBytes("\n");
            }
            tw.writeBytes("\n\n");
        }
    }
}
