/**
 *
 * HotVision
 *  by Numb
 *
 *
 * Description:
 *  This plugin gives some use for nightvision. Normally nightvision only helps in case
 *  if players are close enough. This plugin makes all players visible in the dark, plus
 *  it includes support for infrared (ability to see through some walls/objects),
 *  heart-beat device (radar showing enemies with 1024 units range by default) what
 *  refreshes every 2 seconds, advanced hotvision (not only players are fully visible
 *  in dark places, but also other objects like hostages, weapons...). Also this plugin
 *  includes a fix for switching off nightvision by "fullupdate" command or and when
 *  starting to record a demo.
 *
 *
 * Requires:
 *  Engine
 *  FakeMeta
 *  HamSandWich
 *
 *
 * Cvars:
 *
 *  + "hotvision_enabled" - state of the plugin.
 *  - "2" - enabled with custom player render mod. [default]
 *  - "1" - enabled.
 *  - "0" - disabled.
 *
 *  + "hotvision_radar" - state of radar (heart-beat device).
 *  - "2" - enabled with unlimited range.
 *  - "1" - enabled. [default]
 *  - "0" - disabled.
 *
 *  + "hotvision_radar_range" - range of radar (heart-beat device).
 *  - "14189.0" - maximal unit distance available (range of the map).
 *  - "1024.0" - half of radar radius. [default]
 *  - "128.0" - minimal unit distance available.
 *
 *  + "hotvision_models" - hotvision for custom objects (hostages, weapons...).
 *  - "1" - enabled. [default]
 *  - "0" - disabled.
 *
 *  + "hotvision_walls" - ability to see through some walls (infrared).
 *  - "1" - enabled. [default]
 *  - "0" - disabled.
 *
 *  + "hotvision_effect_fix" - choice between editions to nightvision effect.
 *  - "3" - original with fix, and custom effect in one.
 *  - "2" - custom effect only (massive client FPS improvement). [default]
 *  - "1" - original with fix.
 *  - "0" - original without "fullupdate" fix.
 *
 *  + "hotvision_object_glow" - will players and custom objects emit light.
 *  - "3" - enabled. [default]
 *  - "2" - custom objects only.
 *  - "1" - players only.
 *  - "0" - disabled.
 *
 *  + "hotvision_brightness" - brightness of the map while in hotvision.
 *  - from "a" to "z" - from darkest to brightest.
 *  - from "A" to "Z" - brightest with controlled negative effect on light source edges.
 *  - "!" - brightest with small negative effect on large light sources.
 *  - "W" - brightest with visible enough negative effect. [default]
 *  - ""  - use default map brightness.
 *
 *
 * Additional Info:
 *  Tested in Counter-Strike 1.6 with amxmodx 1.8.2 (dev build hg21). You can disable/edit
 *  some features via cvars. Features like infrared (can be disabled/enabled), advanced
 *  hotvision (disabled/enabled), heart-beat device (disable/enable and set range).
 *  You may find servers what are using this plugin by following this link:
 *  http://www.game-monitor.com/search.php?vars=hotvision=&game=cstrike
 *
 *
 * Notes:
 *  - Cvar changes take effect only at round start.
 *  - Brightness negative effect is largest in dark areas.
 *  - Using only custom nightvision effect makes radar more clear and improves client FPS massively.
 *
 *
 * Warnings:
 *  - Some maps may have sky glitches when infrared is enabled ("hotvision_walls" cvar).
 *  - Using custom nightvision effect will not allow usage of flishlight while nightvision is active.
 *
 *
 * ChangeLog:
 *
 *  + 2.1
 *  - Fixed: Not showing if person has hotvision enabled when spectating.
 *
 *  + 2.0
 *  - Added: Cvar "hotvision_brightness" to control brithness of the map while in hotvision.
 *  - Added: Ability to disable custom player render mod via "hotvision_enabled" cvar.
 *  - Added: Ability to find servers what are using this plugin.
 *
 *  + 1.9
 *  - Added: Cvar "hotvision_object_glow" to choose will players and custom objects glow.
 *  - Fixed: Players nightvision close-range light doesn't work for spectators as it should.
 *
 *  + 1.8
 *  - Fixed: Fix related to impulse command - amxx ham module glitch. Plugin now also needs engine module.
 *
 *  + 1.7
 *  - Added: Extra nightvision effect.
 *  - Added: Ability to choose between nightvision effects (custom one results in much less client FPS drops).
 *  - Added: Extra glowing effect on objects while in nightvision.
 *  - Changed: Plugin uses less resources (improved massively).
 *
 *  + 1.6
 *  - Added: Cvars for plugin configuration (takes effect at new round).
 *  - Changed: Plugin uses less resources.
 *  - Removed: Added notification instead of plugins_by_numb feature.
 *
 *  + 1.5
 *  - Added: Cvar to disable plugins_by_numb feature (set "pbn_simple" to "1").
 *
 *  + 1.4
 *  - Changed: Less CPU usage, more stability.
 *
 *  + 1.3
 *  - Fixed: Error when someone disconnects and other person is spectating him.
 *  - Fixed: Error when using "fullupdate" command.
 *
 *  + 1.2
 *  - Fixed: Glitch that nightvision isn't always restored after "fullupdate" command.
 *
 *  + 1.1
 *  - Fixed: Glitch with having nightvision when you shouldn't when spamming "fullupdate" command.
 *  - Changed: Less CPU usage.
 *
 *  + 1.0
 *  - First release.
 *
 *
 * Downloads:
 *  Amx Mod X forums: http://forums.alliedmods.net/showthread.php?p=1274017#post1274017
 *
**/

