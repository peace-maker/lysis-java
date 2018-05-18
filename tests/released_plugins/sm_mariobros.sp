#pragma semicolon 1

// Includes
#include <sourcemod>
#include <tf2_stocks>
#include <morecolors>
#include <tf2>
#include <tf2items>
#include <tf2items_giveweapon>
#include <sdkhooks>

#undef REQUIRE_EXTENSIONS
#include <steamtools>

// Defines
#define MB_Version "1.0.6d"
#define SOUND_STOMP "mariobros/goombastomp.mp3"
#define SOUND_POWBOLT "mariobros/pow-lightning.mp3"
#define SOUND_MUSHROOM "mariobros/mushroom.mp3"
#define SOUND_BOO "mariobros/boo.mp3"
#define SOUND_HAMMER "mariobros/hammer.mp3"
#define SOUND_STARMAN "mariobros/starman.wav"
#define SOUND_1UP "mariobros/1up.mp3"
#define SOUND_BOWSER "mariobros/bowser.mp3"
#define SOUND_COIN "mariobros/coin.mp3"
//#define MUSIC_1 "mariobros/songmb_1.wav"
//#define MUSIC_2 "mariobros/songmb_2.wav"
//#define MUSIC_3 "mariobros/songmb_3.wav"
//#define MUSIC_4 "mariobros/songmb_4.wav"
//#define MUSIC_5 "mariobros/songmb_5.wav"
//#define MUSIC_6 "mariobros/songmb_6.wav"
#define SPRITE_COIN "materials/mariobros/coin"
#define MODEL_PHONG "materials/e-spowerups/flatphong.vtf"
#define MODEL_POWERUP_TEST "models/props_farm/box_cluster01.mdl"
#define MODEL_COIN "mariobros/goldcoin"
#define SECOND 66
#define MAXJUMPTICKS 33

// Plugin Info
public Plugin:myinfo =
{
	name = "[TF2]Mario Bros.",
	author = "X Kirby",
	description = "Jump, Stomp, and Power Up to defeat your opponents!",
	version = MB_Version,
	url = "http://www.sourcemod.net/",
}

// Handles
new Handle:mb_Version;
new Handle:mb_JumpHeight;
new Handle:mb_JumpDamage;
new Handle:mb_FireFlowerDamage;
new Handle:mb_PowerTime;
new Handle:mb_PowBlockDamage;
new Handle:mb_SpeedBoostBonus;
new Handle:mb_LeafFall;
new Handle:mb_MushroomHP;
new Handle:mb_StarmanSpeed;
new Handle:mb_LightningDamage;
new Handle:mb_BowserHP;
new Handle:mb_PowerDistance;
new Handle:mb_PickupDelay;
new Handle:mb_HUD;
new Handle:mb_HUD2;
new Handle:mb_HUD3;
new Handle:mb_HUD4;
new Handle:mb_RespawnMax;
new Handle:mb_MoveSpeed;
new Handle:mb_GameMode;
new Handle:mb_CoinTimeLimit;
new Handle:mb_CoinLimitGlow;
new Handle:mb_RoundLimit;
new Handle:mb_RoundWait;
new Handle:mb_ArenaTimeLimit;
new Handle:mb_SpawnProtection;
new Handle:mb_HUDLogo;
new Handle:mb_HUD_X;
new Handle:mb_HUD_Y;
new Handle:mb_HUDLogo_Red;
new Handle:mb_HUDLogo_Grn;
new Handle:mb_HUDLogo_Blu;
new Handle:PowerUpShuffler = INVALID_HANDLE;
new Handle:HelpMenu = INVALID_HANDLE;

// Variables
new i_RoundCount = 0;
new i_PowerUp[MAXPLAYERS+1] = 0;
new i_UsingPower[MAXPLAYERS+1] = 0;
new i_SpawnProtect[MAXPLAYERS+1] = 0;
//new bool:LoadSong[MAXPLAYERS+1] = false;
new bool:i_Hints[MAXPLAYERS+1] = true;
//new bool:i_SongMute[MAXPLAYERS+1] = false;
new i_HUDSprite[MAXPLAYERS+1] = -1;
//new i_Song = 0;
new RoundWaitTime = 0;
new Time[2] = 0;
new FrameCount = 0;
new String:Powers[15][128] = {"Fire Flower","POW Block","P Wing","Goomba's Shoe","Super Leaf","Boo Thief","Mushroom","Starman","Hammer","Thunderbolt","Golden Mushroom","Ice Flower","Lazy Shell Armor","1-Up Mushroom","Bowser Suit"};
new bool:Hooked[MAXPLAYERS+1] = false;
new bool:Jumping[MAXPLAYERS+1] = false;
new bool:JumpHold[MAXPLAYERS+1] = false;
new JumpTicks[MAXPLAYERS+1] = 0;
new bool:AirJumping[MAXPLAYERS+1] = false;
new bool:IsBounce[MAXPLAYERS+1] = false;
new bool:IsShocked[MAXPLAYERS+1] = false;
new CheckSprint[MAXPLAYERS+1] = 0;
new bool:IsSprint[MAXPLAYERS+1] = false;
new SteppedOn[MAXPLAYERS+1] = -1;
new Float:BounceVec[MAXPLAYERS+1][3];
new bool:Floating[MAXPLAYERS+1] = false;
new Frozen[MAXPLAYERS+1] = 0;
new Lives[MAXPLAYERS+1] = 0;
new Coins[MAXPLAYERS+1] = 0;
new TotalCoins[2] = 0;
new Respawns[MAXPLAYERS+1] = 0;
new bool:Invincible[MAXPLAYERS+1] = false;
new bool:LazyShellArmor[MAXPLAYERS+1] = true;
new Common[5] = {2, 3, 4, 5, 7};
new Uncommon[5] = {1, 6, 10, 11, 12};
new Rare[5] = {8, 9, 13, 14, 15};
new String:PowModels[15][255] = {"models/e-spowerups/ma_fireflower","models/e-spowerups/ma_powblock","models/e-spowerups/ma_pwing","models/e-spowerups/ma_kuriboshoe","models/e-spowerups/ma_powerleaf","models/e-spowerups/ma_boothief","models/e-spowerups/ma_redmushroom","models/e-spowerups/ma_starman","models/e-spowerups/ma_superhammer","models/e-spowerups/ma_lightningbolt","models/e-spowerups/ma_goldmushroom","models/e-spowerups/ma_iceflower","models/e-spowerups/ma_lazyshell","models/e-spowerups/ma_greenmushroom","models/e-spowerups/ma_bowsersuit"};
new String:PowMaterials[14][255] = {"materials/e-spowerups/fireflower","materials/e-spowerups/powblock","materials/e-spowerups/pbox","materials/e-spowerups/kuriboshoe","materials/e-spowerups/powerleaf","materials/e-spowerups/booface","materials/e-spowerups/redmushroom","materials/e-spowerups/starman","materials/e-spowerups/superhammer","materials/e-spowerups/goldenmushroom","materials/e-spowerups/iceflower","materials/e-spowerups/blueshell","materials/e-spowerups/greenmushroom","materials/e-spowerups/bowsershell"};

// On Plugin Start
public OnPluginStart()
{
	// Version Variable
	mb_Version = CreateConVar("mb_version", MB_Version, "Version Number.", FCVAR_NOTIFY);
	SetConVarString(mb_Version, MB_Version);
	
	// Set Game Description
	if(LibraryExists("SteamTools"))
	{
		new String:GameDesc[255];
		Format(GameDesc, sizeof(GameDesc), "[TF2]Mario Bros. (v%s)", MB_Version);
		Steam_SetGameDescription(GameDesc);
		PrintToServer("[MB] SteamTools detected, changing game description.");
	}
	
	// Console Variables
	mb_JumpHeight = CreateConVar("sm_mb_jumpheight", "450.0", "Sets the jump height for every player.");
	mb_JumpDamage = CreateConVar("sm_mb_jumpdamage", "150.0", "Sets the damage for landing on another player");
	mb_FireFlowerDamage = CreateConVar("sm_mb_fireflowerdamage", "50.0", "Sets the damage that fireballs deal.");
	mb_PowBlockDamage = CreateConVar("sm_mb_powblockdamage", "40.0", "Sets the damage that POW Blocks deal.");
	mb_SpeedBoostBonus = CreateConVar("sm_mb_speedboostpwing", "1.5", "Multiplies your speed by this number.");
	mb_PowerTime = CreateConVar("sm_mb_poweruptimer", "10.0", "Sets the amount of time until your Power Up ends.");
	mb_LeafFall = CreateConVar("sm_mb_leaffallspeed", "-120.0", "Sets the terminal velocity while using the Tanooki Leaf.");
	mb_MushroomHP = CreateConVar("sm_mb_mushroomhealth", "300.0", "Sets the amount of health a Mushroom gives you.");
	mb_StarmanSpeed = CreateConVar("sm_mb_speedbooststar", "1.5", "Sets the speed boost you get from a Starman.");
	mb_LightningDamage = CreateConVar("sm_mb_thunderboltdamage", "0.25", "Sets the percentage of damage that Lightning deals.");
	mb_BowserHP = CreateConVar("sm_mb_bowsersuithealth", "2000.0", "Sets the amount of health a Bowser Suit gives you.");
	mb_PowerDistance = CreateConVar("sm_mb_powerdistance", "2500.0", "The distance between the player and anyone else for certain powers to affect.");
	mb_PickupDelay = CreateConVar("sm_mb_packspawndelay", "16.0", "How long the maximum time is before ammo packs respawn.");
	mb_RespawnMax = CreateConVar("sm_mb_maxrespawns", "5", "How many times you're allowed to respawn during a round of Team Battle Arena.");
	mb_MoveSpeed = CreateConVar("sm_mb_movespeed", "300.0", "How fast you can move normally.");
	mb_GameMode = CreateConVar("sm_mb_gamemode", "0", "Special Game Mode Setting. <0 = None, 1 = Team Battle Arena, 2 = Team Coin Rush>");
	mb_CoinTimeLimit = CreateConVar("sm_mb_coinrushtime", "180", "How much time in seconds you have to collect coins during Coin Rush.");
	mb_ArenaTimeLimit = CreateConVar("sm_mb_arenatime", "900", "How much time in seconds you have until the round ends.");
	mb_CoinLimitGlow = CreateConVar("sm_mb_coinrushglow", "20", "How many coins you're carrying before you start to glow.");
	mb_RoundLimit = CreateConVar("sm_mb_roundlimit", "3", "How many rounds can pass before a Game Mode vote occurs.");
	mb_RoundWait = CreateConVar("sm_mb_roundwait", "30", "How many seconds before the round waiting period ends at the start of the round.");
	mb_SpawnProtection = CreateConVar("sm_mb_spawnprotection", "2", "How many seconds of spawn protection you have.");
	mb_HUDLogo = CreateConVar("sm_mb_hudlogomsg", "", "A generic logo which can be used for advertising and such.");
	mb_HUDLogo_Red = CreateConVar("sm_mb_hudlogor", "0", "The logo's color. (Red)");
	mb_HUDLogo_Grn = CreateConVar("sm_mb_hudlogog", "200", "The logo's color. (Green)");
	mb_HUDLogo_Blu = CreateConVar("sm_mb_hudlogob", "100", "The logo's color. (Blue)");
	mb_HUD_X = CreateConVar("sm_mb_hudlogox", "0.2", "The logo's X position.");
	mb_HUD_Y = CreateConVar("sm_mb_hudlogoy", "0.92", "The logo's Y position.");
	
	// Console Commands
	RegAdminCmd("sm_mb_setpowerup", Command_SetPower, ADMFLAG_CHEATS, "Gives a player a specific power-up. Usage: sm_mb_setpowerup <client> <0-15>");
	//RegAdminCmd("sm_mb_addpowerspawn", Command_AddSpawn, ADMFLAG_ROOT, "Creates a Power-Up Spawnpoint. FOR TESTING PURPOSES ONLY.");
	//RegAdminCmd("sm_mb_spawnpowerups", Command_SpawnPowerUps, ADMFLAG_ROOT, "Creates a Power-Up at every Power-Up Spawnpoint. FOR TESTING PURPOSES ONLY.");
	//RegAdminCmd("sm_mb_addcoinspawn", Command_AddCoin, ADMFLAG_ROOT, "Creates a Coin Spawnpoint. FOR TESTING PURPOSES ONLY.");
	//RegAdminCmd("sm_disableammo", Command_AmmoGone, ADMFLAG_ROOT, "Disables ALL Ammo Packs. FOR TESTING PURPOSES ONLY.");
	RegConsoleCmd("sm_mb_powerhints", Command_ToggleHints, "Toggles Power-Up Hintboxes appearing on your HUD.");
	//RegConsoleCmd("sm_mb_playmusic", Command_PlayMusic, "Toggles Music.");
	RegConsoleCmd("sm_mariohelp", Command_MarioHelp, "Gives you a Help Menu for the gamemode mechanics.");
	RegConsoleCmd("sm_marioayuda", Command_MarioHelp, "Te da un Menu de Ayuda sobre las mecánicas del Gamemode.");
	
	// Hooks
	HookEvent("teamplay_round_start", Event_RoundStart);
	HookEvent("teamplay_waiting_ends", Event_RoundStart);
	HookEvent("teamplay_round_win", Event_RoundWin);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("post_inventory_application", Event_PlayerLocker);
	HookEvent("player_death", Event_BeforePlayerDeath, EventHookMode_Pre);
	HookConVarChange(mb_GameMode, OnGameModeChange);
	
	// Custom Weapons
	// >> Fire Flower
	TF2Items_CreateWeapon(50000, "tf_weapon_rocketlauncher_directhit", 127, 0, 6, 50, "1 ; 0.5 ; 103 ; 2 ; 303 ; -1 ; 280 ; 6 ; 74 ; 0.0 ; 215 ; 300 ; 216 ; 350", 50, "", true);
	// >> Weak Shovel
	TF2Items_CreateWeapon(50001, "tf_weapon_shovel", 6, 2, 6, 1, "1 ; 0.2 ; 5 ; 1.25", 0, "", true);
	// >> Hammer
	TF2Items_CreateWeapon(50002, "tf_weapon_shovel", 153, 2, 6, 100, "2 ; 100 ; 6 ; 0.5", 0, "", true);
	// >> Ice Flower
	TF2Items_CreateWeapon(50003, "tf_weapon_rocketlauncher", 658, 0, 6, 50, "1 ; 0.25 ; 6 ; 0.8 ; 103 ; 2 ; 303 ; -1 ; 280 ; 6 ; 74 ; 0.0 ", 50, "", true);
	// >> Bowser's Fire Flower
	TF2Items_CreateWeapon(50004, "tf_weapon_rocketlauncher_directhit", 127, 0, 6, 50, "1 ; 0.5 ; 103 ; 2 ; 303 ; -1 ; 280 ; 6 ; 74 ; 0.0 ; 215 ; 300 ; 216 ; 350 ; 134 ; 2", 50, "", true);
	
	LoadTranslations("sm_mariobros.phrases.txt");
	
	// Var Resetter and SDKHooks
	for(new i = 1; i <= MAXPLAYERS; i++)
	{
		InitVars(i);
		if(IsValidEntity(i))
		{
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			SDKHook(i, SDKHook_StartTouch, OnStartTouch);
			SDKHook(i, SDKHook_TouchPost, OnTouch);
			Hooked[i] = true;
			CreateTimer(0.1, t_CheckPlayer, any:i);
		}
	}
	
	// Create Hud Synchronizer
	mb_HUD = CreateHudSynchronizer();
	mb_HUD2 = CreateHudSynchronizer();
	mb_HUD3 = CreateHudSynchronizer();
	mb_HUD4 = CreateHudSynchronizer();
	
	// Power-Up Shuffler
	if(PowerUpShuffler == INVALID_HANDLE)
	{
		PowerUpShuffler = CreateTimer(0.1, t_ShufflePowers, _, TIMER_REPEAT);
	}
	
	// Help Menu
	if(HelpMenu == INVALID_HANDLE)
	{
		HelpMenu = BuildHelpMenu();
	}
	
	// Load Translations
	
	// Precache
	PrecacheAll();
}

