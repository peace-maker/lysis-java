#include <amxmodx>
#include <amxmisc>
#include <geoip>
#include <colored_translit>
#include <ini_file2>
#include <crxranks>
#include <gamecms5>



/*
* 	Colored Translit v3.0 by Sho0ter
*	Defines and Constats
*/
#define PLUGIN "Colored Translit" // Don't change it!
#define VERSION "3.0"
#define AUTHOR "Sho0ter"

#define ACCESS_LEVEL (ADMIN_BAN)
#define NICK_LEVEL (ADMIN_RESERVATION | ADMIN_LEVEL_G)
#define IMMUNITY_LEVEL (ADMIN_RESERVATION | ADMIN_LEVEL_G)

#define is_valid_player(%1) (1 <= %1 <= 32)

#define LOGTITLE ""
#define LOGFONT ""

#define PUNISH_CHEAT 1
#define PUNISH_SPAM 2

#define ACTION_CHEAT 1
#define ACTION_SPAM 2

#define MAX_SWEARS 1000
#define MAX_REPLACES 1000
#define MAX_IGNORES 1000
#define MAX_SKIPS 1000
#define MAX_SPAMS 1000
#define MAX_CHEAT 1000

new Adds[4][10][128]
new AddsNum[4]

new Cmds[100][128]
new CmdsNum

new Replace[MAX_REPLACES][192]
new Spam[MAX_SPAMS][192]
new Cheat[MAX_CHEAT][192]
new Ignore[MAX_IGNORES][64]
new Skips[MAX_SKIPS][64]
new Swear[MAX_SWEARS][64]

new g_OriginalSimb[128][32]
new g_TranslitSimb[128][32]
new s_GagName[33][32]
new s_Prefix[33][64]
new s_Prefix2[33][64]
new s_GagIp[33][32]
new SpamFound[33]
new SwearCount[33]
new i_Gag[33]
new translit[33]

new p_LogMessage[1024]
new p_LogMsg[1024]
new p_LogInfo[512]
new p_LogTitle[512]
new p_LogFile[128]
new p_LogFileTime[32]
new p_LogIp[32]
new p_LogSteamId[32]
new p_LogTime[32]
new p_LogDir[64]
new p_LogAdminIp[32]

new Message[512]
new MessagePrefix[512]
new MessageNoPrefix[512]
new s_Msg[256]
new s_SwearMsg[256]
new s_Name[128]
new sUserId[32]
new AliveTeam[32]
new s_CheckGag[64]
new s_CheckIp[32]
new s_GagTime[32]
new s_GagPlayer[32]
new s_GagAdmin[32]
new s_GagTarget[32]
new s_BanAuthId[32]
new s_KickName[64]
new s_BanName[32]
new s_BanIp[32]
new s_Reason[128]
new s_CheatAction[128]

new p_FilePath[128]
new s_ConfigsDir[128]
new s_FilePrefix[128]
new s_ConfigFile[128]
new s_SwearFile[128]
new s_IgnoreFile[128]
new s_SkipsFile[128]
new s_ReplaceFile[128]
new s_SpamFile[128]
new s_CheatFile[128]

new Info[192]
new s_Arg[64]

new g_Translit
new g_Log
new g_NameColor
new g_AllChat
new g_Listen
new g_ChatColor
new g_SwearFilter
new g_SwearWarns
new g_AutoRus
new g_ShowInfo
new g_SwearImmunity
new g_Sounds
new g_Ignore
new g_IgnoreMode
new g_SwearGag
new g_SwearTime
new g_FloodTime
new g_GagImmunity
new g_Spam
new g_SpamImmunity
new g_SpamWarns
new g_SpamAction
new g_SpamActionTime
new g_Cheat
new g_CheatImmunity
new g_CheatAction
new g_CheatActionTime
new g_CheatActionCustom

new fwd_Begin
new fwd_Cheat
new fwd_Spam
new fwd_Swear
new fwd_formatex

new isAlive
new i_MaxSimbols
new SwearNum
new ReplaceNum
new IgnoreNum
new SkipsNum
new SpamNum
new CheatNum
new Len
new gagid
new i_GagTime
new SysTime
new i_ShowGag
new SwearFound
new mLen
new lgLen
new fwdResult
new bool:g_ShowPrefix[33] = true

new bool:Flood[33]
new bool:Logged[33]
new bool:SwearList
new bool:ReplaceList
new bool:ConfigsList
new bool:TranslitList
new bool:IgnoreList
new bool:SkipsList
new bool:SpamList
new bool:IgnoreFound
new bool:SlashFound
new bool:CheatList

new color

/*
* 	Colored Translit v3.0 by Sho0ter
*	Initialization
*/
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_dictionary("colored_translit.txt")
	
	g_Translit = register_cvar("amx_translit", "1")
	g_Log = register_cvar("amx_translit_log", "1")
	g_NameColor = register_cvar("amx_name_color", "6")
	g_ChatColor = register_cvar("amx_chat_color", "1")
	g_AllChat = register_cvar("amx_allchat", "0")
	g_Listen = register_cvar("amx_listen", "1")
	g_Sounds = register_cvar("amx_ctsounds", "1")
	g_SwearFilter = register_cvar("amx_swear_filter", "1")
	g_SwearWarns = register_cvar("amx_swear_warns", "3")
	g_SwearImmunity = register_cvar("amx_swear_immunity", "1")
	g_SwearGag = register_cvar("amx_swear_gag", "1")
	g_SwearTime = register_cvar("amx_swear_gag_time", "5")
	g_AutoRus = register_cvar("amx_auto_rus", "1")
	g_ShowInfo = register_cvar("amx_show_info", "1")
	g_Ignore = register_cvar("amx_ignore", "1")
	g_IgnoreMode = register_cvar("amx_ignore_mode", "1")
	g_GagImmunity = register_cvar("amx_gag_immunity", "1")
	g_FloodTime = register_cvar("amx_flood_time", "3")
	g_Spam = register_cvar("amx_spam_filter", "1")
	g_SpamImmunity = register_cvar("amx_spam_immunity", "1")
	g_SpamWarns = register_cvar("amx_spam_warns", "3")
	g_SpamAction = register_cvar("amx_spam_action", "2")
	g_SpamActionTime = register_cvar("amx_spam_time", "60")
	g_Cheat = register_cvar("amx_cheat_filter", "1")
	g_CheatImmunity = register_cvar("amx_cheat_immunity", "1")
	g_CheatAction = register_cvar("amx_cheat_action", "1")
	g_CheatActionTime = register_cvar("amx_cheat_time", "0")
	g_CheatActionCustom = register_cvar("amx_cheat_custom", "")

	register_clcmd("say prefix","Block")
	register_clcmd("prefix","Block")
	register_clcmd("say /prefix","Block")
	register_clcmd("say_team /prefix","Block")
	register_clcmd("say_team prefix","Block")
	
	register_clcmd("say", "hook_say")
	register_clcmd("say_team", "hook_say_team")
	
	fwd_Begin = CreateMultiForward("ct_message_begin", ET_IGNORE, FP_CELL, FP_STRING, FP_CELL)
	fwd_Cheat = CreateMultiForward("ct_message_cheat", ET_IGNORE, FP_CELL, FP_STRING)
	fwd_Spam = CreateMultiForward("ct_message_spam", ET_IGNORE, FP_CELL, FP_STRING)
	fwd_Swear = CreateMultiForward("ct_message_swear", ET_IGNORE, FP_CELL, FP_STRING)
	fwd_formatex = CreateMultiForward("ct_message_formatex", ET_IGNORE, FP_CELL)
	
	get_localinfo("amxx_logs", p_FilePath, 63)
	
	get_time("20%y.%m.%d", p_LogFileTime, charsmax(p_LogFileTime))
	
	formatex(p_LogDir, charsmax(p_LogDir), "%s/chat_translit", p_FilePath)
	formatex(p_LogFile, charsmax(p_LogFile), "%s/chat_%s.txt", p_LogDir, p_LogFileTime)
	if(!dir_exists(p_LogDir))
	{
		mkdir(p_LogDir)
	}
	if(!file_exists(p_LogFile))
	{
		formatex(p_LogTitle, charsmax(p_LogTitle), "Start log %s", p_LogFileTime)
		write_file(p_LogFile, p_LogTitle)
		write_file(p_LogFile, LOGFONT)
	}
	new MapName[32]
	get_mapname(MapName,31)
	formatex(p_LogMessage, charsmax(p_LogMessage), "================================= %s =================================",MapName)
	write_file(p_LogFile, p_LogMessage)
}


public Block(id)
{
	g_ShowPrefix[id] = !g_ShowPrefix[id];
	client_print_color(id,print_team_default,"Отображение рангов [^x04%s^x01]", g_ShowPrefix[id] ? "Включено" : "Отключено");
	return PLUGIN_CONTINUE;
}