// ----------------------------------------- CONFIG START -----------------------------------------

// If you are having trouble with heart-beat device what can be caused by many hostages or other
// plugins what use hostage system to show something on radar - please change this value to a
// higher one. NOTE: Highest value what you can use is 255-maxplayers, and lowest value should be
// maximal number of hostages what you can have on your server in some specific map.
#define RADARID_OFFSET 16 // default: 16

// ------------------------------------------ CONFIG END ------------------------------------------


#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN_NAME	"HotVision"
#define PLUGIN_VERSION	"2.1"
#define PLUGIN_AUTHOR	"Numb"

#define m_fNvgState 129
#define NVG_ACTIVATED (1<<8) // 256
#define m_iFlashBattery 244

#define SetPlayerBit(%1,%2)    ( %1 |=  ( 1 << ( %2 & 31 ) ) )
#define ClearPlayerBit(%1,%2)  ( %1 &= ~( 1 << ( %2 & 31 ) ) )
#define CheckPlayerBit(%1,%2)  ( %1 &   ( 1 << ( %2 & 31 ) ) )

new g_iJustJoined;
new g_iConnected;
new g_iAlive;
new g_iUpdateData;
new g_iInNvg;

new g_iMsgId_SayText;
new g_iMsgId_NVGToggle;
new g_iMsgId_HostagePos;
new g_iMsgId_HostageK;
new g_iMsgId_Flashlight;

new g_iCvarHotVisionEnabled;
new g_iCvarHotVisionRadar;
new g_iCvarHotVisionRadarRange;
new g_iCvarHotVisionModels;
new g_iCvarHotVisionWalls;
new g_iCvarHotVisionEffectFix;
new g_iCvarHotVisionObjectGlow;
new g_iCvarHotVisionBrightness;

new g_iDefaultBrightness[32];
new g_iCustomBrightness[32];
new Float:g_fRadarRange;
new bool:g_bCustomEffect;
new bool:g_bEffectFix;
new bool:g_bPlrGlow;
new bool:g_bModelGlow;

new bool:g_bHotVisionPlayers;
new g_iMaxPlayers;