// When the Plugin ends
public OnPluginEnd()
{
	if(PowerUpShuffler != INVALID_HANDLE)
	{
		KillTimer(PowerUpShuffler);
		PowerUpShuffler = INVALID_HANDLE;
	}
	
	for(new i = 1; i <= MAXPLAYERS; i++)
	{
		SDKUnhook(i, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKUnhook(i, SDKHook_StartTouch, OnStartTouch);
		SDKUnhook(i, SDKHook_TouchPost, OnTouch);
		Hooked[i] = false;
		InitVars(i);
	}
	
	if(HelpMenu != INVALID_HANDLE)
	{
		CloseHandle(HelpMenu);
		HelpMenu = INVALID_HANDLE;
	}
	
	// Set Game Description
	if(LibraryExists("SteamTools"))
	{
		new String:GameDesc[255];
		Format(GameDesc, sizeof(GameDesc), "Team Fortress");
		Steam_SetGameDescription(GameDesc);
		PrintToServer("[MB] SteamTools detected, changing game description back.");
	}
}

public OnMapStart()
{
	// Precache
	PrecacheAll();

	// Extra Commands
	ServerCommand("sv_hudhint_sound 0");
	ServerCommand("tf_weapon_criticals 0");
	
	for(new i = 1; i <= MAXPLAYERS; i++)
	{
		if(IsValidEntity(i))
		{
			InitVars(i);
			if(Hooked[i] == true)
			{
				SDKUnhook(i, SDKHook_OnTakeDamage, OnTakeDamage);
				SDKUnhook(i, SDKHook_StartTouch, OnStartTouch);
				SDKUnhook(i, SDKHook_TouchPost, OnTouch);
			}
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			SDKHook(i, SDKHook_StartTouch, OnStartTouch);
			SDKHook(i, SDKHook_TouchPost, OnTouch);
		}
	}
	
	i_RoundCount = 0;
}

// When the Client Connects
public OnClientPutInServer(client)
{
	if(Hooked[client] == true)
	{
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKUnhook(client, SDKHook_StartTouch, OnStartTouch);
		SDKUnhook(client, SDKHook_TouchPost, OnTouch);
	}
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_StartTouch, OnStartTouch);
	SDKHook(client, SDKHook_TouchPost, OnTouch);

	InitVars(client);
	if(GetConVarInt(mb_GameMode) == 1 && RoundWaitTime <= 0)
	{
		Respawns[client] = GetConVarInt(mb_RespawnMax);
	}
	
	CreateTimer(0.5, t_HUD, any:client);
}

// When the Client is done disconnecting
public OnClientDisconnect(client)
{
	if(Hooked[client] == true)
	{
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKUnhook(client, SDKHook_StartTouch, OnStartTouch);
		SDKUnhook(client, SDKHook_TouchPost, OnTouch);
		Hooked[client] = false;
	}
	
	if(GetConVarInt(mb_GameMode) == 2 && Coins[client] > 0)
	{
		new entity, Float:pos[3], String:value[16], String:path[128];
		entity = CreateEntityByName("item_ammopack_small");
		if(entity != -1)
		{
			GetEntPropVector(client, Prop_Data, "m_vecOrigin", pos);
			Format(path, sizeof(path), "models/%s.mdl", MODEL_COIN);
			DispatchKeyValue(entity, "powerup_model", path);
			DispatchKeyValue(entity, "targetname", "mb_coin");
			IntToString(Coins[client], value, sizeof(value));
			DispatchKeyValue(entity, "max_health", value);
			DispatchSpawn(entity);
			TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
			SetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
			Coins[client] = 0;
		}
	}
	
	InitVars(client);
}

// Player Command: Toggle Hints
public Action:Command_ToggleHints(client, args)
{
	i_Hints[client] = !i_Hints[client];
	switch(i_Hints[client])
	{
		case true:{CPrintToChat(client, "{crimson}[MB]%t", "mbHintsEnable");}
		case false:{CPrintToChat(client, "{crimson}[MB]%t", "mbHintsDisable");}
	}
	return Plugin_Handled;
}

// Player Command: Toggle Music
/*
public Action:Command_PlayMusic(client, args)
{
	i_SongMute[client] = !i_SongMute[client];
	StopSound(client, 0, MUSIC_1);
	StopSound(client, 0, MUSIC_2);
	StopSound(client, 0, MUSIC_3);
	StopSound(client, 0, MUSIC_4);
	StopSound(client, 0, MUSIC_5);
	StopSound(client, 0, MUSIC_6);
	switch(i_SongMute[client])
	{
		case true:{CPrintToChat(client, "{crimson}[MB]%t", "mbMusicDisable");}
		case false:
		{
			if(i_Song > 0)
			{
				new String:SongFile[128];
				Format(SongFile, sizeof(SongFile), "mariobros/songmb_%i.wav", i_Song);
				EmitSoundToClient(client, SongFile, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			}
			CPrintToChat(client, "{crimson}[MB]%t", "mbMusicEnable");
		}
	}
	return Plugin_Handled;
}
*/