public plugin_cfg()
{
	get_configsdir(s_ConfigsDir, 63)
	formatex(s_FilePrefix, charsmax(s_FilePrefix), "%s/colored_translit/prefix.ini", s_ConfigsDir)
	formatex(s_SwearFile, charsmax(s_SwearFile), "%s/colored_translit/swears.ini", s_ConfigsDir)
	formatex(s_ReplaceFile, charsmax(s_ReplaceFile), "%s/colored_translit/replaces.ini", s_ConfigsDir)
	formatex(s_IgnoreFile, charsmax(s_IgnoreFile), "%s/colored_translit/ignores.ini", s_ConfigsDir)
	formatex(s_SkipsFile, charsmax(s_SkipsFile), "%s/colored_translit/skips.ini", s_ConfigsDir)
	formatex(s_SpamFile,  charsmax(s_SpamFile), "%s/colored_translit/spam.ini", s_ConfigsDir)
	formatex(s_CheatFile,  charsmax(s_CheatFile), "%s/colored_translit/cheat.ini", s_ConfigsDir)
	formatex(s_ConfigFile, charsmax(s_ConfigFile), "%s/colored_translit/config.cfg", s_ConfigsDir)
	
	set_pcvar_num(g_Translit, 0)
	TranslitList = false
	
	if(file_exists(s_SwearFile))
	{
		new i=0
		while(i < MAX_SWEARS && read_file(s_SwearFile, i , Swear[SwearNum], 63, Len))
		{
			i++
			if(Swear[SwearNum][0] == ';' || !Len)
			{
				continue
			}
			SwearNum++
		}
		SwearList = true
	}
	else
	{
		set_pcvar_num(g_SwearFilter, 0)
		SwearList = false
	}
	if(file_exists(s_ReplaceFile))
	{
		new i=0
		while(i < MAX_REPLACES && read_file(s_ReplaceFile, i , Replace[ReplaceNum], 191, Len))
		{
			i++
			if(Replace[ReplaceNum][0] == ';' || !Len)
			{
				continue
			}
			ReplaceNum++
		}
		ReplaceList = true
	}
	else
	{
		set_pcvar_num(g_SwearFilter, 0)
		ReplaceList = false
	}
	if(file_exists(s_IgnoreFile))
	{
		new i=0
		while(i < MAX_IGNORES && read_file(s_IgnoreFile, i , Ignore[IgnoreNum], 63, Len))
		{
			i++
			if(Ignore[IgnoreNum][0] == ';' || !Len)
			{
				continue
			}
			IgnoreNum++
		}
		IgnoreList = true
	}
	else
	{
		set_pcvar_num(g_Ignore, 0)
		IgnoreList = false
	}
	
	
	if(file_exists(s_SkipsFile))
	{
		new i=0
		while(i < MAX_SKIPS && read_file(s_SkipsFile, i , Skips[SkipsNum], 63, Len))
		{
			i++
			if(Skips[SkipsNum][0] == ';' || !Len)
			{
				continue
			}
			SkipsNum++
		}
		SkipsList = true
	}
	else
	{
		SkipsList = false
	}
	
	if(file_exists(s_SpamFile))
	{
		new i=0
		while(i < MAX_SPAMS && read_file(s_SpamFile, i , Spam[SpamNum], 191, Len))
		{
			i++
			if(Spam[SpamNum][0] == ';' || !Len)
			{
				continue
			}
			SpamNum++
		}
		SpamList = true
	}
	else
	{
		set_pcvar_num(g_Spam, 0)
		SpamList = false
	}
	if(file_exists(s_CheatFile))
	{
		new i=0
		while(i < MAX_CHEAT && read_file(s_CheatFile, i , Cheat[CheatNum], 191, Len))
		{
			i++
			if(Cheat[CheatNum][0] == ';' || !Len)
			{
				continue
			}
			CheatNum++
		}
		CheatList = true
	}
	else
	{
		set_pcvar_num(g_Cheat, 0)
		CheatList = false
	}
	if(file_exists(s_ConfigFile))
	{
		server_cmd("exec %s", s_ConfigFile)
		ConfigsList = true
	}
	else
	{
		ConfigsList = false
	}
	log_message("========== [%s] START SET FCVAR ==========", PLUGIN)
	register_cvar("Colored Translit Version", "2.0b Final", FCVAR_SERVER)
	if(TranslitList)
	{
		register_cvar("Colored Translit Status", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Status", "Failed", FCVAR_SERVER)
	}
	if(SwearList)
	{
		register_cvar("Colored Translit Swear", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Swear", "Failed", FCVAR_SERVER)
	}
	if(ReplaceList)
	{
		register_cvar("Colored Translit Replace", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Replace", "Failed", FCVAR_SERVER)
	}
	if(IgnoreList)
	{
		register_cvar("Colored Translit Ignores", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Ignores", "Failed", FCVAR_SERVER)
	}
	if(SkipsList)
	{
		register_cvar("Colored Translit Skips", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Skips", "Failed", FCVAR_SERVER)
	}
	if(SpamList)
	{
		register_cvar("Colored Translit Spam", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Spam", "Failed", FCVAR_SERVER)
	}
	if(CheatList)
	{
		register_cvar("Colored Translit Cheat", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Cheat", "Failed", FCVAR_SERVER)
	}
	if(ConfigsList)
	{
		register_cvar("Colored Translit Config", "Loaded", FCVAR_SERVER)
	}
	else
	{
		register_cvar("Colored Translit Config", "Failed", FCVAR_SERVER)
	}
	log_message("=========== [%s] END SET FCVAR ===========", PLUGIN)
	log_message("=========== [%s] START DEBUG =============", PLUGIN)

	if(SwearList)
	{
		log_message("[%s] Swear File Loaded. Swears: %d", PLUGIN, SwearNum)	
	}
	else
	{
		log_message("[%s] Swear File Not Found: %s", PLUGIN, s_SwearFile)
	}
	if(ReplaceList)
	{
		log_message("[%s] Replace File Loaded. Replacements: %d", PLUGIN, ReplaceNum)	
	}
	else
	{
		log_message("[%s] Replace File Not Found: %s", PLUGIN, s_ReplaceFile)
	}
	if(IgnoreList)
	{
		log_message("[%s] Ignore File Loaded. Ignore Words: %d", PLUGIN, IgnoreNum)
	}
	else
	{
		log_message("[%s] Ignore File Not Found: %s", PLUGIN, s_IgnoreFile)
	}
	if(SkipsList)
	{
		log_message("[%s] Ignore File Loaded. Skips Words: %d", PLUGIN, SkipsNum)
		new i = 0
		while(i < SkipsNum)
		{
			log_message("[%s]",Skips[i++])
		}
	}
	else
	{
		log_message("[%s] Skips File Not Found: %s", PLUGIN, s_SkipsFile)
	}
	if(SpamList)
	{
		log_message("[%s] Spam File Loaded. Spam Words: %d", PLUGIN, SpamNum)
	}
	else
	{
		log_message("[%s] Spam File Not Found: %s", PLUGIN, s_SpamFile)
	}
	if(CheatList)
	{
		log_message("[%s] Cheat File Loaded. Cheat Words: %d", PLUGIN, CheatNum)
	}
	else
	{
		log_message("[%s] Cheat File Not Found: %s", PLUGIN, s_CheatFile)
	}
	if(ConfigsList)
	{
		log_message("[%s] Config File Executed. Version: %s", PLUGIN, VERSION)
	}
	else
	{
		log_message("[%s] Config File Not Found: %s", PLUGIN, s_ConfigFile)
	}
	log_message("=========== [%s] END DEBUG ===============", PLUGIN)
	return PLUGIN_CONTINUE
}
/*
* 	Colored Translit v3.0 by Sho0ter
*	Connector
*/
public client_putinserver(id)
{
	g_ShowPrefix[id] = true
	Logged[id] = false
	set_task(10.0, "ShowInfo", id)
	get_user_name(id, s_CheckGag, charsmax(s_CheckGag))
	get_user_ip(id, s_CheckIp, charsmax(s_CheckIp), 1)


	if(get_systime(0) < i_Gag[id])
	{
		if(!equal(s_GagName[id], s_CheckGag) && !equal(s_GagIp[id], s_CheckIp))
		{
			i_Gag[id] = get_systime(0)
			SpamFound[id] = 0
			SwearCount[id] = 0
		}
	}
	s_Prefix[id][0] = 0;
	s_Prefix2[id][0] = 0;
	set_task(2.0,"setprefix",3000 + id)
	return PLUGIN_CONTINUE
}

public client_disconnected(id)
{
	remove_task(id+3000)
}

public OnAPISendChatPrefix(id, prefix[], type)
{
    if( type == 1 && prefix[0] && cmsapi_get_user_services(id, "", "_nick_prefix", 0))
		formatex(s_Prefix[id], charsmax(s_Prefix[]), "%s", prefix);
}

public setprefix(idx)
{
	new id = idx - 3000
	new player_authid[40] 
	get_user_authid(id, player_authid, 39) 
	crxranks_get_user_rank(id,s_Prefix2[id],63)
	

	if(get_user_flags(id) & ADMIN_IMMUNITY || get_user_flags(id) & ADMIN_RESERVATION || get_user_flags(id) & ADMIN_LEVEL_G || get_user_flags(id) & ADMIN_LEVEL_H)
	{
		if (strlen(s_Prefix[id]) <= 0)
		{
			log_message("Need search prefix %s",player_authid);
			ini_read_string(s_FilePrefix, player_authid, "Prefix", s_Prefix[id], 63);
			if (strlen(s_Prefix[id]) > 0)
			{
				log_message("Prefix found! %s",s_Prefix[id]);
			}
			else 
			{
				
				log_message("Prefix not found!",s_Prefix[id]);
			}
		}
		
		if (strlen(s_Prefix[id]) > 0)
		{
			
		}
		else
		{
			if (get_user_flags(id) & ADMIN_LEVEL_G)
			{
				if (get_user_flags(id) & ADMIN_KICK || get_user_flags(id) & ADMIN_BAN)
					formatex(s_Prefix[id], 63, "%s" ,"Aдминкa")
				else 
					formatex(s_Prefix[id], 63, "%s" ,"Bипкa")
			}
			else
			{
				if (get_user_flags(id) & ADMIN_RCON)
				{
					formatex(s_Prefix[id], 63,"%s" ,"суп.AДMИH")
				}
				else if (get_user_flags(id) & ADMIN_CFG)
				{
					formatex(s_Prefix[id], 63,"%s" ,"cт.AДMИH")
				}
				else if (get_user_flags(id) & ADMIN_BAN && get_user_flags(id) & ADMIN_RESERVATION)
				{
					formatex(s_Prefix[id], 63,"%s" ,"Aдмин+Bип")
				}
				else if (get_user_flags(id) & ADMIN_BAN && get_user_flags(id) & ADMIN_LEVEL_H)
				{
					formatex(s_Prefix[id], 63,"%s" ,"Aдмин+Gold")
				}
				else if (get_user_flags(id) & ADMIN_BAN)
				{
					formatex(s_Prefix[id], 63,"%s" ,"Aдмин")
				}
				else if (get_user_flags(id) & ADMIN_LEVEL_H)
				{
					formatex(s_Prefix[id], 63,"%s" ,"Gold.Вип")
				}
				else 
				{
					formatex(s_Prefix[id], 63,"%s" ,"Bип")
				}
			}
			
		}
	}
}


public rtvrtvrtv(id)
{
	client_cmd ( id, ";^"Say^" /votemap" )
}

public cmd_gag(id, level, cid)
{
	if(!cmd_access(id, level, cid, 3))
	{
		return PLUGIN_HANDLED
	}
	read_args(s_Arg, charsmax(s_Arg))
	parse(s_Arg, s_GagPlayer, charsmax(s_GagPlayer), s_GagTime, charsmax(s_GagTime))
	if(!is_str_num(s_GagTime))
	{
		formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_CMD_ERROR")
		WriteMessage(id, Info,print_team_default)
		return PLUGIN_CONTINUE
	}
	gagid = cmd_target(id, s_GagPlayer, 8)
	if(!gagid)
	{
		return PLUGIN_HANDLED
	}
	get_user_name(id, s_GagAdmin, charsmax(s_GagAdmin))
	get_user_name(gagid, s_GagTarget, charsmax(s_GagTarget))
	if(get_user_flags(gagid) & IMMUNITY_LEVEL && get_pcvar_num(g_GagImmunity))
	{
		formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_IMMUNITY", s_GagTarget)
		WriteMessage(id, Info,print_team_default)
	}
	else
	{
		i_GagTime = str_to_num(s_GagTime)
		get_user_name(gagid, s_GagName[gagid], 31)
		get_user_ip(gagid, s_GagIp[gagid], 31, 1)
		SysTime = get_systime(0)
		i_Gag[gagid] = SysTime + i_GagTime*60
		Flood[gagid] = false
		if(get_pcvar_num(g_Sounds))
		{
			client_cmd(gagid, "spk buttons/button5")
			client_cmd(id, "spk buttons/button5")
		}
		switch(get_cvar_num("amx_show_activity"))
		{
			case 0:
			{
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_A0_GAG", s_GagTarget, i_GagTime)
				WriteMessage(id, Info,print_team_default)
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, gagid, "CT_YOU_GAGED", i_GagTime)
				WriteMessage(gagid, Info,print_team_default)
			}
			case 1:
			{
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_A1_GAG", s_GagTarget, i_GagTime)
				for(new player = 0; player <= get_maxplayers(); player++)
				{
					if(!is_user_connected(player) || player == gagid)
					{
						continue
					}
					WriteMessage(player, Info,print_team_default)
				}
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, gagid, "CT_YOU_GAGED", i_GagTime)
				WriteMessage(gagid, Info,print_team_default)
			}
			case 2:
			{
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_A2_GAG", s_GagAdmin, s_GagTarget, i_GagTime)
				for(new player = 0; player <= get_maxplayers(); player++)
				{
					if(!is_user_connected(player) || player == gagid)
					{
						continue
					}
					WriteMessage(player, Info,print_team_default)
				}
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, gagid, "CT_YOU_GAGED2", s_GagAdmin, i_GagTime)
				WriteMessage(gagid, Info,print_team_default)
				if(get_pcvar_num(g_Log))
				{
					get_time("20%y.%m.%d", p_LogFileTime, charsmax(p_LogFileTime))
					get_time("%H:%M:%S", p_LogTime, charsmax(p_LogTime))
					formatex(p_LogDir, charsmax(p_LogDir), "%s/colored_translit", p_FilePath)
					formatex(p_LogFile, charsmax(p_LogFile), "%s/gag_%s.log", p_LogDir, p_LogFileTime)
					if(!dir_exists(p_LogDir))
					{
						mkdir(p_LogDir)
					}
					get_user_ip(gagid, p_LogIp, charsmax(p_LogIp), 1)
					get_user_ip(id, p_LogAdminIp, charsmax(p_LogAdminIp), 1)
					formatex(p_LogMessage, charsmax(p_LogMessage), "%s - ADMIN %s <%s> has gaged %s <%s> for %d minutes", p_LogTime, s_GagAdmin, p_LogAdminIp, s_GagTarget, p_LogIp, i_GagTime)
					write_file(p_LogFile, p_LogMessage)
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}

/*
* 	Colored Translit v3.0 by Sho0ter
*	Ungager
*/
public cmd_ungag(id, level, cid)
{
	if(!cmd_access(id, level, cid, 2))
	{
		return PLUGIN_HANDLED
	}
	SysTime = get_systime(0)
	read_args(s_GagPlayer, charsmax(s_GagPlayer))
	gagid = cmd_target(id, s_GagPlayer, 8)
	if(!gagid)
	{
		return PLUGIN_HANDLED
	}
	get_user_name(id, s_GagAdmin, charsmax(s_GagAdmin))
	get_user_name(gagid, s_GagTarget, charsmax(s_GagTarget))
	if(i_Gag[gagid] <= SysTime)
	{
			formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_ALREADY", s_GagTarget)
			WriteMessage(id, Info,print_team_default)
	}
	else
	{
		SysTime = get_systime(0)
		i_Gag[gagid] = SysTime
		if(get_pcvar_num(g_Sounds))
		{
			client_cmd(gagid, "spk buttons/button6")
			client_cmd(id, "spk buttons/button6")
		}
		switch(get_cvar_num("amx_show_activity"))
		{
			case 0:
			{
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_A0_UNGAG", s_GagTarget)
				WriteMessage(id, Info,print_team_default)
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, gagid, "CT_YOU_UNGAGED")
				WriteMessage(gagid, Info,print_team_default)
			}
			case 1:
			{
				formatex(Info, charsmax(Info), "[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_A1_UNGAG", s_GagTarget)
				for(new player = 0; player <= get_maxplayers(); player++)
				{
					if(!is_user_connected(player) || player == gagid)
					{
						continue
					}
					WriteMessage(player, Info,print_team_default)
				}
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, gagid, "CT_YOU_UNGAGED")
				WriteMessage(gagid, Info,print_team_default)
			}
			case 2:
			{
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_A2_UNGAG", s_GagAdmin, s_GagTarget)
				for(new player = 0; player <= get_maxplayers(); player++)
				{
					if(!is_user_connected(player) || player == gagid)
					{
						continue
					}
					WriteMessage(player, Info,print_team_default)
				}
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, gagid, "CT_YOU_UNGAGED2", s_GagAdmin)
				WriteMessage(gagid, Info,print_team_default)
				if(get_pcvar_num(g_Log))
				{
					get_time("20%y.%m.%d", p_LogFileTime, charsmax(p_LogFileTime))
					get_time("%H:%M:%S", p_LogTime, charsmax(p_LogTime))
					formatex(p_LogDir, charsmax(p_LogDir), "%s/colored_translit", p_FilePath)
					formatex(p_LogFile, charsmax(p_LogFile), "%s/gag_%s.log", p_LogDir, p_LogFileTime)
					if(!dir_exists(p_LogDir))
					{
						mkdir(p_LogDir)
					}
					get_user_ip(gagid, p_LogIp, charsmax(p_LogIp), 1)
					get_user_ip(id, p_LogAdminIp, charsmax(p_LogAdminIp), 1)
					formatex(p_LogMessage, charsmax(p_LogMessage), "%s - ADMIN %s <%s> has ungaged %s <%s>", p_LogTime, s_GagAdmin, p_LogAdminIp, s_GagTarget, p_LogIp)
					write_file(p_LogFile, p_LogMessage)
				}
			}
		}
	}
	return PLUGIN_CONTINUE
}


public native_register_clcmd(const cmd[])
{
	param_convert(1)
	if(!strlen(cmd))
	{
		log_error(AMX_ERR_NATIVE, "Empty command")
		return 0
	}
	copy(Cmds[CmdsNum], 127, cmd)
	CmdsNum++
	return 1
}

public native_infomsg(id, const input[], any:...)
{
	param_convert(2)
	param_convert(3)
	if(!is_valid_player(id) && id != 0)
	{
		log_error(AMX_ERR_NATIVE, "Invalid player %d", id)
		return 0
	}
	new msg[192]
	vformat(msg, charsmax(msg), input, 3)
	formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %s", PLUGIN, msg)
	new allokay = 0
	if(id && is_user_connected(id))
	{
		WriteMessage(id, Info,print_team_default)
		return 1
	}
	else
	{
		for(new i = 1; i <= get_maxplayers(); i++)
		{
			if(!is_user_connected(i))
			{
				continue
			}
			WriteMessage(i, Info,print_team_default)
			allokay = 1
		}
	}
	return allokay
}

public native_get_lang(id)
{
	if(!is_valid_player(id))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player %d", id)
		return 0
	}
	return translit[id];
}

public native_add_to_msg(position, const input[], any:...)
{
	param_convert(2)
	param_convert(3)
	if(0 > position || position > 3)
	{
		log_error(AMX_ERR_NATIVE, "Invalid message position %d", position)
		return 0
	}
	if(!strlen(input))
	{
		log_error(AMX_ERR_NATIVE, "Empty input string")
		return 0
	}
	new rdmsg[128]
	vformat(rdmsg, charsmax(rdmsg), input, 3)
	copy(Adds[position][AddsNum[position]], 127, rdmsg)
	AddsNum[position]++
	return 1
}

public native_is_gaged(id)
{
	if(!is_valid_player(id))
	{
		log_error(AMX_ERR_NATIVE, "Invalid player %d", id)
		return 0
	}
	if(i_Gag[id] > get_systime(0))
	{
		return i_Gag[id]
	}
	return 0
}

/*
* 	Colored Translit v3.0 by Sho0ter
*	Informer
*/
public ShowInfo(id)
{
	if(get_pcvar_num(g_AutoRus) == 1)
	{
		translit[id] = 1;
	}
	if(get_pcvar_num(g_ShowInfo) == 1 && get_pcvar_num(g_AutoRus) != 2)
	{
		if(!is_user_connected(id))
		{
			return PLUGIN_CONTINUE
		}
		formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_INFO_RUS")
		WriteMessage(id, Info,print_team_default)
		formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_INFO_ENG")
		WriteMessage(id, Info,print_team_default)
	}
	return PLUGIN_CONTINUE
}
 
/*
* 	Colored Translit v3.0 by Sho0ter
*	Say Messager
*/
public hook_say(id)
{
	if(is_user_hltv(id) || is_user_bot(id))
	{
		return PLUGIN_CONTINUE
	}
	if(is_user_gaged(id))
	{
		return PLUGIN_HANDLED
	}
	read_args(s_Msg, charsmax(s_Msg))
	remove_quotes(s_Msg)
	replace_all(s_Msg, charsmax(s_Msg), "%s", "")
	for(new posid; posid < 4; posid++)
	{
		AddsNum[posid] = 0
	}
	ExecuteForward(fwd_Begin, fwdResult, id, s_Msg, 0)
	if(check_plugin_cmd(s_Msg))
	{
		return PLUGIN_CONTINUE
	}
	if(is_empty_message(s_Msg))
	{
		return PLUGIN_HANDLED
	}
	if(is_system_message(s_Msg))
	{
		/*if(get_pcvar_num(g_IgnoreMode) == 1)
		{
			SlashFound = true
		}
		else if(get_pcvar_num(g_IgnoreMode) == 2)
		{*/
			return PLUGIN_HANDLED
		//}
		/*else if(get_pcvar_num(g_IgnoreMode) == 3)
		{
			return PLUGIN_CONTINUE
		}*/
	}
	else
	{
		SlashFound = false
	}
	get_time("20%y.%m.%d", p_LogFileTime, charsmax(p_LogFileTime))
	get_time("%H:%M:%S", p_LogTime, charsmax(p_LogTime))
	if(get_pcvar_num(g_Cheat) && is_cheat_message(id, s_Msg))
	{
		ExecuteForward(fwd_Cheat, fwdResult, id, s_Msg)
		client_punish(id, PUNISH_CHEAT)
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(g_Spam) && is_spam_message(id, s_Msg))
	{
		ExecuteForward(fwd_Spam, fwdResult, id, s_Msg)
		SpamFound[id]++
		if(SpamFound[id]-1 >= get_pcvar_num(g_SpamWarns))
		{
			SpamFound[id] = 0
			client_punish(id, PUNISH_SPAM)
		}
		else
		{
			formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_SPAMWARN", get_pcvar_num(g_SpamWarns) - SpamFound[id])
			WriteMessage(id, Info,print_team_default)
			if(get_pcvar_num(g_Sounds))
			{
				client_cmd(id, "spk buttons/blip2")
			}
		}
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(g_Ignore) && is_ignored_message(s_Msg))
	{
		if(get_pcvar_num(g_IgnoreMode) == 1)
		{
			IgnoreFound = true
		}
		else if(get_pcvar_num(g_IgnoreMode) == 2)
		{
			return PLUGIN_HANDLED
		}
		else if(get_pcvar_num(g_IgnoreMode) == 3)
		{
			return PLUGIN_CONTINUE
		}
	}
	else
	{
		IgnoreFound = false
	}
	
		
	if(is_skips_message(s_Msg))
	{
		return PLUGIN_HANDLED
	}
	
	
	get_user_team(id, AliveTeam, charsmax(AliveTeam))
	ReplaceSwear(charsmax(s_Msg), s_Msg)
	if(get_pcvar_num(g_Translit) && !IgnoreFound)
	{
		if(translit[id] == 1 || get_pcvar_num(g_AutoRus) == 2)
		{
			for(new i; i < i_MaxSimbols; i++)
			{
				if(contain(s_SwearMsg, g_OriginalSimb[i]) != -1)
				{
					replace_all(s_SwearMsg, charsmax(s_SwearMsg), g_OriginalSimb[i], g_TranslitSimb[i])
				}
			}
			for(new i; i < i_MaxSimbols; i++)
			{
				if(contain(s_Msg, g_OriginalSimb[i]) != -1)
				{
					replace_all(s_Msg, charsmax(s_Msg), g_OriginalSimb[i], g_TranslitSimb[i])
				}
			}
		}
	}
	get_user_name(id, s_Name, charsmax(s_Name))
	if(get_pcvar_num(g_SwearFilter))
	{
		new iSwear = is_swear_message(id, s_SwearMsg)
		if(iSwear)
		{
			ExecuteForward(fwd_Swear, fwdResult, id, s_Msg)
		}
		if(iSwear)
		{
			SwearFound = 1
			SwearCount[id]++
			if(get_pcvar_num(g_SwearGag) && (SwearCount[id]-1 >= get_pcvar_num(g_SwearWarns)))
			{
				SwearCount[id] = 0
				Flood[id] = false
				SysTime = get_systime(0)
				i_Gag[id] = SysTime + get_pcvar_num(g_SwearTime)*60
				get_user_name(id, s_GagName[id], 31)
				get_user_ip(id, s_GagIp[id], 31, 1)
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_SWEAR_GAG", get_pcvar_num(g_SwearTime))
				WriteMessage(id, Info,print_team_default)
				if(get_pcvar_num(g_Log) == 1)
				{
					formatex(p_LogDir, charsmax(p_LogDir), "%s/chat_translit", p_FilePath)
					formatex(p_LogFile, charsmax(p_LogFile), "%s/gag_%s.log", p_LogDir, p_LogFileTime)
					if(!dir_exists(p_LogDir))
					{
						mkdir(p_LogDir)
					}
					get_user_ip(id, p_LogIp, charsmax(p_LogIp), 1)
					formatex(p_LogMessage, charsmax(p_LogMessage), "%s - Swear Filter has gaged %s <%s> for %d minutes. Message: %s. Found: %s", p_LogTime, s_GagName[id], p_LogIp, get_pcvar_num(g_SwearTime), s_SwearMsg, Swear[iSwear - 1])
					write_file(p_LogFile, p_LogMessage)
				}
				if(get_pcvar_num(g_Sounds))
				{
					client_cmd(id, "spk buttons/button5")
				}
			}
			else if(get_pcvar_num(g_SwearGag))
			{
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_SWEARWARN", get_pcvar_num(g_SwearWarns) - SwearCount[id])
				WriteMessage(id, Info,print_team_default)
				if(get_pcvar_num(g_Sounds))
				{
					client_cmd(id, "spk buttons/blip2")
				}
			}
		}
		else
		{
			SwearFound = 0
		}
	}
	ExecuteForward(fwd_formatex, fwdResult, id)
	mLen = 0
	lgLen = 0
	new posnum
	mLen = formatex(Message, charsmax(Message), "^x01")
	if(AddsNum[CT_MSGPOS_START])
	{
		for(posnum = 0; posnum < AddsNum[CT_MSGPOS_START]; posnum++)
		{
			mLen += formatex(Message[mLen], charsmax(Message) - mLen, "%s ", Adds[CT_MSGPOS_START][posnum])
			lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", Adds[CT_MSGPOS_START][posnum])
		}
	}
	if(!is_user_alive(id) && !equal(AliveTeam, "SPECTATOR"))
	{
		isAlive = 0
		mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x01*%L* ", LANG_PLAYER, "CT_DEAD")
		lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "*%L* ", LANG_PLAYER, "CT_DEAD")
	}
	else if(!is_user_alive(id) && equal(AliveTeam, "SPECTATOR"))
	{
		isAlive = 0
		mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x01*%L* ", LANG_PLAYER, "CT_SPECTATOR")
		lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "*%L* ", LANG_PLAYER, "CT_SPECTATOR")
	}
	else
	{
		isAlive = 1
		mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x01")
	}
	if(AddsNum[CT_MSGPOS_PREFIX])
	{
		for(posnum = 0; posnum < AddsNum[CT_MSGPOS_PREFIX]; posnum++)
		{
			mLen += formatex(Message[mLen], charsmax(Message) - mLen, "%s ", Adds[CT_MSGPOS_PREFIX][posnum])
			lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", Adds[CT_MSGPOS_PREFIX][posnum])
		}
	}
	
	if(get_user_flags(id) & NICK_LEVEL && strlen(s_Prefix[id]) > 0)
	{
		mLen += formatex(Message[mLen], charsmax(Message) - mLen, "[^x04%s^x01]%s%s%s",s_Prefix[id],"%s","%s","%s")
		lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "[%s] ",s_Prefix[id])
	}
	else 
	{
		mLen += formatex(Message[mLen], charsmax(Message) - mLen, "%s%s%s","%s","%s","%s")
		lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "[%s] ",s_Prefix2[id])
	}
	
	if(AddsNum[CT_MSGPOS_PRENAME])
	{
		for(posnum = 0; posnum < AddsNum[CT_MSGPOS_PRENAME]; posnum++)
		{
			mLen += formatex(Message[mLen], charsmax(Message) - mLen, "%s ", Adds[CT_MSGPOS_PRENAME][posnum])
			lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", Adds[CT_MSGPOS_PRENAME][posnum])
		}
	}
	
	if(get_user_flags(id) & NICK_LEVEL)
	{
		switch(get_pcvar_num(g_NameColor))
		{
			case 1:
			{
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, "%s", s_Name)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", s_Name)
			}
			case 2:
			{
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x04%s^x01 ", s_Name)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", s_Name)
			}
			case 3:
			{
				color = print_team_grey
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x03%s^x01 ", s_Name)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", s_Name)
			}
			case 4:
			{
				color = print_team_blue
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x03%s^x01 ", s_Name)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", s_Name)
			}
			case 5:
			{
				color = print_team_red
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x03%s^x01 ", s_Name)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", s_Name)
			}
			case 6:
			{
				color = id
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x03%s^x01 ", s_Name)
			}
		}
		switch(get_pcvar_num(g_ChatColor))
		{
			case 1:
			{
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, ": %s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, ": %s ", s_Msg)
			}
			case 2:
			{
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, ": ^x04%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, ": %s ", s_Msg)
			}
			case 3:
			{
				color = print_team_grey
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, ": ^x03%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, ": %s ", s_Msg)
			}
			case 4:
			{
				color = print_team_blue
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, ": ^x03%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, ": %s ", s_Msg)
			}
			case 5:
			{
				color = print_team_red
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, ": ^x03%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, ": %s ", s_Msg)
			}
			case 6:
			{
				color = id
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, ": ^x03%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, ": %s ", s_Msg)
			}
		}
	}
	else
	{
		color = id
		mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x03%s ^x01: %s", s_Name, SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
		lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s : %s ", s_Name, s_Msg)
	}
	if(AddsNum[CT_MSGPOS_END])
	{
		for(posnum = 0; posnum < AddsNum[CT_MSGPOS_END]; posnum++)
		{
			mLen += formatex(Message[mLen], charsmax(Message) - mLen, " %s", Adds[CT_MSGPOS_END][posnum])
			lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s", Adds[CT_MSGPOS_END][posnum])
		}
	}
	//if(strlen(Message) >= 192)
	//{
	//	formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_LONGMSG")
	//	WriteMessage(id, Info,print_team_default)
	//	return PLUGIN_HANDLED
	//}
	
	
	formatex(MessageNoPrefix, charsmax(MessageNoPrefix), Message,"","","")
	formatex(MessagePrefix, charsmax(MessagePrefix), Message, "[^x04",s_Prefix2[id],"^x01]")
	
	
	switch(get_pcvar_num(g_AllChat))
	{
		case 0:
		{
			SendMessage(color, isAlive)
		}
		case 1:
		{
			SendMessageAll(color)
		}
		case 2:
		{
			if(get_user_flags(id) & ACCESS_LEVEL)
			{
				SendMessageAll(color)
			}
			else
			{
				SendMessage(color, isAlive)
			}
		}
	}
	if(get_pcvar_num(g_Log))
	{
		formatex(p_LogDir, charsmax(p_LogDir), "%s/chat_translit", p_FilePath)
		formatex(p_LogFile, charsmax(p_LogFile), "%s/chat_%s.txt", p_LogDir, p_LogFileTime)
		if(!dir_exists(p_LogDir))
		{
			mkdir(p_LogDir)
		}
		if(!file_exists(p_LogFile))
		{
			formatex(p_LogTitle, charsmax(p_LogTitle), "Start log %s", p_LogFileTime)
			write_file(p_LogFile, p_LogTitle)
			write_file(p_LogFile, LOGFONT)
		}
		get_user_ip(id, p_LogIp, charsmax(p_LogIp), 1)
		get_user_authid(id, p_LogSteamId, charsmax(p_LogSteamId))
		formatex(p_LogInfo, charsmax(p_LogInfo), "%s [%s] - [%s] - ", p_LogTime, p_LogSteamId, p_LogIp)
		formatex(p_LogMessage, charsmax(p_LogMessage), "%s[ALL] -> %s", p_LogInfo, p_LogMsg)
		write_file(p_LogFile, p_LogMessage)
		
		log_message("^"%s<%i><%s><%s>^" %s ^"%s^"%s",s_Name, get_user_userid(id), p_LogSteamId,
			AliveTeam, "say", s_Msg, "");
	}
	if((!SwearFound || get_pcvar_num(g_SwearGag) != 1) && get_pcvar_num(g_FloodTime))
	{
		SysTime = get_systime(0)
		i_Gag[id] = SysTime + get_pcvar_num(g_FloodTime)
		Flood[id] = true
	}
	return PLUGIN_HANDLED
}

