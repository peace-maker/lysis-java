#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "1.1.1"
//#define MAX_FRAMECHECK 33
#define MAX_FRAMECHECK 20

static BackpackOwner[2048+1] = {0, ...};
static BackpackIndex[MAXPLAYERS+1] = {0, ...};
static iModelIndex[MAXPLAYERS+1] = {0, ...};

GameMode;
L4D2Version;

pack_mols[MAXPLAYERS+1];							//Molotovs
pack_pipes[MAXPLAYERS+1];							//Pipebombs
pack_biles[MAXPLAYERS+1];							//Bile Bombs
pack_kits[MAXPLAYERS+1];							//First Aid Kits
pack_defibs[MAXPLAYERS+1];							//Defibrillator
pack_firepacks[MAXPLAYERS+1];						//Incendiary Ammo Packs
pack_explodepacks[MAXPLAYERS+1];					//Explosive Ammo Packs
pack_pills[MAXPLAYERS+1];							//Pain Pills
pack_adrens[MAXPLAYERS+1];							//Adrenaline

pack_slot2[MAXPLAYERS+1];							//Grenade Selection
pack_slot3[MAXPLAYERS+1];							//Kit Selection
pack_slot4[MAXPLAYERS+1];							//Pills Selection

pack_store[MAXPLAYERS+1][9];						//Backpack Storage

item_drop[MAXPLAYERS+1];
pills_owner[MAXPLAYERS+1];

bool:BombUsed[MAXPLAYERS+1];
bool:KitUsed[MAXPLAYERS+1];
bool:PillsUsed[MAXPLAYERS+1];

bool:g_InUse[MAXPLAYERS+1];
bool:BackpackStart[MAXPLAYERS+1];

Float:Pos[3];
Float:Ang[3];

Handle:pack_version = INVALID_HANDLE;
Handle:help_mode = INVALID_HANDLE;
//Handle:UseDistance = INVALID_HANDLE;
Handle:ShowBackpack = INVALID_HANDLE;
Handle:IncapPickup = INVALID_HANDLE;
Handle:DeathDrop = INVALID_HANDLE;
Handle:DropNotify = INVALID_HANDLE;
Handle:FullNotify = INVALID_HANDLE;
Handle:hTrace[MAXPLAYERS+1] = INVALID_HANDLE;
Handle:nadetimer[MAXPLAYERS+1] = INVALID_HANDLE;

Handle:max_molotovs = INVALID_HANDLE;
Handle:max_pipebombs = INVALID_HANDLE;
Handle:max_vomitjars = INVALID_HANDLE;
Handle:max_kits = INVALID_HANDLE;
Handle:max_defibs = INVALID_HANDLE;
Handle:max_incendiary = INVALID_HANDLE;
Handle:max_explosive = INVALID_HANDLE;
Handle:max_pills = INVALID_HANDLE;
Handle:max_adrenalines = INVALID_HANDLE;

Handle:start_molotovs = INVALID_HANDLE;
Handle:start_pipebombs = INVALID_HANDLE;
Handle:start_vomitjars = INVALID_HANDLE;
Handle:start_kits = INVALID_HANDLE;
Handle:start_defibs = INVALID_HANDLE;
Handle:start_incendiary = INVALID_HANDLE;
Handle:start_explosive = INVALID_HANDLE;
Handle:start_pills = INVALID_HANDLE;
Handle:start_adrenalines = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "Improved Oshroth's Backpack",
	author = "MasterMind420, Oshroth",
	description = "Gives players a backpack to carry extra items",
	version = PLUGIN_VERSION,
	url = ""
}

/*
Improved Oshroth's Backpack
v0.8
Items automatically refill empty slots.

Limit backpack contents added. (Optional)
Pickup items while incap added. (Optional)
Display a backpack on players backs added. (Optional)
Configure players starting backpack contents added. (Optional)

Pills passing problem from the original plugin should be fixed.
Starting backpack contents may be buggy, minimal testing has been done.
There's a compatibility issue with plugins that give throwables, they duplicate.

THIS IS A TEST RELEASE PLEASE REPORT ANY BUGS YOU FIND
*/

public OnPluginStart()
{
	GameCheck();

	RegConsoleCmd("sm_bp", PackMenu);
	RegAdminCmd("sm_vbp", AdminViewMenu, ADMFLAG_GENERIC, "Allows admins to view players backpacks");

	/* Event Hooks */
	HookEvent("item_pickup", Event_ItemPickup);			//Used to handle item pickups
	HookEvent("weapon_drop", Event_WeaponDrop);			//Used to catch item drops
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre); 		//Used to drop player's items on death
	HookEvent("round_freeze_end", Event_RoundEnd);
	HookEvent("mission_lost", Event_MissionLost);
	HookEvent("finale_win", Event_FinaleWin);

	/* Item Use Events */
	HookEvent("weapon_fire", Event_WeaponFire);
	HookEvent("heal_success", Event_KitUsed); 			//Used to catch when someone uses a kit
	HookEvent("defibrillator_used", Event_KitUsed); 	//Used to catch when someone uses a defib
	HookEvent("upgrade_pack_used",Event_KitUsed); 		//Used to catch when someone deploys a ammo pack
	HookEvent("pills_used", Event_PillsUsed); 			//Used to catch when someone uses pills
	HookEvent("adrenaline_used", Event_PillsUsed); 		//Used to catch when someone uses adrenaline

	/* Backpack Changeover */
	HookEvent("bot_player_replace", Event_BotToPlayer); //Used to give a leaving Bot's pack to a joining player
	HookEvent("player_bot_replace", Event_PlayerToBot); //Used to give a leaving player's pack to a joining Bot

	//HookEvent("player_first_spawn", Player_First_Spawn);	//Backpack Model Attachment
	HookEvent("player_spawn", Player_Spawn);	//Backpack Model Attachment
	HookEvent("player_team", TeamChange);

	pack_version = CreateConVar("l4d_backpack_version", PLUGIN_VERSION, "Backpack plugin version.", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	help_mode = CreateConVar("l4d_backpack_help_mode", "1", "Controls how joining help message is displayed.");
	//UseDistance = CreateConVar("l4d_backpack_use_distance", "96", "Pickup distance for items");
	ShowBackpack = CreateConVar("l4d_backpack_show_backpack", "1", "[1 = Enable][0 = Disable] Show backpack model on players backs");
	IncapPickup = CreateConVar("l4d_backpack_incap_pickup", "1", "[1 = Enable][0 = Disable] Allow picking up items while incap");
	DeathDrop = CreateConVar("l4d_backpack_death_drop", "1", "[1 = Enable][0 = Disable] Drop backpack contents when players die");

	DropNotify = CreateConVar("l4d_backpack_drop_notify", "1", "[1 = Enable][0 = Disable] item drop notification");
	FullNotify = CreateConVar("l4d_backpack_full_notify", "1", "[1 = Enable][0 = Disable] item full notification");

	max_molotovs = CreateConVar("l4d_backpack_max_mols", "1", "Max Molotovs", _, true, 0.0);
	max_pipebombs = CreateConVar("l4d_backpack_max_pipes", "1", "Max Pipe Bombs", _, true, 0.0);
	max_vomitjars = CreateConVar("l4d_backpack_max_biles", "1", "Max Bile Jars", _, true, 0.0);
	max_kits = CreateConVar("l4d_backpack_max_kits", "1", "Max Medkits", _, true, 0.0);
	max_defibs = CreateConVar("l4d_backpack_max_defibs", "1", "Max Defibs", _, true, 0.0);
	max_incendiary = CreateConVar("l4d_backpack_max_firepacks", "1", "Max Fire Ammo Packs", _, true, 0.0);
	max_explosive = CreateConVar("l4d_backpack_max_explodepacks", "1", "Max Explode Ammo Packs", _, true, 0.0);
	max_pills = CreateConVar("l4d_backpack_max_pills", "1", "Max Pills", _, true, 0.0);
	max_adrenalines = CreateConVar("l4d_backpack_max_adrens", "1", "Max Adrenalines", _, true, 0.0);

	start_molotovs = CreateConVar("l4d_backpack_start_mols", "0", "Starting Molotovs", _, true, 0.0);
	start_pipebombs = CreateConVar("l4d_backpack_start_pipes", "0", "Starting Pipe Bombs", _, true, 0.0);
	start_vomitjars = CreateConVar("l4d_backpack_start_biles", "0", "Starting Bile Jars", _, true, 0.0);
	start_kits = CreateConVar("l4d_backpack_start_kits", "0", "Starting Medkits", _, true, 0.0);
	start_defibs = CreateConVar("l4d_backpack_start_defibs", "0", "Starting Defibs", _, true, 0.0);
	start_incendiary = CreateConVar("l4d_backpack_start_firepacks", "0", "Starting Fire Ammo Packs", _, true, 0.0);
	start_explosive = CreateConVar("l4d_backpack_start_explodepacks", "0", "Starting Explode Ammo Packs", _, true, 0.0);
	start_pills = CreateConVar("l4d_backpack_start_pills", "0", "Starting Pills", _, true, 0.0);
	start_adrenalines = CreateConVar("l4d_backpack_start_adrens", "0", "Starting Adrenalines", _, true, 0.0);

	AutoExecConfig(true, "l4d_backpack");

	SetConVarString(pack_version, PLUGIN_VERSION);

	ResetBackpack(0, 1);

	CreateTimer(1.0, AutoItemRefill, _, TIMER_REPEAT);
	CreateTimer(0.4, PackLimitEnforce, _, TIMER_REPEAT);
}

GameCheck()
{
	decl String:GameName[16];
	GetConVarString(FindConVar("mp_gamemode"), GameName, sizeof(GameName));

	if(StrEqual(GameName, "coop", false))
		GameMode = 1;
	else if(StrEqual(GameName, "realism", false))
		GameMode = 2;
	else if(StrEqual(GameName, "versus", false))
		GameMode = 3;
	else if(StrEqual(GameName, "scavenge", false))
		GameMode = 4;
	else if(StrEqual(GameName, "teamversus", false))
		GameMode = 5;
	else if(StrEqual(GameName, "teamscavenge", false))
		GameMode = 6;
	else if(StrEqual(GameName, "survival", false))
		GameMode = 7;
	else
		GameMode = 0;

	GetGameFolderName(GameName, sizeof(GameName));

	if (StrEqual(GameName, "left4dead2", false))
		L4D2Version = true;
	else
		L4D2Version = false;

	GameMode += 0;
}

public OnClientPostAdminCheck(client)
{
	if(!IsValidClient(client))
		return;

	if (GetConVarInt(help_mode) > 0)
		CreateTimer(15.0, Timer_WelcomeMessage, client, TIMER_FLAG_NO_MAPCHANGE);

	if(!BackpackStart[client] && !IsFakeClient(client))
	{
		StartBackpack(client);
		BackpackStart[client] = true;
	}

	SaveBackpack(client);

	if (L4D2Version || !L4D2Version)
		return;
}