// Player Command: Help Menu
public Action:Command_MarioHelp(client, args)
{
	if(HelpMenu == INVALID_HANDLE)
	{
		PrintToConsole(client, "[MB]HelpMenu unavailable.");
		return Plugin_Handled;
	}
	
	DisplayMenu(HelpMenu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

// Admin Command: Set Power-Up
public Action:Command_SetPower(client, args)
{
	if(args < 2)
	{
		PrintToConsole(client, "Power-Up List");
		PrintToConsole(client, "0: No Power");
		for(new i=0; i<15; i++)
		{
			PrintToConsole(client, "%i: %t", i+1, Powers[i]);
		}
		return Plugin_Handled;
	}
	
	new String:name[32], String:Num[8];
	GetCmdArg(1, name, sizeof(name));
	GetCmdArg(2, Num, sizeof(Num));
 
	new String:target_name[MAX_TARGET_LENGTH];
	new target_list[MAXPLAYERS], target_count;
	new bool:tn_is_ml;
 
	if ((target_count = ProcessTargetString(
			name,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE, /* Only allow alive players */
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		return Plugin_Handled;
	}
 
	for (new i = 0; i < target_count; i++)
	{
		if(StringToInt(Num) >= 0 && StringToInt(Num) <= 15)
		{
			i_PowerUp[target_list[i]] = StringToInt(Num);
			if(i_PowerUp[target_list[i]] > 0)
			{
				CPrintToChatAll("{crimson}[MB]%t", "mbGivePowerUp", target_name[i], Powers[i_PowerUp[target_list[i]]-1]);
			}
			else
			{
				CPrintToChatAll("{crimson}[MB]%t", "mbLosePowerUp", target_name[i]);
			}
		}
	}
	
	return Plugin_Handled;
}

// Adds a Power-Up Spawn Point
public Action:Command_AddSpawn(client, args)
{
	new Float:pos[3], ent, String:Power[4] = "x";
	if(args >= 1)
	{
		GetCmdArg(1, Power, sizeof(Power));
		if(StringToInt(Power) < 1 || StringToInt(Power) > 15)
		{
			Power = "x";
		}
	}
	
	GetClientAbsOrigin(client, pos);
	
	ent = CreateEntityByName("info_target");
	if(ent != -1)
	{
		new String:entname[32];
		Format(entname, sizeof(entname), "mb_powerspawn %s", Power);
		SetEntPropVector(ent, Prop_Data, "m_vecOrigin", pos);
		DispatchKeyValue(ent, "targetname", entname);
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(ent);
		PrintToConsole(client, "Entity Created Successfully.");
	}
	
	return Plugin_Handled;
}

// Spawns Power-Ups at all Spawn Points
public Action:Command_SpawnPowerUps(client, args)
{
	SpawnFixedPowerUps();
	return Plugin_Handled;
}

// Adds a Coin Spawn Point
public Action:Command_AddCoin(client, args)
{
	new Float:pos[3], ent;
	GetClientAbsOrigin(client, pos);
	
	ent = CreateEntityByName("info_target");
	if(ent != -1)
	{
		SetEntPropVector(ent, Prop_Data, "m_vecOrigin", pos);
		DispatchKeyValue(ent, "max_health", "1");
		DispatchKeyValue(ent, "targetname", "mb_coinspawn");
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(ent);
		PrintToConsole(client, "Entity Created Successfully.");
	}
	
	return Plugin_Handled;
}

public Action:Command_AmmoGone(client, args)
{
	new ent = -1;
	while((ent = FindEntityByClassname(ent, "item_ammopack_full")) != -1)
	{
		AcceptEntityInput(ent, "Disable");
	}
	while((ent = FindEntityByClassname(ent, "item_ammopack_medium")) != -1)
	{
		AcceptEntityInput(ent, "Disable");
	}
	while((ent = FindEntityByClassname(ent, "item_ammopack_small")) != -1)
	{
		AcceptEntityInput(ent, "Disable");
	}
	return Plugin_Handled;
}

// On Player Run Command
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon) 
{
	if(IsPlayerAlive(client))
	{
		// Jump Hold Check #1
		if(!(buttons & IN_JUMP))
		{
			if((GetEntityFlags(client) & FL_ONGROUND))
				{JumpHold[client] = false;}
			JumpTicks[client] = MAXJUMPTICKS;
		}
		else
		{
			JumpTicks[client]++;
		}
		
		// Jump Check #1
		if((GetEntityFlags(client) & FL_ONGROUND))
		{
			Jumping[client] = false;
			if(!(buttons & IN_JUMP))
				{JumpTicks[client] = 0;}
		}
		else
		{
			Jumping[client] = true;
		}
		
		// High Jump
		if((buttons & IN_JUMP) && (((GetEntityFlags(client) & FL_ONGROUND) && Jumping[client] == false
		&& JumpHold[client] == false) || (JumpHold[client] == false || JumpTicks[client] < MAXJUMPTICKS)))
		{
			new Float:force[3], Float:vs[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vs);
			force[0] = FloatAbs(vs[0]) > GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") ? vs[0] / FloatAbs(vs[0]) * GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") : vs[0];
			force[1] = FloatAbs(vs[1]) > GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") ? vs[1] / FloatAbs(vs[1]) * GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") : vs[1];
			force[2] = GetConVarFloat(mb_JumpHeight);
			
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, force);
			Jumping[client] = true;
			AirJumping[client] = true;
			if(JumpTicks[client] >= MAXJUMPTICKS)
				{JumpHold[client] = true;}
		}
		
		// Jump Hold Check #2
		if(buttons & IN_JUMP && JumpTicks[client] >= MAXJUMPTICKS)
		{
			JumpHold[client] = true;
		}
		else if(!(buttons & IN_JUMP))
		{
			if((GetEntityFlags(client) & FL_ONGROUND))
				{JumpHold[client] = false;}
			else
				{JumpHold[client] = true;}
			JumpTicks[client] = MAXJUMPTICKS;
		}
		
		// Jump Check #2
		if((GetEntityFlags(client) & FL_ONGROUND))
		{
			Jumping[client] = false;
			if(!(buttons & IN_JUMP))
				{JumpTicks[client] = 0;}
		}
		else
		{
			Jumping[client] = true;
		}
		
		// Weigh Down
		if((buttons & IN_DUCK) && !(GetEntityFlags(client) & FL_ONGROUND))
		{
			new Float:force[3], Float:vs[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vs);
			if(vs[2] <= 40.0 && vs[2] > -600.0)
			{
				force[0] = FloatAbs(vs[0]) > GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") ? vs[0] / FloatAbs(vs[0]) * GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") : vs[0];
				force[1] = FloatAbs(vs[1]) > GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") ? vs[1] / FloatAbs(vs[1]) * GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") : vs[1];
				force[2] = -600.0;
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, force);
			}
		}
		
		// Jump Cancel
		if(!(buttons & IN_JUMP) && !(GetEntityFlags(client) & FL_ONGROUND))
			{AirJumping[client] = false;}
		
		// If able to float in the air
		if(Floating[client] == true && (buttons & IN_JUMP)
		&& !(GetEntityFlags(client) & FL_ONGROUND))
		{
			new Float:vels[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", vels);
			if(AirJumping[client] == false)
			{
				vels[2] = GetConVarFloat(mb_JumpHeight)*0.66;
			}
			else if(vels[2] < GetConVarFloat(mb_LeafFall))
			{
				vels[2] = GetConVarFloat(mb_LeafFall);
			}
			AirJumping[client] = true;
			JumpHold[client] = true;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vels);
		}
		
		// Sprinting
		if((buttons & IN_FORWARD) && CheckSprint[client] == 2)
		{
			IsSprint[client] = true;
			CheckSprint[client] = 3;
		}
		
		else if(buttons & IN_FORWARD && !IsSprint[client] && CheckSprint[client] == 0)
		{
			CheckSprint[client] = 1;
			CreateTimer(0.3, t_SprintSet, client);
		}

		if(!(buttons & IN_FORWARD))
		{
			IsSprint[client] = false;
			if(CheckSprint[client] == 1)
				{
					CheckSprint[client] = 2;
					CreateTimer(0.3, t_SprintSet, client);
				}
			if(CheckSprint[client] >= 3)
				{CheckSprint[client] = 0;}
		}
		
		if((buttons & IN_BACK) || (buttons & IN_MOVELEFT) || (buttons & IN_MOVERIGHT) ||
		IsShocked[client] || Frozen[client] > 0 || i_UsingPower[client] == 3 || i_UsingPower[client] == 8
		|| i_UsingPower[client] == 15)
			{
				IsSprint[client] = false;
				CheckSprint[client] = 0;
				if(GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") >= GetConVarFloat(mb_MoveSpeed) * 1.3 &&
				i_UsingPower[client] != 3 && i_UsingPower[client] != 8 && i_UsingPower[client] != 15
				&& !IsShocked[client] && Frozen[client] <= 0)
				{
					SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed));
				}
			}
		
		// Sprint Check
		if((GetEntityFlags(client) & FL_ONGROUND) && IsSprint[client])
		{
			if(GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") <= GetConVarFloat(mb_MoveSpeed) * 1.3)
			{
				new Float:spd = GetConVarFloat(mb_MoveSpeed) * 1.3;
				SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", spd);
			}
		}
		
		// P-Wing Check
		if(i_UsingPower[client] == 3 && Frozen[client] < 1)
		{
			SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed) * GetConVarFloat(mb_SpeedBoostBonus));
		}
		
		// Power Up Usage
		if((buttons & IN_ATTACK2) && i_UsingPower[client] == 0 && i_PowerUp[client] > 0)
		{
			new String:powername[128], Handle:panel, String:Hint[1024];
			strcopy(powername, sizeof(powername), Powers[i_PowerUp[client]-1]);
			i_UsingPower[client] = i_PowerUp[client];
			i_PowerUp[client] = 0;
			panel = CreatePanel();
			SetPanelTitle(panel, powername);
			DrawPanelText(panel, " ");
			switch(i_UsingPower[client])
			{
				// Fire Flower
				case 1:
				{
					EmitSoundToAll(SOUND_MUSHROOM, client);
					TF2Items_GiveWeapon(client, 50000);
					TF2_RemoveWeaponSlot(client, 2);
					CreateTimer(GetConVarFloat(mb_PowerTime), t_EndPowerUp, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_FireFlower", client);
				}
				// POW Block
				case 2:
				{
					EmitSoundToAll(SOUND_POWBOLT, client);
					for(new i = 1; i < MaxClients+1; i++)
					{
						if(IsClientInGame(i))
						{
							new Float:uservec[3], Float:targvec[3];
							GetClientAbsOrigin(client, uservec);
							GetClientAbsOrigin(i, targvec);
							
							if((GetEntityFlags(i) & FL_ONGROUND) && i != client
							&& GetClientTeam(i) != GetClientTeam(client)
							&& LazyShellArmor[i] != true && i_UsingPower[i] != 8 && i_SpawnProtect[i] <= 0 &&
							GetVectorDistance(uservec, targvec, false) <= GetConVarFloat(mb_PowerDistance))
							{
								new Float:force[3], Float:damage = GetConVarFloat(mb_PowBlockDamage);
								force[0] = 0.0;
								force[1] = 0.0;
								force[2] = 2000.0;
								
								if(i_UsingPower[i] == 15){damage *= 10.0;}
								if(Lives[i] > 0 && damage >= GetEntProp(i, Prop_Send, "m_iHealth"))
								{
									damage *= 0.0;
									Lives[i] -= 1;
									SetEntityHealth(i, 200);
									Invincible[i] = true;
									CreateTimer(3.0, t_EndInv, any:i);
									CPrintToChat(i, "{crimson}[MB]{default}You have {orange}%i {default}Lives left!", Lives[i]);
								}
								
								if(damage > 0)
								{
									if(Coins[i] > 0)
									{
										new c = RoundToCeil(float(Coins[i]) * 0.1);
										Coins[i] -= c;
										Coins[client] += c;
									}
								}
								
								SDKHooks_TakeDamage(i, client, client, damage, DMG_GENERIC, -1, NULL_VECTOR, NULL_VECTOR);
								TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, force);
							}
						}
					}
					CreateTimer(1.0, t_EndPowerUp, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_POWBlock", client);
				}
				// P Wing
				case 3:
				{
					EmitSoundToAll(SOUND_MUSHROOM, client);
					SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed) * GetConVarFloat(mb_SpeedBoostBonus));
					CreateTimer(GetConVarFloat(mb_PowerTime), t_EndPowerUp, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_PWing", client);
				}
				// Goomba's Shoe
				case 4:
				{
					EmitSoundToAll(SOUND_MUSHROOM, client);
					CreateTimer(GetConVarFloat(mb_PowerTime), t_EndPowerUp, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_GoombaShoe", client);
				}
				// Super Leaf
				case 5:
				{
					EmitSoundToAll(SOUND_MUSHROOM, client);
					Floating[client] = true;
					CreateTimer(GetConVarFloat(mb_PowerTime), t_EndPowerUp, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_SuperLeaf", client);
				}
				// Boo Theif
				case 6:
				{
					EmitSoundToAll(SOUND_BOO, client);
					new PlayerList[MaxClients+1];
					new j = 0, p = -1;
					for(new i = 1; i < MaxClients+1; i++)
					{
						if(IsClientInGame(i))
						{
							if(IsPlayerAlive(i) && GetClientTeam(i) != GetClientTeam(client)
							&& i != client && i_PowerUp[i] > 0)
							{
								PlayerList[j] = i;
								j++;
							}
						}
					}
					
					if(j >= 1)
					{
						p = GetRandomInt(0, j-1);
						i_PowerUp[client] = i_PowerUp[PlayerList[p]];
						i_PowerUp[PlayerList[p]] = 0;
						CPrintToChat(PlayerList[p], "{crimson}[MB]%t", "mbStolenPowerUp");
						
						new String:newpower[128];
						strcopy(newpower, sizeof(newpower), Powers[i_PowerUp[client]-1]);
						CPrintToChat(client, "{crimson}[MB]%t", "mbStealPowerUp", newpower);
					}
					CreateTimer(GetConVarFloat(mb_PowerTime)*0.5, t_EndPowerUp, any:client);
					TF2_AddCondition(client, TFCond_Stealthed, GetConVarFloat(mb_PowerTime)*0.5);
					if(!IsShocked[client] && Frozen[client] <= 0)
						{SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed));}
					Format(Hint, sizeof(Hint), "%t", "mbHint_BooTheif", client);
				}
				// Mushroom
				case 7:
				{
					new Health = GetEntProp(client, Prop_Send, "m_iHealth");
					EmitSoundToAll(SOUND_MUSHROOM, client);
					SetEntityHealth(client, Health + GetConVarInt(mb_MushroomHP));
					if(Health + GetConVarInt(mb_MushroomHP) > GetConVarInt(mb_MushroomHP)*3)
					{
						SetEntityHealth(client, GetConVarInt(mb_MushroomHP) * 3);
					}
					CreateTimer(1.0, t_EndPowerUp, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_Mushroom", client);
				}
				// Starman
				case 8:
				{
					EmitSoundToAll(SOUND_STARMAN, client);
					for(new Float:i = 0.1; i <= GetConVarFloat(mb_PowerTime)-0.1; i += 0.1)
					{
						CreateTimer(i, t_FlashColors, any:client);
					}
					SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed) * GetConVarFloat(mb_StarmanSpeed));
					CreateTimer(GetConVarFloat(mb_PowerTime), t_EndPowerUp, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_Starman", client);
				}
				// Hammer
				case 9:
				{
					EmitSoundToAll(SOUND_HAMMER, client);
					TF2Items_GiveWeapon(client, 50002);
					CreateTimer(GetConVarFloat(mb_PowerTime), t_EndPowerUp, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_Hammer", client);
				}
				// Thunderbolt
				case 10:
				{
					EmitSoundToAll(SOUND_POWBOLT, client);
					for(new i = 1; i < MaxClients+1; i++)
					{
						if(IsClientInGame(i))
						{
							new Float:uservec[3], Float:targvec[3];
							GetClientAbsOrigin(client, uservec);
							GetClientAbsOrigin(i, targvec);
							
							if(i != client && GetClientTeam(i) != GetClientTeam(client)
							&& LazyShellArmor[client] != true &&
							GetVectorDistance(uservec, targvec, false) <= GetConVarFloat(mb_PowerDistance))
							{
								new CurrentHealth = GetEntProp(i, Prop_Send, "m_iHealth");
								CurrentHealth = RoundToFloor(float(CurrentHealth) * (1.0 - GetConVarFloat(mb_LightningDamage)));
								SetEntityHealth(i, CurrentHealth);
								SetEntPropFloat(i, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed)*0.5);
								IsShocked[i] = true;
								CreateTimer(GetConVarFloat(mb_PowerTime), t_FixSpeed, any:i);
							}
						}
					}
					CreateTimer(GetConVarFloat(mb_PowerTime), t_EndPowerUp, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_Thunderbolt", client);
				}
				// Golden Mushroom
				case 11:
				{
					EmitSoundToAll(SOUND_MUSHROOM, client);
					SetEntityHealth(client, GetConVarInt(mb_MushroomHP) * 3);
					CreateTimer(1.0, t_EndPowerUp, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_GoldenMushroom", client);
				}
				// Ice Flower
				case 12:
				{
					EmitSoundToAll(SOUND_MUSHROOM, client);
					TF2Items_GiveWeapon(client, 50003);
					TF2_RemoveWeaponSlot(client, 2);
					CreateTimer(GetConVarFloat(mb_PowerTime), t_EndPowerUp, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_IceFlower", client);
				}
				// Lazy Shell Armor
				case 13:
				{
					EmitSoundToAll(SOUND_MUSHROOM, client);
					LazyShellArmor[client] = true;
					CreateTimer(1.0, t_EndPowerUp, any:client);
					CreateTimer(GetConVarFloat(mb_PowerTime), t_EndArmor, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_LazyShellArmor", client);
				}
				// 1-Up Mushroom
				case 14:
				{
					EmitSoundToAll(SOUND_1UP, client);
					Lives[client] += 1;
					if(Lives[client] > 3)
					{
						Lives[client] = 3;
					}
					CreateTimer(1.0, t_EndPowerUp, any:client);
					CPrintToChat(client, "{crimson}[MB]%t", "mbLivesCount", Lives[client]);
					Format(Hint, sizeof(Hint), "%t", "mbHint_1UpMushroom", client);
				}
				// Bowser Suit
				case 15:
				{
					EmitSoundToAll(SOUND_BOWSER, client);
					TF2Items_GiveWeapon(client, 50004);
					TF2_RemoveWeaponSlot(client, 2);
					SetEntityHealth(client, GetConVarInt(mb_BowserHP));
					SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed)*0.66);
					CreateTimer(GetConVarFloat(mb_PowerTime) * 3.0, t_FixSpeed, any:client);
					CreateTimer(GetConVarFloat(mb_PowerTime) * 3.0, t_EndPowerUp, any:client);
					Format(Hint, sizeof(Hint), "%t", "mbHint_BowserSuit", client);
				}
			}
			new String:username[64];
			GetClientName(client, username, sizeof(username));
			PrintHintTextToAll("%s used %s!", username, powername);
			if(i_Hints[client])
			{
				DrawPanelText(panel, Hint);
				SendPanelToClient(panel, client, Panel_PowerDetails, 5);
			}
			CloseHandle(panel);
		}
	}
	return Plugin_Continue;
}