/*
* 	Colored Translit v3.0 by Sho0ter
*	Say Team Messager
*/
public hook_say_team(id)
{
	if(is_user_hltv(id) || is_user_bot(id))
	{
		return PLUGIN_CONTINUE
	}
	if(is_user_gaged(id))
	{
		return PLUGIN_HANDLED
	}
	read_args(s_Msg, charsmax(s_Msg))
	remove_quotes(s_Msg)
	replace_all(s_Msg, charsmax(s_Msg), "%s", "")
	for(new posid; posid < 4; posid++)
	{
		AddsNum[posid] = 0
	}
	ExecuteForward(fwd_Begin, fwdResult, id, s_Msg, 1)
	if(check_plugin_cmd(s_Msg))
	{
		return PLUGIN_CONTINUE
	}
	if(is_empty_message(s_Msg))
	{
		return PLUGIN_HANDLED
	}
	if(is_system_message(s_Msg))
	{
		if(get_pcvar_num(g_IgnoreMode) == 1)
		{
			SlashFound = true
		}
		else if(get_pcvar_num(g_IgnoreMode) == 2)
		{
			return PLUGIN_HANDLED
		}
		else if(get_pcvar_num(g_IgnoreMode) == 3)
		{
			return PLUGIN_CONTINUE
		}
	}
	else
	{
		SlashFound = false
	}
	get_time("20%y.%m.%d", p_LogFileTime, charsmax(p_LogFileTime))
	get_time("%H:%M:%S", p_LogTime, charsmax(p_LogTime))
	if(get_pcvar_num(g_Cheat) && is_cheat_message(id, s_Msg))
	{
		ExecuteForward(fwd_Cheat, fwdResult, id, s_Msg)
		client_punish(id, PUNISH_CHEAT)
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(g_Spam) && is_spam_message(id, s_Msg))
	{
		ExecuteForward(fwd_Spam, fwdResult, id, s_Msg)
		SpamFound[id]++
		if(SpamFound[id]-1 >= get_pcvar_num(g_SpamWarns))
		{
			SpamFound[id] = 0
			client_punish(id, PUNISH_SPAM)
		}
		else
		{
			formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_SPAMWARN", get_pcvar_num(g_SpamWarns) - SpamFound[id])
			WriteMessage(id, Info,print_team_default)
			if(get_pcvar_num(g_Sounds))
			{
				client_cmd(id, "spk buttons/blip2")
			}
		}
		return PLUGIN_HANDLED
	}
	if(get_pcvar_num(g_Ignore) && is_ignored_message(s_Msg))
	{
		if(get_pcvar_num(g_IgnoreMode) == 1)
		{
			IgnoreFound = true
		}
		else if(get_pcvar_num(g_IgnoreMode) == 2)
		{
			return PLUGIN_HANDLED
		}
		else if(get_pcvar_num(g_IgnoreMode) == 3)
		{
			return PLUGIN_CONTINUE
		}
	}
	else
	{
		IgnoreFound = false
	}
	
	if(is_skips_message(s_Msg))
	{
		return PLUGIN_HANDLED
	}
	
	get_user_team(id, AliveTeam, charsmax(AliveTeam))
	ReplaceSwear(charsmax(s_Msg), s_Msg)
	if(get_pcvar_num(g_Translit) && !IgnoreFound)
	{
		if(translit[id] == 1 || get_pcvar_num(g_AutoRus) == 2)
		{
			for(new i; i < i_MaxSimbols; i++)
			{
				if(contain(s_SwearMsg, g_OriginalSimb[i]) != -1)
				{
					replace_all(s_SwearMsg, charsmax(s_SwearMsg), g_OriginalSimb[i], g_TranslitSimb[i])
				}
			}
			for(new i; i < i_MaxSimbols; i++)
			{
				if(contain(s_Msg, g_OriginalSimb[i]) != -1)
				{
					replace_all(s_Msg, charsmax(s_Msg), g_OriginalSimb[i], g_TranslitSimb[i])
				}
			}
		}
	}
	get_user_name(id, s_Name, charsmax(s_Name))
	if(get_pcvar_num(g_SwearFilter))
	{
		new iSwear = is_swear_message(id, s_SwearMsg)
		if(iSwear)
		{
			ExecuteForward(fwd_Swear, fwdResult, id, s_Msg)
		}
		if(iSwear)
		{
			SwearFound = 1
			SwearCount[id]++
			if(get_pcvar_num(g_SwearGag) && (SwearCount[id]-1 >= get_pcvar_num(g_SwearWarns)))
			{
				SwearCount[id] = 0
				Flood[id] = false
				SysTime = get_systime(0)
				i_Gag[id] = SysTime + get_pcvar_num(g_SwearTime)*60
				get_user_name(id, s_GagName[id], 31)
				get_user_ip(id, s_GagIp[id], 31, 1)
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_SWEAR_GAG", get_pcvar_num(g_SwearTime))
				WriteMessage(id, Info,print_team_default)
				if(get_pcvar_num(g_Log) == 1)
				{
					formatex(p_LogDir, charsmax(p_LogDir), "%s/chat_translit", p_FilePath)
					formatex(p_LogFile, charsmax(p_LogFile), "%s/gag_%s.log", p_LogDir, p_LogFileTime)
					if(!dir_exists(p_LogDir))
					{
						mkdir(p_LogDir)
					}
					get_user_ip(id, p_LogIp, charsmax(p_LogIp), 1)
					formatex(p_LogMessage, charsmax(p_LogMessage), "%s - Swear Filter has gaged %s <%s> for %d minutes. Message: %s. Found: %s", p_LogTime, s_GagName[id], p_LogIp, get_pcvar_num(g_SwearTime), s_SwearMsg, Swear[iSwear - 1])
					write_file(p_LogFile, p_LogMessage)
				}
				if(get_pcvar_num(g_Sounds))
				{
					client_cmd(id, "spk buttons/button5")
				}
			}
			else if(get_pcvar_num(g_SwearGag))
			{
				formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_SWEARWARN", get_pcvar_num(g_SwearWarns) - SwearCount[id])
				WriteMessage(id, Info,print_team_default)
				if(get_pcvar_num(g_Sounds))
				{
					client_cmd(id, "spk buttons/blip2")
				}
			}
		}
		else
		{
			SwearFound = 0
		}
	}
	
	ExecuteForward(fwd_formatex, fwdResult, id)
	mLen = 0
	lgLen = 0
	new posnum
	mLen = formatex(Message, charsmax(Message), "^x01")
	if(AddsNum[CT_MSGPOS_START])
	{
		for(posnum = 0; posnum < AddsNum[CT_MSGPOS_START]; posnum++)
		{
			log_amx("ADD %s", Adds[CT_MSGPOS_START][posnum])
			mLen += formatex(Message[mLen], charsmax(Message) - mLen, "%s ", Adds[CT_MSGPOS_START][posnum])
			lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", Adds[CT_MSGPOS_START][posnum])
		}
	}
	if(!is_user_alive(id) && !equal(AliveTeam, "SPECTATOR"))
	{
		isAlive = 0
		mLen = formatex(Message, charsmax(Message), "^x01*%L* ", LANG_PLAYER, "CT_DEAD")
		lgLen = formatex(p_LogMsg, charsmax(p_LogMsg), "*%L* ", LANG_PLAYER, "CT_DEAD")
	}
	else if(!is_user_alive(id) && equal(AliveTeam, "SPECTATOR"))
	{
		isAlive = 0
		mLen = formatex(Message, charsmax(Message), "^x01*%L* ", LANG_PLAYER, "CT_SPECTATOR")
		lgLen = formatex(p_LogMsg, charsmax(p_LogMsg), "*%L* ", LANG_PLAYER, "CT_SPECTATOR")
	}
	else
	{
		isAlive = 1
		mLen = formatex(Message, charsmax(Message), "^x01")
	}
	if(equal(AliveTeam, "TERRORIST"))
	{
		mLen += formatex(Message[mLen], charsmax(Message) - mLen, "(%L) ", LANG_PLAYER, "CT_TERRORIST")
		lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - mLen, "(%L) ", LANG_PLAYER, "CT_TERRORIST")
	}
	else if(equal(AliveTeam, "CT"))
	{
		mLen += formatex(Message[mLen], charsmax(Message) - mLen, "(%L) ", LANG_PLAYER, "CT_CT")
		lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - mLen,  "(%L) ", LANG_PLAYER, "CT_CT")
	}
	else if(equal(AliveTeam, "SPECTATOR"))
	{
		mLen += formatex(Message[mLen], charsmax(Message) - mLen, "(%L) ", LANG_PLAYER, "CT_SPECTATOR2")
		lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - mLen, "(%L) ", LANG_PLAYER, "CT_SPECTATOR2")
	}
	if(AddsNum[CT_MSGPOS_PREFIX])
	{
		for(posnum = 0; posnum < AddsNum[CT_MSGPOS_PREFIX]; posnum++)
		{
			mLen += formatex(Message[mLen], charsmax(Message) - mLen, "%s ", Adds[CT_MSGPOS_PREFIX][posnum])
			lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", Adds[CT_MSGPOS_PREFIX][posnum])
		}
	}
	
	if(get_user_flags(id) & NICK_LEVEL && strlen(s_Prefix[id]) > 0)
	{
		mLen += formatex(Message[mLen], charsmax(Message) - mLen, "[^x04%s^x01]%s%s%s",s_Prefix[id],"%s","%s","%s")
		lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "[%s] ",s_Prefix[id])
	}
	else 
	{
		mLen += formatex(Message[mLen], charsmax(Message) - mLen, "%s%s%s","%s","%s","%s")
		lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "[%s] ",s_Prefix2[id])
	}
	
	if(AddsNum[CT_MSGPOS_PRENAME])
	{
		for(posnum = 0; posnum < AddsNum[CT_MSGPOS_PRENAME]; posnum++)
		{
			mLen += formatex(Message[mLen], charsmax(Message) - mLen, "%s ", Adds[CT_MSGPOS_PRENAME][posnum])
			lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", Adds[CT_MSGPOS_PRENAME][posnum])
		}
	}
	if(get_user_flags(id) & NICK_LEVEL)
	{
		switch(get_pcvar_num(g_NameColor))
		{
			case 1:
			{
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, "%s", s_Name)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", s_Name)
			}
			case 2:
			{
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x04%s^x01 ", s_Name)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", s_Name)
			}
			case 3:
			{
				color = print_team_grey
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x03%s^x01 ", s_Name)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", s_Name)
			}
			case 4:
			{
				color = print_team_blue
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x03%s^x01 ", s_Name)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", s_Name)
			}
			case 5:
			{
				color = print_team_red
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x03%s^x01 ", s_Name)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", s_Name)
			}
			case 6:
			{
				color = id
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x03%s^x01 ", s_Name)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s ", s_Name)
			}
		}
		switch(get_pcvar_num(g_ChatColor))
		{
			case 1:
			{
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, ": %s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, ": %s ", s_Msg)
			}
			case 2:
			{
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, ": ^x04%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, ": %s ", s_Msg)
			}
			case 3:
			{
				color = print_team_grey
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, ": ^x03%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, ": %s ", s_Msg)
			}
			case 4:
			{
				color = print_team_blue
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, ": ^x03%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, ": %s ", s_Msg)
			}
			case 5:
			{
				color = print_team_red
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, ": ^x03%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, ": %s ", s_Msg)
			}
			case 6:
			{
				color = id
				mLen += formatex(Message[mLen], charsmax(Message) - mLen, ": ^x03%s", SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
				lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, ": %s ", s_Msg)
			}
		}
	}
	else
	{
		color = id
		mLen += formatex(Message[mLen], charsmax(Message) - mLen, "^x03%s ^x01: %s", s_Name, SwearFound ? Replace[random(ReplaceNum)] : s_Msg)
		lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s : %s ", s_Name, s_Msg)
	}
	if(AddsNum[CT_MSGPOS_END])
	{
		for(posnum = 0; posnum < AddsNum[CT_MSGPOS_END]; posnum++)
		{
			mLen += formatex(Message[mLen], charsmax(Message) - mLen, " %s", Adds[CT_MSGPOS_END][posnum])
			lgLen += formatex(p_LogMsg[lgLen], charsmax(p_LogMsg) - lgLen, "%s", Adds[CT_MSGPOS_END][posnum])
		}
	}
	//if(strlen(Message) >= 192)
	//{
	//	formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_LONGMSG")
	//	WriteMessage(id, Info,print_team_default)
	//	return PLUGIN_HANDLED
	//}
	
	formatex(MessageNoPrefix, charsmax(MessageNoPrefix), Message,"","","")
	formatex(MessagePrefix, charsmax(MessagePrefix), Message, "[^x04", s_Prefix2[id], "^x01]")
	
	SendTeamMessage(color, isAlive, get_user_team(id))
	if(get_pcvar_num(g_Log))
	{
		formatex(p_LogDir, charsmax(p_LogDir), "%s/chat_translit", p_FilePath)
		formatex(p_LogFile, charsmax(p_LogFile), "%s/chat_%s.txt", p_LogDir, p_LogFileTime)
		if(!dir_exists(p_LogDir))
		{
			mkdir(p_LogDir)
		}
		if(!file_exists(p_LogFile))
		{
			formatex(p_LogTitle, charsmax(p_LogTitle), "Start log %s", p_LogFileTime)
			write_file(p_LogFile, p_LogTitle)
			write_file(p_LogFile, LOGFONT)
		}
		get_user_ip(id, p_LogIp, charsmax(p_LogIp), 1)
		get_user_authid(id, p_LogSteamId, charsmax(p_LogSteamId))
		formatex(p_LogInfo, charsmax(p_LogInfo), "%s [%s] - [%s] - ", p_LogTime, p_LogSteamId, p_LogIp)
		formatex(p_LogMessage, charsmax(p_LogMessage), "%s[TEAM] -> %s", p_LogInfo, p_LogMsg)
		write_file(p_LogFile, p_LogMessage)
		
		log_message("^"%s<%i><%s><%s>^" %s ^"%s^"%s",s_Name, get_user_userid(id), p_LogSteamId,
			AliveTeam, "say", s_Msg, "");
	}
	if((!SwearFound || get_pcvar_num(g_SwearGag) != 1) && get_pcvar_num(g_FloodTime))
	{
		SysTime = get_systime(0)
		i_Gag[id] = SysTime + get_pcvar_num(g_FloodTime)
		Flood[id] = true
	}
	return PLUGIN_HANDLED
}