public Player_Spawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(GetConVarInt(ShowBackpack) != 1)
		return;

	CreateTimer(0.5, FixBackpackPosition, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:FixBackpackPosition(Handle:Timer, any:client)
{
	if(!IsSurvivor(client))
		return;

	CreateBackpack(client);
}

public OnGameFrame()
{
	static iFrameskip = 0;
	iFrameskip = (iFrameskip + 1) % MAX_FRAMECHECK;

	if(iFrameskip != 0 || !IsServerProcessing() || GetConVarInt(ShowBackpack) != 1)
		return;

	for(new i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || !IsPlayerAlive(i))
			continue;

		if(iModelIndex[i] == GetEntProp(i, Prop_Data, "m_nModelIndex", 2))
			continue;

		iModelIndex[i] = GetEntProp(i, Prop_Data, "m_nModelIndex", 2);

		CreateBackpack(i);
	}
}

public Action:Timer_WelcomeMessage(Handle:timer, any:client)
{
	if (IsValidClient(client) && !IsFakeClient(client))
	{
		switch (GetConVarInt(help_mode))
		{
			case 1:
				PrintToChat(client, "\x01[SM] Type \x04!bp\x01 in chat to access your backpack.");
			case 2:
				PrintHintText(client, "\x01[SM] Type \x04!bp\x01 in chat to access your backpack.");
			case 3:
				PrintCenterText(client, "\x01[SM] Type \x04!bp\x01 in chat to access your backpack.");
		}
	}
}

public Action:PackLimitEnforce(Handle:timer)
{
	decl Float:cPos[3];

	for (new client = 1; client <= MAXPLAYERS; client++)
	{
		if (IsSurvivor(client) && IsPlayerAlive(client) && !IsFakeClient(client))
		{
			GetClientEyePosition(client, cPos);

			if (pack_mols[client] > GetConVarInt(max_molotovs))
			{
				SpawnItem(cPos, "weapon_molotov", 1);
				pack_mols[client] = GetConVarInt(max_molotovs);
			}

			if (pack_pipes[client] > GetConVarInt(max_pipebombs))
			{
				SpawnItem(cPos, "weapon_pipe_bomb", 1);
				pack_pipes[client] = GetConVarInt(max_pipebombs);
			}

			if (pack_biles[client] > GetConVarInt(max_vomitjars))
			{
				SpawnItem(cPos, "weapon_vomitjar", 1);
				pack_biles[client] = GetConVarInt(max_vomitjars);
			}

			if (pack_kits[client] > GetConVarInt(max_kits))
			{
				SpawnItem(cPos, "weapon_first_aid_kit", 1);
				pack_kits[client] = GetConVarInt(max_kits);
			}

			if (pack_defibs[client] > GetConVarInt(max_defibs))
			{
				SpawnItem(cPos, "weapon_defibrillator", 1);
				pack_defibs[client] = GetConVarInt(max_defibs);
			}

			if (pack_firepacks[client] > GetConVarInt(max_incendiary))
			{
				SpawnItem(cPos, "weapon_upgradepack_incendiary", 1);
				pack_firepacks[client] = GetConVarInt(max_incendiary);
			}

			if (pack_explodepacks[client] > GetConVarInt(max_explosive))
			{
				SpawnItem(cPos, "weapon_upgradepack_explosive", 1);
				pack_explodepacks[client] = GetConVarInt(max_explosive);
			}

			if (pack_pills[client] > GetConVarInt(max_pills))
			{
				SpawnItem(cPos, "weapon_pain_pills", 1);
				pack_pills[client] = GetConVarInt(max_pills);
			}

			if (pack_adrens[client] > GetConVarInt(max_adrenalines))
			{
				SpawnItem(cPos, "weapon_adrenaline", 1);
				pack_adrens[client] = GetConVarInt(max_adrenalines);
			}
		}
	}
}

public Action:AutoItemRefill(Handle:timer)
{
	for (new client = 1; client <= MAXPLAYERS; client++)
	{
		if (IsSurvivor(client) && IsPlayerAlive(client) && !IsFakeClient(client))
		{
			int slot2 = GetPlayerWeaponSlot(client, 2);
			int slot3 = GetPlayerWeaponSlot(client, 3);
			int slot4 = GetPlayerWeaponSlot(client, 4);

			if(slot2 == -1)
			{
				if (BombUsed[client])
				{
					BombUsed[client] = false;
					continue;
				}

				else if (pack_mols[client] > 0)
				{
					pack_mols[client] -= 1;
					CheatCommand(client, "give", "weapon_molotov", "");
				}

				else if (pack_pipes[client] > 0)
				{
					pack_pipes[client] -= 1;
					CheatCommand(client, "give", "weapon_pipe_bomb", "");
				}

				else if (pack_biles[client] > 0)
				{
					pack_biles[client] -= 1;
					CheatCommand(client, "give", "weapon_vomitjar", "");
				}
			}
			else if(slot3 == -1)
			{
				if (KitUsed[client])
				{
					KitUsed[client] = false;
					continue;
				}

				else if (pack_kits[client] > 0)
				{
					pack_kits[client] -= 1;
					CheatCommand(client, "give", "weapon_first_aid_kit", "");
				}

				else if (pack_defibs[client] > 0)
				{
					pack_defibs[client] -= 1;
					CheatCommand(client, "give", "weapon_defibrillator", "");
				}

				else if (pack_firepacks[client] > 0)
				{
					pack_firepacks[client] -= 1;
					CheatCommand(client, "give", "weapon_upgradepack_incendiary", "");
				}

				else if (pack_explodepacks[client] > 0)
				{
					pack_explodepacks[client] -= 1;
					CheatCommand(client, "give", "weapon_upgradepack_explosive", "");
				}
			}
			else if(slot4 == -1)
			{
				if (PillsUsed[client])
				{
					PillsUsed[client] = false;
					continue;
				}

				else if (pack_pills[client] > 0)
				{
					pack_pills[client] -= 1;
					CheatCommand(client, "give", "weapon_pain_pills", "");
				}

				else if (pack_adrens[client] > 0)
				{
					pack_adrens[client] -= 1;
					CheatCommand(client, "give", "weapon_adrenaline", "");
				}
			}
		}
	}
}

public Action:Event_ItemPickup(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	decl String:item[32];
	GetEventString(event, "item", item, sizeof(item));

	item_drop[client] = 0;

	if(StrContains(item, "molotov", false) != -1)
	{
		if(nadetimer[client] != INVALID_HANDLE)
		{
			KillTimer(nadetimer[client]);
			nadetimer[client] = INVALID_HANDLE;
			GrenadeRemove(client);
		}

		pack_slot2[client] = 1;
	}
	else if(StrContains(item, "pipe_bomb", false) != -1)
	{
		if(nadetimer[client] != INVALID_HANDLE)
		{
			KillTimer(nadetimer[client]);
			nadetimer[client] = INVALID_HANDLE;
			GrenadeRemove(client);
		}

		pack_slot2[client] = 2;
	}
	else if(StrContains(item, "vomitjar", false) != -1)
	{
		if(nadetimer[client] != INVALID_HANDLE)
		{
			KillTimer(nadetimer[client]);
			nadetimer[client] = INVALID_HANDLE;
			GrenadeRemove(client);
		}

		pack_slot2[client] = 3;
	}
	else if(StrContains(item, "first_aid_kit", false) != -1)
		pack_slot3[client] = 1;
	else if(StrContains(item, "defibrillator", false) != -1)
		pack_slot3[client] = 2;
	else if(StrContains(item, "upgradepack_incendiary", false) != -1)
		pack_slot3[client] = 3;
	else if(StrContains(item, "upgradepack_explosive", false) != -1)
		pack_slot3[client] = 4;
	else if(StrContains(item, "pain_pills", false) != -1)
	{
		if(pills_owner[client] != 0)
		{
			CreateTimer(1.0, GivePills, pills_owner[client]);
			pills_owner[client] = 0;
		}

		pack_slot4[client] = 1;
		PillsUsed[client] = false;
	}
	else if(StrContains(item, "adrenaline", false) != -1)
	{
		if(pills_owner[client] != 0)
		{
			CreateTimer(1.0, GivePills, pills_owner[client]);
			pills_owner[client] = 0;
		}

		pack_slot4[client] = 2;
		PillsUsed[client] = false;
	}

	return Plugin_Continue;
}

