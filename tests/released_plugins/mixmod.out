public PlVers:__version =
{
	version = 5,
	filevers = "1.3.9-dev",
	date = "06/10/2014",
	time = "09:22:38"
};
new Float:NULL_VECTOR[3];
new String:NULL_STRING[4];
public Extension:__ext_core =
{
	name = "Core",
	file = "core",
	autoload = 0,
	required = 0,
};
new MaxClients;
public Extension:__ext_sdktools =
{
	name = "SDKTools",
	file = "sdktools.ext",
	autoload = 1,
	required = 1,
};
public Extension:__ext_cstrike =
{
	name = "cstrike",
	file = "games/game.cstrike.ext",
	autoload = 0,
	required = 1,
};
new g_CurrentRound = 1;
new g_CurrentHalf = 1;
new g_nCTScore;
new g_nTScore;
new g_nCTScore2;
new g_nTScore2;
new g_nCTScoreH1;
new g_nTScoreH1;
new bool:hasMixStarted;
new bool:didLiveStarted;
new bool:g_SwapNow;
new bool:isKo3Running;
new bool:isPauseBeingUsed;
new bool:isRandomPasswordWasLastPw;
new bool:isBuyZoneDisabled;
new bool:isRandomBeingUsed;
new String:guns[17][20] =
{
	"weapon_m4a1",
	"weapon_ak47",
	"weapon_awp",
	"weapon_mp5navy",
	"weapon_famas",
	"weapon_scout",
	"weapon_p90",
	"weapon_ump45",
	"weapon_mac10",
	"weapon_xm1014",
	"weapon_m3",
	"weapon_sg550",
	"weapon_g3sg1",
	"weapon_tmp",
	"weapon_sg552",
	"weapon_aug",
	"weapon_m249"
};
new String:pistols[6][20] =
{
	"weapon_glock",
	"weapon_usp",
	"weapon_p228",
	"weapon_deagle",
	"weapon_elite",
	"weapon_fiveseven"
};
new g_ArrPause[66][10];
new g_iToolsAmmo = -1;
new bool:ENABLE_PLUGIN_CHECKING;
new bool:isMapListGenerated;
new Handle:g_MapListMenu;
new bool:isMixMenuGenerated;
new Handle:g_MixMenu;
new Handle:g_AdminMenu;
new Handle:g_WinTeamPanel;
new Handle:g_HelpPanel;
new Handle:g_CvarEnabled;
new Handle:g_CvarShowMoneyAndWeapons;
new Handle:g_CvarShowScores;
new Handle:g_CvarEnableRRCommand;
new Handle:g_CvarPlayTeamSwapedSound;
new Handle:g_CvarCusomNameTeamCT;
new Handle:g_CvarCusomNameTeamT;
new Handle:g_CvarRestartTimeInLiveCommand;
new Handle:g_CvarUseZBMatchCommand;
new Handle:g_CvarMr3Enabled;
new Handle:g_CvarStopCustomCfg;
new Handle:g_CvarShowSwitchInPanel;
new Handle:g_CvarShowCashInPanel;
new Handle:g_CvarHalfAutoLiveStart;
new Handle:g_CvarCustomLiveCfg;
new Handle:g_CvarCustomPracCfg;
new Handle:g_CvarCustomMr3Cfg;
new Handle:g_CvarKickAdmins;
new Handle:g_CvarDisableSayCommand;
new Handle:g_CvarMapListFrom;
new Handle:g_CvarEnableKnifeRound;
new Handle:g_CvarUseKo3Command;
new Handle:g_CvarInformWinnerInPanel;
new Handle:g_CvarRpwShowPass;
new Handle:g_CvarRemoveProps;
new Handle:g_CvarAutoMixEnabled;
new Handle:g_CvarAutoMixRandomize;
new Handle:g_CvarAutoMixBan;
new Handle:g_CvarEnableAutoSourceTVRecord;
new Handle:g_CvarAutoSourceTVRecordSaveDir;
new Handle:g_CvarKnifeWinTeamVote;
new Handle:g_CvarEnablePasswords;
new Handle:g_CvarAllowManualSwitching;
new Handle:g_CvarDelayBeforeSwapping;
new Handle:g_CvarShowTkMessage;
new Handle:g_CvarRemovePassWhenMixIsEnded;
new Handle:g_CvarShowMVP;
new Handle:g_CvarDontRemovePropsMaps;
new Handle:g_CvarEnableVoiceCommands;
new Handle:g_hPluginVersion;
new Handle:g_hRestartGame;
new Handle:g_hPassword;
new Handle:g_hFreezeTime;
new Handle:g_hHostName;
new g_iAccount = -1;
new g_ReadyCount;
new bool:g_ReadyPlayers[66];
new g_ReadyPlayersData[66] =
{
	-1, ...
};
new bool:g_AllowReady = 1;
new bool:g_IsItManual = 1;
new String:g_HostName[152];
new Handle:readyStatus;
new bool:g_IsRecording;
new bool:g_IsRecordManual;
new bool:g_SaveClientsScore;
new g_ScoresOfTheRound[66];
new g_ScoresOfTheGame[66];
new g_DeathsOfTheGame[66];
new bool:g_MutedPlayers[66];
new bool:g_GaggedPlayers[66];
new String:g_LastEntered_SteamID[36];
new String:g_LastEntered_Name[36];
new g_IsMapValidToRemoveProps = 1;
new String:ctmodels[4][112] =
{
	"models/player/ct_urban.mdl",
	"models/player/ct_gsg9.mdl",
	"models/player/ct_sas.mdl",
	"models/player/ct_gign.mdl"
};
new String:tmodels[4][] =
{
	"models/player/t_phoenix.mdl",
	"models/player/t_leet.mdl",
	"models/player/t_arctic.mdl",
	"models/player/t_guerilla.mdl"
};
public Plugin:myinfo =
{
	name = "Mix-Plugin",
	description = "Makes the admin's work easier to run a mix (team match or clan war) And Auto-Mix system.",
	author = "iDragon",
	version = "4.3",
	url = ""
};
public __ext_core_SetNTVOptional()
{
	MarkNativeAsOptional("GetFeatureStatus");
	MarkNativeAsOptional("RequireFeature");
	MarkNativeAsOptional("AddCommandListener");
	MarkNativeAsOptional("RemoveCommandListener");
	VerifyCoreVersion();
	return 0;
}

bool:operator<(Float:,Float:)(Float:oper1, Float:oper2)
{
	return FloatCompare(oper1, oper2) < 0;
}

bool:StrEqual(String:str1[], String:str2[], bool:caseSensitive)
{
	return strcmp(str1, str2, caseSensitive) == 0;
}

PrintToChatAll(String:format[])
{
	decl String:buffer[192];
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i))
		{
			SetGlobalTransTarget(i);
			VFormat(buffer, 192, format, 2);
			PrintToChat(i, "%s", buffer);
		}
		i++;
	}
	return 0;
}

bool:GetEntityClassname(entity, String:clsname[], maxlength)
{
	return !!GetEntPropString(entity, PropType:1, "m_iClassname", clsname, maxlength);
}