// Standard Power-Up Detail Panel
public Panel_PowerDetails(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Cancel)
	{
		return;
	}
}

// Help Menu Panel Details
public Panel_HelpMenu(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_End)
	{
		DisplayMenu(HelpMenu, param1, MENU_TIME_FOREVER);
		return;
	}
}

// When Damage is dealt and received
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon,
        Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	// Flare-based Weapon Damage
	if(damagecustom == TF_CUSTOM_BURNING_FLARE)
	{
		if(i_UsingPower[attacker] == 1)
		{
			damage = GetConVarFloat(mb_FireFlowerDamage);
		}
		if(i_UsingPower[attacker] == 12)
		{
			damage = GetConVarFloat(mb_FireFlowerDamage) * 0.5;
			
			Frozen[victim] += SECOND * 2;
			if(Frozen[victim] > SECOND * 6){Frozen[victim] = SECOND * 6;}
		}
	}
	
	// Disable Afterburn Damage &
	// Disable Mantread Damage
	if(damagecustom == TF_CUSTOM_BOOTS_STOMP || damagecustom == TF_CUSTOM_BURNING)
	{
		damage = 0.0;
	}
	
	// Fall Damage Stuff
	if(damagetype == DMG_FALL)
	{
		damage *= 0.0;
	}
	
	// If using the Star, 1-Up Invincibility, or Respawning
	if(i_UsingPower[victim] == 8 || Invincible[victim] == true ||
	i_SpawnProtect[victim] > 0)
	{
		damage *= 0.0;
		Frozen[victim] = 0;
	}
	
	// If using the Lazy Shell Armor
	if(LazyShellArmor[victim] == true)
	{
		damage *= 0.25;
		Frozen[victim] = 0;
	}
	
	// If the victim used some 1-Ups
	if(Lives[victim] > 0 && damage >= GetEntProp(victim, Prop_Send, "m_iHealth"))
	{
		damage *= 0.0;
		Lives[victim] -= 1;
		SetEntityHealth(victim, 200);
		Invincible[victim] = true;
		CreateTimer(3.0, t_EndInv, any:victim);
		CPrintToChat(victim, "{crimson}[MB]{default}You have {orange}%i {default}Lives left!", Lives[victim]);
	}
	
	if(GetConVarInt(mb_GameMode) == 2 && damage > 0)
	{
		if(attacker > 0 && attacker <= MaxClients)
		{
			if(IsPlayerAlive(attacker) && victim != attacker && Coins[victim] > 0)
			{
				new c = RoundToCeil(float(Coins[victim]) * 0.1);
				Coins[victim] -= c;
				Coins[attacker] += c;
			}
		}
	}

	return Plugin_Changed;
}

// When the Client spawns
public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsValidEntity(client))
	{
		if(IsClientInGame(client))
		{
			// Reset Power Up Settings
			if(i_PowerUp[client] == 0)
			{
				new R = GetRandomInt(1, 100), String:powername[128];
				if(R <= 100){i_PowerUp[client] = Common[GetRandomInt(1, 5)-1];}
				if(R <= 50){i_PowerUp[client] = Uncommon[GetRandomInt(1, 5)-1];}
				if(R <= 20){i_PowerUp[client] = Rare[GetRandomInt(1, 5)-1];}
				powername = Powers[i_PowerUp[client]-1];
				CPrintToChat(client, "{crimson}[MB]%t", "mbSpawnWithPowerUp", powername);
			}
			i_UsingPower[client] = 0;
			Jumping[client] = false;
			IsBounce[client] = false;
			SteppedOn[client] = -1;
			Frozen[client] = 0;
			IsShocked[client] = false;
			Floating[client] = false;
			LazyShellArmor[client] = false;
			JumpTicks[client] = 0;
			IsSprint[client] = false;
			CheckSprint[client] = 0;
			Lives[client] = 0;
			i_SpawnProtect[client] = SECOND*GetConVarInt(mb_SpawnProtection);
			
			// Set Speed
			SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed));
			CreateTimer(0.1, t_ForceDefaultSpeed, any:client);
			
			// Set Player Class as Soldier.
			TF2_SetPlayerClass(client, TFClass_Soldier, false, true);
			
			// Remove All Weapons
			TF2_RemoveAllWeapons(client);
			
			// Gives you a really weak Shovel.
			TF2Items_GiveWeapon(client, 50001);
			
			// Recolor the player correctly
			SetEntityRenderColor(client, 255, 255, 255, 255);
			SetEntProp(client, Prop_Send, "m_bGlowEnabled", false);
			
			// Stop Sounds
			StopSound(client, 0, SOUND_STARMAN);
			StopSound(client, 0, SOUND_HAMMER);
			
			if(GetConVarInt(mb_GameMode) == 1)
			{
				if(Respawns[client] <= GetConVarInt(mb_RespawnMax))
				{
					CPrintToChat(client, "{crimson}[MB]%t", "mbRespawnCount", GetConVarInt(mb_RespawnMax) - Respawns[client]);
				}
				
				if(Respawns[client] > GetConVarInt(mb_RespawnMax))
				{
					Respawns[client] = GetConVarInt(mb_RespawnMax)+1;
					ChangeClientTeam(client, 1);
				}
			}
			
			// Check if required to Load a Song.
			/*
			if(!i_SongMute[client] && i_Song > 0 && !LoadSong[client])
			{
				// Reset all Music Tracks
				StopSound(client, 0, MUSIC_1);
				StopSound(client, 0, MUSIC_2);
				StopSound(client, 0, MUSIC_3);
				StopSound(client, 0, MUSIC_4);
				StopSound(client, 0, MUSIC_5);
				StopSound(client, 0, MUSIC_6);
				LoadSong[client] = true;
				CPrintToChat(client, "{crimson}[MB]{default}%t", "mbWelcome");
				
				new String:SongFile[128];
				Format(SongFile, sizeof(SongFile), "mariobros/songmb_%i.wav", i_Song);
				EmitSoundToClient(client, SongFile, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			}
			*/
		}
	}
}

// When any Client dies (Pre-Death Event)
public Action:Event_BeforePlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(attacker > 0 && attacker <= MaxClients)
	{
		if(SteppedOn[attacker] == client)
		{
			SetEventInt(event, "customkill", TF_CUSTOM_BOOTS_STOMP);
			SetEventString(event, "weapon_logclassname", "mbstomp");
			SetEventString(event, "weapon", "mantreads");
		}
	}
	return Plugin_Continue;
}

// When any Client dies
public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidEntity(client))
	{
		i_PowerUp[client] = 0;
		switch(GetConVarInt(mb_GameMode))
		{
			case 1:
			{
				if(RoundWaitTime <= 0)
				{
					Respawns[client]++;
					if(Respawns[client] > GetConVarInt(mb_RespawnMax))
					{
						Respawns[client] = GetConVarInt(mb_RespawnMax)+1;
						ChangeClientTeam(client, 1);
					}
				}
			}
			case 2:
			{
				if(Coins[client] > 0)
				{
					new entity, Float:pos[3], String:value[16], String:path[128];
					entity = CreateEntityByName("item_ammopack_small");
					if(entity != -1)
					{
						GetEntPropVector(client, Prop_Data, "m_vecOrigin", pos);
						Format(path, sizeof(path), "models/%s.mdl", MODEL_COIN);
						DispatchKeyValue(entity, "powerup_model", path);
						DispatchKeyValue(entity, "targetname", "mb_coin");
						IntToString(Coins[client], value, sizeof(value));
						DispatchKeyValue(entity, "max_health", value);
						DispatchSpawn(entity);
						TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
						SetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
						Coins[client] = 0;
					}
				}
			}
		}
	}
}

