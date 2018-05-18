#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <smlib>
#include <colors>
#include <clientprefs>
#include <tetris>
#include <emitsoundany>

#define PLUGIN_VERSION "1.1"

#define PREFIX "{green}Tetris {default}> {lightgreen}"

#define FIELD_X 10
#define FIELD_Y 16

#define COORD_X 0
#define COORD_Y 1

#define CHAR_OBJPLACED "█"
#define CHAR_CURRENTOBJ "█" // ▒ is hard to see..
#define CHAR_SPACE "░"

#define ROTATE_TICK 16
#define HORIZONTAL_TICK 8
#define DOWN_TICK 4

#define TETRIS_MUSIC "tetris/music_a.mp3"
#define TETRIS_MUSIC_LENGTH 38.6
#define TETRIS_ROTATE "tetris/rotate_block.mp3"
#define TETRIS_PLACE "tetris/place_block.mp3"
#define TETRIS_FULLLINE "tetris/full_line.mp3"
#define TETRIS_LEVELUP "tetris/level_up.mp3"
#define TETRIS_TETRIS "tetris/tetris.mp3"
#define TETRIS_GAMEOVER "tetris/game_over.mp3"

#define BUTTON_FORWARD 0
#define BUTTON_MOVELEFT 1
#define BUTTON_MOVERIGHT 2
#define BUTTON_BACK 3
#define BUTTON_NUM_DEFINES 4

enum TetrisObject
{
	Tetris_None = 0,
	Tetris_Square,
	Tetris_T,
	Tetris_S,
	Tetris_Z,
	Tetris_L,
	Tetris_J,
	Tetris_I
}

enum TetrisRotation
{
	TetrisRotation_None = 0,
	TetrisRotation_0,
	TetrisRotation_90,
	TetrisRotation_180,
	TetrisRotation_270
}

enum TetrisDifficulty
{
	Float:TetrisDifficulty_Easy = 0.4,
	Float:TetrisDifficulty_Normal = 0.3,
	Float:TetrisDifficulty_Hard = 0.1
}

// Game panel
new Handle:g_hPlayerGameThink[MAXPLAYERS+1] = {INVALID_HANDLE,...};
new bool:g_bGameField[MAXPLAYERS+1][FIELD_Y][FIELD_X];
new g_iObjectPosition[MAXPLAYERS+1][2];
new TetrisObject:g_iObjectType[MAXPLAYERS+1] = {Tetris_None,...};
new TetrisObject:g_iNextObjectType[MAXPLAYERS+1] = {Tetris_None,...};
new TetrisRotation:g_iObjectRotation[MAXPLAYERS+1] = {TetrisRotation_None,...};
new g_iTicks[MAXPLAYERS+1];

new g_iButtons[MAXPLAYERS+1];
new g_iButtonsPressed[MAXPLAYERS+1][BUTTON_NUM_DEFINES];

new g_iLinesCleared[MAXPLAYERS+1];
new g_iScore[MAXPLAYERS+1];
new g_iLevel[MAXPLAYERS+1] = {1,...};
new g_iHardDrop[MAXPLAYERS+1];
new g_iCombo[MAXPLAYERS+1];
new TetrisDifficulty:g_fDifficulty[MAXPLAYERS+1] = {TetrisDifficulty_Easy,...};
new Handle:g_hDrawInfoPanel[MAXPLAYERS+1] = {INVALID_HANDLE,...};
new Handle:g_hPlayBackgroundMusic[MAXPLAYERS+1] = {INVALID_HANDLE,...};

// Sound preferences
new Handle:g_hCookieNoSound;
new bool:g_bEnableSound[MAXPLAYERS+1] = {true,...};
new Handle:g_hCookieNoMusic;
new bool:g_bEnableMusic[MAXPLAYERS+1] = {true,...};

// Score database
new Handle:g_hDatabase;
new bool:g_bPlayerHasHighscore[MAXPLAYERS+1];
new g_iPlayerHighscore[MAXPLAYERS+1][3];

// ConVars
new Handle:g_hCVDisableHardDrop;
new Handle:g_hCVDisableSounds;
new Handle:g_hCVOnlyDead;
new Handle:g_hCVDisableStats;
new bool:g_bDisableSounds = false;
new bool:g_bDisableHardDrop = false;
new bool:g_bOnlyDead = false;
new bool:g_bDisableStats = false;

// Game quirks
new bool:g_bIsCSGO = false;

// API
new Handle:g_hfwdOnTetrisGameEnd;

public Plugin:myinfo = 
{
	name = "Tetris",
	author = "Jannik \"Peace-Maker\" Hartung",
	description = "Tetris minigame in a panel",
	version = PLUGIN_VERSION,
	url = "http://www.wcfan.de/"
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	RegPluginLibrary("tetris");
	CreateNative("IsClientInTetrisGame", Native_IsClientInTetrisGame);
	return APLRes_Success;
}