EmitSoundToAll(String:sample[], entity, channel, level, flags, Float:volume, pitch, speakerentity, Float:origin[3], Float:dir[3], bool:updatePos, Float:soundtime)
{
	new clients[MaxClients];
	new total;
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i))
		{
			total++;
			clients[total] = i;
		}
		i++;
	}
	if (!total)
	{
		return 0;
	}
	EmitSound(clients, total, sample, entity, channel, level, flags, volume, pitch, speakerentity, origin, dir, updatePos, soundtime);
	return 0;
}

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	g_CvarEnabled = CreateConVar("sm_mixmod_enable", "1", "Enable or disable this mixmod plugin and its features: 0 - Disable, 1 - Enable.", 0, false, 0.0, false, 0.0);
	g_CvarShowMoneyAndWeapons = CreateConVar("sm_mixmod_showmoney", "1", "Show players money and if they have primary weapon to their team-mates? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarShowScores = CreateConVar("sm_mixmod_showscores", "1", "Show mix scores at round_start? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarEnableRRCommand = CreateConVar("sm_mixmod_enable_rr_command", "1", "Enable the sm_rr command in this mix plugin? (Disable if you have another plugin who uses sm_rr) 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarPlayTeamSwapedSound = CreateConVar("sm_mixmod_enable_st_sound", "1", "Play sound when teams are switched when half ends? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarCusomNameTeamCT = CreateConVar("sm_mixmod_custom_name_ct", "Team A", "Set counter terrorists team custom name. (Can not be longer than 32 characters!)", 0, false, 0.0, false, 0.0);
	g_CvarCusomNameTeamT = CreateConVar("sm_mixmod_custom_name_t", "Team B", "Set terrorists team custom name. (Can not be longer than 32 characters!)", 0, false, 0.0, false, 0.0);
	g_CvarRestartTimeInLiveCommand = CreateConVar("sm_mixmod_live_restart_time", "1", "In seconds, set mp_restartgame <time> in live command. (Num > 0)", 0, false, 0.0, false, 0.0);
	g_CvarUseZBMatchCommand = CreateConVar("sm_mixmod_use_zb_lo3", "0", "Use zb_lo3 command instead of mp_restartgame (Only if zb_warmod is enabled!) ? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarMr3Enabled = CreateConVar("sm_mixmod_mr3_enable", "1", "Enable or disable mr3 settings (when there is a tie 15-15): 0 - Disable, 1 - Enable.", 0, false, 0.0, false, 0.0);
	g_CvarStopCustomCfg = CreateConVar("sm_mixmod_custom_stop_cfg", "0", "Use stop.cfg instead of prac or warmup cfg when sm_stop command is performed? 0 - No, 1 - Yes", 0, false, 0.0, false, 0.0);
	g_CvarShowSwitchInPanel = CreateConVar("sm_mixmod_show_swap_in_panel", "1", "In the last round of the current half, tell the players not to switch their teams in? 0 - Chat, 1 - Panel(menu)", 0, false, 0.0, false, 0.0);
	g_CvarShowCashInPanel = CreateConVar("sm_mixmod_show_cash_in_panel", "0", "When round starts, show players money in? 0 - Chat, 1 - Panel(menu)", 0, false, 0.0, false, 0.0);
	g_CvarHalfAutoLiveStart = CreateConVar("sm_mixmod_half_auto_live", "0", "When new half begins, automatically start live? 0 - No, 1 - Yes", 0, false, 0.0, false, 0.0);
	g_CvarCustomLiveCfg = CreateConVar("sm_mixmod_custom_live_cfg", "mr15.cfg", "Custom name of the mr15 (live or match) config: (If the name doesn't exist, the plugin will try to execute match/live/mr15/esl5on5 cfg)", 0, false, 0.0, false, 0.0);
	g_CvarCustomPracCfg = CreateConVar("sm_mixmod_custom_prac_cfg", "prac.cfg", "Custom name of the prac (warmup) config: (If the name doesn't exist, the plugin will try to execute prac / warmup config)", 0, false, 0.0, false, 0.0);
	g_CvarCustomMr3Cfg = CreateConVar("sm_mixmod_custom_mr3_cfg", "mr3.cfg", "Custome name of the mr3 config: (If the name doesn't exist, the plugin will try to execute mr3.cfg)", 0, false, 0.0, false, 0.0);
	g_CvarKickAdmins = CreateConVar("sm_mixmod_kick_admins", "0", "When admin performs sm_kickct or sm_kickt , kick the admins too? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarDisableSayCommand = CreateConVar("sm_mixmod_disable_public_chat", "0", "Disable public chat (Only team chat will be shown)? 0 - No, 1 - Yes, 2 - Only when live", 0, false, 0.0, false, 0.0);
	g_CvarMapListFrom = CreateConVar("sm_mixmod_maplist_from", "1", "Generate maplist from: 0 - maps dir, 1 - mapcycle.txt", 0, false, 0.0, false, 0.0);
	g_CvarEnableKnifeRound = CreateConVar("sm_mixmod_enable_knife_round", "0", "Before the mix starts, do knife round? 0 - Disable, 1 - Enable.", 0, false, 0.0, false, 0.0);
	g_CvarUseKo3Command = CreateConVar("sm_mixmod_use_zb_ko3", "0", "Use zb_ko3 command instead of mp_restartgame for knife round (Only if zb_warmode is enabled!) ? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarInformWinnerInPanel = CreateConVar("sm_mixmod_show_winner_in", "1", "When mix is ended, show winning team in? 0 - Chat, 1 - Panel(menu)", 0, false, 0.0, false, 0.0);
	g_CvarRpwShowPass = CreateConVar("sm_mixmod_rpw_show_pass", "1", "Show the random password to everyone? 0 - No (only to the admin), 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarRemoveProps = CreateConVar("sm_mixmod_remove_props", "0", "Remove map props (like barrels) at round start when mix is running? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarAutoMixEnabled = CreateConVar("sm_mixmod_auto_warmod_enable", "0", "Enable Auto-Warmod and ready system? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarAutoMixRandomize = CreateConVar("sm_mixmod_auto_warmod_random", "1", "After 10 players are ready, random the team players and start? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarAutoMixBan = CreateConVar("sm_mixmod_auto_warmod_ban", "-1", "In minutes: how long to ban players who has left the server? <Negetive number> - Don't ban, <Positive Number> - Time, 0 - Permanent ban", 0, false, 0.0, false, 0.0);
	g_CvarEnableAutoSourceTVRecord = CreateConVar("sm_mixmod_autorecord_enable", "0", "Auto record the game when match is live? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarAutoSourceTVRecordSaveDir = CreateConVar("sm_mixmod_autorecord_save_dir", "mix_records", "Save directatory for the auto-records (if folder doesn't exist, the record will be saved at: cstrike/ )", 0, false, 0.0, false, 0.0);
	g_CvarKnifeWinTeamVote = CreateConVar("sm_mixmod_knife_round_win_vote", "0", "Let the wining team in the knife round decide in which team they want to be? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarEnablePasswords = CreateConVar("sm_mixmod_password_commands_enable", "1", "Enable password commands (sm_pw or sm_npw or sm_rpw)? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarAllowManualSwitching = CreateConVar("sm_mixmod_manual_switch_enable", "1", "Allow players to switch their team manualy when mix is running? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarDelayBeforeSwapping = CreateConVar("sm_mixmod_time_before_swapping_teams", "0.1", "In seconds: how long should the plugin wait before swapping teams when half ends?", 0, false, 0.0, false, 0.0);
	g_CvarShowTkMessage = CreateConVar("sm_mixmod_show_tk_damage", "1", "Inform all the players in the server when TK (Team killing / team damage) has been done? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarRemovePassWhenMixIsEnded = CreateConVar("sm_mixmod_remove_password_on_mix_end", "1", "Remove the password when mix is ended (not by sm_stop command)? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarShowMVP = CreateConVar("sm_mixmod_show_mvp", "1", "Show the mvp? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_CvarDontRemovePropsMaps = CreateConVar("sm_mixmod_dont_remove_props_maplist", "de_inferno,", "Don't remove props from those maps: (syntax: 'de_inferno, anotherMap2, anotherMap3 ,...' ", 0, false, 0.0, false, 0.0);
	g_CvarEnableVoiceCommands = CreateConVar("sm_mixmod_enable_voice_commands", "1", "Enable sm_mmute and sm_mgag commands? 0 - No, 1 - Yes.", 0, false, 0.0, false, 0.0);
	g_hPluginVersion = CreateConVar("sm_mixmod_version", "4.3", "Mix Plugin version.", 270656, false, 0.0, false, 0.0);
	SetConVarString(g_hPluginVersion, "4.3", false, false);
	AutoExecConfig(true, "sm_mixmod", "sourcemod");
	HookConVarChange(g_hPluginVersion, VersionHasBeenChanged);
	g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");
	if (g_iAccount == -1)
	{
		PrintToChatAll("\x04[%s]:\x03 Can't find the m_iAccount offest! - Money wont be shown in the mix!", "Mix");
	}
	g_hRestartGame = FindConVar("mp_restartgame");
	if (!g_hRestartGame)
	{
		PrintToChatAll("\x04[%s]:\x03 Couldn't find the cvar mp_restartgame !", "Mix");
		SetFailState("[%s]: Couldn't find the cvar mp_restartgame !", "Mix");
	}
	HookConVarChange(g_hRestartGame, OnGameRestarted);
	g_hFreezeTime = FindConVar("mp_freezetime");
	if (!g_hFreezeTime)
	{
		PrintToChatAll("\x04[%s]:\x03 Couldn't find the cvar mp_freezetime !", "Mix");
		SetFailState("[%s]: Couldn't find the cvar mp_freezetime !", "Mix");
	}
	g_iToolsAmmo = FindSendPropInfo("CBasePlayer", "m_iAmmo", 0, 0, 0);
	if (g_iToolsAmmo == -1)
	{
		PrintToChatAll("\x04[%s]:\x03 Couldn't find the offest: m_iAmmo!", "Mix");
		SetFailState("Offset CBasePlayer::m_iAmmo was not found");
	}
	g_hPassword = FindConVar("sv_password");
	g_hHostName = FindConVar("hostname");
	GetConVarString(g_hHostName, g_HostName, 150);
	HookEvent("round_start", Event_RoundStart, EventHookMode:1);
	HookEvent("round_end", Event_RoundEnd, EventHookMode:1);
	HookEvent("bomb_exploded", EventBombExploded, EventHookMode:1);
	HookEvent("bomb_defused", EventBombDefused, EventHookMode:1);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode:1);
	HookEvent("player_hurt", Event_PlayerHurt, EventHookMode:1);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode:1);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode:1);
	RegAdminCmd("sm_start", Command_Start, 4, "Starts a new mix.", "", 0);
	RegAdminCmd("sm_pcw", Command_Pcw, 4, "Starts a new pcw.", "", 0);
	RegAdminCmd("sm_stop", Command_Stop, 4, "Stops the current mix.", "", 0);
	RegAdminCmd("sm_live", Command_Live, 4, "Starts the game (live ...).", "", 0);
	RegAdminCmd("sm_notlive", Command_NotLive, 4, "Pause the current mix untill !live is typed again.", "", 0);
	RegAdminCmd("sm_nl", Command_NotLive, 4, "Pause the current mix untill !live is typed again.", "", 0);
	RegAdminCmd("sm_mr15", Command_Mr15, 4, "Executes the mr15 config.", "", 0);
	RegAdminCmd("sm_match", Command_Mr15, 4, "Executes the mr15 config.", "", 0);
	RegAdminCmd("sm_prac", Command_Prac, 4, "Executes the prac config.", "", 0);
	RegAdminCmd("sm_warmup", Command_Prac, 4, "Executes the prac config.", "", 0);
	RegAdminCmd("sm_mr3", Command_Mr3, 4, "Executes mr3 config.", "", 0);
	RegAdminCmd("sm_knifes", Command_KO3, 4, "Starts knife round", "", 0);
	RegAdminCmd("sm_ko3", Command_KO3, 4, "Starts knife round", "", 0);
	RegAdminCmd("sm_swapteams", Command_SwapTeams, 4, "Swaps each player team.", "", 0);
	RegAdminCmd("sm_st", Command_SwapTeams, 4, "Swaps each player team.", "", 0);
	RegAdminCmd("sm_rpw", Command_GenerateRandomPassword, 4, "Set a random password to the server.", "", 0);
	RegAdminCmd("sm_rr", Command_RestartTheGame, 4, "Restarting the game.", "", 0);
	RegAdminCmd("sm_kickct", Command_KickCT, 4, "Kick ct team.", "", 0);
	RegAdminCmd("sm_kickt", Command_KickT, 4, "Kick t team.", "", 0);
	RegAdminCmd("sm_maps", Command_Maps, 4, "Show maps menu, to changelevel.", "", 0);
	RegAdminCmd("sm_spec", Command_Spec, 4, "Move player to spectors team.", "", 0);
	RegAdminCmd("sm_mix", Command_MixMenu, 4, "Opens mix menu.", "", 0);
	RegAdminCmd("sm_pause", Command_Pause, 4, "Pause the mix for the current round.", "", 0);
	RegAdminCmd("sm_disablechat", Command_DisableChat, 4, "Allows admins to change chat settings through command.", "", 0);
	RegAdminCmd("sm_npw", Command_RemovePass, 4, "Remove the server password.", "", 0);
	RegAdminCmd("sm_mmute", Command_MutePlayer, 4, "Mutes player.", "", 0);
	RegAdminCmd("sm_munmute", Command_UnMutePlayer, 4, "UnMutes player.", "", 0);
	RegAdminCmd("sm_mgag", Command_GagPlayer, 4, "Gags player.", "", 0);
	RegAdminCmd("sm_mungag", Command_UnGagPlayer, 4, "UnGags player.", "", 0);
	RegAdminCmd("sm_last", Command_Last, 4, "Show the last player that connected.", "", 0);
	RegAdminCmd("sm_record", Command_TvRecord, 4, "Start a record.", "", 0);
	RegAdminCmd("sm_stoprecord", Command_TvStopRecord, 4, "Stop the record.", "", 0);
	RegAdminCmd("sm_random", Command_RandomTeams, 4, "Random The Players.", "", 0);
	RegAdminCmd("sm_rnd", Command_RandomTeams, 4, "Random The Players.", "", 0);
	RegConsoleCmd("sm_score", ShowScores, "Show the score of the mix.", 0);
	RegConsoleCmd("sm_teams", Command_ShowTeams, "Show teams when auto-live is running.", 0);
	RegConsoleCmd("sm_pw", Command_Pass, "Change or view the current password.", 0);
	RegConsoleCmd("sm_password", Command_Pass, "Change or view the server password.", 0);
	RegConsoleCmd("sm_ready", Command_Ready, "Become ready command", 0);
	RegConsoleCmd("sm_rdy", Command_Ready, "Become ready command", 0);
	RegConsoleCmd("sm_unready", Command_UnReady, "Become Un-Ready command", 0);
	RegConsoleCmd("sm_urdy", Command_UnReady, "Become Un-Ready command", 0);
	RegConsoleCmd("sm_notready", Command_UnReady, "Become Un-Ready command", 0);
	RegConsoleCmd("sm_nrdy", Command_UnReady, "Become Un-Ready command", 0);
	RegConsoleCmd("sm_mvp", Command_ShowMvp, "Show MVP and player score", 0);
	RegConsoleCmd("sm_mixhelp", Command_MixHelp, "Show plugins commands", 0);
	RegConsoleCmd("say", Command_SayChat, "", 0);
	RegConsoleCmd("say_team", Command_SayChat, "", 0);
	RegConsoleCmd("jointeam", Command_JoinTeam, "", 0);
	if (ENABLE_PLUGIN_CHECKING)
	{
		RegAdminCmd("sm_setmixscore", Command_SetMixScore, 4, "Set the mix score...", "", 0);
		RegAdminCmd("sm_forceready", Command_ForceReady, 4, "Force players to be ready.", "", 0);
	}
	CheckPropsForCurrentMap();
	isMapListGenerated = false;
	CreateMapList();
	isMixMenuGenerated = false;
	CreateMixMenu();
	CreateHelpPanel();
	return 0;
}

public OnClientAuthorized(client, String:auth[])
{
	if (!IsFakeClient(client))
	{
		decl String:name[36];
		decl String:auth2[36];
		GetClientName(client, name, 35);
		Format(auth2, 35, "%s", auth);
		g_LastEntered_SteamID = auth2;
		g_LastEntered_Name = name;
		if (hasMixStarted)
		{
			CreateTimer(60.0, InformPlayerAboutTheMix, client, 0);
			g_ArrPause[client][0] = 800;
			g_ArrPause[client][1] = GetRandomInt(0, 1);
		}
	}
	return 0;
}

public Action:InformPlayerAboutTheMix(Handle:timer, any:client)
{
	if (hasMixStarted)
	{
		PrintToChat(client, "\x04[%s]:x\x03 Mix is running! \x01Good Luck \x03And\x01 Have Fun!", "Mix");
		PrintToChat(client, "\x04[%s]:x\x03 Mix is running! \x01Good Luck \x03And\x01 Have Fun!", "Mix");
		PrintToChat(client, "\x04[%s]:x\x03 Mix is running! \x01Good Luck \x03And\x01 Have Fun!", "Mix");
		PrintToChat(client, "\x04[%s]:x\x03 Mix is running! \x01LIVE-LIVE-\x04LIVE\x01-LIVE-LIVE", "Mix");
	}
	return Action:0;
}

public Action:Command_GagPlayer(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[%s]: Usage: sm_mgag <player>", "Mix");
		return Action:3;
	}
	decl String:pattern[64];
	decl String:buffer[64];
	decl String:targetName[36];
	GetCmdArg(1, pattern, 64);
	new targets[64];
	new bool:mb;
	new count = ProcessTargetString(pattern, client, targets, 64, 0, buffer, 64, mb);
	if (0 >= count)
	{
		PrintToChat(client, "\x04[%s] |\x03No such a target %d", "Mix", pattern);
		return Action:3;
	}
	new i;
	while (i < count)
	{
		g_GaggedPlayers[targets[i]] = 1;
		GetClientName(targets[i], targetName, 33);
		PrintToChat(client, "\x04[%s]:\x03 You have gagged %s !", "Mix", targetName);
		PrintToChat(targets[i], "\x04[%s]:\x03 You have been gagged!", "Mix");
		i++;
	}
	return Action:3;
}

public Action:Command_UnGagPlayer(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[%s]: Usage: sm_mungag <player>", "Mix");
		return Action:3;
	}
	decl String:pattern[64];
	decl String:buffer[64];
	decl String:targetName[36];
	GetCmdArg(1, pattern, 64);
	new targets[64];
	new bool:mb;
	new count = ProcessTargetString(pattern, client, targets, 64, 0, buffer, 64, mb);
	if (0 >= count)
	{
		PrintToChat(client, "\x04[%s] |\x03No such a target %d", "Mix", pattern);
		return Action:3;
	}
	new i;
	while (i < count)
	{
		g_GaggedPlayers[targets[i]] = 0;
		GetClientName(targets[i], targetName, 33);
		PrintToChat(client, "\x04[%s]:\x03 You have un-gagged %s !", "Mix", targetName);
		PrintToChat(targets[i], "\x04[%s]:\x03 You have been un-gagged!", "Mix");
		i++;
	}
	return Action:3;
}

public Action:Command_MutePlayer(client, args)
{
	if (!GetConVarBool(g_CvarEnableVoiceCommands))
	{
		return Action:0;
	}
	if (args < 1)
	{
		ReplyToCommand(client, "[%s]: Usage: sm_mmute <player>", "Mix");
		return Action:3;
	}
	decl String:pattern[64];
	decl String:buffer[64];
	decl String:targetName[36];
	GetCmdArg(1, pattern, 64);
	new targets[64];
	new bool:mb;
	new count = ProcessTargetString(pattern, client, targets, 64, 0, buffer, 64, mb);
	if (0 >= count)
	{
		PrintToChat(client, "\x04[%s] |\x03No such a target %d", "Mix", pattern);
		return Action:3;
	}
	new i;
	while (i < count)
	{
		g_MutedPlayers[targets[i]] = 1;
		SetClientListeningFlags(targets[i], 1);
		GetClientName(targets[i], targetName, 33);
		PrintToChat(client, "\x04[%s]:\x03 You have muted %s !", "Mix", targetName);
		PrintToChat(targets[i], "\x04[%s]:\x03 You have been muted!", "Mix");
		i++;
	}
	return Action:3;
}

public Action:Command_UnMutePlayer(client, args)
{
	if (!GetConVarBool(g_CvarEnableVoiceCommands))
	{
		return Action:0;
	}
	if (args < 1)
	{
		ReplyToCommand(client, "[%s]: Usage: sm_munmute <player>", "Mix");
		return Action:3;
	}
	decl String:pattern[64];
	decl String:buffer[64];
	decl String:targetName[36];
	GetCmdArg(1, pattern, 64);
	new targets[64];
	new bool:mb;
	new count = ProcessTargetString(pattern, client, targets, 64, 0, buffer, 64, mb);
	if (0 >= count)
	{
		PrintToChat(client, "\x04[%s] |\x03No such a target %d", "Mix", pattern);
		return Action:3;
	}
	new i;
	while (i < count)
	{
		g_MutedPlayers[targets[i]] = 0;
		SetClientListeningFlags(targets[i], 0);
		GetClientName(targets[i], targetName, 33);
		PrintToChat(client, "\x04[%s]:\x03 You have un-muted %s !", "Mix", targetName);
		PrintToChat(targets[i], "\x04[%s]:\x03 You have been un-muted!", "Mix");
		i++;
	}
	return Action:3;
}

public Action:Command_Last(client, args)
{
	if (StrContains(g_LastEntered_SteamID, "STEAM", true) == -1)
	{
		PrintToChat(client, "\x04[%s]:\x03 No player has joined since the plugin loaded...", "Mix");
		return Action:3;
	}
	PrintToChatAll("\x04[%s]:\x03 The last player that joined is:", "Mix");
	PrintToChatAll("\x04[\x03%s\x04] \x03%s .", g_LastEntered_SteamID, g_LastEntered_Name);
	return Action:3;
}

public VersionHasBeenChanged(Handle:convar, String:oldValue[], String:newValue[])
{
	SetConVarString(convar, "4.3", false, false);
	return 0;
}

public OnMapEnd()
{
	if (GetConVarInt(g_CvarEnableAutoSourceTVRecord) == 1)
	{
		ServerCommand("tv_enable 1");
	}
	g_IsRecording = false;
	g_IsRecordManual = false;
	return 0;
}

public OnMapStart()
{
	if (isBuyZoneDisabled)
	{
		if (EnableBuyZone())
		{
			isBuyZoneDisabled = false;
		}
	}
	if (!IsSoundPrecached("ambient/misc/brass_bell_C.wav"))
	{
		PrecacheSound("ambient/misc/brass_bell_C.wav", true);
	}
	new i;
	while (i <= MaxClients)
	{
		g_GaggedPlayers[i] = 0;
		g_MutedPlayers[i] = 0;
		i++;
	}
	hasMixStarted = false;
	didLiveStarted = false;
	isKo3Running = false;
	g_IsItManual = true;
	isRandomBeingUsed = false;
	g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");
	if (g_iAccount == -1)
	{
		PrintToChatAll("\x04[%s]:\x03 Can't find the m_iAccount offest! - Money wont be shown in the mix!", "Mix");
	}
	g_hRestartGame = FindConVar("mp_restartgame");
	if (!g_hRestartGame)
	{
		PrintToChatAll("\x04[%s]:\x03 Couldn't find the cvar mp_restartgame !", "Mix");
		SetFailState("[%s]: Couldn't find the cvar mp_restartgame !", "Mix");
	}
	HookConVarChange(g_hRestartGame, OnGameRestarted);
	GetConVarString(g_hHostName, g_HostName, 150);
	isMapListGenerated = false;
	CreateMapList();
	CheckPropsForCurrentMap();
	return 0;
}

CheckPropsForCurrentMap()
{
	decl String:mapName[64];
	decl String:propMaplist[2048];
	GetCurrentMap(mapName, 64);
	GetConVarString(g_CvarDontRemovePropsMaps, propMaplist, 2048);
	g_IsMapValidToRemoveProps = 1;
	if (StrContains(propMaplist, mapName, true) != -1)
	{
		g_IsMapValidToRemoveProps = 0;
	}
	return 0;
}

public Event_PlayerSpawn(Handle:event, String:name[], bool:dontBroadcast)
{
	if (g_MutedPlayers[GetClientOfUserId(GetEventInt(event, "userid"))])
	{
		SetClientListeningFlags(GetClientOfUserId(GetEventInt(event, "userid")), 1);
	}
	if (GetConVarInt(g_CvarShowMVP) == 1)
	{
		g_ScoresOfTheRound[GetClientOfUserId(GetEventInt(event, "userid"))] = 0;
	}
	new var1;
	if (g_SaveClientsScore && GetConVarInt(g_CvarShowMVP) == 1)
	{
		new c = GetClientOfUserId(GetEventInt(event, "userid"));
		if (IsClientInGame(c))
		{
			SetEntProp(c, PropType:1, "m_iFrags", g_ScoresOfTheGame[c], 4);
			SetEntProp(c, PropType:1, "m_iDeaths", g_DeathsOfTheGame[c], 4);
		}
	}
	new var2;
	if (isPauseBeingUsed && hasMixStarted)
	{
		new i = GetClientOfUserId(GetEventInt(event, "userid"));
		if (IsClientInGame(i))
		{
			SetEntProp(i, PropType:0, "m_iAccount", g_ArrPause[i][0], 4);
			if (IsPlayerAlive(i))
			{
				RemovePlayerGuns(i);
				if (g_ArrPause[i][1] != -1)
				{
					GivePlayerItem(i, pistols[g_ArrPause[i][1]], 0);
				}
				if (g_ArrPause[i][2] != -1)
				{
					GivePlayerItem(i, guns[g_ArrPause[i][2]], 0);
				}
				if (0 < g_ArrPause[i][3])
				{
					new num = 1;
					while (g_ArrPause[i][3] >= num)
					{
						GivePlayerItem(i, "weapon_flashbang", 0);
						num++;
					}
				}
				if (g_ArrPause[i][4] == 1)
				{
					GivePlayerItem(i, "weapon_hegrenade", 0);
				}
				if (g_ArrPause[i][5] == 1)
				{
					GivePlayerItem(i, "weapon_smokegrenade", 0);
				}
				SetEntProp(i, PropType:0, "m_bHasHelmet", g_ArrPause[i][8], 4);
				SetEntProp(i, PropType:0, "m_ArmorValue", g_ArrPause[i][9], 4);
			}
			if (!g_SaveClientsScore)
			{
				SetEntProp(i, PropType:1, "m_iFrags", g_ArrPause[i][6], 4);
				SetEntProp(i, PropType:1, "m_iDeaths", g_ArrPause[i][7], 4);
			}
			PrintToChat(i, "\x04[%s]:\x03 Your weapons, money and score has been refreshed!", "Mix");
		}
	}
	else
	{
		if (hasMixStarted)
		{
			new i = GetClientOfUserId(GetEventInt(event, "userid"));
			if (IsClientInGame(i))
			{
				g_ArrPause[i][0] = GetEntProp(i, PropType:0, "m_iAccount", 4);
				if (!IsPlayerAlive(i))
				{
					g_ArrPause[i][1] = -1;
					g_ArrPause[i][2] = -1;
					g_ArrPause[i][3] = 0;
					g_ArrPause[i][4] = 0;
					g_ArrPause[i][5] = 0;
					g_ArrPause[i][8] = 0;
					g_ArrPause[i][9] = 0;
				}
				else
				{
					g_ArrPause[i][1] = GetPistolNum(GetPlayerWeaponSlot(i, 1));
					g_ArrPause[i][2] = GetPrimaryNum(GetPlayerWeaponSlot(i, 0));
					g_ArrPause[i][3] = WeaponAmmoGetGrenadeCount(i, WeaponAmmoGrenadeType:12);
					g_ArrPause[i][4] = WeaponAmmoGetGrenadeCount(i, WeaponAmmoGrenadeType:11);
					g_ArrPause[i][5] = WeaponAmmoGetGrenadeCount(i, WeaponAmmoGrenadeType:13);
					g_ArrPause[i][8] = GetEntProp(i, PropType:0, "m_bHasHelmet", 4);
					g_ArrPause[i][9] = GetEntProp(i, PropType:0, "m_ArmorValue", 4);
					if (g_ArrPause[i][8] == -1)
					{
						g_ArrPause[i][8] = 0;
					}
					if (g_ArrPause[i][9] == -1)
					{
						g_ArrPause[i][9] = 0;
					}
				}
				g_ArrPause[i][6] = GetEntProp(i, PropType:1, "m_iFrags", 4);
				if (g_ArrPause[i][6] == -1)
				{
					g_ArrPause[i][6] = 0;
				}
				g_ArrPause[i][7] = GetEntProp(i, PropType:1, "m_iDeaths", 4);
				if (g_ArrPause[i][7] == -1)
				{
					g_ArrPause[i][7] = 0;
				}
			}
		}
	}
	return 0;
}

public Action:DisablePause(Handle:timer, any:team)
{
	isPauseBeingUsed = false;
	return Action:0;
}

public Event_RoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		new var1;
		if (GetConVarInt(g_CvarAutoMixEnabled) == 1 && !hasMixStarted)
		{
			UpdateReadyPanel();
			new i = 1;
			while (i <= MaxClients)
			{
				new var2;
				if (IsClientInGame(i) && !IsFakeClient(i))
				{
					ShowReadyPanel(i);
				}
				i++;
			}
		}
		if (isKo3Running)
		{
			if (GetConVarInt(g_CvarHalfAutoLiveStart) == 1)
			{
				PrintToChatAll("\x04[%s]:\x03 Ko3 is running...", "Mix");
			}
			else
			{
				if (hasMixStarted)
				{
					PrintToChatAll("\x04[%s]:\x03 Ko3 is running... type !live to start the match", "Mix");
				}
			}
			new i = 1;
			while (i <= MaxClients)
			{
				new var3;
				if (!IsClientInGame(i) || !IsPlayerAlive(i))
				{
				}
				else
				{
					RemovePlayerGuns(i);
					SetEntProp(i, PropType:0, "m_bHasHelmet", any:1, 4);
					SetEntProp(i, PropType:0, "m_ArmorValue", any:100, 4);
				}
				i++;
			}
			PrintToChatAll("\x04[%s]:\x03 This round is decisive on who will pick their side.", "Mix");
			return 0;
		}
		if (hasMixStarted)
		{
			CreateTimer(0.5, DisablePause, any:0, 0);
			if (GetConVarInt(g_CvarRemoveProps) == 1)
			{
				RemoveProps();
			}
			decl String:teamAName[32];
			decl String:teamBName[32];
			GetConVarString(g_CvarCusomNameTeamCT, teamAName, 32);
			GetConVarString(g_CvarCusomNameTeamT, teamBName, 32);
			new var4;
			if (g_nTScoreH1 == -1 || g_nCTScoreH1 == -1)
			{
				g_nTScoreH1 = 0;
				g_nCTScoreH1 = 0;
			}
			SetTeamScore(3, g_nCTScoreH1);
			SetTeamScore(2, g_nTScoreH1);
			if (g_CurrentHalf == 1)
			{
				if (!g_CurrentRound)
				{
					g_CurrentRound = 1;
				}
				if (g_nTScoreH1 + g_nCTScoreH1 + 1 < g_CurrentRound)
				{
					g_CurrentRound -= 1;
				}
				if (GetConVarInt(g_CvarShowScores) == 1)
				{
					PrintToChatAll("\x04[%s]:\x03 Round\x03 %d \x04- Half\x03 %d\x04 /\x03 2\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", "Mix", g_CurrentRound, g_CurrentHalf, teamAName, g_nCTScoreH1, teamBName, g_nTScoreH1);
				}
				if (!didLiveStarted)
				{
					PrintToChatAll("\x04[%s]:\x03 Not Live!", "Mix");
				}
			}
			else
			{
				if (g_CurrentHalf == 2)
				{
					if (!g_CurrentRound)
					{
						g_CurrentRound = 1;
					}
					new var6;
					if (g_nCTScore == 16 || g_nTScore == 16 || (g_nCTScore == 15 && g_nTScore == 15 && GetConVarInt(g_CvarMr3Enabled)))
					{
						if (GetConVarInt(g_CvarInformWinnerInPanel) == 1)
						{
							if (g_nCTScore == 16)
							{
								CreateWinningTeamPanel(3);
							}
							else
							{
								if (g_nTScore == 16)
								{
									CreateWinningTeamPanel(2);
								}
								if (g_nTScore == g_nCTScore)
								{
									CreateWinningTeamPanel(1);
								}
							}
						}
						else
						{
							if (g_nCTScore == 16)
							{
								CreateTimer(3.0, InformMix, any:3, 0);
							}
							if (g_nTScore == 16)
							{
								CreateTimer(3.0, InformMix, any:2, 0);
							}
							if (g_nTScore == g_nCTScore)
							{
								CreateTimer(3.0, InformMix, any:1, 0);
							}
						}
						hasMixStarted = false;
						didLiveStarted = false;
						g_IsItManual = true;
						if (GetConVarInt(g_CvarAutoMixEnabled) == 1)
						{
							g_AllowReady = true;
							new i;
							while (i < MaxClients)
							{
								g_ReadyPlayers[i] = 0;
								g_ReadyPlayersData[i] = -1;
								i++;
							}
						}
						g_CurrentRound = 1;
						g_CurrentHalf = 1;
						g_nTScore = -1;
						g_nCTScore = -1;
						g_SaveClientsScore = false;
						SetConVarString(g_hHostName, g_HostName, false, false);
						Command_Prac(0, 0);
						if (GetConVarInt(g_CvarRemovePassWhenMixIsEnded) == 1)
						{
							Command_RemovePass(0, 0);
						}
					}
					else
					{
						if (g_nCTScoreH1 + g_nCTScoreH1 + 1 < g_CurrentRound)
						{
							g_CurrentRound -= 1;
						}
						if (GetConVarInt(g_CvarShowScores) == 1)
						{
							PrintToChatAll("\x04[%s]:\x03 Round\x03 %d \x04- Half\x03 %d\x04 /\x03 2\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", "Mix", g_CurrentRound, g_CurrentHalf, teamAName, g_nCTScore, teamBName, g_nTScore);
						}
						new var7;
						if (g_nCTScore == 15 && g_nTScore == 15 && GetConVarInt(g_CvarMr3Enabled) == 1)
						{
							g_nCTScore2 = g_nCTScore;
							g_nTScore2 = g_nTScore;
							new Float:time = GetConVarFloat(g_CvarDelayBeforeSwapping);
							if (time < 0.1)
							{
								time = 0.1;
							}
							CreateTimer(time, SwapTimer, any:0, 0);
							g_CurrentRound = 1;
							g_CurrentHalf = 3;
							new var8;
							if (GetConVarInt(g_CvarHalfAutoLiveStart) && g_IsItManual)
							{
								didLiveStarted = false;
							}
							if (GetConVarInt(g_CvarPlayTeamSwapedSound) == 1)
							{
								if (!IsSoundPrecached("ambient/misc/brass_bell_C.wav"))
								{
									PrecacheSound("ambient/misc/brass_bell_C.wav", true);
								}
								EmitSoundToAll("ambient/misc/brass_bell_C.wav", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
							}
							Command_Mr3(0, 0);
							if (GetConVarInt(g_CvarHalfAutoLiveStart))
							{
								PrintToChatAll("\x04[%s]:\x03 Teams swapped. Mr3 settings are loaded!", "Mix");
							}
							else
							{
								PrintToChatAll("\x04[%s]:\x03 Teams swapped. Mr3 settings are loaded! \x01- \x03Type\x04 !live \x03to start.", "Mix");
							}
						}
						if (GetConVarInt(g_CvarMr3Enabled) == 1)
						{
							new var9;
							if (g_nCTScore == 15 && g_nTScore == 14)
							{
								PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s - \x04If %s wins, Mr3 will be loaded!", "Mix", teamAName, teamBName);
							}
							else
							{
								new var10;
								if (g_nCTScore == 14 && g_nTScore == 15)
								{
									PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s - \x04If %s wins, Mr3 will be loaded!", "Mix", teamBName, teamAName);
								}
								if (g_nCTScore == 15)
								{
									PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", "Mix", teamAName);
								}
								if (g_nTScore == 15)
								{
									PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", "Mix", teamBName);
								}
							}
						}
						if (g_nCTScore == 15)
						{
							PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", "Mix", teamAName);
						}
						if (g_nTScore == 15)
						{
							PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", "Mix", teamBName);
						}
					}
					if (!didLiveStarted)
					{
						PrintToChatAll("\x04[%s]:\x03 Not Live!", "Mix");
					}
				}
				if (g_CurrentHalf > 2)
				{
					if (!g_CurrentRound)
					{
						g_CurrentRound = 1;
					}
					if (g_nTScoreH1 + g_nCTScoreH1 + 1 < g_CurrentRound)
					{
						g_CurrentRound -= 1;
					}
					if (GetConVarInt(g_CvarShowScores) == 1)
					{
						PrintToChatAll("\x04[%s]:\x03 Round\x03 %d \x04- Half\x03 %d\x04 /\x03 4\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", "Mix", g_CurrentRound, g_CurrentHalf, teamAName, g_nCTScore, teamBName, g_nTScore);
					}
					if (g_nCTScore == 18)
					{
						PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", "Mix", teamAName);
					}
					if (g_nTScore == 18)
					{
						PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", "Mix", teamBName);
					}
					if (!didLiveStarted)
					{
						PrintToChatAll("\x04[%s]:\x03 Not Live!", "Mix");
					}
				}
			}
			new var11;
			if (hasMixStarted && didLiveStarted)
			{
				g_CurrentRound += 1;
				new var12;
				if (g_CurrentHalf == 1 && g_CurrentRound == 16)
				{
					g_SwapNow = true;
					if (GetConVarInt(g_CvarShowSwitchInPanel) == 1)
					{
						decl String:titleFormat[32];
						Format(titleFormat, 32, "%s: ", "Mix");
						new Handle:panel = CreatePanel(Handle:0);
						SetPanelTitle(panel, titleFormat, false);
						DrawPanelItem(panel, "", 8);
						DrawPanelText(panel, " Teams will be swapped AUTOMATICALLY after this round. \n *Do NOT* \n change your team.");
						DrawPanelItem(panel, "", 8);
						SetPanelCurrentKey(panel, 10);
						DrawPanelItem(panel, "Close", 16);
						new i = 1;
						while (i <= MaxClients)
						{
							new var13;
							if (IsClientInGame(i) && !IsFakeClient(i))
							{
								SendPanelToClient(panel, i, Handler_DoNothing, GetConVarInt(g_hFreezeTime) + -1);
							}
							i++;
						}
						CloseHandle(panel);
					}
					else
					{
						PrintToChatAll("\x04[%s]:\x03 Teams will be swaped AUTOMATICALLY after this round. Do \x01NOT\x03 change your team.", "Mix");
					}
				}
				new var14;
				if (g_CurrentHalf == 3 && g_CurrentRound == 4)
				{
					g_SwapNow = true;
					if (GetConVarInt(g_CvarShowSwitchInPanel) == 1)
					{
						decl String:titleFormat[32];
						Format(titleFormat, 32, "%s: ", "Mix");
						new Handle:panel = CreatePanel(Handle:0);
						SetPanelTitle(panel, titleFormat, false);
						DrawPanelItem(panel, "", 8);
						DrawPanelText(panel, " Teams will be swapped AUTOMATICALLY after this round. \n *Do NOT* \n change your team.");
						DrawPanelItem(panel, "", 8);
						SetPanelCurrentKey(panel, 10);
						DrawPanelItem(panel, "Close", 16);
						new i = 1;
						while (i <= MaxClients)
						{
							new var15;
							if (IsClientInGame(i) && !IsFakeClient(i))
							{
								SendPanelToClient(panel, i, Handler_DoNothing, GetConVarInt(g_hFreezeTime) + -1);
							}
							i++;
						}
						CloseHandle(panel);
					}
					PrintToChatAll("\x04[%s]:\x03 Teams will be swapped AUTOMATICALLY after this round. Do \x01NOT\x03 change your team.", "Mix");
				}
			}
			if (GetConVarInt(g_CvarShowMoneyAndWeapons) == 1)
			{
				ShowTeamMoneyAndWeapons();
			}
		}
	}
	return 0;
}

RemovePlayerGuns(client)
{
	new gunEnt;
	new i;
	while (i < 5)
	{
		if (!(i == 2))
		{
			while ((gunEnt = GetPlayerWeaponSlot(client, i)) != -1)
			{
				RemovePlayerItem(client, gunEnt);
			}
		}
		i++;
	}
	ClientCommand(client, "slot3");
	return 0;
}

WeaponAmmoGetGrenadeCount(client, WeaponAmmoGrenadeType:type)
{
	return GetEntData(client, type * 4 + g_iToolsAmmo, 4);
}

GetPistolNum(ent)
{
	if (ent == -1)
	{
		return -1;
	}
	decl String:weaponName[20];
	if (!GetEntityClassname(ent, weaponName, 20))
	{
		return -1;
	}
	new i;
	while (i < 6)
	{
		if (StrEqual(pistols[i], weaponName, true))
		{
			return i;
		}
		i++;
	}
	return -1;
}

GetPrimaryNum(ent)
{
	if (ent == -1)
	{
		return -1;
	}
	decl String:weaponName[20];
	if (!GetEntityClassname(ent, weaponName, 20))
	{
		return -1;
	}
	new i;
	while (i < 17)
	{
		if (StrEqual(guns[i], weaponName, true))
		{
			return i;
		}
		i++;
	}
	return -1;
}

public Handler_DoNothing(Handle:menu, MenuAction:action, param1, param2)
{
	return 0;
}

PrintToTeamChat(team, String:message[])
{
	new i = 1;
	while (i <= MaxClients)
	{
		new var1;
		if (IsClientInGame(i) && team == GetClientTeam(i))
		{
			PrintToChat(i, "%s", message);
		}
		i++;
	}
	return 0;
}

ShowTeamMoneyAndWeapons()
{
	new var1;
	if (hasMixStarted && g_iAccount != -1)
	{
		new show = GetConVarInt(g_CvarShowCashInPanel);
		new bool:wasMaxed[66];
		if (show)
		{
			if (show == 1)
			{
				decl String:name[32];
				decl String:msg[152];
				new team;
				new money;
				new i;
				new max;
				new pos = -1;
				decl String:teamAName[32];
				decl String:teamBName[32];
				GetConVarString(g_CvarCusomNameTeamCT, teamAName, 32);
				GetConVarString(g_CvarCusomNameTeamT, teamBName, 32);
				decl String:titleCtFormat[64];
				decl String:titleTFormat[64];
				Format(titleCtFormat, 64, "%s cash: ", teamAName);
				Format(titleTFormat, 64, "%s cash: ", teamBName);
				new Handle:panelT = CreatePanel(Handle:0);
				new Handle:panelCT = CreatePanel(Handle:0);
				SetPanelTitle(panelT, "Mix", false);
				DrawPanelText(panelT, titleTFormat);
				DrawPanelItem(panelT, "-------------------------", 8);
				SetPanelTitle(panelCT, "Mix", false);
				DrawPanelText(panelCT, titleCtFormat);
				DrawPanelItem(panelCT, "-------------------------", 8);
				while (max != -1)
				{
					max = -1;
					i = 1;
					while (i <= MaxClients)
					{
						if (!wasMaxed[i])
						{
							new var3;
							if (!IsClientInGame(i) || !IsClientInGame(i))
							{
								wasMaxed[i] = true;
							}
							team = GetClientTeam(i);
							if (team <= 1)
							{
								wasMaxed[i] = true;
							}
							money = GetEntProp(i, PropType:0, "m_iAccount", 4);
							if (max < money)
							{
								max = money;
								pos = i;
							}
						}
						i++;
					}
					if (!(max == -1))
					{
						GetClientName(pos, name, 32);
						if (GetPlayerWeaponSlot(pos, 0) != -1)
						{
							Format(msg, 150, "%s: %d+", name, max);
						}
						else
						{
							Format(msg, 150, "%s: %d", name, max);
						}
						team = GetClientTeam(pos);
						if (team == 3)
						{
							DrawPanelItem(panelCT, msg, 0);
						}
						else
						{
							if (team == 2)
							{
								DrawPanelItem(panelT, msg, 0);
							}
						}
						wasMaxed[pos] = true;
					}
				}
				DrawPanelItem(panelT, "-------------------------", 8);
				DrawPanelItem(panelT, "Close", 16);
				SetPanelCurrentKey(panelT, 10);
				DrawPanelItem(panelCT, "-------------------------", 8);
				DrawPanelItem(panelCT, "Close", 16);
				SetPanelCurrentKey(panelCT, 10);
				new j = 1;
				while (j <= MaxClients)
				{
					new var4;
					if (IsClientInGame(j) && !IsFakeClient(j))
					{
						team = GetClientTeam(j);
						if (team == 2)
						{
							SendPanelToClient(panelT, j, Handler_DoNothing, GetConVarInt(g_hFreezeTime) + -1);
						}
						if (team == 3)
						{
							SendPanelToClient(panelCT, j, Handler_DoNothing, GetConVarInt(g_hFreezeTime) + -1);
						}
					}
					j++;
				}
				CloseHandle(panelT);
				CloseHandle(panelCT);
			}
		}
		else
		{
			decl String:name[32];
			decl String:msg[152];
			new team;
			new money;
			new i;
			new max;
			new pos = -1;
			PrintToChatAll("----------------------------");
			while (max != -1)
			{
				max = -1;
				i = 1;
				while (i <= MaxClients)
				{
					if (!wasMaxed[i])
					{
						new var2;
						if (!IsClientInGame(i) || !IsClientInGame(i))
						{
							wasMaxed[i] = true;
						}
						team = GetClientTeam(i);
						if (team <= 1)
						{
							wasMaxed[i] = true;
						}
						money = GetEntProp(i, PropType:0, "m_iAccount", 4);
						if (max < money)
						{
							max = money;
							pos = i;
						}
					}
					i++;
				}
				if (!(max == -1))
				{
					GetClientName(pos, name, 32);
					if (GetPlayerWeaponSlot(pos, 0) != -1)
					{
						Format(msg, 150, "\x04 %s:\x03 %d+", name, max);
					}
					else
					{
						Format(msg, 150, "\x04 %s:\x03 %d", name, max);
					}
					team = GetClientTeam(pos);
					PrintToTeamChat(team, msg);
					wasMaxed[pos] = true;
				}
			}
		}
	}
	return 0;
}

public Handle_TeamsVoteMenu(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction:16)
	{
		CloseHandle(menu);
	}
	else
	{
		if (action == MenuAction:32)
		{
			if (!param1)
			{
				new team;
				new i = 1;
				while (i <= MaxClients)
				{
					if (IsClientInGame(i))
					{
						team = GetClientTeam(i);
						if (team == 2)
						{
							ChangeClientTeam(i, 3);
						}
						if (team == 3)
						{
							ChangeClientTeam(i, 2);
						}
					}
					i++;
				}
			}
			isKo3Running = false;
			PrintToChatAll("x04[%s]:\x03 Teams has been decided!");
			Command_Mr15(0, 0);
		}
	}
	return 0;
}

public EventBombExploded(Handle:event, String:name[], bool:dontBroadcast)
{
	new var1;
	if (GetConVarInt(g_CvarEnabled) == 1 && hasMixStarted && didLiveStarted && GetConVarInt(g_CvarShowMVP) == 1 && !isPauseBeingUsed)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		new bool:flag;
		new i = 1;
		while (i <= MaxClients)
		{
			new var2;
			if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 3)
			{
				flag = true;
				if (flag)
				{
					g_ScoresOfTheGame[client] += 3;
				}
			}
			i++;
		}
		if (flag)
		{
			g_ScoresOfTheGame[client] += 3;
		}
	}
	return 0;
}

public EventBombDefused(Handle:event, String:name[], bool:dontBroadcast)
{
	new var1;
	if (GetConVarInt(g_CvarEnabled) == 1 && hasMixStarted && didLiveStarted && GetConVarInt(g_CvarShowMVP) == 1 && !isPauseBeingUsed)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		g_ScoresOfTheGame[client] += 3;
	}
	return 0;
}

public Event_RoundEnd(Handle:event, String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (isPauseBeingUsed)
		{
			SetTeamScore(3, g_nCTScoreH1);
			SetTeamScore(2, g_nTScoreH1);
			return 0;
		}
		if (isKo3Running)
		{
			if (GetConVarInt(g_CvarKnifeWinTeamVote) == 1)
			{
				new Handle:switchteams = CreateMenu(Handle_TeamsVoteMenu, MenuAction:28);
				new win_team = GetEventInt(event, "winner");
				if (win_team == 2)
				{
					SetMenuTitle(switchteams, "Switch team side (to ct team)?");
				}
				else
				{
					if (win_team == 3)
					{
						SetMenuTitle(switchteams, "Switch team side (to t team)?");
					}
				}
				AddMenuItem(switchteams, "yes", "Yes", 0);
				AddMenuItem(switchteams, "no", "No", 0);
				SetMenuExitButton(switchteams, false);
				new clientsArr[64];
				new found;
				new i = 1;
				while (i <= MaxClients)
				{
					new var1;
					if (IsClientInGame(i) && win_team == GetClientTeam(i))
					{
						clientsArr[found] = i;
						found++;
					}
					i++;
				}
				VoteMenu(switchteams, clientsArr, found, 12, 0);
				if (win_team == 2)
				{
					PrintToChatAll("\x04[%s]:\x03 Terrorists will choose now their team!", "Mix");
				}
				else
				{
					if (win_team == 3)
					{
						PrintToChatAll("\x04[%s]:\x03 Counter-Terrorists will choose now their team!", "Mix");
					}
				}
				if (EnableBuyZone())
				{
					isBuyZoneDisabled = false;
				}
				if (GetConVarInt(g_CvarHalfAutoLiveStart) == 1)
				{
					Command_Live(0, 0);
					didLiveStarted = true;
				}
				return 0;
			}
			new var2;
			if (GetConVarInt(g_CvarHalfAutoLiveStart) == 1 && hasMixStarted)
			{
				Command_Live(0, 0);
				didLiveStarted = true;
			}
			if (EnableBuyZone())
			{
				isBuyZoneDisabled = false;
			}
			isKo3Running = false;
			return 0;
		}
		new var3;
		if (hasMixStarted && didLiveStarted)
		{
			new win_team = GetEventInt(event, "winner");
			if (win_team == 2)
			{
				g_nTScoreH1 += 1;
			}
			else
			{
				if (win_team == 3)
				{
					g_nCTScoreH1 += 1;
				}
			}
			SetTeamScore(3, g_nCTScoreH1);
			SetTeamScore(2, g_nTScoreH1);
			if (GetConVarInt(g_CvarShowMVP) == 1)
			{
				new max;
				new winnerIndex = -1;
				new i = 1;
				while (i <= MaxClients)
				{
					if (IsClientConnected(i))
					{
						if (g_ScoresOfTheRound[i] > max)
						{
							max = g_ScoresOfTheRound[i];
							winnerIndex = i;
						}
					}
					i++;
				}
				decl String:attackerName[32];
				GetClientName(winnerIndex, attackerName, 32);
				new kills = max;
				if (kills == 5)
				{
					PrintToChatAll("\x04[%s]:\x03 Round\x01 %d \x03MVP:\x04 %s , \x03Did an \x04ACE!", "Mix", g_CurrentRound + -1, attackerName, kills);
				}
				else
				{
					if (kills == 4)
					{
						PrintToChatAll("\x04[%s]:\x03 Round\x01 %d \x03MVP:\x04 %s , \x03Did a \x04MINI!", "Mix", g_CurrentRound + -1, attackerName, kills);
					}
					if (kills == 3)
					{
						PrintToChatAll("\x04[%s]:\x03 Round\x01 %d \x03MVP:\x04 %s , \x03Killed:\x04 %d \x03Enemies!", "Mix", g_CurrentRound + -1, attackerName, kills);
					}
				}
			}
		}
		new var4;
		if (hasMixStarted && g_SwapNow && didLiveStarted && g_CurrentHalf == 1)
		{
			didLiveStarted = false;
			g_nCTScore = g_nCTScoreH1;
			g_nTScore = g_nTScoreH1;
			g_nCTScore2 = g_nCTScore;
			g_nTScore2 = g_nTScore;
			new Float:time = GetConVarFloat(g_CvarDelayBeforeSwapping);
			if (time < 0.1)
			{
				time = 0.1;
			}
			CreateTimer(time, SwapTimer, any:0, 0);
			PrintToChatAll("\x04[%s]:\x03 Swapping teams...", "Mix");
			g_nTScoreH1 = 0;
			g_nCTScoreH1 = 0;
			g_CurrentRound = 1;
			g_CurrentHalf = 2;
			new var5;
			if (GetConVarInt(g_CvarHalfAutoLiveStart) && g_IsItManual)
			{
				didLiveStarted = false;
			}
			if (GetConVarInt(g_CvarPlayTeamSwapedSound) == 1)
			{
				if (!IsSoundPrecached("ambient/misc/brass_bell_C.wav"))
				{
					PrecacheSound("ambient/misc/brass_bell_C.wav", true);
				}
				EmitSoundToAll("ambient/misc/brass_bell_C.wav", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
			}
			if (GetConVarInt(g_CvarHalfAutoLiveStart))
			{
				new executed;
				if (GetConVarInt(g_CvarUseZBMatchCommand) == 1)
				{
					new Handle:zbWarMode = FindConVar("zb_warmode");
					if (zbWarMode)
					{
						if (GetConVarInt(zbWarMode) == 1)
						{
							ServerCommand("zb_lo3");
							executed = 1;
						}
					}
				}
				if (!executed)
				{
					if (0 < GetConVarInt(g_CvarRestartTimeInLiveCommand))
					{
						ServerCommand("mp_restartgame %d", GetConVarInt(g_CvarRestartTimeInLiveCommand));
					}
					ServerCommand("mp_restartgame 3");
				}
				PrintToChatAll("\x04[%s]:\x03 Teams swapped. HALF 2 Will begin in a few seconds!", "Mix");
				PrintToChatAll("\x04[%s]:\x03 Teams swapped. HALF 2 Will begin in a few seconds!", "Mix");
				PrintToChatAll("\x04[%s]:\x03 Teams swapped. HALF 2 Will begin in a few seconds!", "Mix");
			}
			else
			{
				PrintToChatAll("\x04[%s]:\x03 Teams swapped. HALF 2! \x01- \x03Type\x04 !live \x03to start.", "Mix");
			}
			g_SwapNow = false;
		}
		new var6;
		if (hasMixStarted && g_CurrentHalf == 2 && didLiveStarted)
		{
			new win_team = GetEventInt(event, "winner");
			if (win_team == 2)
			{
				g_nCTScore += 1;
			}
			else
			{
				if (win_team == 3)
				{
					g_nTScore += 1;
				}
			}
			new var8;
			if (g_nCTScore == 16 || g_nTScore == 16 || (g_nCTScore == 15 && g_nTScore == 15 && GetConVarInt(g_CvarMr3Enabled)))
			{
				if (GetConVarInt(g_CvarInformWinnerInPanel) == 1)
				{
					if (g_nCTScore == 16)
					{
						CreateWinningTeamPanel(3);
					}
					else
					{
						if (g_nTScore == 16)
						{
							CreateWinningTeamPanel(2);
						}
						if (g_nTScore == g_nCTScore)
						{
							CreateWinningTeamPanel(1);
						}
					}
				}
				else
				{
					if (g_nCTScore == 16)
					{
						CreateTimer(3.0, InformMix, any:3, 0);
					}
					if (g_nTScore == 16)
					{
						CreateTimer(3.0, InformMix, any:2, 0);
					}
					if (g_nTScore == g_nCTScore)
					{
						CreateTimer(3.0, InformMix, any:1, 0);
					}
				}
				hasMixStarted = false;
				didLiveStarted = false;
				g_IsItManual = true;
				if (GetConVarInt(g_CvarAutoMixEnabled) == 1)
				{
					g_AllowReady = true;
					new i;
					while (i < MaxClients)
					{
						g_ReadyPlayers[i] = 0;
						g_ReadyPlayersData[i] = -1;
						i++;
					}
				}
				g_nTScoreH1 = 0;
				g_nCTScoreH1 = 0;
				g_CurrentRound = 1;
				g_CurrentHalf = 1;
				g_nTScore = -1;
				g_nCTScore = -1;
				g_SaveClientsScore = false;
				SetConVarString(g_hHostName, g_HostName, false, false);
				Command_Prac(0, 0);
				if (GetConVarInt(g_CvarRemovePassWhenMixIsEnded) == 1)
				{
					Command_RemovePass(0, 0);
				}
			}
			else
			{
				new var9;
				if (g_nCTScore == 15 && g_nTScore == 15 && GetConVarInt(g_CvarMr3Enabled) == 1)
				{
					didLiveStarted = false;
					g_nCTScore2 = g_nCTScore;
					g_nTScore2 = g_nTScore;
					new Float:time = GetConVarFloat(g_CvarDelayBeforeSwapping);
					if (time < 0.1)
					{
						time = 0.1;
					}
					CreateTimer(time, SwapTimer, any:0, 0);
					PrintToChatAll("\x04[%s]:\x03 Swapping teams...", "Mix");
					g_nTScoreH1 = 0;
					g_nCTScoreH1 = 0;
					g_CurrentRound = 1;
					g_CurrentHalf = 3;
					new var10;
					if (GetConVarInt(g_CvarHalfAutoLiveStart) && g_IsItManual)
					{
						didLiveStarted = false;
					}
					if (GetConVarInt(g_CvarPlayTeamSwapedSound) == 1)
					{
						if (!IsSoundPrecached("ambient/misc/brass_bell_C.wav"))
						{
							PrecacheSound("ambient/misc/brass_bell_C.wav", true);
						}
						EmitSoundToAll("ambient/misc/brass_bell_C.wav", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
					}
					Command_Mr3(0, 0);
					if (GetConVarInt(g_CvarHalfAutoLiveStart))
					{
						PrintToChatAll("\x04[%s]:\x03 Teams swapped. Mr3 settings are loaded!", "Mix");
					}
					else
					{
						PrintToChatAll("\x04[%s]:\x03 Teams swapped. Mr3 settings are loaded! \x01- \x03Type\x04 !live \x03to start.", "Mix");
					}
				}
			}
		}
		new var11;
		if (hasMixStarted && didLiveStarted)
		{
			new win_team = GetEventInt(event, "winner");
			if (g_CurrentHalf == 3)
			{
				if (win_team == 3)
				{
					g_nCTScore += 1;
				}
				else
				{
					if (win_team == 2)
					{
						g_nTScore += 1;
					}
				}
			}
			else
			{
				if (g_CurrentHalf == 4)
				{
					if (win_team == 2)
					{
						g_nCTScore += 1;
					}
					if (win_team == 3)
					{
						g_nTScore += 1;
					}
				}
			}
			new var12;
			if (g_CurrentHalf == 3 && g_SwapNow && g_nCTScore < 19 && g_nTScore < 19)
			{
				didLiveStarted = false;
				g_nCTScore2 = g_nCTScore;
				g_nTScore2 = g_nTScore;
				new Float:time = GetConVarFloat(g_CvarDelayBeforeSwapping);
				if (time < 0.1)
				{
					time = 0.1;
				}
				CreateTimer(time, SwapTimer, any:0, 0);
				PrintToChatAll("\x04[%s]:\x03 Swapping teams...", "Mix");
				g_nTScoreH1 = 0;
				g_nCTScoreH1 = 0;
				g_CurrentRound = 1;
				g_CurrentHalf = 4;
				new var13;
				if (GetConVarInt(g_CvarHalfAutoLiveStart) && g_IsItManual)
				{
					didLiveStarted = false;
				}
				if (GetConVarInt(g_CvarPlayTeamSwapedSound) == 1)
				{
					if (!IsSoundPrecached("ambient/misc/brass_bell_C.wav"))
					{
						PrecacheSound("ambient/misc/brass_bell_C.wav", true);
					}
					EmitSoundToAll("ambient/misc/brass_bell_C.wav", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				}
				if (GetConVarInt(g_CvarHalfAutoLiveStart))
				{
					PrintToChatAll("\x04[%s]:\x03 Teams swapped. LAST HALF!", "Mix");
				}
				else
				{
					PrintToChatAll("\x04[%s]:\x03 Teams swapped. LAST HALF! \x01- \x03Type\x04 !live \x03to start.", "Mix");
				}
				g_SwapNow = false;
			}
			new var14;
			if (g_nCTScore >= 19 || g_nTScore >= 19)
			{
				if (GetConVarInt(g_CvarInformWinnerInPanel) == 1)
				{
					if (g_nCTScore == 19)
					{
						CreateWinningTeamPanel(3);
					}
					else
					{
						if (g_nTScore == 19)
						{
							CreateWinningTeamPanel(2);
						}
					}
				}
				else
				{
					if (g_nCTScore == 19)
					{
						CreateTimer(3.0, InformMix, any:3, 0);
					}
					if (g_nTScore == 19)
					{
						CreateTimer(3.0, InformMix, any:2, 0);
					}
				}
				hasMixStarted = false;
				didLiveStarted = false;
				g_IsItManual = true;
				if (GetConVarInt(g_CvarAutoMixEnabled) == 1)
				{
					g_AllowReady = true;
					new i;
					while (i < MaxClients)
					{
						g_ReadyPlayers[i] = 0;
						g_ReadyPlayersData[i] = -1;
						i++;
					}
				}
				g_nTScoreH1 = 0;
				g_nCTScoreH1 = 0;
				g_CurrentRound = 1;
				g_CurrentHalf = 1;
				g_nTScore = -1;
				g_nCTScore = -1;
				g_SaveClientsScore = false;
				SetConVarString(g_hHostName, g_HostName, false, false);
				Command_Prac(0, 0);
				if (GetConVarInt(g_CvarRemovePassWhenMixIsEnded) == 1)
				{
					Command_RemovePass(0, 0);
				}
			}
		}
	}
	return 0;
}

public Event_PlayerHurt(Handle:event, String:name[], bool:dontBroadcast)
{
	new var1;
	if (GetConVarInt(g_CvarEnabled) == 1 && GetConVarInt(g_CvarShowTkMessage) == 1 && hasMixStarted && !g_SaveClientsScore)
	{
		new victim = GetClientOfUserId(GetEventInt(event, "userid"));
		new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		new var2;
		if (attacker > 0 && attacker <= MaxClients && GetClientTeam(attacker) == GetClientTeam(victim) && attacker != victim)
		{
			decl String:victimName[32];
			decl String:attackerName[32];
			GetClientName(victim, victimName, 32);
			GetClientName(attacker, attackerName, 32);
			PrintToChatAll("\x04[%s]:\x03 %s teamattacked %s with\x01 %d \x03HP,\x01 %d\x03 armor!", "Mix", attackerName, victimName, GetEventInt(event, "dmg_health"), GetEventInt(event, "dmg_armor"));
		}
	}
	return 0;
}

public Action:Event_PlayerDeath(Handle:event, String:name[], bool:dontBroadcast)
{
	new var1;
	if (hasMixStarted && didLiveStarted && GetConVarInt(g_CvarShowMVP) == 1 && !isPauseBeingUsed)
	{
		new victim = GetClientOfUserId(GetEventInt(event, "userid"));
		new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		new var2;
		if (attacker && victim && IsClientConnected(attacker) && IsClientConnected(victim) && attacker != victim)
		{
			new victimTeam = GetClientTeam(victim);
			new attackerTeam = GetClientTeam(attacker);
			if (attackerTeam != victimTeam)
			{
				g_ScoresOfTheRound[attacker]++;
				g_ScoresOfTheGame[attacker]++;
			}
		}
		new var3;
		if (IsClientConnected(victim) && victim && GetClientTeam(attacker) != GetClientTeam(victim))
		{
			g_DeathsOfTheGame[victim]++;
		}
	}
	return Action:0;
}

public Action:Command_TvRecord(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		new var1;
		if (g_IsRecording && client)
		{
			PrintToChat(client, "\x04[%s]:\x03 Source-Tv is already recording. You can either stop the record, or wait for the end of the mix.", "Mix");
			return Action:3;
		}
		StartRecord();
		g_IsRecordManual = true;
		return Action:3;
	}
	return Action:0;
}

public Action:Command_TvStopRecord(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		ServerCommand("tv_stoprecord");
		g_IsRecording = false;
		g_IsRecordManual = false;
		return Action:3;
	}
	return Action:0;
}

StartRecord()
{
	ServerCommand("tv_stoprecord");
	decl String:recordDir[128];
	decl String:date[32];
	decl String:mapName[16];
	decl String:recordName[80];
	FormatTime(date, 32, "%d-%m-%Y-%H%M", -1);
	GetCurrentMap(mapName, 15);
	if (g_IsRecordManual)
	{
		Format(recordName, 80, "%s-%s", date, mapName);
	}
	else
	{
		Format(recordName, 80, "Auto-%s-%s", date, mapName);
	}
	GetConVarString(g_CvarAutoSourceTVRecordSaveDir, recordDir, 128);
	if (DirExists(recordDir))
	{
		ServerCommand("tv_record \"%s/%s.dem\"", recordDir, recordName);
	}
	else
	{
		ServerCommand("tv_record \"%s.dem\"", recordName);
	}
	g_IsRecording = true;
	return 0;
}

public Action:Command_Pcw(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is already running.", "Mix");
			return Action:3;
		}
		if (GetConVarInt(g_CvarShowMVP) != 1)
		{
			PrintToChat(client, "\x04[%s]:\x03 To use sm_pcw, MVP Scores must be shown!", "Mix");
			return Action:3;
		}
		new var1;
		if (client && GetConVarInt(g_CvarAutoMixEnabled) == 1)
		{
			g_IsItManual = false;
		}
		else
		{
			g_IsItManual = true;
		}
		hasMixStarted = true;
		g_nTScoreH1 = 0;
		g_nCTScoreH1 = 0;
		g_CurrentRound = 1;
		g_nCTScore = 0;
		g_nTScore = 0;
		g_CurrentHalf = 1;
		new i;
		while (i <= MaxClients)
		{
			g_ScoresOfTheGame[i] = 0;
			g_DeathsOfTheGame[i] = 0;
			i++;
		}
		g_SaveClientsScore = true;
		Command_Mr15(client, 0);
		new var2;
		if (GetConVarInt(g_CvarEnableKnifeRound) == 1 && g_IsItManual)
		{
			Command_KO3(client, 0);
			return Action:3;
		}
		new var3;
		if (GetConVarInt(g_CvarEnableAutoSourceTVRecord) == 1 && !g_IsRecordManual)
		{
			if (g_IsRecording)
			{
				Command_TvStopRecord(0, 0);
			}
			g_IsRecording = true;
			g_IsRecordManual = false;
			StartRecord();
		}
		didLiveStarted = true;
		if (isBuyZoneDisabled)
		{
			EnableBuyZone();
			isBuyZoneDisabled = false;
		}
		if (GetConVarInt(g_CvarUseZBMatchCommand) == 1)
		{
			new Handle:zbWarMode = FindConVar("zb_warmode");
			if (zbWarMode)
			{
				if (GetConVarInt(zbWarMode) == 1)
				{
					ServerCommand("zb_lo3");
				}
			}
		}
		else
		{
			if (0 < GetConVarInt(g_CvarRestartTimeInLiveCommand))
			{
				ServerCommand("mp_restartgame %d", GetConVarInt(g_CvarRestartTimeInLiveCommand));
			}
			ServerCommand("mp_restartgame 1");
		}
		return Action:3;
	}
	PrintToChat(client, "\x04[%s]:\x03 This plugin is disabled ... To enable it: \x01sm_mixmod_enable 1", "Mix");
	return Action:0;
}