// Round Restart
public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	//i_Song = GetRandomInt(1,6);
	//new String:SongFile[128];
	//Format(SongFile, sizeof(SongFile), "mariobros/songmb_%i.wav", i_Song);
	for(new i=1; i <= MaxClients; i++)
	{
		if(IsValidEntity(i))
		{
			// Reset all Music Tracks
			/*
			StopSound(i, 0, MUSIC_1);
			StopSound(i, 0, MUSIC_2);
			StopSound(i, 0, MUSIC_3);
			StopSound(i, 0, MUSIC_4);
			StopSound(i, 0, MUSIC_5);
			StopSound(i, 0, MUSIC_6);
			if(!i_SongMute[i])
			{
				EmitSoundToClient(i, SongFile, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			}
			*/
			
			// (Battle Arena) If they're in Spectator, put them on a Team.
			if(GetConVarInt(mb_GameMode) == 1 && GetClientTeam(i) == 1)
			{
				if(GetTeamClientCount(2) >= GetTeamClientCount(3))
					{ChangeClientTeam(i, 3);}
				else
					{ChangeClientTeam(i, 2);}
			}
			
			// Resets Resources
			Respawns[i] = 0;
			Coins[i] = 0;
		}
	}
	
	// Set Up Timers
	RoundWaitTime = SECOND * GetConVarInt(mb_RoundWait);
	if(GetConVarInt(mb_GameMode) == 2)
	{
		Time[0] = GetConVarInt(mb_CoinTimeLimit);
		Time[1] = GetConVarInt(mb_CoinTimeLimit);
	}
	else if(GetConVarInt(mb_GameMode) == 1)
	{
		Time[0] = GetConVarInt(mb_ArenaTimeLimit);
	}
	
	// Clean up existing Coin Sprites
	new ent;
	while((ent = FindEntityByClassname(ent, "env_sprite")) != -1)
	{
		new String:modelname[128], String:spr[128];
		Format(spr, sizeof(spr), "%s.vmt", SPRITE_COIN);
		GetEntPropString(ent, Prop_Data, "m_ModelName", modelname, sizeof(modelname));
		if(StrEqual(modelname, spr))
			{AcceptEntityInput(ent, "Kill");}
	}
	
	if(GetConVarInt(mb_GameMode) > 0){ToggleCaps(false);}
	else{ToggleCaps(true);}
	SpawnFixedPowerUps();
}

// When the round is won
public Event_RoundWin(Handle:event, const String:name[], bool:dontBroadcast)
{
	for(new i=1; i <= MaxClients; i++)
	{
		if(IsValidEntity(i))
		{
			// Reset all Music Tracks
			/*
			StopSound(i, 0, MUSIC_1);
			StopSound(i, 0, MUSIC_2);
			StopSound(i, 0, MUSIC_3);
			StopSound(i, 0, MUSIC_4);
			StopSound(i, 0, MUSIC_5);
			StopSound(i, 0, MUSIC_6);
			*/
		}
		Coins[i] = 0;
	}
	//i_Song = 0;
	
	// Round Limit Check
	i_RoundCount++;
	if(i_RoundCount >= GetConVarInt(mb_RoundLimit))
	{
		i_RoundCount = 0;
		if(GetConVarInt(mb_RoundLimit) > 0)
			{VoteGameMode();}
	}
}

// When the Client resupplies
public Event_PlayerLocker(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsValidEntity(client))
	{
		// Set Player Class as Soldier.
		TF2_SetPlayerClass(client, TFClass_Soldier, false, true);
		
		// Remove All Weapons
		TF2_RemoveAllWeapons(client);
		
		// Gives you a really weak Shovel.
		TF2Items_GiveWeapon(client, 50001);
		
		// Recolor the player correctly
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}

public OnTouch(entity, other)
{
	new String:entclass[256], String:powername[128];
	GetEntityClassname(entity, entclass, sizeof(entclass));
	if(StrEqual(entclass, "player"))
	{
		GetEntityClassname(other, entclass, sizeof(entclass));
		if(StrContains(entclass, "item_ammopack", false) > -1)
		{
			if(GetEntProp(other, Prop_Data, "m_bDisabled")){return;}
			if(FixedPowerUpCheck(entity, other)){return;}
			if(i_PowerUp[entity] == 0)
			{
				for(new i = 0; i < 15; i++)
				{
					new String:path[255];
					GetEntPropString(other, Prop_Data, "m_iszModel", path, sizeof(path));
					if(StrContains(path, PowModels[i], false) > -1)
					{
						i_PowerUp[entity] = i+1;
						break;
					}
				}
				
				if(i_PowerUp[entity] > 0)
				{
					powername = Powers[i_PowerUp[entity]-1];
					CPrintToChat(entity, "{crimson}[MB]%t", "mbGetPowerUp", powername);
					
					new Float:newpos[3], Handle:pack;
					GetEntPropVector(other, Prop_Data, "m_vecOrigin", newpos);
					
					CreateDataTimer(GetConVarFloat(mb_PickupDelay) / SquareRoot(float(GetClientCount()+1)), DTimer_RespawnAmmo, pack);
					WritePackCell(pack, other);
					WritePackFloat(pack, newpos[0]);
					WritePackFloat(pack, newpos[1]);
					WritePackFloat(pack, newpos[2]);
					
					newpos[0] = -9999.0;
					newpos[1] = -9999.0;
					newpos[2] = -9999.0;
					TeleportEntity(other, newpos, NULL_VECTOR, NULL_VECTOR);
				}
			}
		}
	}
}

// When starting to touch another entity
public Action:OnStartTouch(entity, other)
{
	if(other == entity){return;}
	
	if(other > 0 && other <= MaxClients+1)
	{
		if(IsPlayerAlive(entity))
		{
			decl Float:cpos[3], Float:vpos[3], Float:vmax[3];
			GetClientAbsOrigin(entity, cpos);
			GetClientAbsOrigin(other, vpos);
			GetEntPropVector(other, Prop_Send, "m_vecMaxs", vmax);
			
			new Float:vheight, Float:heightdiff;
			vheight = vmax[2];
			heightdiff = cpos[2] - vpos[2];
			
			if(heightdiff > vheight)
			{
				if(GetClientTeam(entity) != GetClientTeam(other)
				&& IsBounce[entity] == false)
				{
					EmitSoundToAll(SOUND_STOMP, entity);
					new Float:force[3], Float:v[3], Float:ang[3];
					GetClientEyeAngles(entity, ang);
					GetEntPropVector(entity, Prop_Data, "m_vecVelocity", v);
					force[0] = v[0];
					force[1] = v[1];
					force[2] = GetConVarFloat(mb_JumpHeight);
					BounceVec[entity] = force;
					IsBounce[entity] = true;
					SteppedOn[entity] = other;
				}
			}
			
			else if(i_UsingPower[entity] == 8 || (i_UsingPower[entity] == 15 && heightdiff <= vheight
			&& i_UsingPower[other] != 4 && i_UsingPower[other] != 8))
			{
				if(GetClientTeam(entity) != GetClientTeam(other)
				&& IsBounce[entity] == false)
				{
					EmitSoundToAll(SOUND_STOMP, entity);
					GetEntPropVector(entity, Prop_Data, "m_vecVelocity", BounceVec[entity]);
					IsBounce[entity] = true;
					SteppedOn[entity] = other;
				}
			}
		}
	}
}

// On Every Game Frame
public OnGameFrame()
{
	new Res[2] = {0,0};
	TotalCoins[0] = 0;
	TotalCoins[1] = 0;
	
	for(new client=1; client <= MaxClients; client++)
	{
		// Check if a team won.
		if(IsValidEntity(client))
		{
			if(IsClientInGame(client) && IsPlayerAlive(client))
			{
				if(RoundWaitTime > 0)
				{
					SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed));
					RoundWaitTime--;
				}
				
				// Coin HUD Sprite
				new Float:pos[3], Float:vel[3];
				new entity = i_HUDSprite[client];
				if(entity > 0 && IsValidEntity(entity))
				{
					GetClientEyePosition(client, pos);
					GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
					pos[2] += 30.0;
					TeleportEntity(entity, pos, NULL_VECTOR, vel);
				}
				
				// Check the winning conditions
				if(RoundWaitTime <= 0)
				{
					if(GetConVarInt(mb_RespawnMax) > 0 && GetConVarInt(mb_GameMode) == 1)
					{
						if(Time[0] <= 0)
						{
							if(GetClientTeam(client) > 1)
								{Res[GetClientTeam(client)-2] += GetConVarInt(mb_RespawnMax) - Respawns[client];}
						}
						
						else if(GetTeamClientCount(2) == 0 || GetTeamClientCount(3) == 0)
						{
							if(GetTeamClientCount(2) != GetTeamClientCount(3))
							{
								new team = GetTeamClientCount(2) > GetTeamClientCount(3) ? 2 : 3;
								ForceTeamWin(team);
							}
							else
							{
								ForceTeamWin(0);
							}
						}
					}
				}
				
				if(Time[GetClientTeam(client)-2] >= 0 && GetConVarInt(mb_GameMode) == 2 && GetClientTeam(client) > 1)
				{
					TotalCoins[GetClientTeam(client)-2] += Coins[client];
				}
				
				// If Using the Lazy Shell Armor
				if(LazyShellArmor[client] == true)
				{
					Frozen[client] = 0;
					if(GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") < GetConVarFloat(mb_MoveSpeed))
					{
						SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed));
					}
				}
			
				// If Frozen
				if(Frozen[client] > 0)
				{
					SetEntityRenderColor(client, 0, 0, 200, 255);
					Frozen[client]--;
					if(Frozen[client] < 1)
					{
						SetEntityRenderColor(client, 255, 255, 255, 255);
						if(GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") < GetConVarFloat(mb_MoveSpeed))
						{
							SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed));
						}
					}
					else
					{
						SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed)*0.33);
					}
				}
				
				// If Shocked
				else if(IsShocked[client] && i_UsingPower[client] != 3)
				{
					SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed)*0.5);
				}
				
				// If Spawn Protected
				if(i_SpawnProtect[client] > 0)
					{i_SpawnProtect[client]--;}
				
				// If Bouncing
				if(IsBounce[client] == true)
				{
					TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, BounceVec[client]);
					IsBounce[client] = false;
				}
				
				if(SteppedOn[client] > -1)
				{
					if(IsClientInGame(SteppedOn[client]))
					{
						new Float:damage = GetConVarFloat(mb_JumpDamage);
						if(i_UsingPower[client] == 4){damage *= 4;}
						if(i_UsingPower[SteppedOn[client]] == 15 && i_UsingPower[client] != 4
						&& i_UsingPower[client] != 8) {damage *= 0.0;}
						if(i_UsingPower[SteppedOn[client]] == 8){damage *= 0.0;}
						if(Invincible[SteppedOn[client]] || i_SpawnProtect[SteppedOn[client]] > 0)
							{damage *= 0.0;}
						if(LazyShellArmor[SteppedOn[client]] == true){damage *= 0.25;}
						if(Lives[SteppedOn[client]] && damage >= GetEntProp(SteppedOn[client], Prop_Send, "m_iHealth"))
						{
							Lives[SteppedOn[client]] -= 1;
							damage *= 0.0;
							SetEntityHealth(SteppedOn[client], 200);
							CPrintToChat(SteppedOn[client], "{crimson}[MB]{default}You have {orange}%i {default}Lives left!", Lives[SteppedOn[client]]);
							Invincible[SteppedOn[client]] = true;
							CreateTimer(3.0, t_EndInv, any:SteppedOn[client]);
						}
						
						if(damage > 0)
						{
							if(Coins[SteppedOn[client]] > 0)
							{
								new c = RoundToCeil(float(Coins[SteppedOn[client]]) * 0.2);
								Coins[SteppedOn[client]] -= c;
								Coins[client] += c;
							}
						}
						
						SDKHooks_TakeDamage(SteppedOn[client], client, client, damage, DMG_CRUSH, -1, NULL_VECTOR, NULL_VECTOR);
						SteppedOn[client] = -1;
					}
				}
			}
		}
	}
	
	// Arena Respawn Count Comparison
	if(GetConVarInt(mb_GameMode) == 1)
	{
		if(Time[0] > 0 && RoundWaitTime <= 0){FrameCount++;}
		if(FrameCount >= SECOND)
		{
			Time[0]--;
			FrameCount = 0;
			if(Time[0] <= 0)
			{
				// Winning Conditions
				if(Res[0] > Res[1]){ForceTeamWin(2);}
				if(Res[0] < Res[1]){ForceTeamWin(3);}
				if(Res[0] == Res[1]){ForceTeamWin(0);}
			}
		}
	}
	
	// Coin Rush Timer Countdown
	else if(TotalCoins[0] != TotalCoins[1])
	{
		if(RoundWaitTime <= 0 && Time[0] > 0 && Time[1] > 0){FrameCount++;}
		if(FrameCount >= SECOND)
		{
			FrameCount = 0;
			TotalCoins[0] > TotalCoins[1] ? Time[0]-- : Time[1]--;
		}
		if(FrameCount % SECOND+1 == (SECOND / 2))
		{
			if(TotalCoins[0] >= TotalCoins[1]*3){Time[0]--;}
			if(TotalCoins[1] >= TotalCoins[0]*3){Time[1]--;}
		}
		
		if(Time[0] <= 0)
		{
			ForceTeamWin(2);
		}
		else if(Time[1] <= 0)
		{
			ForceTeamWin(3);
		}
	}
}