/*
* 	Colored Translit v3.0 by Sho0ter
*	Plugin Stock Functions
*/
stock is_user_gaged(id)
{
	SysTime = get_systime(0)
	if(SysTime < i_Gag[id])
	{
		if(Flood[id])
		{
			formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_FLOOD")
			i_Gag[id] = SysTime + get_pcvar_num(g_FloodTime)
		}
		else
		{
			i_ShowGag = i_Gag[id] - SysTime
			formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_GAGED", i_ShowGag/60+1)
		}
		WriteMessage(id, Info,print_team_default)
		if(get_pcvar_num(g_Sounds))
		{
			client_cmd(id, "spk buttons/button2")
		}
		return 1
	}
	else if(Flood[id])
	{
		Flood[id] = false
	}
	return 0
}

stock is_empty_message(const Message[])
{
	if(equal(Message, "") || !strlen(Message))
	{
		return 1
	}
	return 0
}

stock is_system_message(const Message[])
{
	if(Message[0] == '@' || Message[0] == '/' || Message[0] == '!')
	{
		return 1
	}
	return 0
}

stock is_cheat_message(id, const Message[])
{
	new i = 0
	if(get_pcvar_num(g_CheatImmunity) && get_user_flags(id) & IMMUNITY_LEVEL)
	{
		return 0
	}
	while(i < CheatNum)
	{
		if(containi(Message, Cheat[i++]) != -1)
		{
			return 1
		}
	}
	return 0
}