public Action:Command_Start(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is already running.", "Mix");
			return Action:3;
		}
		new var1;
		if (client && GetConVarInt(g_CvarAutoMixEnabled) == 1)
		{
			g_IsItManual = false;
		}
		else
		{
			g_IsItManual = true;
		}
		isKo3Running = false;
		hasMixStarted = true;
		g_nTScoreH1 = 0;
		g_nCTScoreH1 = 0;
		g_CurrentRound = 1;
		g_nCTScore = 0;
		g_nTScore = 0;
		g_CurrentHalf = 1;
		new i;
		while (i <= MaxClients)
		{
			g_ScoresOfTheGame[i] = 0;
			g_DeathsOfTheGame[i] = 0;
			i++;
		}
		g_SaveClientsScore = false;
		Command_Mr15(client, 0);
		new var2;
		if (GetConVarInt(g_CvarEnableKnifeRound) == 1 && g_IsItManual)
		{
			Command_KO3(client, 0);
			return Action:3;
		}
		new var3;
		if (GetConVarInt(g_CvarEnableAutoSourceTVRecord) == 1 && !g_IsRecordManual)
		{
			if (g_IsRecording)
			{
				Command_TvStopRecord(0, 0);
			}
			g_IsRecording = true;
			g_IsRecordManual = false;
			StartRecord();
		}
		didLiveStarted = true;
		if (isBuyZoneDisabled)
		{
			EnableBuyZone();
			isBuyZoneDisabled = false;
		}
		if (GetConVarInt(g_CvarUseZBMatchCommand) == 1)
		{
			new Handle:zbWarMode = FindConVar("zb_warmode");
			if (zbWarMode)
			{
				if (GetConVarInt(zbWarMode) == 1)
				{
					ServerCommand("zb_lo3");
				}
			}
		}
		else
		{
			if (0 < GetConVarInt(g_CvarRestartTimeInLiveCommand))
			{
				ServerCommand("mp_restartgame %d", GetConVarInt(g_CvarRestartTimeInLiveCommand));
			}
			ServerCommand("mp_restartgame 1");
		}
		return Action:3;
	}
	PrintToChat(client, "\x04[%s]:\x03 This plugin is disabled ... To enable it: \x01sm_mixmod_enable 1", "Mix");
	return Action:0;
}