new g_iFwdFM_AddToFullPack;
new g_iFwdFM_LightStyle;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	register_cvar("hotvision", PLUGIN_VERSION, (FCVAR_SERVER|FCVAR_SPONLY));
	
	RegisterHam(Ham_Spawn,                  "player", "Ham_Spawn_player_Post",          1);
	RegisterHam(Ham_Killed,                 "player", "Ham_Killed_player_Post",         1);
	//RegisterHam(Ham_Player_ImpulseCommands, "player", "Ham_Player_ImpulseCommands_Pre", 0); // ham module has glitches with this forward,
	
	unregister_forward(FM_LightStyle, g_iFwdFM_LightStyle, 0);
	register_forward(FM_StartFrame, "FM_StartFrame_Pre", 0);
	register_impulse(100, "client_impulse_flashlight"); // so I'm using engine function instead.
	
	register_event("ResetHUD",  "Event_ResetHUD",  "be");
	register_event("HLTV",      "Event_NewRound",  "a", "1=0", "2=0");
	
	g_iMsgId_HostagePos = get_user_msgid("HostagePos");
	g_iMsgId_HostageK   = get_user_msgid("HostageK");
	g_iMsgId_NVGToggle  = get_user_msgid("NVGToggle");
	g_iMsgId_SayText    = get_user_msgid("SayText");
	g_iMsgId_Flashlight = get_user_msgid("Flashlight");
	
	register_message(g_iMsgId_NVGToggle, "Message_NVGToggle");
	
	g_iCvarHotVisionEnabled    = register_cvar("hotvision_enabled", "2");
	g_iCvarHotVisionRadar      = register_cvar("hotvision_radar", "1");
	g_iCvarHotVisionRadarRange = register_cvar("hotvision_radar_range", "1024.0");
	g_iCvarHotVisionModels     = register_cvar("hotvision_models", "1");
	g_iCvarHotVisionWalls      = register_cvar("hotvision_walls", "1");
	g_iCvarHotVisionEffectFix  = register_cvar("hotvision_effect_fix", "2");
	g_iCvarHotVisionObjectGlow = register_cvar("hotvision_object_glow", "3");
	g_iCvarHotVisionBrightness = register_cvar("hotvision_brightness", "W");
	
	if( !g_iDefaultBrightness[0] )
		g_iDefaultBrightness[0] = 'm';
	
	g_iMaxPlayers = clamp(get_maxplayers(), 1, 32);
}

public plugin_precache()
	g_iFwdFM_LightStyle = register_forward(FM_LightStyle, "FM_LightStyle_Pre", 0);

public plugin_cfg()
	Event_NewRound();

public plugin_pause()
{
	message_begin(MSG_ALL, SVC_LIGHTSTYLE);
	write_byte(0);
	write_string(g_iDefaultBrightness);
	message_end();
}

public plugin_unpause()
{
	g_iConnected = 0;
	g_iAlive = 0;
	g_iUpdateData = 0;
	g_iInNvg = 0;
	
	for( new iPlrId=1; iPlrId<=g_iMaxPlayers; iPlrId++ )
	{
		if( is_user_alive(iPlrId) )
		{
			SetPlayerBit(g_iConnected, iPlrId);
			SetPlayerBit(g_iAlive, iPlrId);
		}
		else if( is_user_connected(iPlrId) )
			SetPlayerBit(g_iConnected, iPlrId);
	}
}