stock is_spam_message(id, const Message[])
{
	new i = 0
	if(get_pcvar_num(g_SpamImmunity) && get_user_flags(id) & IMMUNITY_LEVEL)
	{
		return 0
	}
	while(i < SpamNum)
	{
		if(containi(Message, Spam[i++]) != -1)
		{
			return 1
		}
	}
	return 0
}

stock is_ignored_message(const Message[])
{
	new i = 0
	while(i < IgnoreNum)
	{
		if(containi(Message, Ignore[i++]) != -1 || SlashFound)
		{
			return 1
		}
	}
	return 0
}

stock is_skips_message(const Message[])
{
	new i = 0
	while(i < SkipsNum)
	{
		if(equal(Message, Skips[i++]) || SlashFound)
		{
			return 1
		}
	}
	return 0
}

stock is_swear_message(id, const Message[])
{
	new i = 0
	if(get_user_flags(id) & IMMUNITY_LEVEL && get_pcvar_num(g_SwearImmunity))
	{	
		return 0
	}
	while(i < SwearNum )
	{
		if(containi(Message, Swear[i++]) != -1)
		{
			new j, playercount, players[32]
			get_players( players, playercount, "c" )
			for(j = 0 ; j < playercount ; j++)
			{
				if(get_user_flags(players[j]) & ACCESS_LEVEL && is_user_connected(players[j]))
				{
					formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_CONTAIN", Swear[i-1])
					WriteMessage(players[j], Info,print_team_default)
					console_print(players[j], "[%s] %L", PLUGIN, LANG_PLAYER, "CT_CONTAIN", Swear[i-1])
					formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, LANG_PLAYER, "CT_SWEAR", s_Name, s_Msg)
					WriteMessage(players[j], Info,print_team_default)
					console_print(players[j], "[%s] %L", PLUGIN, LANG_PLAYER, "CT_SWEAR", s_Name, s_Msg)
				}
			}
			return i
		}
	}
	return 0
}