public Action:Command_Stop(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (isBuyZoneDisabled)
		{
			if (EnableBuyZone())
			{
				isBuyZoneDisabled = false;
			}
		}
		if (isKo3Running)
		{
			isKo3Running = false;
			PrintToChat(client, "\x04[%s]:\x03 Knife round has been disabled!", "Mix");
			return Action:3;
		}
		if (!hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is not running...", "Mix");
			return Action:3;
		}
		hasMixStarted = false;
		didLiveStarted = false;
		isKo3Running = false;
		g_IsItManual = true;
		isRandomBeingUsed = false;
		Command_TvStopRecord(client, args);
		if (GetConVarInt(g_CvarAutoMixEnabled) == 1)
		{
			g_AllowReady = true;
			new i;
			while (i < MaxClients)
			{
				g_ReadyPlayers[i] = 0;
				g_ReadyPlayersData[i] = -1;
				i++;
			}
		}
		g_nTScoreH1 = 0;
		g_nCTScoreH1 = 0;
		g_CurrentRound = 1;
		g_CurrentHalf = 1;
		g_nCTScore = 0;
		g_nTScore = 0;
		g_SaveClientsScore = false;
		if (GetConVarInt(g_CvarStopCustomCfg) == 1)
		{
			if (FileExists("cfg/stop.cfg", false))
			{
				ServerCommand("exec stop");
				return Action:3;
			}
			PrintToChatAll("\x04[%s]:\x03 Couldn't find: stop.cfg so prac or warmup cfg will be executed instead!", "Mix");
		}
		SetConVarString(g_hHostName, g_HostName, false, false);
		Command_Prac(client, 0);
		return Action:3;
	}
	return Action:0;
}

