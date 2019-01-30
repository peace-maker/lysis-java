stock ExplodeString2(const String:text[], const String:split[], String:buffers[][], maxStrings, maxStringLength)
{
	new reloc_idx, idx, total;
	
	if (maxStrings < 1 || split[0] == '\0')
	{
		return 0;
	}
	
	while ((idx = SplitString(text[reloc_idx], split, buffers[total], maxStringLength)) != -1)
	{
		reloc_idx += idx;
		if (text[reloc_idx] == '\0')
		{
			break;
		}
		if (++total >= maxStrings)
		{
			return total;
		}
	}
	
	if (text[reloc_idx] != '\0' && total <= maxStrings - 1)
	{
		strcopy(buffers[total++], maxStringLength, text[reloc_idx]);
	}
	
	return total;
}

public void OnPluginStart()
{
	char splits[4][4];
	ExplodeString2("blabla wat yo", " ", splits, sizeof(splits), sizeof(splits[]));
}