public Event_NewRound()
{
	new iPluginState = clamp(get_pcvar_num(g_iCvarHotVisionEnabled), 0, 2);
	if( iPluginState )
	{
		if( iPluginState==2 )
			g_bHotVisionPlayers = true;
		else
			g_bHotVisionPlayers = false;
		
		if( clamp(get_pcvar_num(g_iCvarHotVisionModels), 0, 1) )
		{
			if( clamp(get_pcvar_num(g_iCvarHotVisionWalls), 0, 1) )
				state AllEnabled;
			else
				state ModelsOnly;
		}
		else if( clamp(get_pcvar_num(g_iCvarHotVisionWalls), 0, 1) )
			state WallsOnly;
		else
			state Default;
		
		switch( clamp(get_pcvar_num(g_iCvarHotVisionRadar), 0, 2) )
		{
			case 2:  g_fRadarRange = -1.0;
			case 1:  g_fRadarRange = floatclamp(get_pcvar_float(g_iCvarHotVisionRadarRange), 128.0, 14189.0); // sqrt(8192*8192*3)
			default: g_fRadarRange = 0.0;
		}
		
		if( !g_iFwdFM_AddToFullPack )
			g_iFwdFM_AddToFullPack = register_forward(FM_AddToFullPack, "FM_AddToFullPack_Post", 1);
		
		get_pcvar_string(g_iCvarHotVisionBrightness, g_iCustomBrightness, 31);
		
	}
	else
	{
		if( g_iFwdFM_AddToFullPack )
		{
			unregister_forward(g_iFwdFM_AddToFullPack, 1);
			g_iFwdFM_AddToFullPack = 0;
		}
		state Default;
	}
	
	switch( clamp(get_pcvar_num(g_iCvarHotVisionEffectFix), 0, 3) )
	{
		case 3:
		{
			g_bCustomEffect = true;
			g_bEffectFix = true;
		}
		case 2:
		{
			g_bCustomEffect = true;
			g_bEffectFix = false;
		}
		case 1:
		{
			g_bCustomEffect = false;
			g_bEffectFix = true;
		}
		default:
		{
			g_bCustomEffect = false;
			g_bEffectFix = false;
		}
	}
	
	switch( clamp(get_pcvar_num(g_iCvarHotVisionObjectGlow), 0, 3) )
	{
		case 3:
		{
			g_bPlrGlow = true;
			g_bModelGlow = true;
		}
		case 2:
		{
			g_bPlrGlow = false;
			g_bModelGlow = true;
		}
		case 1:
		{
			g_bPlrGlow = true;
			g_bModelGlow = false;
		}
		default:
		{
			g_bPlrGlow = false;
			g_bModelGlow = false;
		}
	}
}

public Event_ResetHUD(iPlrId)
{
	if( g_bEffectFix && g_iFwdFM_AddToFullPack )
	{
		if( CheckPlayerBit(g_iAlive, iPlrId) )
		{
			if( get_pdata_int(iPlrId, m_fNvgState, 5)&NVG_ACTIVATED )
			{
				new iTaskId = (iPlrId+32);
				remove_task(iTaskId);
				set_task(0.1, "send_nvg_msg", iTaskId);
				
				iTaskId += 32;
				remove_task(iTaskId);
				set_task(0.2, "send_nvg_msg", iTaskId);
				
				iTaskId += 32;
				remove_task(iTaskId);
				set_task(0.3, "send_nvg_msg", iTaskId);
				
				iTaskId += 32;
				if( task_exists(iTaskId) )
				{
					send_nvg_msg(iTaskId);
					remove_task(iTaskId);
				}
				set_task(0.4, "send_nvg_msg", iTaskId);
			}
		}
		else if( pev(iPlrId, pev_iuser1)==4 )
		{
			new iSpectatedPerson = pev(iPlrId, pev_iuser2);
			if( iSpectatedPerson>g_iMaxPlayers || iSpectatedPerson<=0 )
				return;
			else if( !CheckPlayerBit(g_iAlive, iSpectatedPerson) )
				return;
			else if( get_pdata_int(iSpectatedPerson, m_fNvgState, 5)&NVG_ACTIVATED )
			{
				new iTaskId = (iPlrId+32);
				remove_task(iTaskId);
				set_task(0.1, "send_nvg_msg", iTaskId);
				
				iTaskId += 32;
				remove_task(iTaskId);
				set_task(0.2, "send_nvg_msg", iTaskId);
				
				iTaskId += 32;
				remove_task(iTaskId);
				set_task(0.3, "send_nvg_msg", iTaskId);
				
				iTaskId += 32;
				if( task_exists(iTaskId) )
				{
					send_nvg_msg(iTaskId);
					remove_task(iTaskId);
				}
				set_task(0.4, "send_nvg_msg", iTaskId);
			}
		}
	}
}