public Action:Command_Live(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (didLiveStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Live is already running!", "Mix");
			return Action:3;
		}
		if (!hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is not running...", "Mix");
			return Action:3;
		}
		g_CurrentRound = 1;
		g_nTScoreH1 = 0;
		g_nCTScoreH1 = 0;
		if (g_CurrentHalf > 1)
		{
			SetTeamScore(3, g_nCTScore2);
			SetTeamScore(2, g_nTScore2);
			g_nCTScore = g_nCTScore2;
			g_nTScore = g_nTScore2;
		}
		didLiveStarted = true;
		isKo3Running = false;
		new var1;
		if (GetConVarInt(g_CvarEnableAutoSourceTVRecord) == 1 && !g_IsRecordManual)
		{
			if (!g_IsRecording)
			{
				g_IsRecording = true;
				g_IsRecordManual = false;
				StartRecord();
			}
		}
		if (isBuyZoneDisabled)
		{
			if (EnableBuyZone())
			{
				isBuyZoneDisabled = false;
			}
		}
		ServerCommand("mp_friendlyfire 1");
		PrintToChatAll("\x04[%s]:\x03 Live is running!", "Mix");
		if (GetConVarInt(g_CvarUseZBMatchCommand) == 1)
		{
			new Handle:zbWarMode = FindConVar("zb_warmode");
			if (zbWarMode)
			{
				if (GetConVarInt(zbWarMode) == 1)
				{
					ServerCommand("zb_lo3");
					return Action:3;
				}
			}
		}
		if (0 < GetConVarInt(g_CvarRestartTimeInLiveCommand))
		{
			ServerCommand("mp_restartgame %d", GetConVarInt(g_CvarRestartTimeInLiveCommand));
		}
		else
		{
			ServerCommand("mp_restartgame 1");
		}
		return Action:3;
	}
	return Action:0;
}

public Action:Command_NotLive(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (!didLiveStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Live is not running...", "Mix");
			return Action:3;
		}
		if (!hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is not running...", "Mix");
			return Action:3;
		}
		isKo3Running = false;
		didLiveStarted = false;
		if (g_CurrentHalf == 1)
		{
			g_nCTScore = g_nCTScoreH1;
			g_nTScore = g_nTScoreH1;
		}
		ServerCommand("mp_friendlyfire 0");
		PrintToChatAll("\x04[%s]:\x03 Not Live!", "Mix");
		return Action:3;
	}
	return Action:0;
}

public Action:Command_RandomTeams(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is already running. You can't random teams now!", "Mix");
			return Action:3;
		}
		new i = 1;
		while (i <= MaxClients)
		{
			new var1;
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				SwitchPlayerTeam(i, 2);
			}
			i++;
		}
		RandomCTPlayers();
		PrintToChatAll("\x04[%s]:\x03 Teams have been randomized!", "Mix");
		return Action:3;
	}
	return Action:0;
}

RandomCTPlayers()
{
	new numSwitched;
	while (numSwitched < 5)
	{
		new client = GetRandomPlayer(2);
		if (client != -1)
		{
			SwitchPlayerTeam(client, 3);
			if (IsPlayerAlive(client))
			{
				CS_RespawnPlayer(client);
			}
			numSwitched++;
		}
		LogMessage("ERROR with Randomizing CT Players...");
		PrintToChatAll("\x04[%s]:\x01 ERROR: Failed to get a random player from T team!", "Mix");
		return 0;
	}
	return 0;
}

public SwitchPlayerTeam(client, team)
{
	if (team > 1)
	{
		CS_SwitchTeam(client, team);
		set_random_model(client, team);
	}
	else
	{
		ChangeClientTeam(client, team);
	}
	return 0;
}

set_random_model(client, team)
{
	new random = GetRandomInt(0, 3);
	switch (team)
	{
		case 2:
		{
			SetEntityModel(client, tmodels[random]);
		}
		case 3:
		{
			SetEntityModel(client, ctmodels[random]);
		}
		default:
		{
		}
	}
	return 0;
}

GetRandomPlayer(team)
{
	new Players[MaxClients + 1];
	new PlayerCount;
	new i = 1;
	while (i <= MaxClients)
	{
		new var1;
		if (IsClientInGame(i) && !IsFakeClient(i) && team == GetClientTeam(i))
		{
			PlayerCount++;
			Players[PlayerCount] = i;
		}
		i++;
	}
	if (PlayerCount)
	{
		return Players[GetRandomInt(0, PlayerCount + -1)];
	}
	return -1;
}

public Action:Command_Pause(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (!didLiveStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Live is not running...", "Mix");
			return Action:3;
		}
		if (!hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is not running...", "Mix");
			return Action:3;
		}
		if (isPauseBeingUsed)
		{
			return Action:3;
		}
		isPauseBeingUsed = true;
		g_CurrentRound -= 1;
		PrintToChatAll("\x04[%s]:\x03 This round won't be counted!", "Mix");
		return Action:3;
	}
	return Action:0;
}

public Action:InformMix(Handle:timer, any:team)
{
	decl String:teamAName[32];
	decl String:teamBName[32];
	GetConVarString(g_CvarCusomNameTeamCT, teamAName, 32);
	GetConVarString(g_CvarCusomNameTeamT, teamBName, 32);
	PrintToChatAll("\x04--- Mix-Plugin created by iDragon ---");
	PrintToChatAll("\x04[%s]:\x03 The mix has Ended!", "Mix");
	if (team == any:3)
	{
		PrintToChatAll("\x04[%s]: \x03The winner is:\x04 %s", "Mix", teamAName);
	}
	else
	{
		if (team == any:2)
		{
			PrintToChatAll("\x04[%s]: \x03The winner is:\x04 %s", "Mix", teamBName);
		}
		if (team == any:1)
		{
			PrintToChatAll("\x04[%s]: \x03There was no winner.\x04 IT'S A DRAW!", "Mix");
		}
	}
	CreateTimer(2.0, DisplayScores, any:0, 0);
	if (isBuyZoneDisabled)
	{
		if (EnableBuyZone())
		{
			isBuyZoneDisabled = false;
		}
	}
	return Action:0;
}

public Action:DisplayScores(Handle:timer)
{
	new max;
	new win = -1;
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientConnected(i))
		{
			if (g_ScoresOfTheGame[i] >= max)
			{
				max = g_ScoresOfTheGame[i];
				win = i;
			}
		}
		i++;
	}
	if (win < 1)
	{
		PrintToChatAll("\x04[%s]:\x03 There was an error trying to find the mvp player...", "Mix");
		return Action:0;
	}
	decl String:winnerName[36];
	GetClientName(win, winnerName, 33);
	new kills = g_ScoresOfTheGame[win];
	PrintToChatAll("\x04[%s]:\x03 Kills Stat:", "Mix");
	PrintToChatAll("------------------");
	PrintToChatAll("\x03 - The \x01MVP:\x04 %s , \x03Killed:\x04 %d \x03Enemies!", winnerName, kills);
	Command_TvStopRecord(0, 0);
	return Action:0;
}

CreateWinningTeamPanel(team)
{
	if (g_WinTeamPanel)
	{
		CloseHandle(g_WinTeamPanel);
	}
	decl String:teamAName[32];
	decl String:teamBName[32];
	GetConVarString(g_CvarCusomNameTeamCT, teamAName, 32);
	GetConVarString(g_CvarCusomNameTeamT, teamBName, 32);
	decl String:titleFormat[32];
	decl String:teamNameFormat[152];
	Format(titleFormat, 32, "%s - Winning team\n --- Plugin created by iDragon", "Mix");
	g_WinTeamPanel = CreatePanel(Handle:0);
	SetPanelTitle(g_WinTeamPanel, titleFormat, false);
	DrawPanelItem(g_WinTeamPanel, "", 8);
	if (team == 3)
	{
		Format(teamNameFormat, 150, "--------------\nThe mix has ended!\n\n *** The winner is ***\n  -* %s *- \n------------", teamAName);
	}
	else
	{
		if (team == 2)
		{
			Format(teamNameFormat, 150, "--------------\nThe mix has ended!\n\n *** The winner is ***\n  -* %s *- \n------------", teamBName);
		}
		if (team == 1)
		{
			Format(teamNameFormat, 150, "--------------\nThe mix has ended!\n\n *** It's a DRAW! ***\n \n------------");
		}
	}
	DrawPanelText(g_WinTeamPanel, teamNameFormat);
	DrawPanelItem(g_WinTeamPanel, "", 8);
	SetPanelCurrentKey(g_WinTeamPanel, 10);
	DrawPanelItem(g_WinTeamPanel, "Close", 16);
	new i = 1;
	while (i <= MaxClients)
	{
		new var1;
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			SendPanelToClient(g_WinTeamPanel, i, Handler_DoNothing, 30);
		}
		i++;
	}
	CreateTimer(2.0, DisplayScores, any:0, 0);
	return 0;
}

public Action:Command_Mr15(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		decl String:cfgName[128];
		decl String:cfgPath[136];
		GetConVarString(g_CvarCustomLiveCfg, cfgName, 128);
		Format(cfgPath, 135, "cfg/%s", cfgName);
		if (FileExists(cfgPath, false))
		{
			ServerCommand("exec %s", cfgName);
		}
		else
		{
			if (FileExists("cfg/mr15.cfg", false))
			{
				ServerCommand("exec mr15");
			}
			if (FileExists("cfg/match.cfg", false))
			{
				ServerCommand("exec match");
			}
			if (FileExists("cfg/live.cfg", false))
			{
				ServerCommand("exec live");
			}
			if (FileExists("cfg/esl5on5.cfg", false))
			{
				ServerCommand("exec esl5on5");
			}
			PrintToChatAll("\x04[%s]:\x03 Couldn't execute the %s / match / mr15 / live / esl5on5 config!", "Mix", cfgName);
		}
		return Action:3;
	}
	return Action:0;
}

public Action:Command_Prac(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		decl String:cfgName[128];
		decl String:cfgPath[136];
		GetConVarString(g_CvarCustomPracCfg, cfgName, 128);
		Format(cfgPath, 135, "cfg/%s", cfgName);
		if (FileExists(cfgPath, false))
		{
			ServerCommand("exec %s", cfgName);
		}
		else
		{
			if (FileExists("cfg/prac.cfg", false))
			{
				ServerCommand("exec prac");
			}
			if (FileExists("cfg/warmup.cfg", false))
			{
				ServerCommand("exec warmup");
			}
			PrintToChatAll("\x04[%s]:\x03 Couldn't execute the %s / warmup / prac config!", "Mix", cfgName);
		}
		return Action:3;
	}
	return Action:0;
}

public Action:Command_Mr3(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (GetConVarInt(g_CvarMr3Enabled) == 1)
		{
			decl String:cfgName[128];
			decl String:cfgPath[136];
			GetConVarString(g_CvarCustomMr3Cfg, cfgName, 128);
			Format(cfgPath, 135, "cfg/%s", cfgName);
			if (FileExists(cfgPath, false))
			{
				ServerCommand("exec %s", cfgName);
				PrintToChatAll("\x04[%s]:\x03 %s Config has been loaded...", "Mix", cfgName);
			}
			else
			{
				if (FileExists("cfg/mr3.cfg", false))
				{
					ServerCommand("exec mr3");
					PrintToChatAll("\x04[%s]:\x03 MR3 Config has been loaded...", "Mix");
				}
				PrintToChatAll("\x04[%s]:\x03 Couldn't execute the mr3 config!", "Mix");
			}
		}
		else
		{
			PrintToChat(client, "\x04[%s]:\x03 Mr3 is disabled... mr3 settings will not be loaded!", "Mix");
		}
		return Action:3;
	}
	return Action:0;
}

public Action:Command_KO3(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (didLiveStarted)
		{
			PrintToChatAll("\x04[%s]:\x03 Live is running... ko3 settings won't load!", "Mix");
			return Action:3;
		}
		isKo3Running = true;
		if (!isBuyZoneDisabled)
		{
			if (DisableBuyZone())
			{
				isBuyZoneDisabled = true;
			}
		}
		if (GetConVarInt(g_CvarUseKo3Command) == 1)
		{
			new Handle:zbWarMode = FindConVar("zb_warmode");
			if (zbWarMode)
			{
				if (GetConVarInt(zbWarMode) == 1)
				{
					ServerCommand("zb_ko3");
					return Action:3;
				}
			}
		}
		if (0 < GetConVarInt(g_CvarRestartTimeInLiveCommand))
		{
			ServerCommand("mp_restartgame %d", GetConVarInt(g_CvarRestartTimeInLiveCommand));
		}
		else
		{
			ServerCommand("mp_restartgame 1");
		}
		PrintToChatAll("\x04[%s]:\x03 Knives round!", "Mix");
		PrintToChatAll("\x04[%s]:\x03 Knives round!", "Mix");
		PrintToChatAll("\x04[%s]:\x03 Knives round!", "Mix");
		PrintToChatAll("\x04[%s]:\x03 Knives round!", "Mix");
		PrintToChatAll("\x04[%s]:\x03 Knives round!", "Mix");
		PrintToChatAll("\x04[%s]:\x03 Knives round!", "Mix");
		PrintToChatAll("\x04[%s]:\x03 Knives round!", "Mix");
		PrintToChatAll("\x04[%s]:\x03 Knives round!", "Mix");
		return Action:3;
	}
	return Action:0;
}