// When the player's Power Up Timer runs out
public Action:t_EndPowerUp(Handle:timer, any:client)
{
	if(IsClientInGame(client))
	{
		switch(i_UsingPower[client])
		{
			case 1:
			{
				TF2_RemoveWeaponSlot(client, 0);
				TF2Items_GiveWeapon(client, 50001);
			}
			case 3, 6, 8: {SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed));}
			case 5: {Floating[client] = false;}
			case 9: {TF2Items_GiveWeapon(client, 50001);}
			case 12:
			{
				TF2_RemoveWeaponSlot(client, 0);
				TF2Items_GiveWeapon(client, 50001);
			}
			case 15:
			{
				TF2_RemoveWeaponSlot(client, 0);
				TF2Items_GiveWeapon(client, 50001);
				SetEntityHealth(client, 200);
			}
		}
		i_UsingPower[client] = 0;
		StopSound(client, 0, SOUND_STARMAN);
		StopSound(client, 0, SOUND_HAMMER);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		CPrintToChat(client, "{crimson}[MB]%t", "mbEndPowerUp");
	}
}

// When the user is using a Starman
public Action:t_FlashColors(Handle:timer, any:client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		SetEntityRenderColor(client, GetRandomInt(0, 255),
		GetRandomInt(0, 255), GetRandomInt(0, 255), 255);
	}
}

// When the user is no longer affected by Lightning
public Action:t_FixSpeed(Handle:timer, any:client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client) &&
	GetEntPropFloat(client, Prop_Send, "m_flMaxspeed") < GetConVarFloat(mb_MoveSpeed))
	{
		IsShocked[client] = false;
		SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed));
	}
}

// When the user is no longer affected by Lightning
public Action:t_ForceDefaultSpeed(Handle:timer, any:client)
{
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		SetEntPropFloat(client, Prop_Send, "m_flMaxspeed", GetConVarFloat(mb_MoveSpeed));
	}
}

// When the user is done being invincible after losing a life
public Action:t_EndInv(Handle:timer, any:client)
{
	if(IsClientInGame(client))
	{
		Invincible[client] = false;
	}
}

// When the user's Lazy Shell wears out
public Action:t_EndArmor(Handle:timer, any:client)
{
	if(IsClientInGame(client))
	{
		LazyShellArmor[client] = false;
	}
}

public Handle_VoteMenu(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if(action == MenuAction_VoteEnd)
	{
		new String:mode[4];
		GetMenuItem(menu, param1, mode, sizeof(mode));
		ServerCommand("sm_mb_gamemode %s", mode);
	}
}

InitVars(client)
{
	//LoadSong[client] = false;
	//i_SongMute[client] = false;
	i_SpawnProtect[client] = 0;
	i_PowerUp[client] = 0;
	i_UsingPower[client] = 0;
	i_Hints[client] = true;
	Jumping[client] = false;
	AirJumping[client] = false;
	JumpTicks[client] = 0;
	IsSprint[client] = false;
	CheckSprint[client] = 0;
	JumpHold[client] = false;
	IsBounce[client] = false;
	IsShocked[client] = false;
	SteppedOn[client] = -1;
	Floating[client] = false;
	Frozen[client] = 0;
	Lives[client] = 0;
	Coins[client] = 0;
	Invincible[client] = false;
	LazyShellArmor[client] = false;
	Respawns[client] = 0;
}

// Cast a Gamemode VoteGameMode
VoteGameMode()
{
	if(IsVoteInProgress())
	{
		return;
	}
	
	new Handle:menu = CreateMenu(Handle_VoteMenu);
	new String:translatemenu[64];
	// Gamemode Title
	Format(translatemenu, sizeof(translatemenu), "%t", "Which game mode should be next?");
	SetMenuTitle(menu, translatemenu);
	// Map's Game Mode
	Format(translatemenu, sizeof(translatemenu), "%t", "Map's game mode");
	AddMenuItem(menu, "0", translatemenu);
	// Battle Arena
	Format(translatemenu, sizeof(translatemenu), "%t", "Battle Arena");
	AddMenuItem(menu, "1", translatemenu);
	// Coin Rush
	Format(translatemenu, sizeof(translatemenu), "%t", "Coin Rush");
	AddMenuItem(menu, "2", translatemenu);
	SetMenuExitButton(menu, false);
	VoteMenuToAll(menu, 10, VOTEFLAG_NO_REVOTES);
}

// Pull Up the Help Menu
Handle:BuildHelpMenu()
{
	new String:translatemenu[128];
	new Handle:menu = CreateMenu(Menu_ShowHelp);
	Format(translatemenu, sizeof(translatemenu), "%t", "Jumping");
	AddMenuItem(menu, "Jumping", translatemenu);
	//
	Format(translatemenu, sizeof(translatemenu), "%t", "Stomping");
	AddMenuItem(menu, "Stomping", translatemenu);
	//
	Format(translatemenu, sizeof(translatemenu), "%t", "Sprinting");
	AddMenuItem(menu, "Sprinting", translatemenu);
	//
	Format(translatemenu, sizeof(translatemenu), "%t", "Weigh Down");
	AddMenuItem(menu, "Weigh Down", translatemenu);
	//
	Format(translatemenu, sizeof(translatemenu), "%t", "Using Power-Ups");
	AddMenuItem(menu, "Using Power-Ups", translatemenu);
	//
	Format(translatemenu, sizeof(translatemenu), "%t", "Battle Arena");
	AddMenuItem(menu, "Battle Arena", translatemenu);
	//
	Format(translatemenu, sizeof(translatemenu), "%t", "Coin Rush");
	AddMenuItem(menu, "Coin Rush", translatemenu);
	for(new i=0; i<15; i++)
	{
		AddMenuItem(menu, Powers[i], Powers[i]);
	}
	Format(translatemenu, sizeof(translatemenu), "%t", "Mario Bros. Help");
	SetMenuTitle(menu, translatemenu);
	return menu;
}