public RequestFrameCallback(any:data)
{
	if(GetConVarInt(DropNotify) != 1)
		return;

	decl Float:cPos[3];

	for (new client = 1; client <= MaxClients; client++)
	{
		if (!IsSurvivor(client) || !IsPlayerAlive(client) || IsFakeClient(client))
			continue;

		GetClientEyePosition(client, cPos);

		if (pack_mols[client] > GetConVarInt(max_molotovs))
			PrintToChat(client, "\x04[BP] DROPPED MOLOTOV");

		if (pack_pipes[client] > GetConVarInt(max_pipebombs))
			PrintToChat(client, "\x04[BP] DROPPED PIPEBOMB");

		if (pack_biles[client] > GetConVarInt(max_vomitjars))
			PrintToChat(client, "\x04[BP] DROPPED VOMITJAR");

		if (pack_kits[client] > GetConVarInt(max_kits))
			PrintToChat(client, "\x04[BP] DROPPED MEDKIT");

		if (pack_defibs[client] > GetConVarInt(max_defibs))
			PrintToChat(client, "\x04[BP] DROPPED DEFIB");

		if (pack_firepacks[client] > GetConVarInt(max_incendiary))
			PrintToChat(client, "\x04[BP] DROPPED INCENDIARY PACK");

		if (pack_explodepacks[client] > GetConVarInt(max_explosive))
			PrintToChat(client, "\x04[BP] DROPPED EXPLOSIVE PACK");

		if (pack_pills[client] > GetConVarInt(max_pills))
			PrintToChat(client, "\x04[BP] DROPPED PAIN PILLS");

		if (pack_adrens[client] > GetConVarInt(max_adrenalines))
			PrintToChat(client, "\x04[BP] DROPPED ADRENALINE");
	}
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!client || !IsSurvivor(client) || !IsPlayerAlive(client))
		return Plugin_Continue;

	if (!g_InUse[client] && buttons & IN_USE == IN_USE)
	{
		g_InUse[client] = true;

		if(hTrace[client] != INVALID_HANDLE)
		{
			CloseHandle(hTrace[client]);
			hTrace[client] = INVALID_HANDLE;
		}

		float vecAngles[3];
		GetClientEyeAngles(client, vecAngles);

		float vecOrigin[3];
		GetClientEyePosition(client, vecOrigin);

		hTrace[client] = TR_TraceRayFilterEx(vecOrigin, vecAngles, MASK_ALL, RayType_Infinite, TraceRayDontHitPlayers);

		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "weapon_*")) != -1)
		{
			if (IsValidEntity(ent))
			{
				int ref = EntIndexToEntRef(ent);
	
				float endPos[3];
				TR_GetEndPosition(endPos, hTrace[client]);

				float entPos[3];
				GetEntPropVector(ref, Prop_Send, "m_vecOrigin", entPos);

//CHECK DISTANCE BETWEEN CLIENT & ENTITY THEN BETWEEN ENTITY & TRACERAY ENDPOINT
				if (GetVectorDistance(vecOrigin, entPos) <= 100 && GetVectorDistance(entPos, endPos) <= 15.0) //GetConVarInt(UseDistance)
				{
					int slotref = -1;
					char SlotItem[PLATFORM_MAX_PATH];
					int slot2 = GetPlayerWeaponSlot(client, 2);
					int slot3 = GetPlayerWeaponSlot(client, 3);
					int slot4 = GetPlayerWeaponSlot(client, 4);

					char ClassName[PLATFORM_MAX_PATH];
					GetEntityClassname(ref, ClassName, sizeof(ClassName));

					char ModelName[PLATFORM_MAX_PATH];
					GetEntPropString(ref, Prop_Data, "m_ModelName", ModelName, sizeof(ModelName));

/*
					if (IsValidAdmin(client))
					{
						PrintToChat(client, "\x04[DEBUG]\x01 ClassName = %s", ClassName);
						PrintToChat(client, "\x04[DEBUG]\x01 ModelName = %s", ModelName);
					}
*/

					if(StrContains(ModelName, "molotov", false) != -1 || StrContains(ClassName, "molotov", false) != -1)
					{
						if (GetConVarInt(max_molotovs) == 0)
							return Plugin_Continue;

						if(slot2 != -1)
						{
							BombUsed[client] = true;
							slotref = EntIndexToEntRef(slot2);
							GetEntityClassname(slotref, SlotItem, sizeof(SlotItem));

							if(StrContains(SlotItem, "molotov", false) != -1)
							{
								if (pack_mols[client] == GetConVarInt(max_molotovs))
								{
									if(GetConVarInt(FullNotify) == 1)
										PrintToChat(client, "\x04[BP] MOLOTOVS ARE FULL");
									return Plugin_Continue;
								}

								pack_mols[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "pipe_bomb", false) != -1)
							{
								pack_pipes[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "vomitjar", false) != -1)
							{
								pack_biles[client] += 1;
								RequestFrame(RequestFrameCallback);
							}

							RemovePlayerItem(client, slotref);
						}

						if(IsPlayerIncapped(client) && GetConVarInt(IncapPickup) == 1)
						{
							//if(slot2 != -1)
							//	RemovePlayerItem(client, slot2);

							AcceptEntityInput(ref, "kill");
							CheatCommand(client, "give", "weapon_molotov", "");
						}

						return Plugin_Continue;
					}
					else if(StrContains(ModelName, "pipebomb", false) != -1 || StrContains(ClassName, "pipe_bomb", false) != -1)
					{
						if (GetConVarInt(max_pipebombs) == 0)
							return Plugin_Continue;

						if(slot2 != -1)
						{
							BombUsed[client] = true;
							slotref = EntIndexToEntRef(slot2);
							GetEntityClassname(slotref, SlotItem, sizeof(SlotItem));

							if(StrContains(SlotItem, "pipe_bomb", false) != -1)
							{
								if (pack_pipes[client] == GetConVarInt(max_pipebombs))
								{
									if(GetConVarInt(FullNotify) == 1)
										PrintToChat(client, "\x04[BP] PIPEBOMBS ARE FULL");
									return Plugin_Continue;
								}

								pack_pipes[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "molotov", false) != -1)
							{
								pack_mols[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "vomitjar", false) != -1)
							{
								pack_biles[client] += 1;
								RequestFrame(RequestFrameCallback);
							}

							RemovePlayerItem(client, slotref);
						}

						if(IsPlayerIncapped(client) && GetConVarInt(IncapPickup) == 1)
						{
							//if(slot2 != -1)
							//	RemovePlayerItem(client, slot2);
							AcceptEntityInput(ref, "kill");
							CheatCommand(client, "give", "weapon_pipe_bomb", "");
						}

						return Plugin_Continue;
					}
					else if(StrContains(ModelName, "bile_flask", false) != -1 || StrContains(ClassName, "vomitjar", false) != -1)
					{
						if (GetConVarInt(max_vomitjars) == 0)
							return Plugin_Continue;

						if(slot2 != -1)
						{
							BombUsed[client] = true;
							slotref = EntIndexToEntRef(slot2);
							GetEntityClassname(slotref, SlotItem, sizeof(SlotItem));

							if(StrContains(SlotItem, "vomitjar", false) != -1)
							{
								if (pack_biles[client] == GetConVarInt(max_vomitjars))
								{
									if(GetConVarInt(FullNotify) == 1)
										PrintToChat(client, "\x04[BP] VOMITJARS ARE FULL");
									return Plugin_Continue;
								}

								pack_biles[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "molotov", false) != -1)
							{
								pack_mols[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "pipe_bomb", false) != -1)
							{
								pack_pipes[client] += 1;
								RequestFrame(RequestFrameCallback);
							}

							RemovePlayerItem(client, slotref);
						}

						if(IsPlayerIncapped(client) && GetConVarInt(IncapPickup) == 1)
						{
							//if(slot2 != -1)
							//	RemovePlayerItem(client, slot2);
							AcceptEntityInput(ref, "kill");
							CheatCommand(client, "give", "weapon_vomitjar", "");
						}

						return Plugin_Continue;
					}
					else if(StrContains(ModelName, "medkit", false) != -1 || StrContains(ClassName, "first_aid_kit", false) != -1)
					{
						if (GetConVarInt(max_kits) == 0)
							return Plugin_Continue;

						if(slot3 != -1)
						{
							KitUsed[client] = true;
							slotref = EntIndexToEntRef(slot3);
							GetEntityClassname(slotref, SlotItem, sizeof(SlotItem));

							if(StrContains(SlotItem, "first_aid_kit", false) != -1)
							{
								if (pack_kits[client] == GetConVarInt(max_kits))
								{
									if(GetConVarInt(FullNotify) == 1)
										PrintToChat(client, "\x04[BP] MEDKITS ARE FULL");
									return Plugin_Continue;
								}

								pack_kits[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "defibrillator", false) != -1)
							{
								pack_defibs[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "upgradepack_incendiary", false) != -1)
							{
								pack_firepacks[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "upgradepack_explosive", false) != -1)
							{
								pack_explodepacks[client] += 1;
								RequestFrame(RequestFrameCallback);
							}

							RemovePlayerItem(client, slotref);
						}

						if(IsPlayerIncapped(client) && GetConVarInt(IncapPickup) == 1)
						{
							//if(slot3 != -1)
							//	RemovePlayerItem(client, slot3);
							AcceptEntityInput(ref, "kill");
							CheatCommand(client, "give", "weapon_first_aid_kit", "");
						}

						return Plugin_Continue;
					}
					else if(StrContains(ModelName, "defibrillator", false) != -1 || StrContains(ClassName, "defibrillator", false) != -1)
					{
						if (GetConVarInt(max_defibs) == 0)
							return Plugin_Continue;

						if(slot3 != -1)
						{
							KitUsed[client] = true;
							slotref = EntIndexToEntRef(slot3);
							GetEntityClassname(slotref, SlotItem, sizeof(SlotItem));

							if(StrContains(SlotItem, "defibrillator", false) != -1)
							{
								if (pack_defibs[client] == GetConVarInt(max_defibs))
								{
									if(GetConVarInt(FullNotify) == 1)
										PrintToChat(client, "\x04[BP] DEFIBS ARE FULL");
									return Plugin_Continue;
								}

								pack_defibs[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "first_aid_kit", false) != -1)
							{
								pack_kits[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "upgradepack_incendiary", false) != -1)
							{
								pack_firepacks[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "upgradepack_explosive", false) != -1)
							{
								pack_explodepacks[client] += 1;
								RequestFrame(RequestFrameCallback);
							}

							RemovePlayerItem(client, slotref);
						}

						if(IsPlayerIncapped(client) && GetConVarInt(IncapPickup) == 1)
						{
							//if(slot3 != -1)
							//	RemovePlayerItem(client, slot3);
							AcceptEntityInput(ref, "kill");
							CheatCommand(client, "give", "weapon_defibrillator", "");
						}

						return Plugin_Continue;
					}
					else if(StrContains(ModelName, "incendiary", false) != -1 || StrContains(ClassName, "upgradepack_incendiary", false) != -1)
					{
						if (GetConVarInt(max_incendiary) == 0)
							return Plugin_Continue;

						if(slot3 != -1)
						{
							KitUsed[client] = true;
							slotref = EntIndexToEntRef(slot3);
							GetEntityClassname(slotref, SlotItem, sizeof(SlotItem));

							if(StrContains(SlotItem, "upgradepack_incendiary", false) != -1)
							{
								if (pack_firepacks[client] == GetConVarInt(max_incendiary))
								{
									if(GetConVarInt(FullNotify) == 1)
										PrintToChat(client, "\x04[BP] INCENDIARY PACKS ARE FULL");
									return Plugin_Continue;
								}

								pack_firepacks[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "first_aid_kit", false) != -1)
							{
								pack_kits[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "defibrillator", false) != -1)
							{
								pack_defibs[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "upgradepack_explosive", false) != -1)
							{
								pack_explodepacks[client] += 1;
								RequestFrame(RequestFrameCallback);
							}

							RemovePlayerItem(client, slotref);
						}

						if(IsPlayerIncapped(client) && GetConVarInt(IncapPickup) == 1)
						{
							//if(slot3 != -1)
							//	RemovePlayerItem(client, slot3);
							AcceptEntityInput(ref, "kill");
							CheatCommand(client, "give", "weapon_upgradepack_incendiary", "");
						}

						return Plugin_Continue;
					}
					else if(StrContains(ModelName, "explosive", false) != -1 || StrContains(ClassName, "upgradepack_explosive", false) != -1)
					{
						if (GetConVarInt(max_explosive) == 0)
							return Plugin_Continue;

						if(slot3 != -1)
						{
							KitUsed[client] = true;
							slotref = EntIndexToEntRef(slot3);
							GetEntityClassname(slotref, SlotItem, sizeof(SlotItem));

							if(StrContains(SlotItem, "upgradepack_explosive", false) != -1)
							{
								if (pack_explodepacks[client] == GetConVarInt(max_explosive))
								{
									if(GetConVarInt(FullNotify) == 1)
										PrintToChat(client, "\x04[BP] EXPLOSIVE PACKS ARE FULL");
									return Plugin_Continue;
								}

								pack_explodepacks[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "first_aid_kit", false) != -1)
							{
								pack_kits[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "defibrillator", false) != -1)
							{
								pack_defibs[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "upgradepack_incendiary", false) != -1)
							{
								pack_firepacks[client] += 1;
								RequestFrame(RequestFrameCallback);
							}

							RemovePlayerItem(client, slotref);
						}

						if(IsPlayerIncapped(client) && GetConVarInt(IncapPickup) == 1)
						{
							//if(slot3 != -1)
							//	RemovePlayerItem(client, slot3);
							AcceptEntityInput(ref, "kill");
							CheatCommand(client, "give", "weapon_upgradepack_explosive", "");
						}

						return Plugin_Continue;
					}
					else if(StrContains(ModelName, "painpills", false) != -1 || StrContains(ClassName, "pain_pills", false) != -1)
					{
						if (GetConVarInt(max_pills) == 0)
							return Plugin_Continue;

						if(slot4 != -1)
						{
							PillsUsed[client] = true;
							slotref = EntIndexToEntRef(slot4);
							GetEntityClassname(slotref, SlotItem, sizeof(SlotItem));

							if(StrContains(SlotItem, "pain_pills", false) != -1)
							{
								if (pack_pills[client] == GetConVarInt(max_pills))
								{
									if(GetConVarInt(FullNotify) == 1)
										PrintToChat(client, "\x04[BP] PAIN PILLS ARE FULL");
									return Plugin_Continue;
								}

								pack_pills[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "adrenaline", false) != -1)
							{
								pack_adrens[client] += 1;
								RequestFrame(RequestFrameCallback);
							}

							RemovePlayerItem(client, slotref);
						}

						if(IsPlayerIncapped(client) && GetConVarInt(IncapPickup) == 1)
						{
							//if(slot4 != -1)
							//	RemovePlayerItem(client, slot4);
							AcceptEntityInput(ref, "kill");
							CheatCommand(client, "give", "weapon_pain_pills", "");
						}

						return Plugin_Continue;
					}
					else if(StrContains(ModelName, "adrenaline", false) != -1 || StrContains(ClassName, "adrenaline", false) != -1)
					{
						if (GetConVarInt(max_adrenalines) == 0)
							return Plugin_Continue;

						if(slot4 != -1)
						{
							PillsUsed[client] = true;
							slotref = EntIndexToEntRef(slot4);
							GetEntityClassname(slotref, SlotItem, sizeof(SlotItem));

							if(StrContains(SlotItem, "adrenaline", false) != -1)
							{
								if (pack_adrens[client] == GetConVarInt(max_adrenalines))
								{
									if(GetConVarInt(FullNotify) == 1)
										PrintToChat(client, "\x04[BP] ADRENALINES ARE FULL");
									return Plugin_Continue;
								}

								pack_adrens[client] += 1;
								RequestFrame(RequestFrameCallback);
							}
							else if(StrContains(SlotItem, "pain_pills", false) != -1)
							{
								pack_pills[client] += 1;
								RequestFrame(RequestFrameCallback);
							}

							RemovePlayerItem(client, slotref);
						}

						if(IsPlayerIncapped(client) && GetConVarInt(IncapPickup) == 1)
						{
							//if(slot4 != -1)
							//	RemovePlayerItem(client, slot4);
							AcceptEntityInput(ref, "kill");
							CheatCommand(client, "give", "weapon_adrenaline", "");
						}

						return Plugin_Continue;
					}
				}
			}
		}
	}
	else if(g_InUse[client] && !(buttons & IN_USE))
		g_InUse[client] = false;

	return Plugin_Continue;
}