public Action:Command_Pass(client, args)
{
	new var1;
	if (GetConVarInt(g_CvarEnabled) == 1 && GetConVarInt(g_CvarEnablePasswords) == 1)
	{
		if (args < 1)
		{
			decl String:sPass[64];
			GetConVarString(g_hPassword, sPass, 64);
			if (GetUserAdmin(client) != -1)
			{
				PrintToChatAll("\x04[%s]:\x03 The server password is: %s", "Mix", sPass);
			}
			else
			{
				new var2;
				if (isRandomPasswordWasLastPw && GetConVarInt(g_CvarRpwShowPass))
				{
					PrintToChat(client, "\x04[%s]:\x03 The server password is: ***RANDOM***", "Mix");
					if (GetUserAdmin(client) != -1)
					{
						PrintToChat(client, "\x04*** %s", sPass);
					}
				}
				PrintToChat(client, "\x04[%s]:\x03 The server password is: %s", "Mix", sPass);
			}
		}
		else
		{
			if (GetUserAdmin(client) != -1)
			{
				new String:pass[64];
				GetCmdArg(1, pass, 64);
				SetConVarString(g_hPassword, pass, false, false);
				PrintToChatAll("\x04[%s]:\x03 Server password is now: %s", "Mix", pass);
				isRandomPasswordWasLastPw = false;
			}
			PrintToChat(client, "[SM] Only admins can change the password!");
		}
		return Action:3;
	}
	return Action:0;
}

public Action:Command_GenerateRandomPassword(client, args)
{
	new var1;
	if (GetConVarInt(g_CvarEnabled) == 1 && GetConVarInt(g_CvarEnablePasswords) == 1)
	{
		new rnd = GetRandomInt(100, 1000);
		SetConVarInt(g_hPassword, rnd, false, false);
		new var3;
		if (GetConVarInt(g_CvarRpwShowPass) == 1 || (!g_IsItManual && client))
		{
			PrintToChatAll("\x04[%s]:\x03 The server password is: %d", "Mix", rnd);
		}
		else
		{
			if (!(GetConVarInt(g_CvarRpwShowPass)))
			{
				PrintToChatAll("\x04[%s]:\x03 The server password is: ***RANDOM***", "Mix");
				if (client)
				{
					PrintToChat(client, "\x04*** %d", rnd);
				}
				else
				{
					PrintToServer("[%s]: Random pass: %d", rnd);
				}
				isRandomPasswordWasLastPw = true;
			}
		}
		return Action:3;
	}
	return Action:0;
}

public Action:Command_RemovePass(client, args)
{
	new var1;
	if (GetConVarInt(g_CvarEnabled) == 1 && GetConVarInt(g_CvarEnablePasswords) == 1)
	{
		SetConVarString(g_hPassword, "none", false, false);
		PrintToChatAll("\x04[%s]:\x03 Password has been removed!", "Mix");
		isRandomPasswordWasLastPw = false;
		return Action:3;
	}
	return Action:0;
}

public Action:Command_SwapTeams(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (args)
		{
			if (args == 1)
			{
				ReplyToCommand(client, "[%s]: Usage: sm_st <player> <team>", "Mix");
				return Action:3;
			}
			if (args >= 2)
			{
				decl String:searchFor[64];
				decl String:target_name[64];
				decl String:teamNum[8];
				new targetsArr[64];
				new found;
				new team = 1;
				new bool:isML;
				GetCmdArg(1, searchFor, 64);
				GetCmdArg(2, teamNum, 8);
				if (StrContains(teamNum, "ct", true) != -1)
				{
					team = 3;
				}
				else
				{
					if (StrContains(teamNum, "t", true) != -1)
					{
						team = 2;
					}
					if (StrContains(teamNum, "spec", true) != -1)
					{
						team = 1;
					}
					team = StringToInt(teamNum, 10);
					new var1;
					if (team <= 0 || team > 3)
					{
						PrintToChat(client, "\x04[%s]:\x03 Usage: sm_st <player> [team] (legal teams: t,ct,spec,1,2,3)", "Mix");
						return Action:3;
					}
				}
				found = ProcessTargetString(searchFor, client, targetsArr, 64, 0, target_name, 64, isML);
				if (0 < found)
				{
					new bool:flag;
					if (didLiveStarted)
					{
						didLiveStarted = false;
						flag = true;
					}
					new target;
					while (target < found)
					{
						if (team != GetClientTeam(targetsArr[target]))
						{
							ChangeClientTeam(targetsArr[target], team);
							PrintToChat(targetsArr[target], "\x04[%s]:\x03 Your team has been changed!", "Mix");
						}
						target++;
					}
					if (flag)
					{
						didLiveStarted = true;
					}
					PrintToChat(client, "\x04[%s]:\x03 %s team has been changed!", "Mix", searchFor);
				}
				else
				{
					PrintToChat(client, "\x04[%s]:\x03Couldn't find %s in the server...", "Mix", searchFor);
				}
				return Action:3;
			}
		}
		new bool:flag;
		if (didLiveStarted)
		{
			didLiveStarted = false;
			flag = true;
		}
		new team;
		new i = 1;
		while (i <= MaxClients)
		{
			if (IsClientInGame(i))
			{
				team = GetClientTeam(i);
				if (team == 2)
				{
					ChangeClientTeam(i, 3);
					PrintToChat(client, "\x04[%s]:\x03 You have been swapped to \x01 Counter Terrorists\x03 Team.", "Mix");
				}
				else
				{
					if (team == 3)
					{
						ChangeClientTeam(i, 2);
						PrintToChat(client, "\x04[%s]:\x03 You have been swapped to \x01 Terrorists\x03 Team.", "Mix");
					}
				}
			}
			i++;
		}
		PrintToChatAll("\x04[%s]:\x03 All players have been swapped.", "Mix");
		if (flag)
		{
			didLiveStarted = true;
		}
		return Action:3;
	}
	return Action:0;
}

public Action:Command_RestartTheGame(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (GetConVarInt(g_CvarEnableRRCommand) == 1)
		{
			new t = 1;
			if (args)
			{
				decl String:ax[16];
				GetCmdArg(1, ax, 16);
				t = StringToInt(ax, 10);
			}
			ServerCommand("mp_restartgame %d", t);
			return Action:3;
		}
	}
	return Action:0;
}

public OnGameRestarted(Handle:cvar, String:oldVal[], String:newVal[])
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (0 < StringToInt(newVal, 10))
		{
			RestartTheGame();
		}
	}
	return 0;
}

RestartTheGame()
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (!hasMixStarted)
		{
			return 0;
		}
		g_CurrentRound = 0;
		g_nTScoreH1 = -1;
		g_nCTScoreH1 = -1;
		if (g_CurrentHalf > 1)
		{
			SetTeamScore(3, g_nCTScore2);
			SetTeamScore(2, g_nTScore2);
			g_nCTScore = g_nCTScore2;
			g_nTScore = g_nTScore2;
		}
		SetTeamScore(3, 0);
		SetTeamScore(2, 0);
		new i;
		while (i <= MaxClients)
		{
			g_ScoresOfTheGame[i] = 0;
			g_DeathsOfTheGame[i] = 0;
			i++;
		}
	}
	return 0;
}

public Action:ShowScores(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (!IsFakeClient(client))
		{
			if (!hasMixStarted)
			{
				PrintToChat(client, "\x04[%s]:\x03 Mix is not running yet...", "Mix");
				return Action:3;
			}
			decl String:teamAName[36];
			decl String:teamBName[36];
			GetConVarString(g_CvarCusomNameTeamCT, teamAName, 33);
			GetConVarString(g_CvarCusomNameTeamT, teamBName, 33);
			if (g_CurrentHalf == 1)
			{
				PrintToChat(client, "\x04[%s]:\x03 Round\x03 %d \x04- Half\x03 %d\x04 /\x03 2\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", "Mix", g_CurrentRound, g_CurrentHalf, teamAName, g_nCTScoreH1, teamBName, g_nTScoreH1);
				if (!didLiveStarted)
				{
					PrintToChat(client, "\x04[%s]:\x03 Not Live!", "Mix");
				}
			}
			else
			{
				if (g_CurrentHalf == 2)
				{
					PrintToChat(client, "\x04[%s]:\x03 Round\x03 %d \x04- Half\x03 %d\x04 /\x03 2\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", "Mix", g_CurrentRound, g_CurrentHalf, teamAName, g_nCTScore, teamBName, g_nTScore);
					if (GetConVarInt(g_CvarMr3Enabled) == 1)
					{
						new var1;
						if (g_nCTScore == 15 && g_nTScore == 14)
						{
							PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s - \x04If %s wins, Mr3 will be loaded!", "Mix", teamAName, teamBName);
						}
						else
						{
							new var2;
							if (g_nCTScore == 14 && g_nTScore == 15)
							{
								PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s - \x04If %s wins, Mr3 will be loaded!", "Mix", teamBName, teamAName);
							}
							if (g_nCTScore == 15)
							{
								PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", "Mix", teamAName);
							}
							if (g_nTScore == 15)
							{
								PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", "Mix", teamBName);
							}
						}
					}
					else
					{
						if (g_nCTScore == 15)
						{
							PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", "Mix", teamAName);
						}
						if (g_nTScore == 15)
						{
							PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", "Mix", teamBName);
						}
					}
					if (!didLiveStarted)
					{
						PrintToChat(client, "\x04[%s]:\x03 Not Live!", "Mix");
					}
				}
				if (g_CurrentHalf > 2)
				{
					PrintToChat(client, "\x04[%s]:\x03 Round\x03 %d \x04- Half\x03 %d\x04 /\x03 4\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", "Mix", g_CurrentRound, g_CurrentHalf, teamAName, g_nCTScore, teamBName, g_nTScore);
					if (g_nCTScore == 18)
					{
						PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", "Mix", teamAName);
					}
					if (g_nTScore == 18)
					{
						PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", "Mix", teamBName);
					}
					if (!didLiveStarted)
					{
						PrintToChat(client, "\x04[%s]:\x03 Not Live!", "Mix");
					}
				}
			}
		}
		return Action:3;
	}
	return Action:0;
}

public Action:Command_SetMixScore(client, args)
{
	new var1;
	if (GetConVarInt(g_CvarEnabled) == 1 && ENABLE_PLUGIN_CHECKING)
	{
		if (args < 3)
		{
			PrintToChat(client, "[Usage]: sm_setmixscore <half> <ct> <t>");
			return Action:3;
		}
		decl String:half[16];
		decl String:ct[16];
		decl String:t[16];
		GetCmdArg(1, half, 16);
		GetCmdArg(2, ct, 16);
		GetCmdArg(3, t, 16);
		g_nCTScore = StringToInt(ct, 10);
		g_nTScore = StringToInt(t, 10);
		g_CurrentHalf = StringToInt(half, 10);
		PrintToChat(client, "Scores has been set!");
		return Action:3;
	}
	return Action:0;
}

public Action:Command_KickCT(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		KickTeam(client, 3, GetConVarInt(g_CvarKickAdmins));
		PrintToChatAll("\x04[%s]:\x03 Counter-Terrorist team has been kicked!", "Mix");
		return Action:3;
	}
	return Action:0;
}

public Action:Command_KickT(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		KickTeam(client, 2, GetConVarInt(g_CvarKickAdmins));
		PrintToChatAll("\x04[%s]:\x03 Terrorist team has been kicked!", "Mix");
		return Action:3;
	}
	return Action:0;
}

KickTeam(client, team, adminsImmunity)
{
	new i = 1;
	while (i <= MaxClients)
	{
		new var1;
		if (IsClientInGame(i) && !IsFakeClient(i) && i != client && team == GetClientTeam(i))
		{
			if (adminsImmunity == 1)
			{
				if (GetUserAdmin(i) == -1)
				{
					KickClient(client, "[%s]: You have been kicked by the admin!", "Mix");
				}
			}
			KickClient(client, "[%s]: You have been kicked by the admin!", "Mix");
		}
		i++;
	}
	return 0;
}

public Action:Command_Maps(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (isMapListGenerated)
		{
			DisplayMenu(g_MapListMenu, client, 30);
			PrintToChat(client, "\x04[%s]:\x03 Choose a map to changelevel!", "Mix");
		}
		else
		{
			CreateMapList();
			PrintToChat(client, "\x04[%s]:\x03 Map list is being created right now! please use\x01 sm_maps\x03 command agaon in a few seconds...", "Mix");
		}
		return Action:3;
	}
	return Action:0;
}

CreateMapList()
{
	if (!isMapListGenerated)
	{
		decl String:mapName[64];
		decl FileType:type;
		new nameLen;
		if (g_MapListMenu)
		{
			CloseHandle(g_MapListMenu);
		}
		g_MapListMenu = CreateMenu(MapListMenuHandler, MenuAction:28);
		SetMenuTitle(g_MapListMenu, "%s: Map List", "Mix");
		switch (GetConVarInt(g_CvarMapListFrom))
		{
			case 0:
			{
				new Handle:mapsDir = OpenDirectory("maps/");
				while (ReadDirEntry(mapsDir, mapName, 64, type))
				{
					if (type == FileType:2)
					{
						nameLen = strlen(mapName) + -4;
						if (nameLen == StrContains(mapName, ".bsp", false))
						{
							if (StrContains(mapName, "de_", true) != -1)
							{
								strcopy(mapName, nameLen + 1, mapName);
								AddMenuItem(g_MapListMenu, mapName, mapName, 0);
							}
						}
					}
				}
				CloseHandle(mapsDir);
			}
			case 1:
			{
				new Handle:mapsFile = OpenFile("mapcycle.txt", "r");
				while (ReadFileLine(mapsFile, mapName, 64))
				{
					if (StrContains(mapName, "de_", true) != -1)
					{
						AddMenuItem(g_MapListMenu, mapName, mapName, 0);
					}
				}
				CloseHandle(mapsFile);
			}
			default:
			{
			}
		}
		SetMenuExitButton(g_MapListMenu, true);
		isMapListGenerated = true;
	}
	return 0;
}

public MapListMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction:4)
	{
		decl String:map[64];
		new bool:worked = GetMenuItem(menu, param2, map, 64, 0, "", 0);
		if (worked)
		{
			PrintToChatAll("\x04[%s]:\x03 Changing map to:\x01 %s", "Mix", map);
			ServerCommand("changelevel %s", map);
		}
		else
		{
			PrintToChat(param1, "\x04[%s]:\x03 Failed to change map to:\x01 %s", "Mix", map);
		}
	}
	return 0;
}

public Action:Command_DisableChat(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (args < 1)
		{
			ReplyToCommand(client, "[%s]: Usage: sm_disablechat <num> (0-Enable chat, 1-Disable chat, 2-Disable only when live)", "Mix");
			return Action:3;
		}
		decl String:setTo[4];
		GetCmdArg(1, setTo, 2);
		new num = StringToInt(setTo, 10);
		new var1;
		if (num > 2 || num < 0)
		{
			ReplyToCommand(client, "[%s]: Usage: sm_disablechat <num> (0-Enable chat, 1-Disable chat, 2-Disable only when live)", "Mix");
			return Action:3;
		}
		SetConVarString(g_CvarDisableSayCommand, setTo, false, false);
		switch (num)
		{
			case 0:
			{
				PrintToChatAll("\x04[%s]:\x03 Public chat is enabled!", "Mix");
			}
			case 1:
			{
				PrintToChatAll("\x04[%s]:\x03 Public chat is disabled!", "Mix");
			}
			case 2:
			{
				PrintToChatAll("\x04[%s]:\x03 Public chat is disabled when live is running!", "Mix");
			}
			default:
			{
			}
		}
		return Action:3;
	}
	return Action:0;
}

public Action:Command_SayChat(client, args)
{
	if (!IsChatTrigger())
	{
		if (g_GaggedPlayers[client])
		{
			return Action:3;
		}
		new var3;
		if (GetConVarInt(g_CvarEnabled) == 1 && (GetConVarInt(g_CvarDisableSayCommand) == 1 || (GetConVarInt(g_CvarDisableSayCommand) == 2 && hasMixStarted && didLiveStarted)))
		{
			return Action:3;
		}
	}
	return Action:0;
}

public Action:Command_MixHelp(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (g_HelpPanel)
		{
			DisplayMenu(g_HelpPanel, client, 180);
		}
		else
		{
			CreateHelpPanel();
			PrintToChat(client, "\x04[%s]:\x03 Try again in a few seconds!", "Mix");
		}
		return Action:3;
	}
	return Action:0;
}