// Help Menu Handling
public Menu_ShowHelp(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[64], Handle:panel, String:Hint[1024], String:transtitle[64];
		GetMenuItem(menu, param2, info, sizeof(info));
		panel = CreatePanel();
		Format(transtitle, sizeof(transtitle), "%t", info);
		SetPanelTitle(panel, transtitle);
		DrawPanelText(panel, " ");
		if(StrEqual(info, "Jumping"))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_Jumping", param2);
		}
		if(StrEqual(info, "Stomping"))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_Stomping", param2);
		}
		if(StrEqual(info, "Sprinting"))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_Sprinting", param2);
		}
		if(StrEqual(info, "Weigh Down"))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_WeighDown", param2);
		}
		if(StrEqual(info, "Using Power-Ups"))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_UsingPowerUps", param2);
		}
		if(StrEqual(info, "Battle Arena"))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_BattleArena", param2);
		}
		if(StrEqual(info, "Coin Rush"))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_CoinRush", param2);
		}
		if(StrEqual(info, Powers[0]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_FireFlower", param2);
		}
		if(StrEqual(info, Powers[1]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_POWBlock", param2);
		}
		if(StrEqual(info, Powers[2]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_PWing", param2);
		}
		if(StrEqual(info, Powers[3]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_GoombaShoe", param2);
		}
		if(StrEqual(info, Powers[4]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_SuperLeaf", param2);
		}
		if(StrEqual(info, Powers[5]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_BooTheif", param2);
		}
		if(StrEqual(info, Powers[6]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_Mushroom", param2);
		}
		if(StrEqual(info, Powers[7]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_Starman", param2);
		}
		if(StrEqual(info, Powers[8]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_Hammer", param2);
		}
		if(StrEqual(info, Powers[9]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_Thunderbolt", param2);
		}
		if(StrEqual(info, Powers[10]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_GoldenMushroom", param2);
		}
		if(StrEqual(info, Powers[11]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_IceFlower", param2);
		}
		if(StrEqual(info, Powers[12]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_LazyShellArmor", param2);
		}
		if(StrEqual(info, Powers[13]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_1UpMushroom", param2);
		}
		if(StrEqual(info, Powers[14]))
		{
			Format(Hint, sizeof(Hint), "%t", "mbHint_BowserSuit", param2);
		}
		DrawPanelText(panel, Hint);
		SendPanelToClient(panel, param1, Panel_HelpMenu, 5);
		CloseHandle(panel);
	}
}

// Precache Models/Materials
public PrecacheAll()
{
	PrecacheSound(SOUND_STOMP, true);
	PrecacheSound(SOUND_POWBOLT, true);
	PrecacheSound(SOUND_MUSHROOM, true);
	PrecacheSound(SOUND_BOO, true);
	PrecacheSound(SOUND_HAMMER, true);
	PrecacheSound(SOUND_STARMAN, true);
	PrecacheSound(SOUND_1UP, true);
	PrecacheSound(SOUND_BOWSER, true);
	PrecacheSound(SOUND_COIN, true);
	//PrecacheSound(MUSIC_1, true);
	//PrecacheSound(MUSIC_2, true);
	//PrecacheSound(MUSIC_3, true);
	//PrecacheSound(MUSIC_4, true);
	//PrecacheSound(MUSIC_5, true);
	//PrecacheSound(MUSIC_6, true);
	//PrecacheModel(MODEL_POWERUP_TEST, true);
	
	decl String:s_StompPath[128];
	decl String:s_PowboltPath[128];
	decl String:s_MushPath[128];
	decl String:s_BooPath[128];
	decl String:s_HammerPath[128];
	decl String:s_StarPath[128];
	decl String:s_1UpPath[128];
	decl String:s_BowserPath[128];
	//decl String:s_MusicPath[128];
	decl String:s_CoinPath[128];
	decl String:s_SpritePath[128];
	decl String:s_ModelPath[128];
	Format(s_StompPath, sizeof(s_StompPath), "sound/%s", SOUND_STOMP);
	Format(s_PowboltPath, sizeof(s_PowboltPath), "sound/%s", SOUND_POWBOLT);
	Format(s_MushPath, sizeof(s_MushPath), "sound/%s", SOUND_MUSHROOM);
	Format(s_BooPath, sizeof(s_BooPath), "sound/%s", SOUND_BOO);
	Format(s_HammerPath, sizeof(s_HammerPath), "sound/%s", SOUND_HAMMER);
	Format(s_StarPath, sizeof(s_StarPath), "sound/%s", SOUND_STARMAN);
	Format(s_1UpPath, sizeof(s_1UpPath), "sound/%s", SOUND_1UP);
	Format(s_BowserPath, sizeof(s_BowserPath), "sound/%s", SOUND_BOWSER);
	Format(s_CoinPath, sizeof(s_CoinPath), "sound/%s", SOUND_COIN);
	
	AddFileToDownloadsTable(s_StompPath);
	AddFileToDownloadsTable(s_PowboltPath);
	AddFileToDownloadsTable(s_MushPath);
	AddFileToDownloadsTable(s_BooPath);
	AddFileToDownloadsTable(s_HammerPath);
	AddFileToDownloadsTable(s_StarPath);
	AddFileToDownloadsTable(s_1UpPath);
	AddFileToDownloadsTable(s_BowserPath);
	AddFileToDownloadsTable(s_CoinPath);
	
	// Sprites/Models
	new String:ModelExt[6][128] = {"mdl", "dx80.vtx", "dx90.vtx", "phy", "sw.vtx", "vvd"};
	new String:SpriteExt[2][128] = {"vmt", "vtf"};
	
	// Sprite Paths
	PrecacheModel(MODEL_PHONG, true);
	AddFileToDownloadsTable(MODEL_PHONG);
	
	// Coin Normal Map
	Format(s_SpritePath, sizeof(s_SpritePath), "materials/%s_norm.vtf", MODEL_COIN);
	PrecacheModel(s_SpritePath, true);
	AddFileToDownloadsTable(s_SpritePath);
	
	for(new i=0; i<2; i++)
	{
		// Coin Sprite
		Format(s_SpritePath, sizeof(s_SpritePath), "%s.%s", SPRITE_COIN, SpriteExt[i]);
		PrecacheModel(s_SpritePath, true);
		AddFileToDownloadsTable(s_SpritePath);
		
		// Coin Model Textures
		Format(s_SpritePath, sizeof(s_SpritePath), "materials/%s.%s", MODEL_COIN, SpriteExt[i]);
		PrecacheModel(s_SpritePath, true);
		AddFileToDownloadsTable(s_SpritePath);
		
		// Power-Up Model Textures
		for(new j=0; j<14; j++)
		{
			Format(s_SpritePath, sizeof(s_SpritePath), "%s.%s", PowMaterials[j], SpriteExt[i]);
			PrecacheModel(s_SpritePath, true);
			AddFileToDownloadsTable(s_SpritePath);
		}
	}
	
	// Model Paths
	for(new i=0; i<6; i++)
	{
		// Coin Model
		Format(s_ModelPath, sizeof(s_ModelPath), "models/%s.%s", MODEL_COIN, ModelExt[i]);
		PrecacheModel(s_ModelPath, true);
		AddFileToDownloadsTable(s_ModelPath);
		
		// Power-Up Models
		for(new j=0; j<15; j++)
		{
			Format(s_ModelPath, sizeof(s_ModelPath), "%s.%s", PowModels[j], ModelExt[i]);
			PrecacheModel(s_ModelPath, true);
			AddFileToDownloadsTable(s_ModelPath);
		}
	}
	
	// Music Files
	//for(new i = 1; i <= 6; i++)
	//{
	//	Format(s_MusicPath, sizeof(s_MusicPath), "sound/mariobros/songmb_%i.wav", i);
	//	AddFileToDownloadsTable(s_MusicPath);
	//}
}

// Draws a HUD on the screen for a specific player.
public DrawHUD(client)
{
	// Set some data and Draw the HUD if the player is alive.
	ClearSyncHud(client, mb_HUD);
	ClearSyncHud(client, mb_HUD2);
	ClearSyncHud(client, mb_HUD3);
	ClearSyncHud(client, mb_HUD4);
	
	new String:Seconds[2][4] = {"0","0"}, Float:X, Float:Y, String:Logo[1024];
	new R, G, B;
	
	// Life Count
	if(GetConVarInt(mb_GameMode) == 0)
	{
		SetHudTextParams(0.85, 0.7, 3.0, 0, 255, 0, 255);
		ShowSyncHudText(client, mb_HUD, "%t", "Lives_HUD", Lives[client]);
	}
	
	if(GetConVarInt(mb_GameMode) == 1)
	{
		SetHudTextParams(0.85, 0.7, 3.0, 0, 255, 0, 255);
		ShowSyncHudText(client, mb_HUD, "%t", "Lives_Respawn_HUD", Lives[client], GetConVarInt(mb_RespawnMax) - Respawns[client]);
	
		if(Time[0] % 60 < 10){Format(Seconds[0], 4, "0%i", Time[0] % 60);}
		else {IntToString(Time[0] % 60, Seconds[0], 4);}
		SetHudTextParams(-1.0, 0.2, 3.0, 255, 255, 0, 255);
		ShowSyncHudText(client, mb_HUD3, "%t", "TimeLeft_HUD", Time[0]/60, Seconds[0]);
	}
	
	// Add Coins and Timer
	else if(GetConVarInt(mb_GameMode) == 2)
	{
		SetHudTextParams(0.85, 0.7, 3.0, 0, 255, 0, 255);
		ShowSyncHudText(client, mb_HUD, "%t", "Lives_Coins_HUD", Lives[client], Coins[client]);
		
		for(new i = 0; i < 2; i++)
		{
			if(Time[i] % 60 < 10){Format(Seconds[i], 4, "0%i", Time[i] % 60);}
			else {IntToString(Time[i] % 60, Seconds[i], 4);}
		}
		SetHudTextParams(-1.0, 0.2, 3.0, 255, 255, 0, 255);
		ShowSyncHudText(client, mb_HUD3, "%t", "RED_and_BLU_Coins_HUD", TotalCoins[0], Time[0]/60, Seconds[0], TotalCoins[1], Time[1]/60, Seconds[1]);
	}
	
	// Power Up Name
	SetHudTextParams(0.85, 0.75, 3.0, 128, 128, 128, 255);
	if(i_PowerUp[client] > 0)
	{
		ShowSyncHudText(client, mb_HUD2, "%t", "Power_Up_HUD_List", Powers[i_PowerUp[client]-1]);
	}
	else
	{
		ShowSyncHudText(client, mb_HUD2, "%t", "Power_Up_None_HUD");
	}
	
	// Logo
	GetConVarString(mb_HUDLogo, Logo, sizeof(Logo));
	if(strlen(Logo) > 0)
	{
		X = GetConVarFloat(mb_HUD_X);
		Y = GetConVarFloat(mb_HUD_Y);
		R = GetConVarInt(mb_HUDLogo_Red);
		G = GetConVarInt(mb_HUDLogo_Grn);
		B = GetConVarInt(mb_HUDLogo_Blu);
		SetHudTextParams(X, Y, 3.0, R, G, B, 255);
		ShowSyncHudText(client, mb_HUD4, Logo);
	}
	
	// If you're alive
	if(IsPlayerAlive(client))
	{
		// Coin Sprite
		new String:Sprite[255];
		new Float:pos[3], ent;
		
		if(Coins[client] > 0 && GetConVarInt(mb_GameMode) == 2 &&
		!TF2_IsPlayerInCondition(client, TFCond_Stealthed))
		{
			if(Coins[client] >= GetConVarInt(mb_CoinLimitGlow))
			{
				SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1, 1);
			}
			else
			{
				SetEntProp(client, Prop_Send, "m_bGlowEnabled", 0, 1);
			}
			
			GetClientEyePosition(client, pos);
			pos[2] += 30.0;
			
			ent = CreateEntityByName("env_sprite");
			SetEntProp(ent, Prop_Send, "m_hOwnerEntity", client);
			
			if(ent != -1)
			{
				i_HUDSprite[client] = ent;
				Format(Sprite, sizeof(Sprite), "%s.vmt", SPRITE_COIN);
				
				DispatchKeyValue(ent, "model", Sprite);
				DispatchKeyValue(ent, "classname", "env_sprite");
				DispatchKeyValue(ent, "spawnflags", "1");
				DispatchKeyValue(ent, "scale", "0.02");
				DispatchKeyValue(ent, "rendermode", "1");
				DispatchKeyValue(ent, "rendercolor", "255 255 255");
				DispatchSpawn(ent);
				SetEntityMoveType(ent, MOVETYPE_NOCLIP);
				SetEntityRenderColor(ent, 255, 255, 255, 100);
				TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
				
				new String:AddOutput[100];
				Format(AddOutput, sizeof(AddOutput), "OnUser1 !self:kill::%0.2f:-1", 0.2);
				SetVariantString(AddOutput);
				AcceptEntityInput(ent, "AddOutput");
				AcceptEntityInput(ent, "FireUser1");
			}
		}
	}
}

// Copied straight out of VSH. Sorry.
public ForceTeamWin(team)
{
	new ent = FindEntityByClassname(-1, "team_control_point_master");
	if (ent == -1)
	{
		ent = CreateEntityByName("team_control_point_master");
		DispatchSpawn(ent);
		AcceptEntityInput(ent, "Enable");
	}
	SetVariantInt(team);
	AcceptEntityInput(ent, "SetWinner");
}

public Action:DTimer_RespawnAmmo(Handle:timer, Handle:pack)
{
	new Float:newpos[3], entity, String:entclass[255], String:path[255];
	ResetPack(pack);
	entity = ReadPackCell(pack);
	newpos[0] = ReadPackFloat(pack);
	newpos[1] = ReadPackFloat(pack);
	newpos[2] = ReadPackFloat(pack);
	
	TeleportEntity(entity, newpos, NULL_VECTOR, NULL_VECTOR);
	
	new R = GetRandomInt(1, 100);
	GetEntityClassname(entity, entclass, sizeof(entclass));
	if(StrEqual(entclass, "item_ammopack_small"))
	{
		if(R <= 100){Format(path, sizeof(path), "%s.mdl", PowModels[Common[GetRandomInt(0, 4)]-1]);}
		if(R <= 35){Format(path, sizeof(path), "%s.mdl", PowModels[Uncommon[GetRandomInt(0, 4)]-1]);}
		if(R <= 10){Format(path, sizeof(path), "%s.mdl", PowModels[Rare[GetRandomInt(0, 4)]-1]);}
	}
	
	if(StrEqual(entclass, "item_ammopack_medium"))
	{
		if(R <= 100){Format(path, sizeof(path), "%s.mdl", PowModels[Common[GetRandomInt(0, 4)]-1]);}
		if(R <= 50){Format(path, sizeof(path), "%s.mdl", PowModels[Uncommon[GetRandomInt(0, 4)]-1]);}
		if(R <= 15){Format(path, sizeof(path), "%s.mdl", PowModels[Rare[GetRandomInt(0, 4)]-1]);}
	}
	
	if(StrEqual(entclass, "item_ammopack_full"))
	{
		if(R <= 100){Format(path, sizeof(path), "%s.mdl", PowModels[Common[GetRandomInt(0, 4)]-1]);}
		if(R <= 65){Format(path, sizeof(path), "%s.mdl", PowModels[Uncommon[GetRandomInt(0, 4)]-1]);}
		if(R <= 20){Format(path, sizeof(path), "%s.mdl", PowModels[Rare[GetRandomInt(0, 4)]-1]);}
	}
	
	DispatchKeyValue(entity, "powerup_model", path);
	DispatchSpawn(entity);
}

public Action:DTimer_RespawnPowerUp(Handle:timer, Handle:pack)
{
	new Float:pos[3], entity, String:Power[16], String:ModelName[255];
	ResetPack(pack);
	entity = ReadPackCell(pack);
	pos[0] = ReadPackFloat(pack);
	pos[1] = ReadPackFloat(pack);
	pos[2] = ReadPackFloat(pack);
	ReadPackString(pack, Power, sizeof(Power));
	
	if(IsValidEntity(entity))
	{
		if(StringToInt(Power) > 0 && StringToInt(Power) <= 15)
		{
			Format(ModelName, sizeof(ModelName), "%s.mdl", PowModels[StringToInt(Power) - 1]);
			DispatchKeyValue(entity, "powerup_model", ModelName);
		}
		else if(StringToInt(Power) == 0)
		{
			Format(ModelName, sizeof(ModelName), "%s.mdl", PowModels[GetRandomInt(0, 14)]);
			DispatchKeyValue(entity, "powerup_model", ModelName);
		}
		else
		{
			DispatchKeyValue(entity, "powerup_model", MODEL_POWERUP_TEST);
		}
		TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
	}
}

public Action:t_HUD(Handle:timer, any:client)
{
	if(IsValidEntity(client))
	{
		if(IsClientInGame(client))
		{
			i_HUDSprite[client] = -1;
			if(IsPlayerAlive(client))
			{
				DrawHUD(client);
			}
			CreateTimer(0.1, t_HUD, any:client);
		}
	}
}

public Action:t_CheckPlayer(Handle:timer, any:client)
{
	if(client <= MaxClients && client > 0)
	{
		if(IsClientInGame(client))
		{
			CreateTimer(0.1, t_HUD, any:client);
		}
	}
}

// On Entity Created
// Used for Map-based Ammo Packs.
public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname, "item_ammopack_small"))
	{
		new String:EntName[64], i, PowerUp, String:ns[4] = "x", String:ModelName[255];
		GetEntPropString(entity, Prop_Data, "m_iName", EntName, sizeof(EntName));
		if(StrContains(EntName, "mb_powerspawn", false) > -1)
		{
			for(i = 15; i>0; i--)
			{
				IntToString(i, ns, sizeof(ns));
				if(StrContains(EntName, ns, false) > -1)
				{
					PowerUp = i;
					break;
				}
			}
			
			if(PowerUp > 0 && PowerUp <= 15)
			{
				Format(ModelName, sizeof(ModelName), "%s.mdl", PowModels[PowerUp-1]);
				DispatchKeyValue(entity, "powerup_model", MODEL_POWERUP_TEST);
			}
			else if(PowerUp == 0)
			{
				Format(ModelName, sizeof(ModelName), "%s.mdl", PowModels[GetRandomInt(0, 14)]);
				DispatchKeyValue(entity, "powerup_model", MODEL_POWERUP_TEST);
			}
			else{DispatchKeyValue(entity, "powerup_model", MODEL_POWERUP_TEST);}
		}
	}
}

// Spawn Fixed Power-Ups
public SpawnFixedPowerUps()
{
	new index = -1, String:EntName[64], String:PowerName[64], Float:pos[3], String:ns[16], i, String:path[255];
	while((index = FindEntityByClassname(index, "info_target")) != -1)
	{
		GetEntPropString(index, Prop_Data, "m_iName", EntName, sizeof(EntName));
		if(StrContains(EntName, "mb_powerspawn", false) > -1)
		{
			ns = "x";
			new entity = CreateEntityByName("item_ammopack_small");
			if(entity != -1)
			{
				for(i = 15; i>0; i--)
				{
					IntToString(i, ns, sizeof(ns));
					if(StrContains(EntName, ns, false) > -1)
					{
						break;
					}
					else
					{
						ns = "x";
					}
				}
				
				GetEntPropVector(index, Prop_Data, "m_vecOrigin", pos);
				Format(PowerName, sizeof(PowerName), "mb_powerup %s", ns);
				if(StrEqual(ns, "x"))
				{
					Format(path, sizeof(path), "%s.mdl", PowModels[GetRandomInt(0, 14)]);
					DispatchKeyValue(entity, "powerup_model", path);
				}
				else if(StringToInt(ns) > 0 && StringToInt(ns) <= 15)
				{
					Format(path, sizeof(path), "%s.mdl", PowModels[StringToInt(ns)-1]);
					DispatchKeyValue(entity, "powerup_model", path);
				}
				DispatchKeyValue(entity, "targetname", PowerName);
				DispatchSpawn(entity);
				TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
				SetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
			}
		}
		
		if(StrContains(EntName, "mb_coinspawn", false) > -1 && GetConVarInt(mb_GameMode) == 2)
		{
			new entity = CreateEntityByName("item_ammopack_small");
			if(entity != -1)
			{
				GetEntPropVector(index, Prop_Data, "m_vecOrigin", pos);
				Format(path, sizeof(path), "models/%s.mdl", MODEL_COIN);
				DispatchKeyValue(entity, "powerup_model", path);
				DispatchKeyValue(entity, "targetname", "mb_coin");
				DispatchKeyValue(entity, "max_health", "1");
				DispatchSpawn(entity);
				TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
				SetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
			}
		}
	}
	
	// Find Normal Ammopacks
	while((index = FindEntityByClassname(index, "item_ammopack_small")) != -1)
	{
		GetEntPropString(index, Prop_Data, "m_iName", EntName, sizeof(EntName));
		if(StrContains(EntName, "mb_powerup", false) == -1 &&
		StrContains(EntName, "mb_coin", false) == -1)
		{
			new R = GetRandomInt(1, 100);
			if(R <= 100){Format(path, sizeof(path), "%s.mdl", PowModels[Common[GetRandomInt(0, 4)]-1]);}
			if(R <= 35){Format(path, sizeof(path), "%s.mdl", PowModels[Uncommon[GetRandomInt(0, 4)]-1]);}
			if(R <= 10){Format(path, sizeof(path), "%s.mdl", PowModels[Rare[GetRandomInt(0, 4)]-1]);}
			DispatchKeyValue(index, "powerup_model", path);
			DispatchSpawn(index);
		}
	}
	
	while((index = FindEntityByClassname(index, "item_ammopack_medium")) != -1)
	{
		new R = GetRandomInt(1, 100);
		if(R <= 100){Format(path, sizeof(path), "%s.mdl", PowModels[Common[GetRandomInt(0, 4)]-1]);}
		if(R <= 50){Format(path, sizeof(path), "%s.mdl", PowModels[Uncommon[GetRandomInt(0, 4)]-1]);}
		if(R <= 15){Format(path, sizeof(path), "%s.mdl", PowModels[Rare[GetRandomInt(0, 4)]-1]);}
		DispatchKeyValue(index, "powerup_model", path);
		DispatchSpawn(index);
	}
	
	while((index = FindEntityByClassname(index, "item_ammopack_full")) != -1)
	{
		new R = GetRandomInt(1, 100);
		if(R <= 100){Format(path, sizeof(path), "%s.mdl", PowModels[Common[GetRandomInt(0, 4)]-1]);}
		if(R <= 65){Format(path, sizeof(path), "%s.mdl", PowModels[Uncommon[GetRandomInt(0, 4)]-1]);}
		if(R <= 20){Format(path, sizeof(path), "%s.mdl", PowModels[Rare[GetRandomInt(0, 4)]-1]);}
		DispatchKeyValue(index, "powerup_model", path);
		DispatchSpawn(index);
	}
}

// Fixed Power-Up Check
public bool:FixedPowerUpCheck(entity, other)
{
	// Fixed Power-Up Check
	new String:entclass[128], String:powername[128], String:ns[16] = "x";
	GetEntityClassname(other, entclass, sizeof(entclass));
	
	if(StrEqual(entclass, "item_ammopack_small"))
	{
		new String:EntName[64];
		GetEntPropString(other, Prop_Data, "m_iName", EntName, sizeof(EntName));
		
		// Coin
		if(StrContains(EntName, "mb_coin", false) > -1)
		{
			Coins[entity] += GetEntProp(other, Prop_Data, "m_iMaxHealth");
			EmitSoundToAll(SOUND_COIN, entity);
			AcceptEntityInput(other, "Kill");
			return true;
		}
		
		// Power Up
		if(StrContains(EntName, "mb_powerup", false) > -1)
		{
			if(i_PowerUp[entity] == 0)
			{
				new i;
				for(i = 15; i>0; i--)
				{
					IntToString(i, ns, sizeof(ns));
					if(StrContains(EntName, ns, false) > -1)
					{
						i_PowerUp[entity] = i;
						break;
					}
					else
					{
						ns = "x";
					}	
				}
				
				if(StrEqual(ns, "x"))
				{
					i_PowerUp[entity] = GetRandomInt(1, 15);
				}
				
				if(i_PowerUp[entity] > 0)
				{
					powername = Powers[i_PowerUp[entity]-1];
					CPrintToChat(entity, "{crimson}[MB]{default}Power Up! Obtained: {orange}%s!", powername);
				
					new Float:newpos[3], Handle:pack;
					GetEntPropVector(other, Prop_Data, "m_vecOrigin", newpos);
					
					CreateDataTimer(GetConVarFloat(mb_PickupDelay) / SquareRoot(float(GetClientCount()+1)), DTimer_RespawnPowerUp, pack);
					WritePackCell(pack, other);
					WritePackFloat(pack, newpos[0]);
					WritePackFloat(pack, newpos[1]);
					WritePackFloat(pack, newpos[2]);
					WritePackString(pack, ns);
					
					newpos[0] = -9999.0;
					newpos[1] = -9999.0;
					newpos[2] = -9999.0;
					TeleportEntity(other, newpos, NULL_VECTOR, NULL_VECTOR);
					return true;
				}
			}
		}
	}
	return false;
}

// Whenever you change the gamemode.
public OnGameModeChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	switch(StringToInt(newVal))
	{
		case 1:
		{
			ServerCommand("sv_hudhint_sound 0");
			ServerCommand("tf_weapon_criticals 0");
			ServerCommand("mp_idlemaxtime 1000000");
			ServerCommand("mp_restartgame_immediate 1");
			ServerCommand("mp_teams_unbalance_limit 0");
		}
		case 2:
		{
			ServerCommand("sv_hudhint_sound 0");
			ServerCommand("tf_weapon_criticals 0");
			ServerCommand("mp_idlemaxtime 60");
			ServerCommand("mp_restartgame_immediate 1");
			ServerCommand("mp_teams_unbalance_limit 1");
		}
		
		// Normal Game
		default:
		{
			if(StringToInt(newVal) != 0){SetConVarInt(cvar, 0);}
			else if(StringToInt(newVal) == 0 && StringToInt(oldVal) != StringToInt(newVal))
			{
				ServerCommand("sv_hudhint_sound 0");
				ServerCommand("tf_weapon_criticals 0");
				ServerCommand("mp_idlemaxtime 60");
				ServerCommand("mp_restartgame_immediate 1");
				ServerCommand("mp_teams_unbalance_limit 1");
			}
		}
	}
}

// Disable/Enable Points
ToggleCaps(bool:newstate)
{
	new i, ent = 0, String:input[8];
	if(newstate){input = "Enable";}
	else {input = "Disable";}
	new String:targets[8][64] = {"team_control_point_master","team_control_point","trigger_capture_area","item_teamflag","func_capturezone","func_regenerate","func_respawnroom","func_respawnroomvisualizer"};
	for(i=0; i<8; i++)
	{
		while((ent = FindEntityByClassname(ent, targets[i])) != -1)
		{
			AcceptEntityInput(ent, input);
		}
	}
}

// Shuffles Power-Up Models
public Action:t_ShufflePowers(Handle:timer)
{
	if(timer == INVALID_HANDLE){return Plugin_Stop;}

	new index = -1, String:ns[4], String:path[255], i;
	while((index = FindEntityByClassname(index, "item_ammopack_small")) != -1)
	{
		new String:EntName[64];
		GetEntPropString(index, Prop_Data, "m_iName", EntName, sizeof(EntName));
		if(StrContains(EntName, "mb_powerup", false) > -1)
		{
			for(i = 15; i>0; i--)
			{
				IntToString(i, ns, sizeof(ns));
				if(StrContains(EntName, ns, false) > -1)
				{
					break;
				}
				else
				{
					ns = "x";
				}	
			}
			
			if(StrEqual(ns, "x"))
			{
				Format(path, sizeof(path), "%s.mdl", PowModels[GetRandomInt(0, 14)]);
				DispatchKeyValue(index, "powerup_model", path);
				DispatchSpawn(index);
			}
		}
	}
	
	return Plugin_Continue;
}

// Run Check
public Action:t_SprintSet(Handle:timer, any:client)
{
	if(IsValidEntity(client))
	{
		CheckSprint[client] = 0;
	}
}