public OnPluginStart()
{
	new Handle:hVersion = CreateConVar("sm_tetris_version", PLUGIN_VERSION, "Tetris minigame version", FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_DONTRECORD);
	if(hVersion != INVALID_HANDLE)
		SetConVarString(hVersion, PLUGIN_VERSION);
	
	g_hCVDisableHardDrop = CreateConVar("sm_tetris_disableharddrop", "0", "Disable hard dropping the tetrimino instantly to the floor with the spacebar?", _, true, 0.0, true, 1.0);
	g_hCVDisableSounds = CreateConVar("sm_tetris_disablesounds", "0", "Disable all tetris sounds?", _, true, 0.0, true, 1.0);
	g_hCVOnlyDead = CreateConVar("sm_tetris_onlydead", "0", "Player has to be dead to play tetris?", _, true, 0.0, true, 1.0);
	g_hCVDisableStats = CreateConVar("sm_tetris_disableinfopanel", "0", "Disable showing stats like score/cleared bars in a (Key)Hint panel while playing?", _, true, 0.0, true, 1.0);
	
	HookConVarChange(g_hCVDisableHardDrop, ConVar_OnChange);
	HookConVarChange(g_hCVDisableSounds, ConVar_OnChange);
	HookConVarChange(g_hCVOnlyDead, ConVar_OnChange);
	HookConVarChange(g_hCVDisableStats, ConVar_OnChange);
	
	RegConsoleCmd("sm_tetris", Cmd_Tetris, "Opens the tetris minigame.");
	
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	
	g_hfwdOnTetrisGameEnd = CreateGlobalForward("OnTetrisGameEnd", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	
	g_hCookieNoSound = RegClientCookie("tetris_nosound", "Disable sound effects in tetris?", CookieAccess_Public);
	g_hCookieNoMusic = RegClientCookie("tetris_nomusic", "Disable background music in tetris?", CookieAccess_Public);
	
	g_bIsCSGO = GetEngineVersion() == Engine_CSGO;
	
	SQL_TConnect(SQL_OnDatabaseConnected, (SQL_CheckConfig("tetris")?"tetris":"storage-local"));
	
	AutoExecConfig(true);
}

public OnConfigsExecuted()
{
	g_bDisableSounds = GetConVarBool(g_hCVDisableSounds);
	g_bDisableHardDrop = GetConVarBool(g_hCVDisableHardDrop);
	g_bOnlyDead = GetConVarBool(g_hCVOnlyDead);
	g_bDisableStats = GetConVarBool(g_hCVDisableStats);
}

public OnMapStart()
{
	if(g_bDisableSounds)
		return;
	
	File_AddToDownloadsTable("sound/tetris");
	PrecacheSoundAny(TETRIS_MUSIC, true);
	PrecacheSoundAny(TETRIS_ROTATE, true);
	PrecacheSoundAny(TETRIS_PLACE, true);
	PrecacheSoundAny(TETRIS_FULLLINE, true);
	PrecacheSoundAny(TETRIS_LEVELUP, true);
	PrecacheSoundAny(TETRIS_TETRIS, true);
	PrecacheSoundAny(TETRIS_GAMEOVER, true);
}

public OnClientPutInServer(client)
{
	ResetTetrisGame(client);
}

public OnClientAuthorized(client, const String:auth[])
{
	if (!g_hDatabase)
		return;
	
	SQL_TQueryF(g_hDatabase, SQL_GetClientHighscores, GetClientUserId(client), DBPrio_Normal, "SELECT score_easy, score_normal, score_hard FROM tetris_players WHERE steamid = \"%s\";", auth);
}

public OnClientDisconnect(client)
{
	ResetTetrisGame(client);
	g_iButtons[client] = 0;
	g_fDifficulty[client] = TetrisDifficulty_Easy;
	g_bEnableSound[client] = true;
	g_bEnableMusic[client] = true;
	g_bPlayerHasHighscore[client] = false;
	for(new i=0;i<3;i++)
		g_iPlayerHighscore[client][i] = 0;
}

public OnClientCookiesCached(client)
{
	decl String:sBuffer[4];
	GetClientCookie(client, g_hCookieNoSound, sBuffer, sizeof(sBuffer));
	if(StrEqual(sBuffer, "1"))
		g_bEnableSound[client] = false;
	else
		g_bEnableSound[client] = true;
	
	GetClientCookie(client, g_hCookieNoMusic, sBuffer, sizeof(sBuffer));
	if(StrEqual(sBuffer, "1"))
		g_bEnableMusic[client] = false;
	else
		g_bEnableMusic[client] = true;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(g_hPlayerGameThink[client] != INVALID_HANDLE)
	{
		// Let it fall down completely.
		// Hard Drop!
		if( (buttons & (IN_JUMP|IN_USE)) && !(g_iButtons[client] & (IN_JUMP|IN_USE)) && !g_bDisableHardDrop)
		{
			new bool:bGameOver = false;
			while(MoveCurrentObjectDown(client, bGameOver))
			{
				g_iHardDrop[client]++;
			}
			DrawTetrisGameField(client, bGameOver);
		}
		
		if(buttons & IN_FORWARD)
		{
			// Handle rotation
			if((g_iButtonsPressed[client][BUTTON_FORWARD] == 0
			|| g_iButtonsPressed[client][BUTTON_FORWARD] > (ROTATE_TICK-1) && (g_iButtonsPressed[client][BUTTON_FORWARD] % ROTATE_TICK) == 0)
			&& RotateObject(client))
			{
				if(!g_bDisableSounds && g_bEnableSound[client])
					EmitSoundToClientAny(client, TETRIS_ROTATE);
				DrawTetrisGameField(client, false);
			}
			g_iButtonsPressed[client][BUTTON_FORWARD]++;
		}
		else if( (buttons & IN_MOVELEFT) || (buttons & IN_MOVERIGHT) )
		{
			new bool:bGameField[FIELD_Y][FIELD_X], bool:bDoIt = false;
			
			// Handle horizontal movement
			new iTempPosition[2];
			iTempPosition = g_iObjectPosition[client];
			if(buttons & IN_MOVELEFT)
			{
				if(g_iButtonsPressed[client][BUTTON_MOVELEFT] == 0
				|| g_iButtonsPressed[client][BUTTON_MOVELEFT] > (HORIZONTAL_TICK-1) && (g_iButtonsPressed[client][BUTTON_MOVELEFT] % HORIZONTAL_TICK) == 0)
				{
					iTempPosition[COORD_X]--;
					bDoIt = true;
				}
				g_iButtonsPressed[client][BUTTON_MOVELEFT]++;
			}
			else
			{
				if(g_iButtonsPressed[client][BUTTON_MOVERIGHT] == 0
				|| g_iButtonsPressed[client][BUTTON_MOVERIGHT] > (HORIZONTAL_TICK-1) && (g_iButtonsPressed[client][BUTTON_MOVERIGHT] % HORIZONTAL_TICK) == 0)
				{
					iTempPosition[COORD_X]++;
					bDoIt = true;
				}
				g_iButtonsPressed[client][BUTTON_MOVERIGHT]++;
			}
			
			// Are we still inside our field?
			if(bDoIt && iTempPosition[COORD_X] >= 0)
			{
				new iMinMax[2];
				GetObjectMinMax(g_iObjectType[client], g_iObjectRotation[client], iMinMax);
				if(iTempPosition[COORD_X]+iMinMax[COORD_X]-1 < FIELD_X)
				{
					// Did we hit anything?
					PutObjectOnGameField(g_iObjectType[client], g_iObjectRotation[client], iTempPosition, bGameField);
					if(!IsObjectColliding(g_bGameField[client], bGameField))
					{
						g_iObjectPosition[client] = iTempPosition;
						DrawTetrisGameField(client, false);
					}
				}
			}
		}

		// Speed it up?
		if( (buttons & IN_BACK) )
		{
			g_iButtonsPressed[client][BUTTON_BACK]++;
			if(g_iButtonsPressed[client][BUTTON_BACK] == 0
			|| g_iButtonsPressed[client][BUTTON_BACK] > (DOWN_TICK-1) && (g_iButtonsPressed[client][BUTTON_BACK] % DOWN_TICK) == 0)
			{
				new bool:bGameOver = false;
				// Soft dropping gives 1 point per line!
				if(MoveCurrentObjectDown(client, bGameOver))
					g_iScore[client]++;
				DrawTetrisGameField(client, bGameOver);
			}
		}
		
		if(!(buttons & IN_FORWARD))
			g_iButtonsPressed[client][BUTTON_FORWARD] = 0;
		if(!(buttons & IN_MOVELEFT))
			g_iButtonsPressed[client][BUTTON_MOVELEFT] = 0;
		if(!(buttons & IN_MOVERIGHT))
			g_iButtonsPressed[client][BUTTON_MOVERIGHT] = 0;
		if(!(buttons & IN_BACK))
			g_iButtonsPressed[client][BUTTON_BACK] = 0;
	}
	g_iButtons[client] = buttons;
	return Plugin_Continue;
}

public Event_OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsClientInTetrisGame(client))
	{
		// Stop the game now. Concentrate on the real game!
		if (g_bOnlyDead && IsPlayerAlive(client))
		{
			PauseTetrisGame(client);
			CPrintToChat(client, "%sYou have to be dead to play Tetris.", PREFIX);
			return;
		}
		
		// Disable any movement
		SetEntProp(client, Prop_Send, "m_fFlags", FL_CLIENT|FL_ATCONTROLS);
		
		if (!g_bDisableSounds)
			StopSoundAny(client, SNDCHAN_AUTO, TETRIS_MUSIC);
		if(!g_bDisableSounds && g_bEnableMusic[client])
			TriggerTimer(g_hPlayBackgroundMusic[client], true);
	}
}