public Message_NVGToggle(iMsgId, iMsgType, iPlrId)
{
	if( g_iFwdFM_AddToFullPack )
	{
		if( get_msg_arg_int(1) && g_fRadarRange )
		{
			if( !task_exists(iPlrId) )
				set_task(2.0, "refresh_radar", iPlrId, "", 0, "b");
		}
		else
			remove_task(iPlrId);
	
		if( g_bCustomEffect )
		{
			set_pev(iPlrId, pev_effects, (pev(iPlrId, pev_effects)&~EF_DIMLIGHT)); // remove EF_DIMLIGHT;
			
			message_begin(MSG_ONE, g_iMsgId_Flashlight, _, iPlrId); // when enabeling nightvision custom effect,
			write_byte(0);						// make sure that flashlight is disabled
			write_byte(get_pdata_int(iPlrId, m_iFlashBattery, 5));
			message_end();
			
			if( !g_bEffectFix )
				return PLUGIN_HANDLED;
		}
	}
	else
		remove_task(iPlrId);
	
	return PLUGIN_CONTINUE;
}

public client_putinserver(iPlrId)
{
	SetPlayerBit(g_iConnected, iPlrId);
	SetPlayerBit(g_iJustJoined, iPlrId);
}

public client_disconnect(iPlrId)
{
	ClearPlayerBit(g_iConnected, iPlrId);
	ClearPlayerBit(g_iAlive, iPlrId);
	ClearPlayerBit(g_iJustJoined, iPlrId);
	
	for( new iTaskId=iPlrId; iTaskId<=160; (iTaskId+=32) )
		remove_task(iTaskId);
}

public Ham_Spawn_player_Post(iPlrId)
{
	if( is_user_alive(iPlrId) && CheckPlayerBit(g_iConnected, iPlrId) )
		SetPlayerBit(g_iAlive, iPlrId);
	
	if( CheckPlayerBit(g_iJustJoined, iPlrId) )
	{
		ClearPlayerBit(g_iJustJoined, iPlrId);
		
		message_begin(MSG_ONE, g_iMsgId_SayText, _, iPlrId);
		write_byte(iPlrId);
		write_string("^x03* ^x01This server has support for ^x04hotvision^x01 when using ^x04nightvision^x01.");
		message_end();
	}
}

public Ham_Killed_player_Post(iPlrId)
{
	if( !is_user_alive(iPlrId) )
		ClearPlayerBit(g_iAlive, iPlrId);
	
	for( new iTaskId=iPlrId; iTaskId<=160; (iTaskId+=32) )
		remove_task(iTaskId);
}

