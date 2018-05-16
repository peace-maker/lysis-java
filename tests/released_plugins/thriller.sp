#include <sourcemod>

#define FILE_GAMEDATA "thriller.plugin"

new Address:g_addrPatch = Address_Null;
new g_iMemoryPatched = 0;

public Plugin:myinfo = 
{
	name = "Thriller",
	author = "linux_lover",
	description = "Blocks (random) thriller taunt",
	version = "0.2",
	url = "https://forums.alliedmods.net/showthread.php?p=2070774"
}

public OnPluginStart()
{
	Patch_Enable();
}

public OnPluginEnd()
{
	Patch_Disable();
}

Patch_Enable()
{
	g_addrPatch = Address_Null;
	g_iMemoryPatched = 0;
	
	// The "tf" in the gamedata probably makes game check redundant
	decl String:strGame[10];
	GetGameFolderName(strGame, sizeof(strGame));
	if(strcmp(strGame, "tf") != 0)
	{
		LogMessage("Failed to load thriller: Can only be loaded on Team Fortress.");
		return;
	}
	
	new Handle:hGamedata = LoadGameConfigFile(FILE_GAMEDATA);
	if(hGamedata == INVALID_HANDLE)
	{
		LogMessage("Failed to load thriller: Missing gamedata/%s.txt.", FILE_GAMEDATA);
		return;
	}
	
	new iPatchOffset = GameConfGetOffset(hGamedata, "Offset_ThrillerTaunt");
	if(iPatchOffset == -1)
	{
		LogMessage("Failed to load thriller: Failed to lookup patch offset.");
		CloseHandle(hGamedata);
		return;
	}
	
	new iPayload = GameConfGetOffset(hGamedata, "Payload_ThrillerTaunt");
	if(iPayload == -1)
	{
		LogMessage("Failed to load thriller: Failed to lookup patch payload.");
		CloseHandle(hGamedata);
		return;
	}
	
	g_addrPatch = GameConfGetAddress(hGamedata, "ThrillerTaunt");
	if(g_addrPatch == Address_Null)
	{
		LogMessage("Failed to load thriller: Failed to locate signature.");
		CloseHandle(hGamedata);
		return;
	}
	
	CloseHandle(hGamedata);
	
	g_addrPatch += Address:iPatchOffset;
	
	LogMessage("Patching ThrillerTaunt at address: 0x%.8X..", g_addrPatch);
	g_iMemoryPatched = LoadFromAddress(g_addrPatch, NumberType_Int8);
	StoreToAddress(g_addrPatch, iPayload, NumberType_Int8);
}

Patch_Disable()
{
	if(g_addrPatch == Address_Null) return;
	if(g_iMemoryPatched <= 0) return;
	
	LogMessage("Unpatching ThrillerTaunt at address: 0x%.8X..", g_addrPatch);
	StoreToAddress(g_addrPatch, g_iMemoryPatched, NumberType_Int8);
	
	g_addrPatch = Address_Null;
	g_iMemoryPatched = 0;
}