public Action:Event_WeaponDrop(Handle:event, const String:name[], bool:dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client)) return Plugin_Continue;

	int weapon = GetEventInt(event, "propid");

	char item[32];
	GetEventString(event, "item", item, sizeof(item));

	if(StrContains(item, "molotov", false) != -1)
	{
		if(nadetimer[client] != INVALID_HANDLE)
			TriggerTimer(nadetimer[client]);

		nadetimer[client] = CreateTimer(0.5, GiveGrenade, client);
	}

	else if(StrContains(item, "pipe_bomb", false) != -1)
	{
		if(nadetimer[client] != INVALID_HANDLE)
			TriggerTimer(nadetimer[client]);

		nadetimer[client] = CreateTimer(0.5, GiveGrenade, client);
	}

	else if(StrContains(item, "vomitjar", false) != -1)
	{
		if(nadetimer[client] != INVALID_HANDLE)
			TriggerTimer(nadetimer[client]);

		nadetimer[client] = CreateTimer(0.5, GiveGrenade, client);
	}

	else if(StrContains(item, "first_aid_kit", false) != -1)
	{
		AcceptEntityInput(weapon, "Kill");
		pack_kits[client] += 1;
		item_drop[client] = 4;
	}

	else if(StrContains(item, "defibrillator", false) != -1)
	{
		AcceptEntityInput(weapon, "Kill");
		pack_defibs[client] += 1;
		item_drop[client] = 5;
	}

	else if(StrContains(item, "upgradepack_incendiary", false) != -1)
	{
		AcceptEntityInput(weapon, "Kill");
		pack_firepacks[client] += 1;
		item_drop[client] = 6;
	}

	else if(StrContains(item, "upgradepack_explosive", false) != -1)
	{
		AcceptEntityInput(weapon, "Kill");
		pack_explodepacks[client] += 1;
		item_drop[client] = 7;
	}

	if(PillsUsed[client])
	{
		PillsUsed[client] = false;
		return Plugin_Continue;
	}

	else if(StrContains(item, "pain_pills", false) != -1)
	{
		//THIS FIXES PILL PASSING
		new target = GetClientAimTarget(client);

		if(target > -1)
		{
			pills_owner[target] = client;
			return Plugin_Continue;
		}

		AcceptEntityInput(weapon, "Kill");
		pack_pills[client] += 1;
		item_drop[client] = 8;
	}

	else if(StrContains(item, "adrenaline", false) != -1)
	{
		//THIS FIXES ADRENALINE PASSING
		new target = GetClientAimTarget(client);

		if(target > -1)
		{
			pills_owner[target] = client;
			return Plugin_Continue;
		}

		AcceptEntityInput(weapon, "Kill");
		pack_adrens[client] += 1;
		item_drop[client] = 9;
	}

	return Plugin_Continue;
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client)) return Plugin_Continue;

	float victim[3];
	victim[0] = GetEventFloat(event, "victim_x");
	victim[1] = GetEventFloat(event, "victim_y");
	victim[2] = GetEventFloat(event, "victim_z");

	if(GetClientTeam(client) == 2 && GetConVarInt(DeathDrop) == 1)
	{
		SpawnItem(victim, "weapon_molotov", pack_mols[client]);
		SpawnItem(victim, "weapon_pipe_bomb", pack_pipes[client]);
		SpawnItem(victim, "weapon_vomitjar", pack_biles[client]);
		SpawnItem(victim, "weapon_first_aid_kit", pack_kits[client]);
		SpawnItem(victim, "weapon_defibrillator", pack_defibs[client]);
		SpawnItem(victim, "weapon_upgradepack_incendiary", pack_firepacks[client]);
		SpawnItem(victim, "weapon_upgradepack_explosive", pack_explodepacks[client]);
		SpawnItem(victim, "weapon_pain_pills", pack_pills[client]);
		SpawnItem(victim, "weapon_adrenaline", pack_adrens[client]);
	}

	ResetBackpack(client, 0);

	if(GetConVarInt(ShowBackpack) != 1) return Plugin_Continue;

	int iEntity = BackpackIndex[client];
	if(!IsValidEntRef(iEntity)) return Plugin_Continue;

	AcceptEntityInput(iEntity, "kill");
	BackpackIndex[client] = -1;

	return Plugin_Continue;
}

public SpawnItem(const Float:origin[3], const String:item[], const amount)
{
	int entity = -1;

	for(int i = 1; i <= amount; i++)
	{
		entity = CreateEntityByName(item);

		if(entity == -1)
			break;

		if(!DispatchSpawn(entity))
			continue;

		//DispatchKeyValue(entity, "solid", "6");
		//DispatchKeyValue(entity, "rendermode", "3");
		DispatchKeyValue(entity, "disableshadows", "1");
		TeleportEntity(entity, origin, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(entity);
	}
}

public Action:Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if((GameMode == 1 || GameMode == 2))
	{
		for(new i = 1; i <= MAXPLAYERS; i++)
			SaveBackpack(i);
	}

	return Plugin_Continue;
}

public Action:Event_FinaleWin(Handle:event, const String:name[], bool:dontBroadcast)
{	
	if(GameMode == 1 || GameMode == 2)
	{
		ResetBackpack(0, 1);

		for(int i = 1; i <= MAXPLAYERS; i++)
			SaveBackpack(i);
	}

	return Plugin_Continue;
}

public Action:Event_MissionLost(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(GameMode == 1 || GameMode == 2)
	{
		for (int i = 1; i <= MAXPLAYERS; i++)
		{
			if (IsSurvivor(i))
				LoadBackpack(i);
		}
	}

	return Plugin_Continue;
}

public GrenadeRemove(any:client)
{
	decl String:grenade[128]; //Dropped grenade name

	new Float:position[3]; //Current entity position
	new Float:eyepos[3]; //Client eye position

	new Float:distance = 10000.0; //Stores vector distance of closest grenade
	new Float:dist; //Stores vector distance of current grenade

	new entity = -1; //Stores closest grenade entity/edict
	new slot2 = pack_slot2[client];

	GetClientAbsOrigin(client, eyepos);

	switch (slot2)
	{
		case 1:
			strcopy(grenade, sizeof(grenade), "weapon_molotov");

		case 2:
			strcopy(grenade, sizeof(grenade), "weapon_pipe_bomb");

		case 3:
			strcopy(grenade, sizeof(grenade), "weapon_vomitjar");

		default:
			return;
	}

	for(new i = 0; i <= GetEntityCount(); i++)
	{
		if(IsValidEntity(i))
		{
			decl String:EdictName[128];
			GetEdictClassname(i, EdictName, sizeof(EdictName));

			if(StrContains(EdictName, grenade) != -1)
			{
				GetEntPropVector(i, Prop_Send, "m_vecOrigin", position);

				dist = FloatAbs(GetVectorDistance(eyepos, position));

				if((dist < distance) && (dist != 50.0)) //The grenade found exactly 50 units away is the one you are holding
				{
					distance = dist;
					entity = i;
				}
			}
		}
	}

	if(distance == 10000.0 || entity <= 0) //Last grenade couldn't be found for some reason
		return;

	AcceptEntityInput(entity, "Kill");

	switch (slot2)
	{
		case 1:
			pack_mols[client] += 1;

		case 2:
			pack_pipes[client] += 1;

		case 3:
			pack_biles[client] += 1;
	}

	return;
}

public Action:Event_WeaponFire(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (!IsValidClient(client))
		return Plugin_Continue;

	decl String:item[10];
	GetEventString(event, "weapon", item, sizeof(item));

	switch(item[0])
	{
		case 'p':
		{
			if(StrEqual(item, "pipe_bomb"))
				BombUsed[client] = true;
		}
		case 'm':
		{
			if(StrEqual(item, "molotov"))
				BombUsed[client] = true;
		}
		case 'v':
		{
			if(StrEqual(item, "vomitjar"))
				BombUsed[client] = true;
		}
	}

	return Plugin_Continue;
}