public client_impulse_flashlight(iPlrId) // flashlight doesn't work while in nightvision custom effect, so we block it to avoid glitches
{
	if( g_iFwdFM_AddToFullPack && g_bCustomEffect && CheckPlayerBit(g_iConnected, iPlrId) && CheckPlayerBit(g_iAlive, iPlrId) )
	{
		if( get_pdata_int(iPlrId, m_fNvgState, 5)&NVG_ACTIVATED )
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

/* // this one is not yet fixed - ham module has glitches with this forward, so I must use engine for this one instead
public Ham_Player_ImpulseCommands_Pre(iPlrId) // flashlight doesn't work while in nightvision custom effect, so we block it to avoid glitches
{
	if( g_iFwdFM_AddToFullPack && g_bCustomEffect && CheckPlayerBit(g_iConnected, iPlrId) && CheckPlayerBit(g_iAlive, iPlrId) )
	{
		if( get_pdata_int(iPlrId, m_fNvgState, 5)&NVG_ACTIVATED && pev(iPlrId, pev_impulse)==100 )
			set_pev(iPlrId, pev_impulse, 0);
	}
	
	return HAM_IGNORED;
}
*/

public FM_LightStyle_Pre(iStyle, iVal[])
{
	if( !iStyle )
		copy(g_iDefaultBrightness, 31, iVal);
}

public FM_StartFrame_Pre()
	g_iUpdateData = 4294967295; // 4294967296-1 == (((1<<31)*2)-1) == (1<<0)|(1<<1)|...|(1<<31) == (1<<32)-1

public FM_AddToFullPack_Post(iEsHandle, iE, iEnt, iHost, iHostFlags, iPlayer, iPSet) <AllEnabled>
{
	if( 1<=iHost<=g_iMaxPlayers && get_orig_retval() )
	{
		if( frame_nvg_update(iHost, iPlayer, iEsHandle, iEnt) )
		{
			if( get_es(iEsHandle, ES_RenderMode) || !pev_valid(iEnt) )
				return FMRES_IGNORED;
			
			static s_iModel[2];
			pev(iEnt, pev_model, s_iModel, 1);
			
			if( s_iModel[0]=='m' )
			{
				set_hotvision_object(iEsHandle);
				return FMRES_IGNORED;
			}
			
			if( s_iModel[0]=='*' )
			{
				set_hotvision_walls(iEsHandle);
				return FMRES_IGNORED;
			}
		}
	}
	
	return FMRES_IGNORED;
}

public FM_AddToFullPack_Post(iEsHandle, iE, iEnt, iHost, iHostFlags, iPlayer, iPSet) <ModelsOnly>
{
	if( 1<=iHost<=g_iMaxPlayers && get_orig_retval() )
	{
		if( frame_nvg_update(iHost, iPlayer, iEsHandle, iEnt) )
		{
			if( get_es(iEsHandle, ES_RenderMode) || !pev_valid(iEnt) )
				return FMRES_IGNORED;
			
			static s_iModel[2];
			pev(iEnt, pev_model, s_iModel, 1);
			
			if( s_iModel[0]=='m' )
			{
				set_hotvision_object(iEsHandle);
				return FMRES_IGNORED;
			}
		}
	}
	
	return FMRES_IGNORED;
}

public FM_AddToFullPack_Post(iEsHandle, iE, iEnt, iHost, iHostFlags, iPlayer, iPSet) <WallsOnly>
{
	if( 1<=iHost<=g_iMaxPlayers && get_orig_retval() )
	{
		if( frame_nvg_update(iHost, iPlayer, iEsHandle, iEnt) )
		{
			if( get_es(iEsHandle, ES_RenderMode) || !pev_valid(iEnt) )
				return FMRES_IGNORED;
			
			static s_iModel[2];
			pev(iEnt, pev_model, s_iModel, 1);
			
			if( s_iModel[0]=='*' )
			{
				set_hotvision_walls(iEsHandle);
				return FMRES_IGNORED;
			}
		}
	}
	
	return FMRES_IGNORED;
}

public FM_AddToFullPack_Post(iEsHandle, iE, iEnt, iHost, iHostFlags, iPlayer, iPSet) <Default>
{
	if( 1<=iHost<=g_iMaxPlayers && get_orig_retval() )
		frame_nvg_update(iHost, iPlayer, iEsHandle, iEnt);
	
	return FMRES_IGNORED;
}

public FM_AddToFullPack_Post(iEsHandle, iE, iEnt, iHost, iHostFlags, iPlayer, iPSet) <>
{
	if( g_iFwdFM_AddToFullPack )
	{
		unregister_forward(g_iFwdFM_AddToFullPack, 1);
		g_iFwdFM_AddToFullPack = 0;
	}
	
	return FMRES_IGNORED;
}

public send_nvg_msg(iTaskId)
{
	if( !g_bEffectFix )
		return;
	
	new iPlrId = (((iTaskId-1)%32)+1);
	
	if( CheckPlayerBit(g_iAlive, iPlrId) )
	{
		if( !(get_pdata_int(iPlrId, m_fNvgState, 5)&NVG_ACTIVATED) )
			return;
	}
	else if( pev(iPlrId, pev_iuser1)==4 )
	{
		new iSpectated = pev(iPlrId, pev_iuser2);
		
		if( iSpectated>g_iMaxPlayers || iSpectated<=0 )
			return;
		
		if( !CheckPlayerBit(g_iAlive, iSpectated) || !(get_pdata_int(iSpectated, m_fNvgState, 5)&NVG_ACTIVATED) )
			return;
	}
	else
		return;
	
	message_begin(MSG_ONE, g_iMsgId_NVGToggle, _, iPlrId);
	write_byte(1);
	message_end();
}

public refresh_radar(iPlrId)
{
	if( CheckPlayerBit(g_iConnected, iPlrId) && CheckPlayerBit(g_iAlive, iPlrId) )
	{
		if( get_pdata_int(iPlrId, m_fNvgState, 5)&NVG_ACTIVATED )
		{
			new iTeam = get_user_team(iPlrId);
			new Float:fOrigin[3], iOffsetId;
			
			if( g_fRadarRange<0.0 )
			{
				for( new iEnemyId=1; iEnemyId<=g_iMaxPlayers; iEnemyId++ )
				{
					if( iEnemyId!=iPlrId && CheckPlayerBit(g_iConnected, iEnemyId) && CheckPlayerBit(g_iAlive, iEnemyId) && iTeam!=get_user_team(iEnemyId) )
					{
						pev(iEnemyId, pev_origin, fOrigin);
						
						iOffsetId = (RADARID_OFFSET+iEnemyId);
						
						message_begin(MSG_ONE, g_iMsgId_HostagePos, _, iPlrId);
						write_byte(1);
						write_byte(iOffsetId);
						engfunc(EngFunc_WriteCoord, fOrigin[0]);
						engfunc(EngFunc_WriteCoord, fOrigin[1]);
						engfunc(EngFunc_WriteCoord, fOrigin[2]);
						message_end();
						
						message_begin(MSG_ONE, g_iMsgId_HostageK, _, iPlrId);
						write_byte(iOffsetId);
						message_end();
					}
				}
			}
			else
			{
				new Float:fMainOrigin[3];
				pev(iPlrId, pev_origin, fMainOrigin);
				
				for( new iEnemyId=1; iEnemyId<=g_iMaxPlayers; iEnemyId++ )
				{
					if( iEnemyId!=iPlrId && CheckPlayerBit(g_iConnected, iEnemyId) && CheckPlayerBit(g_iAlive, iEnemyId) && iTeam!=get_user_team(iEnemyId) )
					{
						pev(iEnemyId, pev_origin, fOrigin);
						
						if( get_distance_f(fMainOrigin, fOrigin)>g_fRadarRange )
							continue;
						
						iOffsetId = (RADARID_OFFSET+iEnemyId);
						
						message_begin(MSG_ONE, g_iMsgId_HostagePos, _, iPlrId);
						write_byte(1);
						write_byte(iOffsetId);
						engfunc(EngFunc_WriteCoord, fOrigin[0]);
						engfunc(EngFunc_WriteCoord, fOrigin[1]);
						engfunc(EngFunc_WriteCoord, fOrigin[2]);
						message_end();
						
						message_begin(MSG_ONE, g_iMsgId_HostageK, _, iPlrId);
						write_byte(iOffsetId);
						message_end();
					}
				}
			}
			
			return;
		}
	}
	
	remove_task(iPlrId);
}

set_hotvision_plr(iEsHandle, bool:bNotSelfUpdate)
{
	if( g_bHotVisionPlayers )
	{
		set_es(iEsHandle, ES_RenderMode, kRenderTransAdd);
		set_es(iEsHandle, ES_RenderAmt, 255);
		set_es(iEsHandle, ES_RenderFx, kRenderFxFadeSlow);
		set_es(iEsHandle, ES_RenderColor, {0, 0, 0});
	}
	
	if( bNotSelfUpdate )
	{
		if( g_bPlrGlow )
			set_es(iEsHandle, ES_Effects, (get_es(iEsHandle, ES_Effects)|EF_DIMLIGHT));
	}
	else if( g_bCustomEffect )
		set_es(iEsHandle, ES_Effects, (get_es(iEsHandle, ES_Effects)|EF_BRIGHTLIGHT));
}

set_hotvision_object(iEsHandle)
{
	set_es(iEsHandle, ES_RenderMode, kRenderTransAdd);
	set_es(iEsHandle, ES_RenderAmt, 255);
	set_es(iEsHandle, ES_RenderFx, kRenderFxDistort);
	set_es(iEsHandle, ES_RenderColor, {0, 0, 0});
	if( g_bModelGlow )
		set_es(iEsHandle, ES_Effects, (get_es(iEsHandle, ES_Effects)|EF_DIMLIGHT));
}

set_hotvision_walls(iEsHandle)
{
	set_es(iEsHandle, ES_RenderMode, kRenderTransTexture);
	set_es(iEsHandle, ES_RenderAmt, 95);
	set_es(iEsHandle, ES_RenderFx, kRenderFxNone);
	set_es(iEsHandle, ES_RenderColor, {0, 0, 0});
}

bool:frame_nvg_update(iPlrId, iUpdatingPlayer, iEsHandle, iEnt)
{
	if( CheckPlayerBit(g_iConnected, iPlrId) )
	{
		static s_iSpectatedPerson[33];
		
		if( CheckPlayerBit(g_iUpdateData, iPlrId) )
		{
			static bool:s_bOldNvg;
			s_bOldNvg = (CheckPlayerBit(g_iInNvg, iPlrId)?true:false);
			
			ClearPlayerBit(g_iUpdateData, iPlrId);
			
			if( CheckPlayerBit(g_iAlive, iPlrId) )
			{
				s_iSpectatedPerson[iPlrId] = iPlrId;
				if( get_pdata_int(iPlrId, m_fNvgState, 5)&NVG_ACTIVATED )
					SetPlayerBit(g_iInNvg, iPlrId);
				else
					ClearPlayerBit(g_iInNvg, iPlrId);
			}
			else if( pev(iPlrId, pev_iuser1)==4 )
			{
				s_iSpectatedPerson[iPlrId] = pev(iPlrId, pev_iuser2);
				if( s_iSpectatedPerson[iPlrId]>g_iMaxPlayers || s_iSpectatedPerson[iPlrId]<=0 )
					ClearPlayerBit(g_iInNvg, iPlrId);
				else if( CheckPlayerBit(g_iAlive, s_iSpectatedPerson[iPlrId]) )
				{
					if( get_pdata_int(s_iSpectatedPerson[iPlrId], m_fNvgState, 5)&NVG_ACTIVATED )
						SetPlayerBit(g_iInNvg, iPlrId);
					else
						ClearPlayerBit(g_iInNvg, iPlrId);
				}
				else
					ClearPlayerBit(g_iInNvg, iPlrId);
			}
			else
			{
				s_iSpectatedPerson[iPlrId] = 0;
				ClearPlayerBit(g_iInNvg, iPlrId);
			}
			
			if( s_bOldNvg )
			{
				if( !CheckPlayerBit(g_iInNvg, iPlrId) )
				{
					message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, iPlrId);
					write_byte(0);
					write_string(g_iDefaultBrightness);
					message_end();
				}
			}
			else if( CheckPlayerBit(g_iInNvg, iPlrId) && g_iCustomBrightness[0] )
			{
				message_begin(MSG_ONE, SVC_LIGHTSTYLE, _, iPlrId);
				write_byte(0);
				write_string(g_iCustomBrightness);
				message_end();
			}
		}
		
		if( CheckPlayerBit(g_iInNvg, iPlrId) )
		{
			if( iUpdatingPlayer )
			{
				if( iPlrId==s_iSpectatedPerson[iPlrId] || iPlrId!=iEnt )
					set_hotvision_plr(iEsHandle, ((iEnt!=s_iSpectatedPerson[iPlrId])?true:false));
				//set_hotvision_plr(iEsHandle, ((iPlrId!=iEnt)?true:false));
			}
			
			return true;
		}
	}
	return false;
}