stock check_plugin_cmd(const Message[])
{
	for(new cmdid; cmdid < CmdsNum; cmdid++)
	{
		if(equal(Message, Cmds[cmdid]))
		{
			return 1
		}
	}
	return 0
}

stock client_punish(id, type)
{
	switch(type)
	{
		case PUNISH_CHEAT:
		{
			switch(get_pcvar_num(g_CheatAction))
			{
				case 1:
				{
					server_cmd("kick #%d ^"%L^"", get_user_userid(id), id, "CT_KICKCHEAT")
				}
				case 2:
				{
					get_user_authid(id, s_BanAuthId, charsmax(s_BanAuthId))
					get_user_name(id, s_BanName, charsmax(s_BanName))
					server_cmd("banid ^"%d^" ^"%s^";wait;wait;wait;writeid", get_pcvar_num(g_CheatActionTime), s_BanAuthId)
				}
				case 3:
				{
					get_user_ip(id, s_BanIp, charsmax(s_BanIp), 1)
					get_user_name(id, s_BanName, charsmax(s_BanName))
					server_cmd("addip ^"%d^" ^"%s^";wait;wait;wait;writeip", get_pcvar_num(g_CheatActionTime), s_BanIp)
				}
				case 4:
				{
					get_user_authid(id, s_BanAuthId, charsmax(s_BanAuthId))
					get_user_name(id, s_BanName, charsmax(s_BanName))
					formatex(s_Reason, 127, "[%s] Cheat", PLUGIN)
					server_cmd("amx_ban %d %s %s", get_pcvar_num(g_CheatActionTime), s_BanAuthId, s_Reason)
				}
				case 5:
				{
					get_user_ip(id, s_BanIp, charsmax(s_BanIp), 1)
					get_user_name(id, s_BanName, charsmax(s_BanName))
					formatex(s_Reason, 127, "[%s] Cheat", PLUGIN)
					server_cmd("amx_ban %d %s %s", get_pcvar_num(g_CheatActionTime), s_BanIp, s_Reason)
				}
				case 6:
				{
					get_user_name(id, s_KickName, charsmax(s_KickName))
					get_user_ip(id, s_BanIp, charsmax(s_BanIp), 1)
					get_user_authid(id, s_BanAuthId, charsmax(s_BanAuthId))
					get_user_name(id, s_BanName, charsmax(s_BanName))
					num_to_str(get_user_userid(id), sUserId, charsmax(sUserId))
					get_pcvar_string(g_CheatActionCustom, s_CheatAction, charsmax(s_CheatAction))
					replace_all(s_CheatAction, charsmax(s_CheatAction), "%userid%", sUserId)
					replace_all(s_CheatAction, charsmax(s_CheatAction), "%ip%", s_BanIp)
					replace_all(s_CheatAction, charsmax(s_CheatAction), "%steamid%", s_BanAuthId)
					replace_all(s_CheatAction, charsmax(s_CheatAction), "%name%", s_KickName)
					server_cmd(s_CheatAction)
				}
			}
			if(get_pcvar_num(g_Log) && get_pcvar_num(g_CheatAction) != 1 && get_pcvar_num(g_CheatAction) != 6 && !Logged[id])
			{
				log_action(id, ACTION_CHEAT)
				Logged[id] = true
			}
		}
		case PUNISH_SPAM:
		{
			switch(get_pcvar_num(g_SpamAction))
			{
				case 1:
				{
					server_cmd("kick #%d ^"%L^"", get_user_userid(id), id, "CT_KICK")
				}
				case 2:
				{
					SysTime = get_systime(0)
					i_Gag[id] = SysTime + get_pcvar_num(g_SpamActionTime) * 60
					formatex(Info, charsmax(Info), "^x01[^x04%s^x01] %L", PLUGIN, id, "CT_SPAMGAG", get_pcvar_num(g_SpamActionTime))
					WriteMessage(id, Info,print_team_default)
					Flood[id] = false
					get_user_name(id, s_GagName[id], 31)
					get_user_ip(id, s_GagIp[id], 31, 1)
					if(get_pcvar_num(g_Log))
					{
						formatex(p_LogDir, charsmax(p_LogDir), "%s/colored_translit", p_FilePath)
						formatex(p_LogFile, charsmax(p_LogFile), "%s/gag_%s.log", p_LogDir, p_LogFileTime)
						if(!dir_exists(p_LogDir))
						{
							mkdir(p_LogDir)
						}
						get_user_ip(id, p_LogIp, charsmax(p_LogIp), 1)
						formatex(p_LogMessage, charsmax(p_LogMessage), "%s - Spam Filter has gaged %s <%s> for %d minutes. Message: %s", p_LogTime, s_GagName[id], s_GagIp[id], get_pcvar_num(g_SpamActionTime), s_Msg)
						write_file(p_LogFile, p_LogMessage)
						if(get_pcvar_num(g_Sounds))
						{
							client_cmd(id, "spk buttons/button5")
						}
					}
				}
				case 3:
				{
					get_user_authid(id, s_BanAuthId, charsmax(s_BanAuthId))
					get_user_name(id, s_BanName, charsmax(s_BanName))
					server_cmd("banid ^"%d^" ^"%s^";wait;wait;wait;writeid", get_pcvar_num(g_SpamActionTime), s_BanAuthId)
				}
				case 4:
				{
					get_user_ip(id, s_BanIp, charsmax(s_BanIp), 1)
					get_user_name(id, s_BanName, charsmax(s_BanName))
					server_cmd("addip ^"%d^" ^"%s^";wait;wait;wait;writeip", get_pcvar_num(g_SpamActionTime), s_BanIp)
				}
				case 5:
				{
					get_user_authid(id, s_BanAuthId, charsmax(s_BanAuthId))
					get_user_name(id, s_BanName, charsmax(s_BanName))
					formatex(s_Reason, 127, "[%s] Spam", PLUGIN)
					server_cmd("amx_ban %d %s %s", get_pcvar_num(g_SpamActionTime), s_BanAuthId, s_Reason)
				}
				case 6:
				{
					get_user_ip(id, s_BanIp, charsmax(s_BanIp), 1)
					get_user_name(id, s_BanName, charsmax(s_BanName))
					formatex(s_Reason, 127, "[%s] Spam", PLUGIN)
					server_cmd("amx_ban %d %s %s", get_pcvar_num(g_SpamActionTime), s_BanIp, s_Reason)
				}
			}
			if(get_pcvar_num(g_Log) && get_pcvar_num(g_SpamAction) > 2)
			{
				log_action(id, ACTION_SPAM)
			}
		}
	}	
}