public Action:GiveGrenade(Handle:timer, any:client)
{
	if(!IsValidClient(client))
		return Plugin_Continue;

	nadetimer[client] = INVALID_HANDLE;

	int slot2 = GetPlayerWeaponSlot(client, 2);

	if(slot2 <= -1)
	{
		switch (pack_slot2[client])
		{
			case 1:
			{
				if(pack_mols[client] > 0)
				{
					pack_slot2[client] = 1;
					pack_mols[client] -= 1;

					CheatCommand(client, "give", "weapon_molotov", "");
				}
				else
				{
					if(pack_pipes[client] > 0)
					{
						pack_slot2[client] = 2;
						pack_pipes[client] -= 1;

						if(pack_pipes[client] < 0)
							pack_pipes[client] = 0;

						CheatCommand(client, "give", "weapon_pipe_bomb", "");
					}
					else if(pack_biles[client] > 0)
					{
						pack_slot2[client] = 3;
						pack_biles[client] -= 1;

						if(pack_biles[client] < 0)
							pack_biles[client] = 0;

						CheatCommand(client, "give", "weapon_vomitjar", "");
					}
				}
			}
			case 2:
			{
				if(pack_pipes[client] > 0)
				{
					pack_slot2[client] = 2;
					pack_pipes[client] -= 1;

					CheatCommand(client, "give", "weapon_pipe_bomb", "");
				}
				else
				{
					if(pack_biles[client] > 0)
					{
						pack_slot2[client] = 3;
						pack_biles[client] -= 1;

						if(pack_biles[client] < 0)
							pack_biles[client] = 0;

						CheatCommand(client, "give", "weapon_vomitjar", "");
					}
					else if(pack_mols[client] > 0)
					{
						pack_slot2[client] = 1;
						pack_mols[client] -= 1;

						if(pack_mols[client] < 0)
							pack_mols[client] = 0;

						CheatCommand(client, "give", "weapon_molotov", "");
					}
				}
			}
			case 3:
			{
				if(pack_biles[client] > 0)
				{
					pack_slot2[client] = 3;
					pack_biles[client] -= 1;

					CheatCommand(client, "give", "weapon_vomitjar", "");
				}
				else
				{
					if(pack_mols[client] > 0)
					{
						pack_slot2[client] = 1;
						pack_mols[client] -= 1;

						if(pack_mols[client] < 0)
							pack_mols[client] = 0;

						CheatCommand(client, "give", "weapon_molotov", "");
					}
					else if(pack_pipes[client] > 0)
					{
						pack_slot2[client] = 2;
						pack_pipes[client] -= 1;

						if(pack_pipes[client] < 0)
							pack_pipes[client] = 0;

						CheatCommand(client, "give", "weapon_pipe_bomb", "");
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action:Event_KitUsed(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	KitUsed[client] = true;

	int slot3 = GetPlayerWeaponSlot(client, 3);

	if(slot3 <= -1)
	{
		switch (pack_slot3[client])
		{
			case 1:
			{
				if(item_drop[client] == 4)
					pack_kits[client] -= 1;

				if(pack_kits[client] > 0)
				{
					pack_slot3[client] = 1;
					pack_kits[client] -= 1;

					CheatCommand(client, "give", "weapon_first_aid_kit", "");
				}
				else
				{
					if(pack_defibs[client] > 0)
					{
						pack_slot3[client] = 2;
						pack_defibs[client] -= 1;

						if(pack_defibs[client] < 0)
							pack_defibs[client] = 0;

						CheatCommand(client, "give", "weapon_defibrillator", "");
					}
					else if(pack_firepacks[client] > 0)
					{
						pack_slot3[client] = 3;
						pack_firepacks[client] -= 1;

						if(pack_firepacks[client] < 0)
							pack_firepacks[client] = 0;

						CheatCommand(client, "give", "weapon_upgradepack_incendiary", "");
					}
					else if(pack_explodepacks[client] > 0)
					{
						pack_slot3[client] = 4;
						pack_explodepacks[client] -= 1;

						if(pack_explodepacks[client] < 0)
							pack_explodepacks[client] = 0;

						CheatCommand(client, "give", "weapon_upgradepack_explosive", "");
					}
				}
			}
			case 2:
			{
				if(item_drop[client] == 5)
					pack_defibs[client] -= 1;

				if(pack_defibs[client] > 0)
				{
					pack_slot3[client] = 2;
					pack_defibs[client] -= 1;

					CheatCommand(client, "give", "weapon_defibrillator", "");
				}
				else
				{
					if(pack_firepacks[client] > 0)
					{
						pack_slot3[client] = 3;
						pack_firepacks[client] -= 1;

						if(pack_firepacks[client] < 0)
							pack_firepacks[client] = 0;

						CheatCommand(client, "give", "weapon_upgradepack_incendiary", "");
					}
					else if(pack_explodepacks[client] > 0)
					{
						pack_slot3[client] = 4;
						pack_explodepacks[client] -= 1;

						if(pack_explodepacks[client] < 0)
							pack_explodepacks[client] = 0;

						CheatCommand(client, "give", "weapon_upgradepack_explosive", "");
					}
					else if(pack_kits[client] > 0)
					{
						pack_slot3[client] = 1;
						pack_kits[client] -= 1;

						if(pack_kits[client] < 0)
							pack_kits[client] = 0;

						CheatCommand(client, "give", "weapon_first_aid_kit", "");
					}
				}
			}
			case 3:
			{
				if(item_drop[client] == 6)
					pack_firepacks[client] -= 1;

				if(pack_firepacks[client] > 0)
				{
					pack_slot3[client] = 3;
					pack_firepacks[client] -= 1;

					CheatCommand(client, "give", "weapon_upgradepack_incendiary", "");
				}
				else
				{
					if(pack_explodepacks[client] > 0)
					{
						pack_slot3[client] = 4;
						pack_explodepacks[client] -= 1;

						if(pack_explodepacks[client] < 0)
							pack_explodepacks[client] = 0;

						CheatCommand(client, "give", "weapon_upgradepack_explosive", "");
					}
					else if(pack_kits[client] > 0)
					{
						pack_slot3[client] = 1;
						pack_kits[client] -= 1;

						if(pack_kits[client] < 0)
							pack_kits[client] = 0;

						CheatCommand(client, "give", "weapon_first_aid_kit", "");
					}
					else if(pack_defibs[client] > 0)
					{
						pack_slot3[client] = 2;
						pack_defibs[client] -= 1;

						if(pack_defibs[client] < 0)
							pack_defibs[client] = 0;

						CheatCommand(client, "give", "weapon_defibrillator", "");
					}
				}
			}
			case 4:
			{
				if(item_drop[client] == 7)
					pack_explodepacks[client] -= 1;

				if(pack_explodepacks[client] > 0)
				{
					pack_slot3[client] = 4;
					pack_explodepacks[client] -= 1;

					CheatCommand(client, "give", "weapon_upgradepack_explosive", "");
				}
				else
				{
					if(pack_kits[client] > 0)
					{
						pack_slot3[client] = 1;
						pack_kits[client] -= 1;

						if(pack_kits[client] < 0)
							pack_kits[client] = 0;

						CheatCommand(client, "give", "weapon_first_aid_kit", "");
					}
					else if(pack_defibs[client] > 0)
					{
						pack_slot3[client] = 2;
						pack_defibs[client] -= 1;

						if(pack_defibs[client] < 0)
							pack_defibs[client] = 0;

						CheatCommand(client, "give", "weapon_defibrillator", "");
					}
					else if(pack_firepacks[client] > 0)
					{
						pack_slot3[client] = 3;
						pack_firepacks[client] -= 1;

						if(pack_firepacks[client] < 0)
							pack_firepacks[client] = 0;

						CheatCommand(client, "give", "weapon_upgradepack_incendiary", "");
					}
				}
			}
		}
		item_drop[client] = 0;
	}

	return Plugin_Continue;
}

public Action:Event_PillsUsed(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	PillsUsed[client] = true;
	CreateTimer(1.0, GivePills, client);

	return Plugin_Continue;
}

public Action:GivePills(Handle:timer, any:client)
{
	if(!IsValidClient(client))
		return Plugin_Continue;

	int slot4 = GetPlayerWeaponSlot(client, 4);

	if(slot4 <= -1)
	{
		switch (pack_slot4[client])
		{
			case 1:
			{
				if(item_drop[client] == 8)
					pack_pills[client] -= 1;

				if(pack_pills[client] > 0)
				{
					pack_slot4[client] = 1;
					pack_pills[client] -= 1;

					CheatCommand(client, "give", "weapon_pain_pills", "");
				}
				else
				{
					if(pack_adrens[client] > 0)
					{
						pack_slot4[client] = 2;
						pack_adrens[client] -= 1;

						if(pack_adrens[client] < 0)
							pack_adrens[client] = 0;

						CheatCommand(client, "give", "weapon_adrenaline", "");
					}
				}
			}
			case 2:
			{
				if(item_drop[client] == 9)
					pack_adrens[client] -= 1;

				if(pack_adrens[client] > 0)
				{
					pack_slot4[client] = 2;
					pack_adrens[client] -= 1;

					CheatCommand(client, "give", "weapon_adrenaline", "");
				}
				else
				{
					if(pack_pills[client] > 0)
					{
						pack_slot4[client] = 1;
						pack_pills[client] -= 1;

						if(pack_pills[client] < 0)
							pack_pills[client] = 0;

						CheatCommand(client, "give", "weapon_pain_pills", "");
					}
				}
			}
		}
		item_drop[client] = 0;
	}

	return Plugin_Continue;
}

public Action:Event_PlayerToBot(Handle:event, const String:name[], bool:dontBroadcast)
{
	new bot = GetClientOfUserId(GetEventInt(event, "bot"));
	new player = GetClientOfUserId(GetEventInt(event, "player"));

	/* Changeover */
	pack_mols[bot] += pack_mols[player];
	pack_pipes[bot] += pack_pipes[player];
	pack_biles[bot] += pack_biles[player];
	pack_kits[bot] += pack_kits[player];
	pack_defibs[bot] += pack_defibs[player];
	pack_firepacks[bot] += pack_firepacks[player];
	pack_explodepacks[bot] += pack_explodepacks[player];
	pack_pills[bot] += pack_pills[player];
	pack_adrens[bot] += pack_adrens[player];
	pack_slot2[bot] = pack_slot2[player];
	pack_slot3[bot] = 1;
	pack_slot4[bot] = pack_slot4[player];
	item_drop[bot] = 0;
	pills_owner[bot] = pills_owner[player];
	BombUsed[bot] = false;
	KitUsed[bot] = false;
	PillsUsed[bot] = false;

	/* Remove Old */
	ResetBackpack(player, 0);

	if(GameMode == 1 || GameMode == 2)
	{
		pack_store[bot][0] += pack_store[player][0];
		pack_store[bot][1] += pack_store[player][1];
		pack_store[bot][2] += pack_store[player][2];
		pack_store[bot][3] += pack_store[player][3];
		pack_store[bot][4] += pack_store[player][4];
		pack_store[bot][5] += pack_store[player][5];
		pack_store[bot][6] += pack_store[player][6];
		pack_store[bot][7] += pack_store[player][7];
		pack_store[bot][8] += pack_store[player][8];

		pack_store[player][0] = 0;
		pack_store[player][1] = 0;
		pack_store[player][2] = 0;
		pack_store[player][3] = 0;
		pack_store[player][4] = 0;
		pack_store[player][5] = 0;
		pack_store[player][6] = 0;
		pack_store[player][7] = 0;
		pack_store[player][8] = 0;
	}

	return Plugin_Continue;
}

public Action:Event_BotToPlayer(Handle:event, const String:name[], bool:dontBroadcast)
{
	new bot = GetClientOfUserId(GetEventInt(event, "bot"));
	new player = GetClientOfUserId(GetEventInt(event, "player"));

	/* Changeover */
	pack_mols[player] += pack_mols[bot];
	pack_pipes[player] += pack_pipes[bot];
	pack_biles[player] += pack_biles[bot];
	pack_kits[player] += pack_kits[bot];
	pack_defibs[player] += pack_defibs[bot];
	pack_firepacks[player] += pack_firepacks[bot];
	pack_explodepacks[player] += pack_explodepacks[bot];
	pack_pills[player] += pack_pills[bot];
	pack_adrens[player] += pack_adrens[bot];
	pack_slot2[player] = pack_slot2[bot];
	pack_slot3[player] = pack_slot3[bot];
	pack_slot4[player] = pack_slot4[bot];
	item_drop[player] = 0;
	pills_owner[player] = 0;
	BombUsed[player] = false;
	KitUsed[player] = false;
	PillsUsed[player] = false;
	
	/* Remove Old */
	ResetBackpack(bot, 0);
	
	if(GameMode == 1 || GameMode == 2)
	{
		pack_store[player][0] += pack_store[bot][0];
		pack_store[player][1] += pack_store[bot][1];
		pack_store[player][2] += pack_store[bot][2];
		pack_store[player][3] += pack_store[bot][3];
		pack_store[player][4] += pack_store[bot][4];
		pack_store[player][5] += pack_store[bot][5];
		pack_store[player][6] += pack_store[bot][6];
		pack_store[player][7] += pack_store[bot][7];
		pack_store[player][8] += pack_store[bot][8];

		pack_store[bot][0] = 0;
		pack_store[bot][1] = 0;
		pack_store[bot][2] = 0;
		pack_store[bot][3] = 0;
		pack_store[bot][4] = 0;
		pack_store[bot][5] = 0;
		pack_store[bot][6] = 0;
		pack_store[bot][7] = 0;
		pack_store[bot][8] = 0;
	}

	return Plugin_Continue;
}

ResetBackpack(client = 0, reset = 1)
{
	/*
	* Client Values
	* Client number for player you want to reset
	* 0 means reset all
	* 
	* Reset Values
	* 0 means empty the pack back to 0
	* 1 means set the pack to starting amounts
	*/

	new mols;
	new pipes;
	new biles;
	new kits;
	new defibs;
	new firepacks;
	new explodepacks;
	new pills;
	new adrens;

	if(reset == 1)
	{
		mols = GetConVarInt(FindConVar("l4d_backpack_start_mols"));
		pipes = GetConVarInt(FindConVar("l4d_backpack_start_pipes"));
		biles = GetConVarInt(FindConVar("l4d_backpack_start_biles"));
		kits = GetConVarInt(FindConVar("l4d_backpack_start_kits"));
		defibs = GetConVarInt(FindConVar("l4d_backpack_start_defibs"));
		firepacks = GetConVarInt(FindConVar("l4d_backpack_start_firepacks"));
		explodepacks = GetConVarInt(FindConVar("l4d_backpack_start_explodepacks"));
		pills = GetConVarInt(FindConVar("l4d_backpack_start_pills"));
		adrens = GetConVarInt(FindConVar("l4d_backpack_start_adrens"));
	}

	if(client != 0)
	{
		pack_mols[client] = mols;
		pack_pipes[client] = pipes;
		pack_biles[client] = biles;
		pack_kits[client] = kits;
		pack_defibs[client] = defibs;
		pack_firepacks[client] = firepacks;
		pack_explodepacks[client] = explodepacks;
		pack_pills[client] = pills;
		pack_adrens[client] = adrens;
		pack_slot2[client] = 0;
		pack_slot3[client] = 0;
		pack_slot4[client] = 0;
		item_drop[client] = 0;
		pills_owner[client] = 0;
		BombUsed[client] = false;
		KitUsed[client] = false;
		PillsUsed[client] = false;
		nadetimer[client] = INVALID_HANDLE;

		return;
	}
	
	for(new i = 0; i <= MAXPLAYERS; i++)
	{
		pack_mols[i] = mols;
		pack_pipes[i] = pipes;
		pack_biles[i] = biles;
		pack_kits[i] = kits;
		pack_defibs[i] = defibs;
		pack_firepacks[i] = firepacks;
		pack_explodepacks[i] = explodepacks;
		pack_pills[i] = pills;
		pack_adrens[i] = adrens;
		pack_slot2[i] = 0;
		pack_slot3[i] = 0;
		pack_slot4[i] = 0;
		item_drop[i] = 0;
		pills_owner[i] = 0;
		BombUsed[i] = false;
		KitUsed[i] = false;
		PillsUsed[i] = false;
		nadetimer[i] = INVALID_HANDLE;
	}

	return;
}

//-----[FUNCTIONS]-----//
StartBackpack(client)
{
	pack_mols[client] = GetConVarInt(start_molotovs);
	pack_pipes[client] = GetConVarInt(start_pipebombs);
	pack_biles[client] = GetConVarInt(start_vomitjars);
	pack_kits[client] = GetConVarInt(start_kits);
	pack_defibs[client] = GetConVarInt(start_defibs);
	pack_firepacks[client] = GetConVarInt(start_incendiary);
	pack_explodepacks[client] = GetConVarInt(start_explosive);
	pack_pills[client] = GetConVarInt(start_pills);
	pack_adrens[client] = GetConVarInt(start_adrenalines);
}

SaveBackpack(client)
{
	pack_store[client][0] = pack_mols[client];
	pack_store[client][1] = pack_pipes[client];
	pack_store[client][2] = pack_biles[client];
	pack_store[client][3] = pack_kits[client];
	pack_store[client][4] = pack_defibs[client];
	pack_store[client][5] = pack_firepacks[client];
	pack_store[client][6] = pack_explodepacks[client];
	pack_store[client][7] = pack_pills[client];
	pack_store[client][8] = pack_adrens[client];
}

LoadBackpack(client)
{
	pack_mols[client] = pack_store[client][0];
	pack_pipes[client] = pack_store[client][1];
	pack_biles[client] = pack_store[client][2];
	pack_kits[client] = pack_store[client][3];
	pack_defibs[client] = pack_store[client][4];
	pack_firepacks[client] = pack_store[client][5];
	pack_explodepacks[client] = pack_store[client][6];
	pack_pills[client] = pack_store[client][7];
	pack_adrens[client] = pack_store[client][8];
}

/*
ResetBackpack(client)
{
	pack_mols[client] = 0;
	pack_pipes[client] = 0;
	pack_biles[client] = 0;
	pack_kits[client] = 0;
	pack_defibs[client] = 0;
	pack_firepacks[client] = 0;
	pack_explodepacks[client] = 0;
	pack_pills[client] = 0;
	pack_adrens[client] = 0;

	pack_slot2[client] = 0;
	pack_slot3[client] = 0;
	pack_slot4[client] = 0;

	item_drop[client] = 0;
	pills_owner[client] = 0;

	BombUsed[client] = false;
	KitUsed[client] = false;
	PillsUsed[client] = false;

	nadetimer[client] = INVALID_HANDLE;
}
*/

//-----[MENU]-----//
public Action:PackMenu(client, arg)
{
	new iSlot;
	new entity;

	decl String:sSlot[128];
	decl String:EdictName[128];

	if(IsClientInGame(client) && !IsFakeClient(client))
	{
		if(GetClientTeam(client) == 2)
		{
			if(IsPlayerAlive(client))
			{
				GetCmdArg(1, sSlot, sizeof(sSlot));
				iSlot = StringToInt(sSlot);

				switch(iSlot)
				{
					case 1, 2, 3:
					{
						entity = GetPlayerWeaponSlot(client, 2);

						if(entity > -1)
						{
							GetEdictClassname(entity, EdictName, sizeof(EdictName));

							if(StrContains(EdictName, "molotov", false) != -1)
							{
								RemovePlayerItem(client, entity);
								pack_mols[client] += 1;
							}

							if(StrContains(EdictName, "pipe_bomb", false) != -1)
							{
								RemovePlayerItem(client, entity);
								pack_pipes[client] += 1;
							}

							if(StrContains(EdictName, "vomitjar", false) != -1)
							{
								RemovePlayerItem(client, entity);
								pack_biles[client] += 1;
							}
						}

						pack_slot2[client] = iSlot;

						switch (iSlot)
						{
							case 1:
							{
								if(pack_mols[client] > 0)
								{
									CheatCommand(client, "give", "weapon_molotov", "");
									pack_mols[client] -= 1;
								}
								else
									pack_slot2[client] = 0;
							}
							case 2:
							{
								if(pack_pipes[client] > 0)
								{
									CheatCommand(client, "give", "weapon_pipe_bomb", "");
									pack_pipes[client] -= 1;
								}
								else
									pack_slot2[client] = 0;
							}
							case 3:
							{
								if(pack_biles[client] > 0)
								{
									CheatCommand(client, "give", "weapon_vomitjar", "");
									pack_biles[client] -= 1;
								}
								else
									pack_slot2[client] = 0;
							}
						}
					}

					case 4, 5, 6, 7:
					{
						entity = GetPlayerWeaponSlot(client, 3);

						if(entity > -1)
						{
							GetEdictClassname(entity, EdictName, sizeof(EdictName));

							if(StrContains(EdictName, "first_aid_kit", false) != -1)
							{
								RemovePlayerItem(client, entity);
								pack_kits[client] += 1;
							}

							if(StrContains(EdictName, "defibrillator", false) != -1)
							{
								RemovePlayerItem(client, entity);
								pack_defibs[client] += 1;
							}

							if(StrContains(EdictName, "upgradepack_incendiary", false) != -1)
							{
								RemovePlayerItem(client, entity);
								pack_firepacks[client] += 1;
							}

							if(StrContains(EdictName, "upgradepack_explosive", false) != -1)
							{
								RemovePlayerItem(client, entity);
								pack_explodepacks[client] += 1;
							}
						}

						pack_slot2[client] = iSlot - 3;

						switch (iSlot - 3)
						{
							case 1:
							{
								if(pack_kits[client] > 0)
								{
									CheatCommand(client, "give", "weapon_first_aid_kit", "");
									pack_kits[client] -= 1;
								}
								else
									pack_slot3[client] = 0;
							}
							case 2:
							{
								if(pack_defibs[client] > 0)
								{
									CheatCommand(client, "give", "weapon_defibrillator", "");
									pack_defibs[client] -= 1;
								}
								else
									pack_slot3[client] = 0;
							}
							case 3:
							{
								if(pack_firepacks[client] > 0)
								{
									CheatCommand(client, "give", "weapon_upgradepack_incendiary", "");
									pack_firepacks[client] -= 1;
								}
								else
									pack_slot3[client] = 0;
							}
							case 4:
							{
								if(pack_explodepacks[client] > 0)
								{
									CheatCommand(client, "give", "weapon_upgradepack_explosive", "");
									pack_explodepacks[client] -= 1;
								}
								else
									pack_slot3[client] = 0;
							}
						}
					}

					case 8, 9:
					{
						entity = GetPlayerWeaponSlot(client, 4);

						if(entity > -1)
						{
							GetEdictClassname(entity, EdictName, sizeof(EdictName));

							if(StrContains(EdictName, "pain_pills", false) != -1)
							{
								RemovePlayerItem(client, entity);
								pack_pills[client] += 1;
							}

							if(StrContains(EdictName, "adrenaline", false) != -1)
							{
								RemovePlayerItem(client, entity);
								pack_adrens[client] += 1;
							}
						}

						pack_slot4[client] = iSlot - 7;

						switch (iSlot - 7)
						{
							case 1:
							{
								if(pack_pills[client] > 0)
								{
									CheatCommand(client, "give", "weapon_pain_pills", "");
									pack_pills[client] -= 1;
								}
								else
									pack_slot4[client] = 0;
							}
							case 2:
							{
								if(pack_adrens[client] > 0)
								{
									CheatCommand(client, "give", "weapon_adrenaline", "");
									pack_adrens[client] -= 1;
								}
								else
									pack_slot4[client] = 0;
							}
						}
					}
					default:
						showpackHUD(client);
				}
			}
			else
				PrintToChat(client, "You cannot access your Backpack while dead.");
		}
		else
			PrintToChat(client, "Only survivors can access the backpack.");
	}

	return Plugin_Handled;
}

public showpackHUD(client)
{
	decl String:line[100];
	new Handle:panel = CreatePanel();

	SetPanelTitle(panel, "-----> BACKPACK <-----");
	//DrawPanelText(panel, "---------------------");

	Format(line, sizeof(line), "Molotovs: %d", pack_mols[client]);
	if(pack_slot2[client] == 1) StrCat(line, sizeof(line), " <--");
	DrawPanelItem(panel, line);

	Format(line, sizeof(line), "Pipe Bombs: %d", pack_pipes[client]);
	if(pack_slot2[client] == 2) StrCat(line, sizeof(line), " <--");
	DrawPanelItem(panel, line);

	Format(line, sizeof(line), "Bile Bombs: %d", pack_biles[client]);
	if(pack_slot2[client] == 3) StrCat(line, sizeof(line), " <--");
	DrawPanelItem(panel, line);

	Format(line, sizeof(line), "Medkits: %d", pack_kits[client]);
	if(pack_slot3[client] == 1) StrCat(line, sizeof(line), " <--");
	DrawPanelItem(panel, line);

	Format(line, sizeof(line), "Defibs: %d", pack_defibs[client]);
	if(pack_slot3[client] == 2) StrCat(line, sizeof(line), " <--");
	DrawPanelItem(panel, line);

	Format(line, sizeof(line), "Incendiary Packs: %d", pack_firepacks[client]);
	if(pack_slot3[client] == 3) StrCat(line, sizeof(line), " <--");
	DrawPanelItem(panel, line);

	Format(line, sizeof(line), "Explosive Packs: %d", pack_explodepacks[client]);
	if(pack_slot3[client] == 4) StrCat(line, sizeof(line), " <--");
	DrawPanelItem(panel, line);

	Format(line, sizeof(line), "Pills: %d", pack_pills[client]);
	if(pack_slot4[client] == 1) StrCat(line, sizeof(line), " <--");
	DrawPanelItem(panel, line);

	Format(line, sizeof(line), "Adrenaline: %d", pack_adrens[client]);
	if(pack_slot4[client] == 2) StrCat(line, sizeof(line), " <--");
	DrawPanelItem(panel, line);

	DrawPanelItem(panel, "Exit");

	SendPanelToClient(panel, client, Panel_Backpack, 60);
	CloseHandle(panel);

	return;
}

public Panel_Backpack(Handle:menu, MenuAction:action, param1, param2)
{
	if (!(action == MenuAction_Select))
		return;

	new entity;
	decl String:EdictName[128];

	switch (param2)
	{
		case 1, 2, 3:
		{
			entity = GetPlayerWeaponSlot(param1, 2);

			if(entity > -1)
			{
				GetEdictClassname(entity, EdictName, sizeof(EdictName));

				if(StrContains(EdictName, "molotov", false) != -1)
				{
					RemovePlayerItem(param1, entity);
					pack_mols[param1] += 1;
				}

				if(StrContains(EdictName, "pipe_bomb", false) != -1)
				{
					RemovePlayerItem(param1, entity);
					pack_pipes[param1] += 1;
				}

				if(StrContains(EdictName, "vomitjar", false) != -1)
				{
					RemovePlayerItem(param1, entity);
					pack_biles[param1] += 1;
				}
			}

			pack_slot2[param1] = param2;

			switch (param2)
			{
				case 1:
				{
					if(pack_mols[param1] > 0)
					{
						CheatCommand(param1, "give", "weapon_molotov", "");
						pack_mols[param1] -= 1;
					}
					else
						pack_slot2[param1] = 0;
				}
				case 2:
				{
					if(pack_pipes[param1] > 0)
					{
						CheatCommand(param1, "give", "weapon_pipe_bomb", "");
						pack_pipes[param1] -= 1;
					}
					else
						pack_slot2[param1] = 0;
				}
				case 3:
				{
					if(pack_biles[param1] > 0)
					{
						CheatCommand(param1, "give", "weapon_vomitjar", "");
						pack_biles[param1] -= 1;
					}
					else
						pack_slot2[param1] = 0;
				}
			}
		}
		case 4, 5, 6, 7:
		{
			entity = GetPlayerWeaponSlot(param1, 3);

			if(entity > -1)
			{
				GetEdictClassname(entity, EdictName, sizeof(EdictName));

				if(StrContains(EdictName, "first_aid_kit", false) != -1)
				{
					RemovePlayerItem(param1, entity);
					pack_kits[param1] += 1;
				}

				if(StrContains(EdictName, "defibrillator", false) != -1)
				{
					RemovePlayerItem(param1, entity);
					pack_defibs[param1] += 1;
				}

				if(StrContains(EdictName, "upgradepack_incendiary", false) != -1)
				{
					RemovePlayerItem(param1, entity);
					pack_firepacks[param1] += 1;
				}

				if(StrContains(EdictName, "upgradepack_explosive", false) != -1)
				{
					RemovePlayerItem(param1, entity);
					pack_explodepacks[param1] += 1;
				}
			}

			pack_slot2[param1] = param2 - 3;

			switch (param2 - 3)
			{
				case 1:
				{
					if(pack_kits[param1] > 0)
					{
						CheatCommand(param1, "give", "weapon_first_aid_kit", "");
						pack_kits[param1] -= 1;
					}
					else
						pack_slot3[param1] = 0;
				}
				case 2:
				{
					if(pack_defibs[param1] > 0)
					{
						CheatCommand(param1, "give", "weapon_defibrillator", "");
						pack_defibs[param1] -= 1;
					}
					else
						pack_slot3[param1] = 0;
				}
				case 3:
				{
					if(pack_firepacks[param1] > 0)
					{
						CheatCommand(param1, "give", "weapon_upgradepack_incendiary", "");
						pack_firepacks[param1] -= 1;
					}
					else
						pack_slot3[param1] = 0;
				}
				case 4:
				{
					if(pack_explodepacks[param1] > 0)
					{
						CheatCommand(param1, "give", "weapon_upgradepack_explosive", "");
						pack_explodepacks[param1] -= 1;
					}
					else
						pack_slot3[param1] = 0;
				}
			}
		}
		case 8, 9:
		{
			entity = GetPlayerWeaponSlot(param1, 4);

			if(entity > -1)
			{
				GetEdictClassname(entity, EdictName, sizeof(EdictName));

				if(StrContains(EdictName, "pain_pills", false) != -1)
				{
					RemovePlayerItem(param1, entity);
					pack_pills[param1] += 1;
				}

				if(StrContains(EdictName, "adrenaline", false) != -1)
				{
					RemovePlayerItem(param1, entity);
					pack_adrens[param1] += 1;
				}
			}

			pack_slot4[param1] = param2 - 7;

			switch (param2 - 7)
			{
				case 1:
				{
					if(pack_pills[param1] > 0)
					{
						CheatCommand(param1, "give", "weapon_pain_pills", "");
						pack_pills[param1] -= 1;
					}
					else
						pack_slot4[param1] = 0;
				}
				case 2:
				{
					if(pack_adrens[param1] > 0)
					{
						CheatCommand(param1, "give", "weapon_adrenaline", "");
						pack_adrens[param1] -= 1;
					}
					else
						pack_slot4[param1] = 0;
				}
			}
		}
	}

	return;
}

public Action:AdminViewMenu(client, args)
{
	decl String:line[100];
	new Handle:panel = CreatePanel();

	SetPanelTitle(panel, "-----> ADMIN BACKPACK VIEW <-----");
	//DrawPanelText(panel, "---------------------");
	
	Format(line, sizeof(line), "Players: %3d %3d %3d %3d %3d %3d %3d %3d", 1, 2, 3, 4, 5, 6, 7, 8);
	DrawPanelText(panel, line);
	Format(line, sizeof(line), "Molotovs: %3d %3d %3d %3d %3d %3d %3d %3d", pack_mols[1], pack_mols[2], pack_mols[3], pack_mols[4], pack_mols[5], pack_mols[6], pack_mols[7], pack_mols[8]);
	DrawPanelItem(panel, line);
	Format(line, sizeof(line), "Pipe Bombs: %3d %3d %3d %3d %3d %3d %3d %3d", pack_pipes[1], pack_pipes[2], pack_pipes[3], pack_pipes[4], pack_pipes[5], pack_pipes[6], pack_pipes[7], pack_pipes[8]);
	DrawPanelItem(panel, line);
	Format(line, sizeof(line), "Bile Bombs: %3d %3d %3d %3d %3d %3d %3d %3d", pack_biles[1], pack_biles[2], pack_biles[3], pack_biles[4], pack_biles[5], pack_biles[6], pack_biles[7], pack_biles[8]);
	DrawPanelItem(panel, line);
	Format(line, sizeof(line), "Medkits: %3d %3d %3d %3d %3d %3d %3d %3d", pack_kits[1], pack_kits[2], pack_kits[3], pack_kits[4], pack_kits[5], pack_kits[6], pack_kits[7], pack_kits[8]);
	DrawPanelItem(panel, line);
	Format(line, sizeof(line), "Defibs: %3d %3d %3d %3d %3d %3d %3d %3d", pack_defibs[1], pack_defibs[2], pack_defibs[3], pack_defibs[4], pack_defibs[5], pack_defibs[6], pack_defibs[7], pack_defibs[8]);
	DrawPanelItem(panel, line);
	Format(line, sizeof(line), "Incediary Packs: %3d %3d %3d %3d %3d %3d %3d %3d", pack_firepacks[1], pack_firepacks[2], pack_firepacks[3], pack_firepacks[4], pack_firepacks[5], pack_firepacks[6], pack_firepacks[7], pack_firepacks[8]);
	DrawPanelItem(panel, line);
	Format(line, sizeof(line), "Explosive Packs: %3d %3d %3d %3d %3d %3d %3d %3d", pack_explodepacks[1], pack_explodepacks[2], pack_explodepacks[3], pack_explodepacks[4], pack_explodepacks[5], pack_explodepacks[6], pack_explodepacks[7], pack_explodepacks[8]);
	DrawPanelItem(panel, line);
	Format(line, sizeof(line), "Pills: %3d %3d %3d %3d %3d %3d %3d %3d", pack_pills[1], pack_pills[2], pack_pills[3], pack_pills[4], pack_pills[5], pack_pills[6], pack_pills[7], pack_pills[8]);
	DrawPanelItem(panel, line);
	Format(line, sizeof(line), "Adrenaline: %3d %3d %3d %3d %3d %3d %3d %3d", pack_adrens[1], pack_adrens[2], pack_adrens[3], pack_adrens[4], pack_adrens[5], pack_adrens[6], pack_adrens[7], pack_adrens[8]);
	DrawPanelItem(panel, line);

	DrawPanelItem(panel, "Exit");

	SendPanelToClient(panel, client, Panel_Nothing, 60);
	CloseHandle(panel);

	return Plugin_Handled;
}

public Panel_Nothing(Handle:menu, MenuAction:action, param1, param2)
{
	return;
}

/*BACKPACK MODEL CODE*/
public TeamChange(Handle:hEvent, const String:sEventName[], bool:bDontBroadcast)
{
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if(iClient < 1 || iClient > MaxClients || !IsClientInGame(iClient) || GetConVarInt(ShowBackpack) != 1)
		return;

	new iEntity = BackpackIndex[iClient];
	
	if(!IsValidEntRef(iEntity))
		return;
	
	AcceptEntityInput(iEntity, "kill");
	BackpackIndex[iClient] = -1;
}

public OnMapStart()
{
	PrecacheModel("models/props_collectables/backpack.mdl");
}

SetVector(Float:target[3], Float:x, Float:y, Float:z)
{
	target[0] = x, target[1] = y, target[2] = z;
}

CreateBackpack(iClient)
{
	if(!IsSurvivor(iClient) || !IsPlayerAlive(iClient) || GetConVarInt(ShowBackpack) != 1)
		return;

	int iEntity = BackpackIndex[iClient];
	if(IsValidEntRef(iEntity))
		AcceptEntityInput(iEntity, "kill");

	iEntity = CreateEntityByName("prop_dynamic_ornament");
	if(iEntity < 0) return;

	DispatchKeyValue(iEntity, "model", "models/props_collectables/backpack.mdl");

	SetEntityRenderMode(iEntity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iEntity, 25, 0, 0, 255);

/*
	int Random = GetRandomInt(0, 255);

	char sModel[64];
	GetEntPropString(iClient, Prop_Data, "m_ModelName", sModel, sizeof(sModel));

	switch(sModel[29])
	{
		case 'b'://nick
			SetEntityRenderColor(iEntity, Random, Random, Random, 255);
		case 'd'://rochelle
			SetEntityRenderColor(iEntity, Random, Random, Random, 255);
		case 'c'://coach
			SetEntityRenderColor(iEntity, Random, Random, Random, 255);
		case 'h'://ellis
			SetEntityRenderColor(iEntity, Random, Random, Random, 255);
		case 'v'://bill
			SetEntityRenderColor(iEntity, Random, Random, Random, 255);
		case 'n'://zoey
			SetEntityRenderColor(iEntity, Random, Random, Random, 255);
		case 'e'://francis
			SetEntityRenderColor(iEntity, Random, Random, Random, 255);
		case 'a'://louis
			SetEntityRenderColor(iEntity, Random, Random, Random, 255);
		case 'w'://adawong
			SetEntityRenderColor(iEntity, Random, Random, Random, 255);
	}
*/
	//SetEntityRenderColor(iEntity, 255, 0, 0, 255); //RED
	//SetEntityRenderColor(iEntity, 0, 255, 0, 255); //GREEN
	//SetEntityRenderColor(iEntity, 0, 0, 255, 255); //BLUE
	//SetEntityRenderColor(iEntity, Random, Random, Random, 255);

	DispatchSpawn(iEntity);
	ActivateEntity(iEntity);

	SetEntPropFloat(iEntity, Prop_Send,"m_flModelScale", 0.66); //CHANGE SIZE OF MODEL

	SetVariantString("!activator");
	AcceptEntityInput(iEntity, "SetParent", iClient);

	SetVariantString("medkit");
	AcceptEntityInput(iEntity, "SetParentAttachment", iEntity);
	AcceptEntityInput(iEntity, "TurnOn");

	//SetVector(Pos, In/Out, Up/Down, Left/Right), SetVector(Ang, 175.0, 75.0, -75.0);
	SetVector(Pos, 4.0, 4.0, 2.5), SetVector(Ang, 175.0, 85.0, -75.0);

	TeleportEntity(iEntity, Pos, Ang, NULL_VECTOR);

	if(!IsFakeClient(iClient))
		SDKHook(iEntity, SDKHook_SetTransmit, Hook_SetTransmit_View);

	BackpackIndex[iClient] = EntIndexToEntRef(iEntity);
	BackpackOwner[iEntity] = GetClientUserId(iClient);
}

public Action:Hook_SetTransmit_View(int entity, int client)
{
	if(!IsValidEntRef(BackpackIndex[client]))
		return Plugin_Continue;

	static iEntOwner;
	iEntOwner = GetClientOfUserId(BackpackOwner[entity]);

	if(iEntOwner < 1 || !IsClientInGame(iEntOwner))
		return Plugin_Continue;

	if(GetClientTeam(iEntOwner) == 2)
	{
		if(iEntOwner != client)
			return Plugin_Continue;

		if(!IsSurvivorThirdPerson(client))
			return Plugin_Handled;
	}

	return Plugin_Continue;
}

static bool:IsSurvivorThirdPerson(iClient)
{
    //if(bThirdPerson[iClient])
        //return true;
    if(GetEntPropFloat(iClient, Prop_Send, "m_TimeForceExternalView") > GetGameTime())
        return true;
    if(GetEntProp(iClient, Prop_Send, "m_iObserverMode") == 1)
        return true;
    if(GetEntPropEnt(iClient, Prop_Send, "m_pummelAttacker") > 0)
        return true;
    if(GetEntPropEnt(iClient, Prop_Send, "m_carryAttacker") > 0)
        return true;
    if(GetEntPropEnt(iClient, Prop_Send, "m_pounceAttacker") > 0)
        return true;
    if(GetEntPropEnt(iClient, Prop_Send, "m_jockeyAttacker") > 0)
        return true; 
    if(GetEntProp(iClient, Prop_Send, "m_isHangingFromLedge") > 0)
        return true;
    if(GetEntPropEnt(iClient, Prop_Send, "m_reviveTarget") > 0)
        return true;  
    if(GetEntPropFloat(iClient, Prop_Send, "m_staggerTimer", 1) > -1.0)
        return true;

    switch(GetEntProp(iClient, Prop_Send, "m_iCurrentUseAction"))
    {
        case 1:
        {
            static iTarget;
            iTarget = GetEntPropEnt(iClient, Prop_Send, "m_useActionTarget");
            
            if(iTarget == GetEntPropEnt(iClient, Prop_Send, "m_useActionOwner"))
                return true;
            else if(iTarget != iClient)
                return true;
        }
        case 4, 6, 7, 8, 9, 10:
            return true;
    }
    
    static String:sModel[31];
    GetEntPropString(iClient, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
    
    switch(sModel[29])
    {
        case 'b'://nick
        {
            switch(GetEntProp(iClient, Prop_Send, "m_nSequence"))
            {
                case 626, 625, 624, 623, 622, 621, 661, 662, 664, 665, 666, 667, 668, 670, 671, 672, 673, 674, 620, 680:
                    return true;
            }
        }
        case 'd'://rochelle
        {
            switch(GetEntProp(iClient, Prop_Send, "m_nSequence"))
            {
                case 674, 678, 679, 630, 631, 632, 633, 634, 668, 677, 681, 680, 676, 675, 673, 672, 671, 670, 687, 629:
                    return true;
            }
        }
        case 'c'://coach
        {
            switch(GetEntProp(iClient, Prop_Send, "m_nSequence"))
            {
                case 656, 622, 623, 624, 625, 626, 663, 662, 661, 660, 659, 658, 657, 654, 653, 652, 651, 621, 620, 669:
                    return true;
            }
        }
        case 'h'://ellis
        {
            switch(GetEntProp(iClient, Prop_Send, "m_nSequence"))
            {
                case 625, 675, 626, 627, 628, 629, 630, 631, 678, 677, 676, 575, 674, 673, 672, 671, 670, 669, 668, 667, 666, 665, 684:
                    return true;
            }
        }
        case 'v'://bill
        {
            switch(GetEntProp(iClient, Prop_Send, "m_nSequence"))
            {
                case 528, 759, 763, 764, 529, 530, 531, 532, 533, 534, 753, 676, 675, 761, 758, 757, 756, 755, 754, 527, 772, 762:
                    return true;
            }
        }
        case 'n'://zoey
        {
            switch(GetEntProp(iClient, Prop_Send, "m_nSequence"))
            {
                case 537, 819, 823, 824, 538, 539, 540, 541, 542, 543, 813, 828, 825, 822, 821, 820, 818, 817, 816, 815, 814, 536, 809:
                    return true;
            }
        }
        case 'e'://francis
        {
            switch(GetEntProp(iClient, Prop_Send, "m_nSequence"))
            {
                case 532, 533, 534, 535, 536, 537, 769, 768, 767, 766, 765, 764, 763, 762, 761, 760, 759, 758, 757, 756, 531, 530, 775:
                    return true;
            }
        }
        case 'a'://louis
        {
            switch(GetEntProp(iClient, Prop_Send, "m_nSequence"))
            {
                case 529, 530, 531, 532, 533, 534, 766, 765, 764, 763, 762, 761, 760, 759, 758, 757, 756, 755, 754, 753, 527, 772, 528:
                    return true;
            }
        }
        case 'w'://adawong
        {
            switch(GetEntProp(iClient, Prop_Send, "m_nSequence"))
            {
            case 674, 678, 679, 630, 631, 632, 633, 634, 668, 677, 681, 680, 676, 675, 673, 672, 671, 670, 687, 629:
                    return true;
            }
        }
    }
    
    return false;
}

/*-----|STOCKS|-----*/
stock bool:IsValidClient(client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client))
		return true;
	return false;
}

stock bool:IsValidAdmin(client)
{
	if (GetUserFlagBits(client) & ADMFLAG_ROOT)
		return true;
	return false;
}

stock bool:IsSurvivor(client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2)
		return true;
	return false;
}

stock bool:IsInfected(client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3)
		return true;
	return false;
}

bool:IsPlayerIncapped(client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1))
		return true;
 	return false;
}

public bool:TraceRayDontHitPlayers(entity, mask)
{
    if (!entity || entity <= MaxClients || !IsValidEntity(entity))
        return false;
    return true;
}

static bool:IsValidEntRef(iEntRef)
{
    static iEntity;
    iEntity = EntRefToEntIndex(iEntRef);
    return (iEntRef && iEntity != INVALID_ENT_REFERENCE && IsValidEntity(iEntity));
}

void CheatCommand(int client, const char[] command, const char[] argument1, const char[] argument2)
{
	int userFlags = GetUserFlagBits(client);
	SetUserFlagBits(client, ADMFLAG_ROOT);
	int flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s %s", command, argument1, argument2);
	SetCommandFlags(command, flags);
	SetUserFlagBits(client, userFlags);
}