CreateHelpPanel()
{
	if (g_HelpPanel)
	{
		CloseHandle(g_HelpPanel);
	}
	g_HelpPanel = CreateMenu(HelpMenuHandler, MenuAction:28);
	SetMenuTitle(g_HelpPanel, "%s - Help \n ---Created by iDragon\n", "Mix");
	AddMenuItem(g_HelpPanel, "Admin commands:", "Admin commands:", 0);
	AddMenuItem(g_HelpPanel, "--------------", "---------------", 0);
	AddMenuItem(g_HelpPanel, "sm_start - Starts a new mix", "sm_start - Starts a new mix", 0);
	AddMenuItem(g_HelpPanel, "sm_pcw - Starts a new mix (saving scores!)", "sm_pcw - Starts a new mix", 0);
	AddMenuItem(g_HelpPanel, "sm_stop - Stops the current mix", "sm_stop - Stops the current mix", 0);
	AddMenuItem(g_HelpPanel, "sm_live - Starts the game (live ...).", "sm_live - Starts the game (live ...).", 0);
	AddMenuItem(g_HelpPanel, "sm_nl - Pause the mix untill sm_live is used.", "sm_nl - Pause the mix untill sm_live is used.", 0);
	AddMenuItem(g_HelpPanel, "sm_mr15 - Executes the mr15 (match) config.", "sm_mr15 - Executes the mr15 (match) config.", 0);
	AddMenuItem(g_HelpPanel, "sm_prac - Executes the prac (warmup) config.", "sm_prac - Executes the prac (warmup) config.", 0);
	AddMenuItem(g_HelpPanel, "sm_pw - Change the server password. usage: sm_pw <pass>", "sm_pw - Change the server password.", 0);
	AddMenuItem(g_HelpPanel, "sm_st <player> [t/ct/spec/1/2/3] or sm_st", "sm_st - Swaps player or players team", 0);
	AddMenuItem(g_HelpPanel, "sm_rpw - Set a random password to the server.", "sm_rpw - Set a random password to the server.", 0);
	AddMenuItem(g_HelpPanel, "sm_rr <seconds>", "sm_rr - Restart the game", 0);
	AddMenuItem(g_HelpPanel, "sm_kickct - Kick ct team.", "sm_kickct - Kick ct team.", 0);
	AddMenuItem(g_HelpPanel, "sm_kickt -Kick t team.", "sm_kickt -Kick t team.", 0);
	AddMenuItem(g_HelpPanel, "sm_maps - Show maps menu.", "sm_maps - Show maps menu.", 0);
	AddMenuItem(g_HelpPanel, "sm_ko3 or sm_knifes - Starts knife round.", "sm_ko3 or sm_knifes - Starts knife round.", 0);
	AddMenuItem(g_HelpPanel, "sm_spec <player>", "sm_spec - Move player to spectors team.", 0);
	AddMenuItem(g_HelpPanel, "sm_mix - Open the mix menu.", "sm_mix - Open the mix menu.", 0);
	AddMenuItem(g_HelpPanel, "sm_pause - Pause the mix (the current round was never played)", "sm_pause - Pause the mix (the current round was never played)", 0);
	AddMenuItem(g_HelpPanel, "sm_disablechat: 0-Enable chat, 1-Disable chat, 2-Disable chat only when live is running.", "sm_disablechat - Change public chat settings.", 0);
	AddMenuItem(g_HelpPanel, "sm_npw - Remove the server password.", "sm_npw - Remove the server password.", 0);
	AddMenuItem(g_HelpPanel, "sm_record - Starts a record", "sm_record - Starts a record", 0);
	AddMenuItem(g_HelpPanel, "sm_stoprecord - Stop the record (if running).", "sm_stoprecord - Stop the record (if running).", 0);
	AddMenuItem(g_HelpPanel, "sm_random / sm_rnd - Random the teams.", "sm_random / sm_rnd - Randomizing the teams.", 0);
	AddMenuItem(g_HelpPanel, "Player commands in next page...", "---------------------", 0);
	AddMenuItem(g_HelpPanel, "Player commands in next page...", "---Player commands---", 0);
	AddMenuItem(g_HelpPanel, "Player commands in next page...", "-----In next---------", 0);
	AddMenuItem(g_HelpPanel, "Player commands in next page...", "-------Page----------", 0);
	AddMenuItem(g_HelpPanel, "Player commands in next page...", "---------------------", 0);
	AddMenuItem(g_HelpPanel, "Player commands:", "Player commands:", 0);
	AddMenuItem(g_HelpPanel, "sm_score - Show the round number and team scores.", "sm_score - Show the round number and team scores.", 0);
	AddMenuItem(g_HelpPanel, "sm_password or sm_pw - To see the server password.", "sm_password or sm_pw - To see the server password.", 0);
	AddMenuItem(g_HelpPanel, "sm_ready or sm_rdy - Become ready.", "sm_ready or sm_rdy - Become ready.", 0);
	AddMenuItem(g_HelpPanel, "sm_notready or sm_unready - Become not ready.", "sm_notready or sm_unready - Become not ready.", 0);
	AddMenuItem(g_HelpPanel, "sm_teams - Only when auto-mix running! see teams.", "sm_teams - Only when auto-mix running! see teams.", 0);
	AddMenuItem(g_HelpPanel, "sm_mixhelp - See all the plugin commands.", "sm_mixhelp - See all the plugin commands.", 0);
	AddMenuItem(g_HelpPanel, "-----------------------", "-----------------------", 0);
	AddMenuItem(g_HelpPanel, "--- Created by iDragon ---", "--- Created by iDragon ---", 0);
	decl String:versio[32];
	Format(versio, 32, "Mix-Plugin version: %s", "4.3");
	AddMenuItem(g_HelpPanel, versio, versio, 0);
	AddMenuItem(g_HelpPanel, "http://forums.alliedmods.net/showthread.php?p=1512637", "Download this plugin (click)", 0);
	AddMenuItem(g_HelpPanel, "-----------------------", "-----------------------", 0);
	SetMenuExitButton(g_HelpPanel, true);
	return 0;
}

public HelpMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction:256)
	{
		return 0;
	}
	if (action == MenuAction:4)
	{
		decl String:info[128];
		GetMenuItem(menu, param2, info, 128, 0, "", 0);
		PrintToChat(param1, "\x04[%s]:\x03 %s", "Mix", info);
	}
	return 0;
}

public Action:Command_Spec(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (args < 1)
		{
			ReplyToCommand(client, "[%s]: Usage: sm_spec <player>", "Mix");
			return Action:3;
		}
		decl String:searchFor[64];
		decl String:target_name[64];
		new targetsArr[64];
		new found;
		new bool:isML;
		GetCmdArg(1, searchFor, 64);
		found = ProcessTargetString(searchFor, client, targetsArr, 64, 0, target_name, 64, isML);
		if (0 < found)
		{
			new target;
			while (target < found)
			{
				ChangeClientTeam(targetsArr[target], 1);
				PrintToChat(targetsArr[target], "\x04[%s]:\x03 You have been moved to the spectors team!", "Mix");
				target++;
			}
			PrintToChat(client, "\x04[%s]:\x03 %s has been moved to Spectors team!", "Mix", searchFor);
		}
		else
		{
			PrintToChat(client, "\x04[%s]:\x03Couldn't find %s in the server...", "Mix", searchFor);
		}
		return Action:3;
	}
	return Action:0;
}

public Action:Command_MixMenu(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (isMixMenuGenerated)
		{
			DisplayMenu(g_MixMenu, client, 30);
		}
		else
		{
			CreateMixMenu();
			PrintToChat(client, "\x04[%s]:\x03 Mix Menu is being created right now! please use\x01 sm_mix\x03 command again in a few seconds...", "Mix");
		}
		return Action:3;
	}
	return Action:0;
}

CreateMixMenu()
{
	if (!isMixMenuGenerated)
	{
		if (g_MixMenu)
		{
			CloseHandle(g_MixMenu);
		}
		g_MixMenu = CreateMenu(MixMenuHandler, MenuAction:28);
		SetMenuTitle(g_MixMenu, "%s: ", "Mix");
		AddMenuItem(g_MixMenu, "Start", "Start match", 0);
		AddMenuItem(g_MixMenu, "Stop", "Stop the match", 0);
		AddMenuItem(g_MixMenu, "Ko3", "Knife round (KO3 if enabled)", 0);
		AddMenuItem(g_MixMenu, "Live", "Live (LO3 if enabled)", 0);
		AddMenuItem(g_MixMenu, "NL", "Not live", 0);
		AddMenuItem(g_MixMenu, "Cfgs", "CFGs menu", 0);
		AddMenuItem(g_MixMenu, "Admin", "Admin menu", 0);
		SetMenuExitButton(g_MixMenu, true);
		if (g_AdminMenu)
		{
			CloseHandle(g_AdminMenu);
		}
		g_AdminMenu = CreateMenu(AdminMenuHandler, MenuAction:28);
		SetMenuTitle(g_AdminMenu, "%s - Admin menu", "Mix");
		AddMenuItem(g_AdminMenu, "back", "-> Back to mix menu", 0);
		AddMenuItem(g_AdminMenu, "map", "Change map", 0);
		AddMenuItem(g_AdminMenu, "swap", "Swap player", 0);
		AddMenuItem(g_AdminMenu, "kick", "Kick Player", 0);
		AddMenuItem(g_AdminMenu, "spec", "Move all to spectators", 0);
		AddMenuItem(g_AdminMenu, "rpw", "Set a random password to the server.", 0);
		AddMenuItem(g_AdminMenu, "settings", "Change plugin settings", 0);
		SetMenuExitButton(g_AdminMenu, true);
		isMixMenuGenerated = true;
	}
	return 0;
}

public MixMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction:256)
	{
		return 0;
	}
	if (action == MenuAction:4)
	{
		switch (param2)
		{
			case 0:
			{
				Command_Start(param1, 0);
			}
			case 1:
			{
				Command_Stop(param1, 0);
			}
			case 2:
			{
				Command_KO3(param1, 0);
			}
			case 3:
			{
				Command_Live(param1, 0);
			}
			case 4:
			{
				Command_NotLive(param1, 0);
			}
			case 5:
			{
				new Handle:cfgMenu = CreateMenu(CfgMenuHandler, MenuAction:28);
				SetMenuTitle(cfgMenu, "%s - Cfg menu", "Mix");
				AddMenuItem(cfgMenu, "back", "-> Back to mix menu", 0);
				AddMenuItem(cfgMenu, "mr15", "Mr15 (match)", 0);
				AddMenuItem(cfgMenu, "prac", "Prac (warmup)", 0);
				AddMenuItem(cfgMenu, "mr3", "Mr3", 0);
				SetMenuExitButton(cfgMenu, true);
				DisplayMenu(cfgMenu, param1, 30);
			}
			case 6:
			{
				DisplayMenu(g_AdminMenu, param1, 30);
			}
			default:
			{
			}
		}
	}
	return 0;
}

public AdminMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction:256)
	{
		return 0;
	}
	if (action == MenuAction:4)
	{
		switch (param2)
		{
			case 0:
			{
				DisplayMenu(g_MixMenu, param1, 30);
			}
			case 1:
			{
				Command_Maps(param1, 0);
			}
			case 2:
			{
				new Handle:swapMenu = CreateMenu(SwapMenuHandler, MenuAction:28);
				SetMenuTitle(swapMenu, "%s - Swap player", "Mix");
				AddMenuItem(swapMenu, "back", "-> Back to admin menu", 0);
				AddMenuItem(swapMenu, "swapTeams", "Swap teams", 0);
				AddMenuItem(swapMenu, "swapPlayer", "Swap player", 0);
				SetMenuExitButton(swapMenu, true);
				DisplayMenu(swapMenu, param1, 30);
			}
			case 3:
			{
				new Handle:kickMenu = CreateMenu(KickMenuHandler, MenuAction:28);
				SetMenuTitle(kickMenu, "%s - Kick", "Mix");
				AddMenuItem(kickMenu, "back", "-> Back to admin menu", 0);
				AddMenuItem(kickMenu, "kickCT", "Kick CT", 0);
				AddMenuItem(kickMenu, "kickT", "Kick T", 0);
				AddMenuItem(kickMenu, "kickSPEC", "Kick Spec", 0);
				AddMenuItem(kickMenu, "kick", "Kick Player", 0);
				SetMenuExitButton(kickMenu, true);
				DisplayMenu(kickMenu, param1, 30);
			}
			case 4:
			{
				new i = 1;
				while (i < MaxClients)
				{
					new var1;
					if (IsClientInGame(i) && GetClientTeam(i) != 1)
					{
						ChangeClientTeam(i, 1);
					}
					i++;
				}
				PrintToChatAll("\x04[%s]:\x03 All players are in spectors team!", "Mix");
			}
			case 5:
			{
				Command_GenerateRandomPassword(param1, 0);
			}
			case 6:
			{
				new Handle:cvarMenu = CreateMenu(CvarMenuHandler, MenuAction:28);
				SetMenuTitle(cvarMenu, "%s - Cvar settings", "Mix");
				AddMenuItem(cvarMenu, "back", "-> Back to admin menu", 0);
				if (GetConVarInt(g_CvarEnabled) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_enable \"0\"", "Disable this plugin", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_enable \"1\"", "Enable this plugin", 0);
				}
				if (GetConVarInt(g_CvarMr3Enabled) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_mr3_enable \"0\"", "Disable mr3 settings", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_mr3_enable \"1\"", "Enable mr3 settings", 0);
				}
				if (GetConVarInt(g_CvarEnableKnifeRound) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_enable_knife_round \"0\"", "Disable knife round before live", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_enable_knife_round \"1\"", "Enable knife round before live", 0);
				}
				if (GetConVarInt(g_CvarUseKo3Command) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_use_zb_ko3 \"0\"", "Use mp_restartgame instead of zb_ko3", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_use_zb_ko3 \"1\"", "Use zb_ko3 instead of mp_restartgame", 0);
				}
				if (GetConVarInt(g_CvarHalfAutoLiveStart) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_half_auto_live \"0\"", "Disable Automatically start live", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_half_auto_live \"1\"", "Enable Automatically start live", 0);
				}
				if (GetConVarInt(g_CvarShowMoneyAndWeapons) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_showmoney \"0\"", "Don't Show money", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_showmoney \"1\"", "Show money", 0);
				}
				if (GetConVarInt(g_CvarShowCashInPanel) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_show_cash_in_panel \"0\"", "Show money in chat", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_show_cash_in_panel \"1\"", "Show money in panel", 0);
				}
				if (GetConVarInt(g_CvarShowScores) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_showscores \"0\"", "Show scores", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_showscores \"1\"", "Don't show scores", 0);
				}
				if (GetConVarInt(g_CvarShowSwitchInPanel) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_show_swap_in_panel \"0\"", "Show auto-swap msg in chat", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_show_swap_in_panel \"1\"", "Show auto-swap msg in panel", 0);
				}
				if (GetConVarInt(g_CvarEnableRRCommand) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_enable_rr_command \"0\"", "Disable sm_rr command", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_enable_rr_command \"1\"", "Enable sm_rr command", 0);
				}
				if (GetConVarInt(g_CvarPlayTeamSwapedSound) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_enable_st_sound \"0\"", "Don't play swap team music", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_enable_st_sound \"1\"", "Play swap team music", 0);
				}
				if (GetConVarInt(g_CvarUseZBMatchCommand) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_use_zb_lo3 \"0\"", "Use mp_restartgame instead of zb_lo3", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_use_zb_lo3 \"1\"", "Use zb_lo3 instead of mp_restartgame", 0);
				}
				if (GetConVarInt(g_CvarKickAdmins) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_kick_admins \"0\"", "Don't kick admins with sm_kickTEAM", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_kick_admins \"1\"", "Kick admins with sm_kickTEAM", 0);
				}
				if (GetConVarInt(g_CvarDisableSayCommand) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_disable_public_chat \"0\"", "Enable public chat", 0);
				}
				else
				{
					if (GetConVarInt(g_CvarDisableSayCommand) == 2)
					{
						AddMenuItem(cvarMenu, "sm_mixmod_disable_public_chat \"1\"", "Disable public chat", 0);
					}
					if (!(GetConVarInt(g_CvarDisableSayCommand)))
					{
						AddMenuItem(cvarMenu, "sm_mixmod_disable_public_chat \"2\"", "Disable public chat only when live", 0);
					}
				}
				if (GetConVarInt(g_CvarInformWinnerInPanel) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_show_winner_in \"0\"", "Show winning team in chat", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_show_winner_in \"1\"", "Show winning team in menu", 0);
				}
				if (GetConVarInt(g_CvarRpwShowPass) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_rpw_show_pass \"0\"", "Show random password only to admins", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_rpw_show_pass \"1\"", "Show random password to everyone", 0);
				}
				if (GetConVarInt(g_CvarRemoveProps) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_remove_props \"0\"", "Don't remove props from the map", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_remove_props \"1\"", "Remove props from the map", 0);
				}
				if (GetConVarInt(g_CvarAutoMixEnabled) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_auto_warmod_enable \"0\"", "Disable sm_ready system", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_auto_warmod_enable \"1\"", "Enable sm_ready system", 0);
				}
				if (GetConVarInt(g_CvarAutoMixRandomize) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_auto_warmod_random \"0\"", "Don't random the teams in auto-war", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_auto_warmod_random \"1\"", "Random the teams in auto-war", 0);
				}
				if (GetConVarInt(g_CvarEnableAutoSourceTVRecord) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_autorecord_enable \"0\"", "Disable SourceTv auto record when mix starts", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_autorecord_enable \"1\"", "Enable SourceTv auto record when mix starts", 0);
				}
				if (GetConVarInt(g_CvarKnifeWinTeamVote) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_knife_round_win_vote \"0\"", "Disable winning team in knife - team choose vote", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_knife_round_win_vote \"1\"", "Enable winning team in knife - team choose vote", 0);
				}
				if (GetConVarInt(g_CvarEnablePasswords) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_password_commands_enable \"0\"", "Disable password commands", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_password_commands_enable \"1\"", "Enable password commands", 0);
				}
				if (GetConVarInt(g_CvarAllowManualSwitching) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_manual_switch_enable \"0\"", "Don't let players change their team when mix is running", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_manual_switch_enable \"1\"", "Allow players to change their team when mix is running", 0);
				}
				if (GetConVarInt(g_CvarShowTkMessage) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_show_tk_damage \"0\"", "Don't show TK damage in chat", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_show_tk_damage \"1\"", "Show TK damage in chat", 0);
				}
				if (GetConVarInt(g_CvarRemovePassWhenMixIsEnded) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_remove_password_on_mix_end \"0\"", "Don't remove the password on mix end", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_remove_password_on_mix_end \"1\"", "Remove the password on mix end", 0);
				}
				if (GetConVarInt(g_CvarShowMVP) == 1)
				{
					AddMenuItem(cvarMenu, "sm_mixmod_show_mvp \"0\"", "Don't show MVP stats.", 0);
				}
				else
				{
					AddMenuItem(cvarMenu, "sm_mixmod_show_mvp \"1\"", "Show MVP stats.", 0);
				}
				SetMenuExitButton(cvarMenu, true);
				DisplayMenu(cvarMenu, param1, 30);
			}
			default:
			{
			}
		}
	}
	return 0;
}

public SwapMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction:256)
	{
		return 0;
	}
	if (action == MenuAction:4)
	{
		switch (param2)
		{
			case 0:
			{
				DisplayMenu(g_AdminMenu, param1, 30);
			}
			case 1:
			{
				Command_SwapTeams(param1, 0);
			}
			case 2:
			{
				decl String:clientName[128];
				decl String:useridS[20];
				new Handle:swapPlayerMenu = CreateMenu(SwapPlayerMenuHandler, MenuAction:28);
				SetMenuTitle(swapPlayerMenu, "%s - Swap player", "Mix");
				AddMenuItem(swapPlayerMenu, "back", "-> Back to admin menu", 0);
				new i = 1;
				while (i <= MaxClients)
				{
					new var1;
					if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) != 1)
					{
						GetClientName(i, clientName, 128);
						IntToString(GetClientUserId(i), useridS, 20);
						AddMenuItem(swapPlayerMenu, useridS, clientName, 0);
					}
					i++;
				}
				SetMenuExitButton(swapPlayerMenu, true);
				DisplayMenu(swapPlayerMenu, param1, 30);
			}
			default:
			{
			}
		}
	}
	if (action == MenuAction:16)
	{
		CloseHandle(menu);
	}
	return 0;
}

public SwapPlayerMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction:256)
	{
		return 0;
	}
	if (action == MenuAction:4)
	{
		if (0 < param2)
		{
			decl String:info[64];
			GetMenuItem(menu, param2, info, 64, 0, "", 0);
			new target = GetClientOfUserId(StringToInt(info, 10));
			new team = GetClientTeam(target);
			if (team == 3)
			{
				ChangeClientTeam(target, 2);
			}
			else
			{
				if (team == 2)
				{
					ChangeClientTeam(target, 3);
				}
			}
			GetClientName(target, info, 64);
			PrintToChat(param1, "\x04[%s]:\x03 %s has been swapped!", "Mix", info);
			PrintToChat(target, "\x04[%s]:\x03 You has been swapped!", "Mix");
		}
		if (!param2)
		{
			DisplayMenu(g_AdminMenu, param1, 30);
		}
	}
	if (action == MenuAction:16)
	{
		CloseHandle(menu);
	}
	return 0;
}

public KickMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction:256)
	{
		return 0;
	}
	if (action == MenuAction:4)
	{
		switch (param2)
		{
			case 0:
			{
				DisplayMenu(g_AdminMenu, param1, 30);
			}
			case 1:
			{
				Command_KickCT(param1, 0);
			}
			case 2:
			{
				Command_KickT(param1, 0);
			}
			case 3:
			{
				KickTeam(param1, 1, GetConVarInt(g_CvarKickAdmins));
				PrintToChatAll("\x04[%s]:\x03 Spectors team has been kicked!", "Mix");
			}
			case 4:
			{
				decl String:clientName[128];
				decl String:useridS[20];
				new Handle:kickPlayerMenu = CreateMenu(KickPlayerMenuHandler, MenuAction:28);
				SetMenuTitle(kickPlayerMenu, "%s - Kick player", "Mix");
				AddMenuItem(kickPlayerMenu, "back", "-> Back to admin menu", 0);
				new i = 1;
				while (i <= MaxClients)
				{
					new var1;
					if (IsClientInGame(i) && !IsFakeClient(i))
					{
						GetClientName(i, clientName, 128);
						IntToString(GetClientUserId(i), useridS, 20);
						AddMenuItem(kickPlayerMenu, useridS, clientName, 0);
					}
					i++;
				}
				SetMenuExitButton(kickPlayerMenu, true);
				DisplayMenu(kickPlayerMenu, param1, 30);
			}
			default:
			{
			}
		}
	}
	if (action == MenuAction:16)
	{
		CloseHandle(menu);
	}
	return 0;
}

public KickPlayerMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction:256)
	{
		return 0;
	}
	if (action == MenuAction:4)
	{
		if (0 < param2)
		{
			decl String:info[64];
			GetMenuItem(menu, param2, info, 64, 0, "", 0);
			new target = GetClientOfUserId(StringToInt(info, 10));
			KickClient(target, "[%s]: You have been kicked by the admin!", "Mix");
			GetClientName(target, info, 64);
			PrintToChat(param1, "\x04[%s]:\x03 %s has been kicked!", "Mix", info);
		}
		if (!param2)
		{
			DisplayMenu(g_AdminMenu, param1, 30);
		}
	}
	if (action == MenuAction:16)
	{
		CloseHandle(menu);
	}
	return 0;
}

public CvarMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction:256)
	{
		return 0;
	}
	if (action == MenuAction:4)
	{
		if (param2)
		{
			if (0 < param2)
			{
				decl String:info[64];
				GetMenuItem(menu, param2, info, 64, 0, "", 0);
				ServerCommand(info);
			}
		}
		DisplayMenu(g_AdminMenu, param1, 30);
	}
	if (action == MenuAction:16)
	{
		CloseHandle(menu);
	}
	return 0;
}

public CfgMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction:256)
	{
		return 0;
	}
	if (action == MenuAction:4)
	{
		switch (param2)
		{
			case 0:
			{
				DisplayMenu(g_MixMenu, param1, 30);
			}
			case 1:
			{
				Command_Mr15(param1, 0);
			}
			case 2:
			{
				Command_Prac(param1, 0);
			}
			case 3:
			{
				Command_Mr3(param1, 0);
			}
			default:
			{
			}
		}
	}
	if (action == MenuAction:16)
	{
		CloseHandle(menu);
	}
	return 0;
}

bool:IsValidMapToRemoveProps()
{
	if (g_IsMapValidToRemoveProps)
	{
		return true;
	}
	return false;
}

RemoveProps()
{
	if (!IsValidMapToRemoveProps())
	{
		return 0;
	}
	decl String:propClass[32];
	new maxEntities = GetMaxEntities();
	new i = MaxClients + 1;
	while (i < maxEntities)
	{
		if (IsValidToBeRemoved(i))
		{
			GetEdictClassname(i, propClass, 30);
			if (!(StrContains(propClass, "prop_", false)))
			{
				RemoveEdict(i);
			}
		}
		i++;
	}
	return 0;
}

bool:IsValidToBeRemoved(ent)
{
	new var1;
	if (!IsValidEdict(ent) || !IsValidEntity(ent))
	{
		return false;
	}
	return true;
}

public Event_PlayerDisconnect(Handle:event, String:name[], bool:dontBroadcast)
{
	g_GaggedPlayers[GetClientOfUserId(GetEventInt(event, "userid"))] = 0;
	g_MutedPlayers[GetClientOfUserId(GetEventInt(event, "userid"))] = 0;
	if (hasMixStarted)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		g_ScoresOfTheGame[client] = 0;
		g_DeathsOfTheGame[client] = 0;
	}
	new var1;
	if (GetConVarInt(g_CvarAutoMixEnabled) == 1 && !g_IsItManual)
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (IsFakeClient(client))
		{
			return 0;
		}
		if (g_ReadyPlayers[client])
		{
			g_ReadyPlayers[client] = 0;
			g_ReadyPlayersData[client] = -1;
			g_ReadyCount -= 1;
		}
		decl String:reason[32];
		GetEventString(event, "reason", reason, 30);
		if (StrContains(reason, "Disconnect by user", true) != -1)
		{
			new banTime = GetConVarInt(g_CvarAutoMixBan);
			if (0 <= banTime)
			{
				new String:auth[64];
				GetClientAuthString(client, auth, 64);
				ServerCommand("sm_addban %d %s Left the mix", banTime, auth);
			}
		}
	}
	return 0;
}

public Action:Command_JoinTeam(client, args)
{
	new String:team[8];
	GetCmdArg(1, team, 8);
	new var1;
	if (hasMixStarted && GetConVarInt(g_CvarAllowManualSwitching) && GetClientTeam(client) != 1)
	{
		PrintToChat(client, "\x04[%s]:\x03 You can not change your team when mix is running!", "Mix");
		return Action:3;
	}
	return Action:0;
}

public Action:Command_ForceReady(client, args)
{
	new clients = 1;
	while (clients <= MaxClients)
	{
		if (!g_ReadyPlayers[clients])
		{
			g_ReadyPlayers[clients] = 1;
			g_ReadyCount += 1;
			if (g_ReadyCount == 10)
			{
				Command_GenerateRandomPassword(0, 0);
				g_IsItManual = false;
				g_AllowReady = false;
				StartAutoMix();
			}
		}
		clients++;
	}
	return Action:3;
}

public Action:Command_Ready(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (GetConVarInt(g_CvarAutoMixEnabled))
		{
			if (!g_AllowReady)
			{
				PrintToChat(client, "\x04[%s]:\x03 There are already 10 players ready!", "Mix");
				return Action:3;
			}
			if (hasMixStarted)
			{
				if (GetPlayersInServerAndReady() >= 10)
				{
					PrintToChat(client, "\x04[%s]:\x03 Mix is running! This command is now disabled.", "Mix");
					return Action:3;
				}
			}
			if (GetClientTeam(client) < 2)
			{
				PrintToChat(client, "\x04[%s]:\x03 You must be in Terrorist or Counter-Terrorist team to use this command.", "Mix");
				return Action:3;
			}
			if (!g_ReadyPlayers[client])
			{
				g_ReadyPlayers[client] = 1;
				g_ReadyCount += 1;
				if (g_ReadyCount == 10)
				{
					Command_GenerateRandomPassword(0, 0);
					g_IsItManual = false;
					g_AllowReady = false;
					StartAutoMix();
				}
			}
			PrintToChatAll("\x04[%s]:\x03 You are ready!", "Mix");
			return Action:3;
		}
		PrintToChat(client, "\x04[%s]:\x03 Auto-War is not running! This command is disabled.", "Mix");
		return Action:3;
	}
	return Action:0;
}

StartAutoMix()
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (GetConVarInt(g_CvarAutoMixRandomize) == 1)
		{
			new countA;
			new countB;
			new rnd;
			new bool:clients[66];
			while (countA < 5 && rnd != -1)
			{
				rnd = GetRandomClient(clients);
				new var2;
				if (!clients[rnd] && g_ReadyPlayers[rnd])
				{
					countA++;
					clients[rnd] = true;
					ChangeClientTeam(rnd, 3);
					g_ReadyPlayersData[rnd] = 3;
				}
			}
			rnd = GetRandomClient(clients);
			while (countB < 5 && rnd != -1)
			{
				new var4;
				if (g_ReadyPlayers[rnd] && !clients[rnd])
				{
					countB++;
					clients[rnd] = true;
					ChangeClientTeam(rnd, 2);
					g_ReadyPlayersData[rnd] = 2;
				}
				rnd = GetRandomClient(clients);
			}
		}
		else
		{
			new i = 1;
			while (i <= MaxClients)
			{
				if (g_ReadyPlayers[i])
				{
					g_ReadyPlayersData[i] = GetClientTeam(i);
				}
				i++;
			}
		}
		if (BalanceTeams())
		{
			Command_ShowTeams(0, 0);
		}
		Command_Start(0, 0);
	}
	return 0;
}

GetRandomClient(clients[])
{
	new clients2[MaxClients + 1];
	new count;
	new i;
	while (i < MaxClients)
	{
		if (!clients[i])
		{
			clients2[count] = i;
			count++;
		}
		i++;
	}
	if (count)
	{
		return clients2[GetRandomInt(0, count + -1)];
	}
	return -1;
}

GetPlayersInServerAndReady()
{
	new count;
	new i = 1;
	while (i <= MaxClients)
	{
		new var1;
		if (IsClientInGame(i) && !IsFakeClient(i) && g_ReadyPlayers[i])
		{
			count++;
		}
		i++;
	}
	return count;
}

AreTeamsBalanced()
{
	new teamACount;
	new teamBCount;
	new team;
	new i = 1;
	while (i <= MaxClients)
	{
		if (g_ReadyPlayers[i])
		{
			team = GetClientTeam(i);
			if (team == 3)
			{
				teamACount++;
			}
			if (team == 2)
			{
				teamBCount++;
			}
		}
		i++;
	}
	if (teamACount > teamBCount)
	{
		return 1;
	}
	if (teamACount < teamBCount)
	{
		return -1;
	}
	return 0;
}

bool:BalanceTeams()
{
	new balance = AreTeamsBalanced();
	new var1;
	if (GetPlayersInServerAndReady() % 2 && balance)
	{
		new rnd;
		if (balance == -1)
		{
			rnd = GetRandomClientFromReadyTeam(2);
			ChangeClientTeam(rnd, 3);
			g_ReadyPlayersData[rnd] = 3;
			if (IsFakeClient(rnd))
			{
				ClientCommand(rnd, "slot1");
			}
		}
		else
		{
			if (balance == 1)
			{
				rnd = GetRandomClientFromReadyTeam(3);
				ChangeClientTeam(rnd, 2);
				g_ReadyPlayersData[rnd] = 2;
				if (IsFakeClient(rnd))
				{
					ClientCommand(rnd, "slot1");
				}
			}
		}
		return BalanceTeams();
	}
	return true;
}

GetRandomClientFromReadyTeam(team)
{
	new clients[MaxClients + 1];
	new count;
	new i = 1;
	while (i <= MaxClients)
	{
		if (team == g_ReadyPlayersData[i])
		{
			clients[count] = i;
			count++;
		}
		i++;
	}
	if (count)
	{
		return clients[GetRandomInt(0, count + -1)];
	}
	return -1;
}

public Action:Command_ShowTeams(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (!(GetConVarInt(g_CvarAutoMixEnabled)))
		{
			if (!isRandomBeingUsed)
			{
				if (client)
				{
					PrintToChat(client, "\x04[%s]:\x03 Teams weren't randomized!", "Mix");
				}
				return Action:3;
			}
		}
		new var1;
		if (g_IsItManual || !hasMixStarted)
		{
			if (!hasMixStarted)
			{
				if (client)
				{
					PrintToChat(client, "\x04[%s]:\x03 This command is enabled only when mix is running");
				}
				return Action:3;
			}
		}
		decl String:teamAName[32];
		decl String:teamBName[32];
		decl String:teamAPlayers[252];
		decl String:teamBPlayers[252];
		decl String:name[32];
		GetConVarString(g_CvarCusomNameTeamCT, teamAName, 32);
		GetConVarString(g_CvarCusomNameTeamT, teamBName, 32);
		Format(teamAPlayers, 250, "\x04%s:\x03 ", teamAName);
		Format(teamBPlayers, 250, "\x04%s:\x03 ", teamBName);
		if (client)
		{
			PrintToChat(client, "\x04[%s]:\x03 Teams:", "Mix");
		}
		else
		{
			PrintToChatAll("\x04[%s]:\x03 Teams:", "Mix");
		}
		new i = 1;
		while (i <= MaxClients)
		{
			new var2;
			if (g_ReadyPlayers[i] && IsClientConnected(i))
			{
				GetClientName(i, name, 32);
				if (g_ReadyPlayersData[i] == 3)
				{
					Format(teamAPlayers, 250, "%s%s\x01, \x03", teamAPlayers, name);
				}
				if (g_ReadyPlayersData[i] == 2)
				{
					Format(teamBPlayers, 250, "%s%s\x01, \x03", teamBPlayers, name);
				}
			}
			i++;
		}
		if (client)
		{
			PrintToChat(client, teamAPlayers);
			PrintToChat(client, teamBPlayers);
		}
		else
		{
			PrintToChatAll(teamAPlayers);
			PrintToChatAll(teamBPlayers);
		}
		return Action:3;
	}
	return Action:0;
}

public Action:Command_UnReady(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (GetConVarInt(g_CvarAutoMixEnabled))
		{
			if (hasMixStarted)
			{
				PrintToChat(client, "\x04[%s]:\x03 Mix is running! This command is now disabled.", "Mix");
				return Action:3;
			}
			if (g_ReadyPlayers[client])
			{
				g_ReadyCount -= 1;
				g_ReadyPlayers[client] = 0;
			}
			PrintToChatAll("\x04[%s]:\x03 You are not ready!", "Mix");
			return Action:3;
		}
		PrintToChat(client, "\x04[%s]:\x03 Auto-War is not running! This command is now disabled.", "Mix");
		return Action:3;
	}
	return Action:0;
}

public Action:Command_ShowMvp(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (!hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix/Pcw is not running! This command is now disabled.", "Mix");
			return Action:3;
		}
		if (GetConVarInt(g_CvarShowMVP))
		{
			new max;
			new index = -1;
			new i = 1;
			while (i <= MaxClients)
			{
				if (IsClientConnected(i))
				{
					if (g_ScoresOfTheGame[i] >= max)
					{
						max = g_ScoresOfTheGame[i];
						index = i;
					}
				}
				i++;
			}
			decl String:mvpName[36];
			GetClientName(index, mvpName, 33);
			new kills = g_ScoresOfTheGame[index];
			if (0 >= kills)
			{
				PrintToChat(client, "\x04[%s]:\x03 MVP wasn't chosen yet. Please wait a few minutes.", "Mix");
				return Action:3;
			}
			PrintToChat(client, "\x04[%s]:\x03 MVP:", "Mix");
			PrintToChat(client, "------------------");
			PrintToChat(client, "\x03 - The \x01MVP:\x04 %s , \x03Killed:\x04 %d \x03Enemies!", mvpName, kills);
			if (client == index)
			{
				return Action:3;
			}
			decl String:clientName[36];
			GetClientName(client, clientName, 33);
			PrintToChat(client, "\x03 You killed:\x04 %d \x03 Enemies.", g_ScoresOfTheGame[client]);
			return Action:3;
		}
		PrintToChat(client, "\x04[%s]:\x03 MVP Stats is disabled! thsi command is now disabled.", "Mix");
		return Action:3;
	}
	return Action:0;
}

UpdateReadyPanel()
{
	if (readyStatus)
	{
		CloseHandle(readyStatus);
	}
	readyStatus = CreatePanel(Handle:0);
	decl String:title[128];
	decl String:notReady[400];
	decl String:name[32];
	Format(title, 128, "%s - Ready system \n ---Created by iDragon", "Mix");
	SetPanelTitle(readyStatus, title, false);
	DrawPanelText(readyStatus, "\n \n");
	DrawPanelItem(readyStatus, "Match will begin when 10 players are ready", 0);
	DrawPanelText(readyStatus, "\n \n");
	DrawPanelItem(readyStatus, "Not ready: ", 0);
	Format(notReady, 400, "");
	new i = 1;
	while (i <= MaxClients)
	{
		new var1;
		if (!g_ReadyPlayers[i] && IsClientConnected(i))
		{
			GetClientName(i, name, 32);
			Format(notReady, 400, "%s %s\n", notReady, name);
		}
		i++;
	}
	DrawPanelText(readyStatus, notReady);
	DrawPanelText(readyStatus, "\n \n");
	DrawPanelItem(readyStatus, "Exit", 0);
	return 0;
}

ShowReadyPanel(client)
{
	SendPanelToClient(readyStatus, client, Handler_DoNothing, 20);
	return 0;
}

bool:DisableBuyZone()
{
	new ent = -1;
	new bool:disabled;
	while ((ent = FindEntityByClassname(ent, "func_buyzone")) != -1)
	{
		AcceptEntityInput(ent, "Disable", -1, -1, 0);
		disabled = true;
	}
	return disabled;
}

bool:EnableBuyZone()
{
	new ent = -1;
	new bool:enabled;
	while ((ent = FindEntityByClassname(ent, "func_buyzone")) != -1)
	{
		AcceptEntityInput(ent, "Enable", -1, -1, 0);
		enabled = true;
	}
	return enabled;
}

public Action:SwapTimer(Handle:timer)
{
	didLiveStarted = false;
	new team;
	new client = 1;
	while (client <= MaxClients)
	{
		new var1;
		if (IsClientInGame(client) && !IsFakeClient(client) && IsClientConnected(client))
		{
			team = GetClientTeam(client);
			if (team == 3)
			{
				ChangeClientTeam(client, 2);
			}
			if (team == 2)
			{
				ChangeClientTeam(client, 3);
			}
		}
		client++;
	}
	new var2;
	if (GetConVarInt(g_CvarHalfAutoLiveStart) == 1 && g_IsItManual)
	{
		didLiveStarted = true;
	}
	return Action:0;
}