stock log_action(id, action)
{
	get_time("20%y.%m.%d", p_LogFileTime, charsmax(p_LogFileTime))
	get_time("%H:%M:%S", p_LogTime, charsmax(p_LogTime))
	formatex(p_LogDir, charsmax(p_LogDir), "%s/colored_translit", p_FilePath)
	if(!dir_exists(p_LogDir))
	{
		mkdir(p_LogDir)
	}
	formatex(p_LogFile, charsmax(p_LogFile), "%s/ban_%s.log", p_LogDir, p_LogFileTime)
	get_user_ip(id, p_LogIp, charsmax(p_LogIp), 1)
	get_user_authid(id, s_BanAuthId, charsmax(s_BanAuthId))
	get_user_name(id, s_BanName, charsmax(s_BanName))
	switch(action)
	{
		case ACTION_CHEAT:
		{
			if(get_pcvar_num(g_CheatActionTime))
			{
				formatex(p_LogMessage, charsmax(p_LogMessage), "%s - Cheat Filter has banned %s <%s> <%s> for %d minutes. Message: %s", p_LogTime, s_BanName, s_BanIp, s_BanAuthId, get_pcvar_num(g_CheatActionTime), s_Msg)
			}
			else
			{
				formatex(p_LogMessage, charsmax(p_LogMessage), "%s - Cheat Filter has banned %s <%s> <%s> permanently. Message: %s", p_LogTime, s_BanName, s_BanIp, s_BanAuthId, s_Msg)
			}
			write_file(p_LogFile, p_LogMessage)
		}
		case ACTION_SPAM:
		{
			if(get_pcvar_num(g_SpamActionTime))
			{
				formatex(p_LogMessage, charsmax(p_LogMessage), "%s - Spam Filter has banned %s <%s> <%s> for %d minutes. Message: %s", p_LogTime, s_BanName, s_BanIp, s_BanAuthId, get_pcvar_num(g_SpamActionTime), s_Msg)
			}
			else
			{
				formatex(p_LogMessage, charsmax(p_LogMessage), "%s - Spam Filter has banned %s <%s> <%s> permanently. Message: %s", p_LogTime, s_BanName, s_BanIp, s_BanAuthId, s_Msg)
			}
			write_file(p_LogFile, p_LogMessage)
		}
	}
}