public Action:Cmd_Tetris(client, args)
{
	if(!client)
	{
		ReplyToCommand(client, "Tetris: This command is ingame only.");
		return Plugin_Handled;
	}
	
	DisplayTetrisMainMenu(client);
	return Plugin_Handled;
}

DisplayTetrisMainMenu(client)
{
	new Handle:hMenu = CreateMenu(Menu_MainMenu);
	SetMenuTitle(hMenu, "Tetris: Mainmenu");
	SetMenuExitButton(hMenu, true);
	
	if(g_iObjectType[client] != Tetris_None)
		AddMenuItem(hMenu, "resume", "Resume current game");

	// Stop any running game!
	if(IsClientInTetrisGame(client))
	{
		PauseTetrisGame(client);
	}
	
	AddMenuItem(hMenu, "startnew", "Start new game");
	decl String:sMenu[32];
	switch(g_fDifficulty[client])
	{
		case TetrisDifficulty_Easy:
		{
			Format(sMenu, sizeof(sMenu), "Change difficutly: Easy");
		}
		case TetrisDifficulty_Normal:
		{
			Format(sMenu, sizeof(sMenu), "Change difficutly: Normal");
		}
		case TetrisDifficulty_Hard:
		{
			Format(sMenu, sizeof(sMenu), "Change difficutly: Hard");
		}
	}
	AddMenuItem(hMenu, "difficulty", sMenu);
	
	if(!g_bDisableSounds)
	{
		if(g_bEnableSound[client])
			Format(sMenu, sizeof(sMenu), "Enable sound effects: Yes");
		else
			Format(sMenu, sizeof(sMenu), "Enable sound effects: No");
		AddMenuItem(hMenu, "sound", sMenu);
		
		if(g_bEnableMusic[client])
			Format(sMenu, sizeof(sMenu), "Enable music: Yes");
		else
			Format(sMenu, sizeof(sMenu), "Enable music: No");
			
		AddMenuItem(hMenu, "music", sMenu);
	}
	
	AddMenuItem(hMenu, "", "", ITEMDRAW_SPACER);
	
	AddMenuItem(hMenu, "top5", "View top 5");
	
	AddMenuItem(hMenu, "highscore", "Show your best scores");
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public Menu_MainMenu(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		// Start a new game
		if(StrEqual(info, "startnew"))
		{
			if (g_bOnlyDead && IsPlayerAlive(param1))
			{
				CPrintToChat(param1, "%sYou have to be dead to play Tetris.", PREFIX);
				DisplayTetrisMainMenu(param1);
				return;
			}
		
			// Clear the previous
			ResetTetrisGame(param1);
			
			// Select the first object type
			SelectRandomObject(param1);
			
			g_hPlayerGameThink[param1] = CreateTimer(Float:g_fDifficulty[param1], Timer_PlayerGameThink, GetClientUserId(param1), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			TriggerTimer(g_hPlayerGameThink[param1]);
			
			// The info panel might interfere with other mods.
			if (!g_bDisableStats)
			{
				g_hDrawInfoPanel[param1] = CreateTimer(2.0, Timer_DrawInfoPanel, GetClientUserId(param1), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				TriggerTimer(g_hDrawInfoPanel[param1]);
			}
			
			if(!g_bDisableSounds && g_bEnableMusic[param1])
			{
				g_hPlayBackgroundMusic[param1] = CreateTimer(TETRIS_MUSIC_LENGTH, Timer_PlayBackgroundMusic, GetClientUserId(param1), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				TriggerTimer(g_hPlayBackgroundMusic[param1], true);
			}
			
			// Disable any movement
			SetEntProp(param1, Prop_Send, "m_fFlags", FL_CLIENT|FL_ATCONTROLS);
		}
		// Resume running game
		else if(StrEqual(info, "resume"))
		{
			if (g_bOnlyDead && IsPlayerAlive(param1))
			{
				DisplayTetrisMainMenu(param1);
				CPrintToChat(param1, "%sYou have to be dead to play Tetris.", PREFIX);
				return;
			}
			
			g_hPlayerGameThink[param1] = CreateTimer(Float:g_fDifficulty[param1], Timer_PlayerGameThink, GetClientUserId(param1), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			TriggerTimer(g_hPlayerGameThink[param1]);
			
			// The info panel might interfere with other mods.
			if (!g_bDisableStats)
			{
				g_hDrawInfoPanel[param1] = CreateTimer(2.0, Timer_DrawInfoPanel, GetClientUserId(param1), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				TriggerTimer(g_hDrawInfoPanel[param1]);
			}
			
			if(!g_bDisableSounds && g_bEnableMusic[param1])
			{
				g_hPlayBackgroundMusic[param1] = CreateTimer(TETRIS_MUSIC_LENGTH, Timer_PlayBackgroundMusic, GetClientUserId(param1), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				TriggerTimer(g_hPlayBackgroundMusic[param1], true);
			}
			
			// Disable any movement
			SetEntProp(param1, Prop_Send, "m_fFlags", FL_CLIENT|FL_ATCONTROLS);
		}
		// Change the difficulty
		else if(StrEqual(info, "difficulty"))
		{
			if(g_fDifficulty[param1] == TetrisDifficulty_Easy)
				g_fDifficulty[param1] = TetrisDifficulty_Normal;
			else if(g_fDifficulty[param1] == TetrisDifficulty_Normal)
				g_fDifficulty[param1] = TetrisDifficulty_Hard;
			else if(g_fDifficulty[param1] == TetrisDifficulty_Hard)
				g_fDifficulty[param1] = TetrisDifficulty_Easy;
			
			// Reset the current game.
			ResetTetrisGame(param1);
			DisplayTetrisMainMenu(param1);
		}
		// Disable/Enable sound effects
		else if(StrEqual(info, "sound"))
		{
			g_bEnableSound[param1] = !g_bEnableSound[param1];
			
			if(g_bEnableSound[param1])
				SetClientCookie(param1, g_hCookieNoSound, "0");
			else
				SetClientCookie(param1, g_hCookieNoSound, "1");
			
			DisplayTetrisMainMenu(param1);
		}
		// Disable/Enable background music
		else if(StrEqual(info, "music"))
		{
			g_bEnableMusic[param1] = !g_bEnableMusic[param1];
			
			if(g_bEnableMusic[param1])
				SetClientCookie(param1, g_hCookieNoMusic, "0");
			else
				SetClientCookie(param1, g_hCookieNoMusic, "1");
			
			DisplayTetrisMainMenu(param1);
		}
		// Display the tetris top 5
		else if(StrEqual(info, "top5"))
		{
			if(g_hDatabase == INVALID_HANDLE)
			{
				CPrintToChat(param1, "%sDatabase unavailable. Can't fetch the top 5.", PREFIX);
				DisplayTetrisMainMenu(param1);
			}
			else
			{
				new Handle:hDataPack = CreateDataPack();
				WritePackCell(hDataPack, GetClientUserId(param1));
				WritePackCell(hDataPack, 0);
				ResetPack(hDataPack);
				SQL_TQueryF(g_hDatabase, SQL_FetchTop5, hDataPack, DBPrio_Normal, "SELECT name, score_easy FROM tetris_players WHERE score_easy > 0 ORDER BY score_easy DESC LIMIT 5;");
			}
		}
		// Display player's best times
		else if(StrEqual(info, "highscore"))
		{
			new Handle:hMenu = CreateMenu(Menu_HandleHighscore);
			SetMenuTitle(hMenu, "Tetris: Personal Highscores");
			SetMenuExitBackButton(hMenu, true);
			
			decl String:sMenu[64];
			Format(sMenu, sizeof(sMenu), "Easy: %d", g_iPlayerHighscore[param1][0]);
			AddMenuItem(hMenu, "", sMenu);
			Format(sMenu, sizeof(sMenu), "Normal: %d", g_iPlayerHighscore[param1][1]);
			AddMenuItem(hMenu, "", sMenu);
			Format(sMenu, sizeof(sMenu), "Hard: %d", g_iPlayerHighscore[param1][2]);
			AddMenuItem(hMenu, "", sMenu);
			
			DisplayMenu(hMenu, param1, MENU_TIME_FOREVER);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Menu_HandleHighscore(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		DisplayTetrisMainMenu(param1);
	}
	if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
	{
		DisplayTetrisMainMenu(param1);
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Menu_HandleTop5(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		// Switch to easy top5
		if(StrEqual(info, "easy"))
		{
			new Handle:hDataPack = CreateDataPack();
			WritePackCell(hDataPack, GetClientUserId(param1));
			WritePackCell(hDataPack, 0);
			ResetPack(hDataPack);
			SQL_TQueryF(g_hDatabase, SQL_FetchTop5, hDataPack, DBPrio_Normal, "SELECT name, score_easy FROM tetris_players WHERE score_easy > 0 ORDER BY score_easy DESC LIMIT 5;");
		}
		else if(StrEqual(info, "normal"))
		{
			new Handle:hDataPack = CreateDataPack();
			WritePackCell(hDataPack, GetClientUserId(param1));
			WritePackCell(hDataPack, 1);
			ResetPack(hDataPack);
			SQL_TQueryF(g_hDatabase, SQL_FetchTop5, hDataPack, DBPrio_Normal, "SELECT name, score_normal FROM tetris_players WHERE score_normal > 0 ORDER BY score_normal DESC LIMIT 5;");
		}
		else if(StrEqual(info, "hard"))
		{
			new Handle:hDataPack = CreateDataPack();
			WritePackCell(hDataPack, GetClientUserId(param1));
			WritePackCell(hDataPack, 2);
			ResetPack(hDataPack);
			SQL_TQueryF(g_hDatabase, SQL_FetchTop5, hDataPack, DBPrio_Normal, "SELECT name, score_hard FROM tetris_players WHERE score_hard > 0 ORDER BY score_hard DESC LIMIT 5;");
		}
		else
		{
			DisplayTetrisMainMenu(param1);
		}
	}
	else if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
	{
		DisplayTetrisMainMenu(param1);
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Panel_HandleGame(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		if(param2 == 1 || param2 == 10)
		{
			DisplayTetrisMainMenu(param1);
		}
	}
}

public Action:Timer_PlayerGameThink(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if(!client)
		return Plugin_Stop;
	
	new bool:bGameOver = false;
	
	// Only move the object down each x timer runs
	g_iTicks[client]++;
	if(g_iTicks[client] > 1)
	{
		MoveCurrentObjectDown(client, bGameOver);
		
		g_iTicks[client] = 0;
	}
	
	DrawTetrisGameField(client, bGameOver);
	
	if(bGameOver)
	{
		g_hPlayerGameThink[client] = INVALID_HANDLE;
		return Plugin_Stop;
	}
	
	return Plugin_Continue;
}

public Action:Timer_DrawInfoPanel(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if(!client)
		return Plugin_Stop;
	
	// Generate the next object's preview
	new String:sNextObject[64], String:sCurrentRow[17];
	if (!g_bIsCSGO)
	{
		new iMatrix[4][4];
		GetObjectShape(g_iNextObjectType[client], GetDefaultRotation(g_iNextObjectType[client]), iMatrix);
		for(new y=3;y>=0;y--)
		{
			for(new x=3;x>=0;x--)
			{
				if(iMatrix[y][x] == 1)
				{
					Format(sCurrentRow, sizeof(sCurrentRow), "%s%s", CHAR_CURRENTOBJ, sCurrentRow);
				}
				else
				{
					Format(sCurrentRow, sizeof(sCurrentRow), "%s%s", CHAR_SPACE, sCurrentRow);
				}
			}
			Format(sNextObject, sizeof(sNextObject), "%s%s\n", sNextObject, sCurrentRow);
			Format(sCurrentRow, sizeof(sCurrentRow), "");
		}
	}
	
	new String:sCombo[32];
	if(g_iCombo[client] > 1)
		Format(sCombo, sizeof(sCombo), "Combo: %d\n", g_iCombo[client]);
	
	if (g_bIsCSGO)
		Client_PrintHintText(client, "<u>Tetris Stats</u>\nLevel: <b>%d</b>\tLines: <b>%d</b>\tScore: <b>%d</b>\t%s", g_iLevel[client], g_iLinesCleared[client], g_iScore[client], sCombo);
	else
		Client_PrintKeyHintText(client, "Tetris Stats\n\nLevel: %d\nLines: %d\nScore: %d\n%sNext:\n\n%s", g_iLevel[client], g_iLinesCleared[client], g_iScore[client], sCombo, sNextObject);
	
	return Plugin_Continue;
}

public Action:Timer_PlayBackgroundMusic(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if(!client)
		return Plugin_Stop;
	
	EmitSoundToClientAny(client, TETRIS_MUSIC);
	
	return Plugin_Continue;
}

public SQL_OnDatabaseConnected(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl == INVALID_HANDLE || strlen(error) > 0)
	{
		LogError("Error connecting to database: %s", error);
		return;
	}
	
	g_hDatabase = hndl;
	
	decl String:sDriver[16];
	SQL_ReadDriver(hndl, sDriver, sizeof(sDriver));
	if(StrEqual(sDriver, "sqlite", false))
	{
		SQL_TQuery(hndl, SQL_DoNothing, "CREATE TABLE IF NOT EXISTS tetris_players (steamid VARCHAR(64) PRIMARY KEY, name VARCHAR(64) NOT NULL, score_easy INTEGER DEFAULT '0', score_normal INTEGER DEFAULT '0', score_hard INTEGER DEFAULT '0');");
	}
	else
	{
		SQL_TQuery(hndl, SQL_DoNothing, "SET NAMES 'utf8';");
	}
	
	decl String:sAuth[32];
	for(new i=1;i<=MaxClients;i++)
	{
		if(IsClientInGame(i) && IsClientAuthorized(i) && GetClientAuthId(i, AuthId_Steam2, sAuth, sizeof(sAuth)))
		{
			OnClientAuthorized(i, sAuth);
		}
	}
}

public SQL_GetClientHighscores(Handle:owner, Handle:hndl, const String:error[], any:userid)
{
	if(hndl == INVALID_HANDLE || strlen(error) > 0)
	{
		LogError("SQL query error: %s", error);
		return;
	}
	
	new client = GetClientOfUserId(userid);
	if(!client)
		return;
	
	while(SQL_MoreRows(hndl))
	{
		if(!SQL_FetchRow(hndl))
			continue;
		
		g_bPlayerHasHighscore[client] = true;
		g_iPlayerHighscore[client][0] = SQL_FetchInt(hndl, 0);
		g_iPlayerHighscore[client][1] = SQL_FetchInt(hndl, 1);
		g_iPlayerHighscore[client][2] = SQL_FetchInt(hndl, 2);
	}
}

public SQL_FetchTop5(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new userid, difficulty;
	if(data != INVALID_HANDLE)
	{
		ResetPack(data);
		userid = ReadPackCell(data);
		difficulty = ReadPackCell(data);
		CloseHandle(data);
	}
	
	if(hndl == INVALID_HANDLE || strlen(error) > 0)
	{
		LogError("SQL query error: %s", error);
		return;
	}
	
	new client = GetClientOfUserId(userid);
	if(!client)
		return;
	
	new Handle:hMenu = CreateMenu(Menu_HandleTop5);
	SetMenuTitle(hMenu, "Tetris: Top 5 > %s", (difficulty==0?"Easy":(difficulty==1?"Normal":"Hard")));
	SetMenuExitBackButton(hMenu, true);
	
	decl String:sMenu[128];
	new iPlace = 1;
	while(SQL_MoreRows(hndl))
	{
		if(!SQL_FetchRow(hndl))
			continue;
		
		SQL_FetchString(hndl, 0, sMenu, sizeof(sMenu));
		Format(sMenu, sizeof(sMenu), "%d. %s: %d", iPlace, sMenu, SQL_FetchInt(hndl, 1));
		AddMenuItem(hMenu, "", sMenu);
		iPlace++;
	}
	
	for(new i=iPlace;i<=5;i++)
	{
		Format(sMenu, sizeof(sMenu), "%d. ", i);
		AddMenuItem(hMenu, "", sMenu);
	}
	
	if(difficulty != 0)
		AddMenuItem(hMenu, "easy", "View easy difficulty");
	if(difficulty != 1)
		AddMenuItem(hMenu, "normal", "View normal difficulty");
	if(difficulty != 2)
		AddMenuItem(hMenu, "hard", "View hard difficulty");
	
	DisplayMenu(hMenu, client, MENU_TIME_FOREVER);
}

public SQL_DoNothing(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl == INVALID_HANDLE || strlen(error) > 0)
	{
		LogError("SQL query error: %s", error);
		return;
	}
}

PauseTetrisGame(client)
{
	ClearTimer(g_hPlayerGameThink[client]);
	ClearTimer(g_hDrawInfoPanel[client]);
	ClearTimer(g_hPlayBackgroundMusic[client]);
	if (!g_bDisableSounds)
		StopSoundAny(client, SNDCHAN_AUTO, TETRIS_MUSIC);
	CPrintToChat(client, "%sGame paused. You're able to resume with !tetris.", PREFIX);
	SetEntProp(client, Prop_Send, "m_fFlags", FL_FAKECLIENT|FL_ONGROUND|FL_PARTIALGROUND);
}

ResetTetrisGame(client)
{
	ClearTimer(g_hPlayerGameThink[client]);
	ClearTimer(g_hDrawInfoPanel[client]);
	ClearTimer(g_hPlayBackgroundMusic[client]);
	if (!g_bDisableSounds)
		StopSoundAny(client, SNDCHAN_AUTO, TETRIS_MUSIC);
	ResetGameField(g_bGameField[client]);
	g_iObjectPosition[client][COORD_X] = -1;
	g_iObjectPosition[client][COORD_Y] = -1;
	g_iObjectType[client] = Tetris_None;
	g_iNextObjectType[client] = Tetris_None;
	g_iObjectRotation[client] = TetrisRotation_None;
	g_iTicks[client] = 0;
	g_iLinesCleared[client] = 0;
	g_iScore[client] = 0;
	g_iLevel[client] = 1;
	g_iHardDrop[client] = 0;
	g_iCombo[client] = 0;
	
	for(new i=0;i<BUTTON_NUM_DEFINES;i++)
		g_iButtonsPressed[client][i] = 0;
}

SelectRandomObject(client)
{
	// Do we have our next object already?
	if(g_iNextObjectType[client] != Tetris_None)
		g_iObjectType[client] = g_iNextObjectType[client];
	// This is our first object. Generate our first!
	else
		g_iObjectType[client] = TetrisObject:Math_GetRandomInt(_:Tetris_Square, _:Tetris_I);
	
	// What's next?
	g_iNextObjectType[client] = TetrisObject:Math_GetRandomInt(_:Tetris_Square, _:Tetris_I);
	
	g_iObjectRotation[client] = GetDefaultRotation(g_iObjectType[client]);
	
	new iMinMax[2];
	GetObjectMinMax(g_iObjectType[client], g_iObjectRotation[client], iMinMax);
	
	g_iObjectPosition[client][COORD_X] = (FIELD_X / 2) - (iMinMax[COORD_X]-1) / 2;
	g_iObjectPosition[client][COORD_Y] = FIELD_Y-1 - iMinMax[COORD_Y]+1;
	
	g_iHardDrop[client] = 0;
}

// Awwwwwwful implementation but i'm too tired now
GetObjectShape(TetrisObject:iObject, TetrisRotation:iRotation, iMatrix[4][4])
{
	Reset4x4(iMatrix);
	
	switch(iObject)
	{
		case Tetris_Square:
		{
			// ==
			// ==
			// Always the same, don't care for rotation..
			iMatrix[0][0] = 1;
			iMatrix[0][1] = 1;
			iMatrix[1][0] = 1;
			iMatrix[1][1] = 1;
		}
		case Tetris_T:
		{
			switch(iRotation)
			{
				//  =
				// ===
				case TetrisRotation_0:
				{
					iMatrix[0][0] = 1;
					iMatrix[0][1] = 1;
					iMatrix[0][2] = 1;
					iMatrix[1][1] = 1;
				}
				// =
				// ==
				// =
				case TetrisRotation_90:
				{
					iMatrix[0][0] = 1;
					iMatrix[1][0] = 1;
					iMatrix[1][1] = 1;
					iMatrix[2][0] = 1;
				}
				// ===
				//  =
				case TetrisRotation_180:
				{
					iMatrix[0][1] = 1;
					iMatrix[1][0] = 1;
					iMatrix[1][1] = 1;
					iMatrix[1][2] = 1;
				}
				//  =
				// ==
				//  =
				case TetrisRotation_270:
				{
					iMatrix[0][1] = 1;
					iMatrix[1][0] = 1;
					iMatrix[1][1] = 1;
					iMatrix[2][1] = 1;
				}
			}
		}
		case Tetris_S:
		{
			switch(iRotation)
			{
				//  ==
				// ==
				case TetrisRotation_0, TetrisRotation_180:
				{
					iMatrix[0][0] = 1;
					iMatrix[0][1] = 1;
					iMatrix[1][1] = 1;
					iMatrix[1][2] = 1;
				}
				// =
				// ==
				//  =
				case TetrisRotation_90, TetrisRotation_270:
				{
					iMatrix[0][1] = 1;
					iMatrix[1][0] = 1;
					iMatrix[1][1] = 1;
					iMatrix[2][0] = 1;
				}
			}
		}
		case Tetris_Z:
		{
			switch(iRotation)
			{
				// ==
				//  ==
				case TetrisRotation_0, TetrisRotation_180:
				{
					iMatrix[0][1] = 1;
					iMatrix[0][2] = 1;
					iMatrix[1][0] = 1;
					iMatrix[1][1] = 1;
				}
				//  =
				// ==
				// =
				case TetrisRotation_90, TetrisRotation_270:
				{
					iMatrix[0][0] = 1;
					iMatrix[1][0] = 1;
					iMatrix[1][1] = 1;
					iMatrix[2][1] = 1;
				}
			}
		}
		case Tetris_L:
		{
			switch(iRotation)
			{
				// =
				// =
				// ==
				case TetrisRotation_0:
				{
					iMatrix[0][0] = 1;
					iMatrix[0][1] = 1;
					iMatrix[1][0] = 1;
					iMatrix[2][0] = 1;
				}
				// ===
				// =
				case TetrisRotation_90:
				{
					iMatrix[0][0] = 1;
					iMatrix[1][0] = 1;
					iMatrix[1][1] = 1;
					iMatrix[1][2] = 1;
				}
				// ==
				//  =
				//  =
				case TetrisRotation_180:
				{
					iMatrix[0][1] = 1;
					iMatrix[1][1] = 1;
					iMatrix[2][0] = 1;
					iMatrix[2][1] = 1;
				}
				//   =
				// ===
				case TetrisRotation_270:
				{
					iMatrix[0][0] = 1;
					iMatrix[0][1] = 1;
					iMatrix[0][2] = 1;
					iMatrix[1][2] = 1;
				}
			}
		}
		case Tetris_J:
		{
			switch(iRotation)
			{
				//  =
				//  =
				// ==
				case TetrisRotation_0:
				{
					iMatrix[0][0] = 1;
					iMatrix[0][1] = 1;
					iMatrix[1][1] = 1;
					iMatrix[2][1] = 1;
				}
				// =
				// ===
				case TetrisRotation_90:
				{
					iMatrix[0][0] = 1;
					iMatrix[0][1] = 1;
					iMatrix[0][2] = 1;
					iMatrix[1][0] = 1;
				}
				// ==
				// =
				// =
				case TetrisRotation_180:
				{
					iMatrix[0][0] = 1;
					iMatrix[1][0] = 1;
					iMatrix[2][0] = 1;
					iMatrix[2][1] = 1;
				}
				// ===
				//   =
				case TetrisRotation_270:
				{
					iMatrix[0][2] = 1;
					iMatrix[1][0] = 1;
					iMatrix[1][1] = 1;
					iMatrix[1][2] = 1;
				}
			}
		}
		case Tetris_I:
		{
			switch(iRotation)
			{
				// =
				// =
				// =
				// =
				case TetrisRotation_0, TetrisRotation_180:
				{
					iMatrix[0][0] = 1;
					iMatrix[1][0] = 1;
					iMatrix[2][0] = 1;
					iMatrix[3][0] = 1;
				}
				// ====
				case TetrisRotation_90, TetrisRotation_270:
				{
					iMatrix[0][0] = 1;
					iMatrix[0][1] = 1;
					iMatrix[0][2] = 1;
					iMatrix[0][3] = 1;
				}
			}
		}
	}
}

PutObjectOnGameField(TetrisObject:iObject, TetrisRotation:iRotation, iObjectPosition[2], bool:bGameField[FIELD_Y][FIELD_X])
{
	new iMatrix[4][4];
	GetObjectShape(iObject, iRotation, iMatrix);
	
	for(new x=0;x<4;x++)
	{
		for(new y=3;y>=0;y--)
		{
			if(iMatrix[y][x] == 1)
				bGameField[y+iObjectPosition[COORD_Y]][x+iObjectPosition[COORD_X]] = iMatrix[y][x] == 1;
		}
	}
}

GetObjectMinMax(TetrisObject:iObject, TetrisRotation:iRotation, iMinMax[2])
{
	switch(iObject)
	{
		case Tetris_Square:
		{
			iMinMax[COORD_X] = 2;
			iMinMax[COORD_Y] = 2;
		}
		case Tetris_T, Tetris_S, Tetris_Z:
		{
			switch(iRotation)
			{
				case TetrisRotation_0, TetrisRotation_180:
				{
					iMinMax[COORD_X] = 3;
					iMinMax[COORD_Y] = 2;
				}
				case TetrisRotation_90, TetrisRotation_270:
				{
					iMinMax[COORD_X] = 2;
					iMinMax[COORD_Y] = 3;
				}
			}
		}
		case Tetris_L, Tetris_J:
		{
			switch(iRotation)
			{
				case TetrisRotation_0, TetrisRotation_180:
				{
					iMinMax[COORD_X] = 2;
					iMinMax[COORD_Y] = 3;
				}
				case TetrisRotation_90, TetrisRotation_270:
				{
					iMinMax[COORD_X] = 3;
					iMinMax[COORD_Y] = 2;
				}
			}
		}
		case Tetris_I:
		{
			switch(iRotation)
			{
				case TetrisRotation_0, TetrisRotation_180:
				{
					iMinMax[COORD_X] = 1;
					iMinMax[COORD_Y] = 4;
				}
				case TetrisRotation_90, TetrisRotation_270:
				{
					iMinMax[COORD_X] = 4;
					iMinMax[COORD_Y] = 1;
				}
			}
		}
	}
}

TetrisRotation:GetDefaultRotation(TetrisObject:iObject)
{
	switch(iObject)
	{
		case Tetris_Square, Tetris_S, Tetris_Z:
		{
			return TetrisRotation_0;
		}
		case Tetris_L, Tetris_I:
		{
			return TetrisRotation_90;
		}
		case Tetris_T:
		{
			return TetrisRotation_180;
		}
		case Tetris_J:
		{
			return TetrisRotation_270;
		}
	}
	
	return TetrisRotation_None;
}

bool:RotateObject(client)
{
	// Rotate the object
	new TetrisRotation:iTempRotation = g_iObjectRotation[client];
	iTempRotation++;
	if(iTempRotation > TetrisRotation_270)
		iTempRotation = TetrisRotation_0;
	
	new iTempPosition[2];
	iTempPosition = g_iObjectPosition[client];
	
	switch(g_iObjectType[client])
	{
		case Tetris_T:
		{
			switch(iTempRotation)
			{
				case TetrisRotation_0:
				{
					iTempPosition[COORD_Y] += 1;
				}
				case TetrisRotation_90:
				{
					iTempPosition[COORD_X] += 1;
					iTempPosition[COORD_Y] -= 1;
				}
				case TetrisRotation_180:
				{
					iTempPosition[COORD_X] -= 1;
				}
			}
		}
		case Tetris_S, Tetris_Z:
		{
			switch(iTempRotation)
			{
				case TetrisRotation_0, TetrisRotation_180:
				{
					iTempPosition[COORD_X] -= 1;
					iTempPosition[COORD_Y] += 1;
				}
				case TetrisRotation_90, TetrisRotation_270:
				{
					iTempPosition[COORD_X] += 1;
					iTempPosition[COORD_Y] -= 1;
				}
			}
		}
		case Tetris_L:
		{
			switch(iTempRotation)
			{
				case TetrisRotation_0:
				{
					iTempPosition[COORD_X] += 1;
					iTempPosition[COORD_Y] -= 1;
				}
				case TetrisRotation_90:
				{
					iTempPosition[COORD_X] -= 1;
					iTempPosition[COORD_Y] += 1;
				}
				case TetrisRotation_180:
				{
					iTempPosition[COORD_Y] -= 1;
				}
				case TetrisRotation_270:
				{
					iTempPosition[COORD_Y] += 1;
				}
			}
		}
		case Tetris_J:
		{
			switch(iTempRotation)
			{
				case TetrisRotation_0:
				{
					iTempPosition[COORD_Y] += 1;
				}
				case TetrisRotation_90:
				{
					iTempPosition[COORD_X] += 1;
					iTempPosition[COORD_Y] -= 1;
				}
				case TetrisRotation_180:
				{
					iTempPosition[COORD_X] -= 1;
					iTempPosition[COORD_Y] += 1;
				}
				case TetrisRotation_270:
				{
					iTempPosition[COORD_Y] -= 1;
				}
			}
		}
		case Tetris_I:
		{
			switch(iTempRotation)
			{
				case TetrisRotation_0, TetrisRotation_180:
				{
					iTempPosition[COORD_X] += 1;
					iTempPosition[COORD_Y] -= 2;
				}
				case TetrisRotation_90, TetrisRotation_270:
				{
					iTempPosition[COORD_X] -= 1;
					iTempPosition[COORD_Y] += 2;
				}
			}
		}
	}
	
	// We're out of bounds on the left
	if(iTempPosition[COORD_X] < 0)
		return false;
	
	// We're out of bounds on the bottom
	if(iTempPosition[COORD_Y] < 0)
		return false;
	
	new iMinMax[2];
	// Check, if there is enough space to rotate here?
	GetObjectMinMax(g_iObjectType[client], iTempRotation, iMinMax);
	
	// We're out of bounds on the right
	if(iTempPosition[COORD_X]+iMinMax[COORD_X]-1 >= FIELD_X)
		return false;
	
	// We're over the top!
	if(iTempPosition[COORD_Y]+iMinMax[COORD_Y]-1 >= FIELD_Y)
		return false;
	
	new bool:bGameField[FIELD_Y][FIELD_X];
	PutObjectOnGameField(g_iObjectType[client], iTempRotation, iTempPosition, bGameField);
	
	// There's already something!
	if(IsObjectColliding(g_bGameField[client], bGameField))
		return false;
	
	// Successfully rotated. Save.
	g_iObjectPosition[client] = iTempPosition;
	g_iObjectRotation[client] = iTempRotation;
	
	return true;
}

DrawTetrisGameField(client, bool:bGameOver)
{
	new Handle:hPanel = CreatePanel();
	new String:sGameLine[FIELD_X*4+1];
	new bool:bGameField[FIELD_Y][FIELD_X];
	
	PutObjectOnGameField(g_iObjectType[client], g_iObjectRotation[client], g_iObjectPosition[client], bGameField);
	
	// Draw the game field
	for(new y=FIELD_Y-1;y>=0;y--)
	{
		for(new x=0;x<FIELD_X;x++)
		{
			// Draw the already placed parts
			if(g_bGameField[client][y][x])
				Format(sGameLine, sizeof(sGameLine), "%s%s", sGameLine, CHAR_OBJPLACED);
			else if(bGameField[y][x])
				Format(sGameLine, sizeof(sGameLine), "%s%s", sGameLine, CHAR_CURRENTOBJ);
			else
				Format(sGameLine, sizeof(sGameLine), "%s%s", sGameLine, CHAR_SPACE);
		}
		DrawPanelText(hPanel, sGameLine);
		Format(sGameLine, sizeof(sGameLine), "");
	}
	
	DrawPanelItem(hPanel, "Back");
	
	// Allow pausing with 0 as well.
	SetPanelKeys(hPanel, (1<<0)|(1<<9));
	SendPanelToClient(hPanel, client, Panel_HandleGame, (bGameOver?10:1));
	CloseHandle(hPanel);
	
	if(bGameOver)
	{
		CPrintToChat(client, "%sGAME OVER! Your score is: %d.", PREFIX, g_iScore[client]);
		
		if(!g_bDisableSounds && g_bEnableSound[client])
			EmitSoundToClientAny(client, TETRIS_GAMEOVER);
		SetEntProp(client, Prop_Send, "m_fFlags", FL_FAKECLIENT|FL_ONGROUND|FL_PARTIALGROUND);
		
		new bool:bNewHighscore = false;
		switch(g_fDifficulty[client])
		{
			case TetrisDifficulty_Easy:
			{
				if(g_iPlayerHighscore[client][0] < g_iScore[client])
				{
					bNewHighscore = true;
					g_iPlayerHighscore[client][0] = g_iScore[client];
				}
			}
			case TetrisDifficulty_Normal:
			{
				if(g_iPlayerHighscore[client][1] < g_iScore[client])
				{
					bNewHighscore = true;
					g_iPlayerHighscore[client][1] = g_iScore[client];
				}
			}
			case TetrisDifficulty_Hard:
			{
				if(g_iPlayerHighscore[client][2] < g_iScore[client])
				{
					bNewHighscore = true;
					g_iPlayerHighscore[client][2] = g_iScore[client];
				}
			}
		}
		
		if(bNewHighscore)
			CPrintToChat(client, "%sNew personal highscore!", PREFIX);
		
		// Inform other plugins.
		Call_StartForward(g_hfwdOnTetrisGameEnd);
		Call_PushCell(client);
		Call_PushCell(g_iLevel[client]);
		Call_PushCell(g_iLinesCleared[client]);
		Call_PushCell(g_iScore[client]);
		Call_PushCell(bNewHighscore);
		Call_Finish();
		
		// Save the highscore into our database.
		if(g_hDatabase != INVALID_HANDLE && bNewHighscore)
		{
			decl String:sName[MAX_NAME_LENGTH], String:sEscapedName[MAX_NAME_LENGTH*2+1], String:sAuth[32];
			if (GetClientAuthId(client, AuthId_Steam2, sAuth, sizeof(sAuth)))
			{
				GetClientName(client, sName, sizeof(sName));
				SQL_EscapeString(g_hDatabase, sName, sEscapedName, sizeof(sEscapedName));
				
				if(g_bPlayerHasHighscore[client])
					SQL_TQueryF(g_hDatabase, SQL_DoNothing, 0, DBPrio_Normal, "UPDATE tetris_players SET name = '%s', score_easy = %d, score_normal = %d, score_hard = %d WHERE steamid = '%s';", sEscapedName, g_iPlayerHighscore[client][0], g_iPlayerHighscore[client][1], g_iPlayerHighscore[client][2], sAuth);
				else
					SQL_TQueryF(g_hDatabase, SQL_DoNothing, 0, DBPrio_Normal, "INSERT INTO tetris_players (name, steamid, score_easy, score_normal, score_hard) VALUES('%s', '%s', %d, %d, %d);", sEscapedName, sAuth, g_iPlayerHighscore[client][0], g_iPlayerHighscore[client][1], g_iPlayerHighscore[client][2]);
				
				g_bPlayerHasHighscore[client] = true;
			}
		}
		ResetTetrisGame(client);
	}
}

bool:MoveCurrentObjectDown(client, &bool:bGameOver)
{
	new bool:bGameField[FIELD_Y][FIELD_X];
	new iTempPosition2[2];
	iTempPosition2 = g_iObjectPosition[client];
	iTempPosition2[COORD_Y]--;
	if(iTempPosition2[COORD_Y] < 0)
	{
		// We're on the ground already. Save and get the next object!
		SaveCurrentObject(client);
		if (g_hDrawInfoPanel[client] != INVALID_HANDLE)
			TriggerTimer(g_hDrawInfoPanel[client]);
		
		// Is there enough space to draw the new one?
		ResetGameField(bGameField);
		PutObjectOnGameField(g_iObjectType[client], g_iObjectRotation[client], g_iObjectPosition[client], bGameField);
		if(IsObjectColliding(g_bGameField[client], bGameField))
		{
			// No there isn't. GAME OVER!!!
			bGameOver = true;
		}
		return false;
	}
	else
	{
		// Are we even able to move it down?
		PutObjectOnGameField(g_iObjectType[client], g_iObjectRotation[client], iTempPosition2, bGameField);
		if(IsObjectColliding(g_bGameField[client], bGameField))
		{
			// No, we're not. This object is blocked here, Save it and get the next one!
			SaveCurrentObject(client);
			if (g_hDrawInfoPanel[client] != INVALID_HANDLE)
				TriggerTimer(g_hDrawInfoPanel[client]);
			
			// Is there enough space to draw the new one?
			ResetGameField(bGameField);
			PutObjectOnGameField(g_iObjectType[client], g_iObjectRotation[client], g_iObjectPosition[client], bGameField);
			if(IsObjectColliding(g_bGameField[client], bGameField))
			{
				// No there isn't. GAME OVER!!!
				bGameOver = true;
			}
			return false;
		}
		// Yes, we can move it down. Do so :)
		else
		{
			g_iObjectPosition[client] = iTempPosition2;
			return true;
		}
	}
}

bool:IsObjectColliding(bool:bGameField1[FIELD_Y][FIELD_X], bool:bGameField2[FIELD_Y][FIELD_X])
{
	for(new y=0;y<FIELD_Y;y++)
	{
		for(new x=0;x<FIELD_X;x++)
		{
			if(bGameField1[y][x] && bGameField2[y][x])
				return true;
		}
	}
	return false;
}

MergeGameFields(bool:bGameField[FIELD_Y][FIELD_X], bool:bGameFieldAdd[FIELD_Y][FIELD_X])
{
	for(new y=0;y<FIELD_Y;y++)
	{
		for(new x=0;x<FIELD_X;x++)
		{
			if(!bGameField[y][x] && bGameFieldAdd[y][x])
				bGameField[y][x] = true;
		}
	}
}

RemoveFullLines(bool:bGameField[FIELD_Y][FIELD_X])
{
	new iRemovedLines;
	
	for(new y=0;y<FIELD_Y;y++)
	{
		for(new x=0;x<FIELD_X;x++)
		{
			if(!bGameField[y][x])
				break;
			
			// This row is full!
			if(x == FIELD_X-1)
			{
				iRemovedLines++;
				for(new y2=y;y2<FIELD_Y-1;y2++)
				{
					for(new x2=0;x2<FIELD_X;x2++)
					{
						bGameField[y2][x2] = bGameField[y2+1][x2];
						bGameField[y2+1][x2] = false;
					}
				}
				// Check this row again, since we moved the field down one row!
				y--;
			}
		}
	}
	
	return iRemovedLines;
}

SaveCurrentObject(client)
{
	new bool:bGameField[FIELD_Y][FIELD_X];
	PutObjectOnGameField(g_iObjectType[client], g_iObjectRotation[client], g_iObjectPosition[client], bGameField);
	MergeGameFields(g_bGameField[client], bGameField);
	
	new iLinesCleared = RemoveFullLines(g_bGameField[client]);
	
	if(!g_bDisableSounds && g_bEnableSound[client])
	{
		if(iLinesCleared == 4)
			EmitSoundToClientAny(client, TETRIS_TETRIS);
		else if(iLinesCleared > 0)
			EmitSoundToClientAny(client, TETRIS_FULLLINE);
		else
			EmitSoundToClientAny(client, TETRIS_PLACE);
	}
	
	// Handle combos
	if(g_iCombo[client] > 0 && iLinesCleared == 0)
	{
		g_iScore[client] += g_iCombo[client]*50*g_iLevel[client];
		g_iCombo[client] = 0;
	}
	else if(iLinesCleared > 0)
		g_iCombo[client]++;
	
	// Scoring...
	// http://www.tetrisfriends.com/help/tips_appendix.php#scoringchart Thanks twistedpanda :)
	
	switch(iLinesCleared)
	{
		case 1:
		{
			g_iScore[client] += 100 * g_iLevel[client];
			g_iLinesCleared[client] += 1;
		}
		case 2:
		{
			g_iScore[client] += 300 * g_iLevel[client];
			g_iLinesCleared[client] += 3;
		}
		case 3:
		{
			g_iScore[client] += 500 * g_iLevel[client];
			g_iLinesCleared[client] += 5;
		}
		case 4:
		{
			g_iScore[client] += 800 * g_iLevel[client];
			g_iLinesCleared[client] += 8;
		}
	}
	
	g_iScore[client] += 2 * (g_iHardDrop[client]-1);
	
	// Level up?
	while(g_iLevel[client]*5 <= g_iLinesCleared[client])
	{
		g_iLevel[client]++;
		if(!g_bDisableSounds && g_bEnableSound[client])
			EmitSoundToClientAny(client, TETRIS_LEVELUP);
	}
	
	if (g_hDrawInfoPanel[client] != INVALID_HANDLE)
		TriggerTimer(g_hDrawInfoPanel[client]);
	
	SelectRandomObject(client);
}

public ConVar_OnChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(StrEqual(newValue, oldValue))
		return;
	
	if(convar == g_hCVDisableHardDrop)
	{
		if(StrEqual(newValue, "1"))
			g_bDisableHardDrop = true;
		else
			g_bDisableHardDrop = false;
	}
	else if(convar == g_hCVDisableSounds)
	{
		if(StrEqual(newValue, "1"))
			g_bDisableSounds = true;
		else
			g_bDisableSounds = false;
	}
	else if(convar == g_hCVOnlyDead)
	{
		if(StrEqual(newValue, "1"))
			g_bOnlyDead = true;
		else
			g_bOnlyDead = false;
	}
	else if(convar == g_hCVDisableStats)
	{
		if(StrEqual(newValue, "1"))
			g_bDisableStats = true;
		else
			g_bDisableStats = false;
	}
}

public Native_IsClientInTetrisGame(Handle:plugin, numParams)
{
	new client = GetNativeCell(1);
	if (client < 1 || client > MaxClients)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid client index (%d)", client);
	}
	
	return g_hPlayerGameThink[client] != INVALID_HANDLE;
}

stock ResetGameField(bool:bGameField[FIELD_Y][FIELD_X])
{
	for(new y=0;y<FIELD_Y;y++)
	{
		for(new x=0;x<FIELD_X;x++)
			bGameField[y][x] = false;
	}
}

stock Reset4x4(iMatrix[4][4])
{
	for(new x=0;x<4;x++)
		for(new y=0;y<4;y++)
			iMatrix[x][y] = -1;
}

stock ClearTimer(&Handle:timer, bool:autoClose=false)
{
	if(timer != INVALID_HANDLE)
		KillTimer(timer, autoClose);
	timer = INVALID_HANDLE;
}