stock ReplaceSwear(Size, Message[])
{
	copy(s_SwearMsg, Size, Message)
	replace_all(s_SwearMsg, Size, " ", "")
	replace_all(s_SwearMsg, Size, "A", "a")
	replace_all(s_SwearMsg, Size, "B", "b")
	replace_all(s_SwearMsg, Size, "C", "c")
	replace_all(s_SwearMsg, Size, "D", "d")
	replace_all(s_SwearMsg, Size, "E", "e")
	replace_all(s_SwearMsg, Size, "F", "f")
	replace_all(s_SwearMsg, Size, "G", "g")
	replace_all(s_SwearMsg, Size, "H", "h")
	replace_all(s_SwearMsg, Size, "I", "i")
	replace_all(s_SwearMsg, Size, "J", "j")
	replace_all(s_SwearMsg, Size, "K", "k")
	replace_all(s_SwearMsg, Size, "L", "l")
	replace_all(s_SwearMsg, Size, "M", "m")
	replace_all(s_SwearMsg, Size, "N", "n")
	replace_all(s_SwearMsg, Size, "O", "o")
	replace_all(s_SwearMsg, Size, "P", "p")
	replace_all(s_SwearMsg, Size, "Q", "q")
	replace_all(s_SwearMsg, Size, "R", "r")
	replace_all(s_SwearMsg, Size, "S", "s")
	replace_all(s_SwearMsg, Size, "T", "t")
	replace_all(s_SwearMsg, Size, "U", "u")
	replace_all(s_SwearMsg, Size, "V", "v")
	replace_all(s_SwearMsg, Size, "W", "w")
	replace_all(s_SwearMsg, Size, "X", "x")
	replace_all(s_SwearMsg, Size, "Y", "y")
	replace_all(s_SwearMsg, Size, "Z", "z")
	replace_all(s_SwearMsg, Size, "{", "[")
	replace_all(s_SwearMsg, Size, "}", "]")
	replace_all(s_SwearMsg, Size, "<", ",")
	replace_all(s_SwearMsg, Size, ">", ".")
	replace_all(s_SwearMsg, Size, "~", "`")
	replace_all(s_SwearMsg, Size, "*", "")
	replace_all(s_SwearMsg, Size, "_", "")
}

stock SendMessage(color, alive)
{
	for(new player = 0; player <= get_maxplayers(); player++)
	{
		if(!is_user_connected(player))
		{
			continue
		}
		if (alive && is_user_alive(player) || !alive && !is_user_alive(player) || get_pcvar_num(g_Listen) && get_user_flags(player) & ACCESS_LEVEL)
		{
			console_print(player, "%s : %s", s_Name, s_Msg)
			if (g_ShowPrefix[player] && s_Prefix2[player][0])
				WriteMessage(player, MessagePrefix,color)
			else 
				WriteMessage(player, MessageNoPrefix,color)
		}
	}
}

stock SendMessageAll(color)
{
	for(new player = 0; player <= get_maxplayers(); player++)
	{
		if(!is_user_connected(player))
		{
			continue
		}
		if (g_ShowPrefix[player] && s_Prefix2[player][0])
			WriteMessage(player, MessagePrefix,color)
		else 
			WriteMessage(player, MessageNoPrefix,color)
	}
}

stock SendTeamMessage(color, alive, playerTeam)
{
	for (new player = 0; player <= get_maxplayers(); player++)
	{
		if (!is_user_connected(player))
		{
			continue
		}
		if(get_user_team(player) == playerTeam || (get_pcvar_num(g_Listen) && get_user_flags(player) & ACCESS_LEVEL))
		{
			if (alive && is_user_alive(player) || !alive && !is_user_alive(player) || get_pcvar_num(g_Listen) && get_user_flags(player) & ACCESS_LEVEL)
			{
				console_print(player, "%s : %s", s_Name, s_Msg)
				if (g_ShowPrefix[player] && s_Prefix2[player][0])
					WriteMessage(player, MessagePrefix,color)
				else 
					WriteMessage(player, MessageNoPrefix,color)
			}
		}
	}
}

stock WriteMessage(player, message[], color)
{
	client_print_color(player,color,"%s",message)
}
