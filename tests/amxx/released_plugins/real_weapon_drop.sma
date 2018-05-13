/**
 *
 * Real Weapon Drop
 *  by Numb
 *
 *
 * Description:
 *  This plugin introduces into the game more features related to dropped weapons. Features
 *  such as:
 *  + Ability to drop weapons up and down - where you aim, in that direction weapon will be
 *   thrown.
 *  + Ability to manually drop grenades.
 *  + Drop all weapons at death. Including grenades and a special box of ammunition.
 *  + Drop all weapons on disconnect. Including grenades and a special box of ammunition.
 *  + Barrel of dropped weapons is always facing in the same direction as player was looking.
 *
 *
 * Requires:
 *  FakeMeta
 *  HamSandWich
 *
 *
 * Cvars:
 *
 *  + "rwd_aimdrop" - Counter-Strike:Source style manual weapon drop.
 *  - "1" - enabled. [default]
 *  - "0" - disabled.
 *
 *  + "rwd_grenadedrop" - ability to manually drop grenades.
 *  - "1" - enabled. [default]
 *  - "0" - disabled.
 *
 *  + "rwd_deathdrop" - drop all weapons on death.
 *  - "1" - enabled. [default]
 *  - "0" - disabled.
 *
 *  + "rwd_disconnectdrop" - drop all weapons on disconnect.
 *  - "1" - enabled. [default]
 *  - "0" - disabled.
 *
 *  + "rwd_modelanglefix[/U]" - barrel of the weapon angle fix.
 *  - "1" - enabled. [default]
 *  - "0" - disabled.
 *
 *
 * Additional info:
 *  Tested in Counter-Strike 1.6 with amxmodx 1.8.2. Various features can be enabled and
 *  disabled via cvars. This plugin also has support VIP objectives and grenade trail
 *  plugins.
 *
 *
 * Notes:
 *  Barrel of dropped weapons may be facing in wrong direction if client is using custom
 *  weapon models.
 *
 *
 * WARNINGS:
 *  In some cases pausing this plugin may lead to glitches, therefor if when needed please
 *  use cvars instead. That is if paused in certain moments by other plugins. Manual pauses
 *  won't do much harm, except dropped flashes will fill up your flashbang slot to maximum,
 *  and ammunition box will be touchable only once.
 *
 *
 * Credits:
 *  Special thanks to Arkshine ( http://forums.alliedmods.net/member.php?u=7779 ) for
 *  Counter-Strike SDK ( https://github.com/Arkshine/CSSDK/ ) and big help what he have
 *  provided by delivering very useful information! Also big thanks goes to eDark for
 *  calculation functions!
 *
 *
 * Change-Log:
 *
 *  + 2.3
 *  - Fixed: Crash at mapchange if there's too many players and other entities.
 *  - Changed: More reliability when saving number of dropped bullets and flash grenades.
 *
 *  + 2.2
 *  - Fixed: VIPs drop all their weapons on escape.
 *  - Changed: Minor performance improvement.
 *
 *  + 2.1
 *  - Changed: Minor performance improvement.
 *
 *  + 2.0
 *  - Fixed: Grenades do not bounce insane when dropped.
 *  - Fixed: VIPs can't no longer pick-up ammunition.
 *  - Fixed: VIPs also do drop their weapons if have any.
 *  - Changed: Full plugin rewrite - plugin is now much more stable.
 *
 *  + 1.4
 *  - Fixed: "grenade bounce for ever" by adding gravitation level manually. // had issues
 *
 *  + 1.3
 *  - Fixed: Explode grenade on death if it's not armed.
 *  - Added: Grenade drop.
 *
 *  + 1.2
 *  - Fixed: Due to bug in standard ArrayDeleteItem(Array:which, item) native I created my
 *   own working one.
 *
 *  + 1.1
 *  - Changed: (code) Modified array clear (less cpu usage - I think).
 *  - Changed: (code) Entity scan (less cpu usage).
 *  - Changed: (code) Unneeded data getting from array - removed (less cpu usage).
 *
 *  + 1.0
 *  - First release.
 *
 *
 * Downloads:
 *  Amx Mod X forums: http://forums.alliedmods.net/showthread.php?p=619788#post619788
 *
**/

//#define FAST_METHOD // saves AllocString value at mapstart, but isn't as reliable

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN_NAME	"Real Weapon Drop"
#define PLUGIN_VERSION	"2.3"
#define PLUGIN_AUTHOR	"Numb"

#define AMMO_MODEL "models/w_357ammobox.mdl"
#define AMMO_SOUND "items/9mmclip2.wav"

#define SetPlayerBit(%1,%2)    ( %1 |=  ( 1 << ( %2 & 31 ) ) )
#define ClearPlayerBit(%1,%2)  ( %1 &= ~( 1 << ( %2 & 31 ) ) )
#define CheckPlayerBit(%1,%2)  ( %1 &   ( 1 << ( %2 & 31 ) ) )

// "weapon_" entity
#define m_flStartThrow 30
#define m_pPlayer 41
#define m_iId 43
#define m_flTimeWeaponIdle 48

// "player" entity
#define m_bIsVIP 209
#define m_pActiveItem 373
#define m_rgAmmo_player 376
#define FLAG_VIP (1<<8)

// "weaponbox" entity
#define m_rgpPlayerItems 34
#define m_rgiszAmmo 41
#define m_rgAmmo 73
#define AMMO_FLASHBANG 11
#define AMMO_HEGRENADE 12
#define AMMO_SMOKENADE 13

new g_iBulletsDropped[33][15];
#if defined FAST_METHOD
new m_rgiszAmmoNames[15];
#endif
new g_iMaxPlayers;
new g_iConnected;
new g_iAlive;

new g_iMsgId_AmmoPickup;
new g_iMsgId_WeapPickup;

new g_iCvar_AimDrop;
new g_iCvar_GrenadeDrop;
new g_iCvar_DeathDrop;
new g_iCvar_DisconnectDrop;
new g_iCvar_ModelAngleFix;

new g_bInAutoDrop;
new HamHook:g_iHamHook_Think;
new g_iHamHook_Active;
new g_iDeathDrops[33][29];
new g_iDeathDropsNum[33];
new Float:g_fPlayerAngle[33];
new bool:g_bVipDrop;
new bool:g_bChangingMap;

new g_iAmmoNames[15][] = {
	"",
	"338Magnum", // awp
	"762Nato", // ak47 scout g3sg1
	"556NatoBox", // m249
	"556Nato", // aug m4a1 sgg550 sgg552 galil famas
	"buckshot", // m3 xm1014
	"45ACP", // mac10 usp ump45
	"57mm", // p90 fiveseven
	"50AE", // deagle
	"357SIG", // p228
	"9mm", // glock elites mp5navy tmp
	"Flashbang",
	"HEGrenade",
	"SmokeGrenade",
	"C4"
};

new g_iAmmoEntityNames[15][] = {
	"",
	"ammo_338magnum", // awp
	"ammo_762nato", // ak47 scout g3sg1
	"ammo_556natobox", // m249
	"ammo_556nato", // aug m4a1 sgg550 sgg552 galil famas
	"ammo_buckshot", // m3 xm1014
	"ammo_45acp", // mac10 usp ump45
	"ammo_57mm", // p90 fiveseven
	"ammo_50ae", // deagle
	"ammo_357sig", // p228
	"ammo_9mm", // glock elites mp5navy tmp
	"weapon_flashbang",
	"weapon_hegrenade",
	"weapon_smokegenade",
	"weapon_c4"
};

new g_iMaxAmmo[15] = {
	0,
	30,
	90,
	200,
	90,
	32,
	100,
	100,
	35,
	52,
	120,
	2,
	1,
	1,
	1
};

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	
	register_event("30", "Event_MapChangeScoreboard", "a");
	
	register_forward(FM_ClientDisconnect, "FM_ClientDisconnect_Pre", 0);
	register_forward(FM_SetModel,         "FM_SetModel_Pre",         0);
	
	RegisterHam(Ham_Spawn,           "player",              "Ham_Spawn_Player_Post",  1);
	RegisterHam(Ham_Killed,          "player",              "Ham_Killed_player_Pre",  0);
	RegisterHam(Ham_Killed,          "player",              "Ham_Killed_player_Post", 1);
	RegisterHam(Ham_CS_Item_CanDrop, "weapon_hegrenade",    "Ham_Item_CanDrop_Pre",   0);
	RegisterHam(Ham_CS_Item_CanDrop, "weapon_flashbang",    "Ham_Item_CanDrop_Pre",   0);
	RegisterHam(Ham_CS_Item_CanDrop, "weapon_smokegrenade", "Ham_Item_CanDrop_Pre",   0);
	RegisterHam(Ham_CS_Item_CanDrop, "weapon_knife",        "Ham_Item_CanDrop_Pre",   0);
	RegisterHam(Ham_Touch,           "weaponbox",           "Ham_Touch_wpnbox_Pre",   0);
	RegisterHam(Ham_Touch,           "func_vip_safetyzone", "Ham_Touch_safezone_Pre", 0);
	
	g_iHamHook_Think = RegisterHam(Ham_Think, "player", "Ham_Think_player_Pre", 0);
	DisableHamForward(g_iHamHook_Think);
	
	g_iCvar_AimDrop        = register_cvar("rwd_aimdrop", "1");
	g_iCvar_GrenadeDrop    = register_cvar("rwd_grenadedrop", "1");
	g_iCvar_DeathDrop      = register_cvar("rwd_deathdrop", "1");
	g_iCvar_DisconnectDrop = register_cvar("rwd_disconnectdrop", "1");
	g_iCvar_ModelAngleFix  = register_cvar("rwd_modelanglefix", "1");
	
	g_iMaxPlayers = clamp(get_maxplayers(), 1, 32);
	
#if defined FAST_METHOD
	for( new iLoop=1; iLoop<15; iLoop++ )
		m_rgiszAmmoNames[iLoop] = engfunc(EngFunc_AllocString, g_iAmmoNames[iLoop]);
#endif
	
	g_iMsgId_AmmoPickup = get_user_msgid("AmmoPickup");
	g_iMsgId_WeapPickup = get_user_msgid("WeapPickup");
}

public plugin_precache()
{
	precache_model(AMMO_MODEL);
	precache_sound(AMMO_SOUND);
}

public plugin_unpause()
{
	g_iConnected = 0;
	g_iAlive = 0;
	
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

public client_connect(iPlrId)
{
	ClearPlayerBit(g_iAlive, iPlrId);
	ClearPlayerBit(g_iConnected, iPlrId);
}

public client_putinserver(iPlrId)
	SetPlayerBit(g_iConnected, iPlrId);

public Event_MapChangeScoreboard()
	g_bChangingMap = true;

public Message_AmmoPickup(iMsgId, iMsgType, iPlrId) // modify given ammo on hud when needed
{
	static s_iAmmoNum;
	s_iAmmoNum = g_iBulletsDropped[iPlrId][get_msg_arg_int(1)];
	if( s_iAmmoNum )
		set_msg_arg_int(2, ARG_BYTE, s_iAmmoNum);
}

public Message_Block(iMsgId, iMsgType, iPlrId) // block ammo and weaponpickup hud update when needed
	return PLUGIN_HANDLED;

public FM_ClientDisconnect_Pre(iPlrId)
{
	ClearPlayerBit(g_iConnected, iPlrId);
	ClearPlayerBit(g_iAlive, iPlrId);
	ClearPlayerBit(g_iHamHook_Active, iPlrId);
	
	if( get_pcvar_num(g_iCvar_DisconnectDrop) )
	{
		static s_iVip;
		s_iVip = get_pdata_int(iPlrId, m_bIsVIP, 5);
		set_pdata_int(iPlrId, m_bIsVIP, (s_iVip&~FLAG_VIP), 5);
		force_weapon_drop(iPlrId, 0, 0);
		set_pdata_int(iPlrId, m_bIsVIP, s_iVip, 5);
	}
}

public FM_SetModel_Pre(iEnt, iModel[])
{
	if( !equal(iModel, "models/w_", 9) )
		return FMRES_IGNORED;
	
	if( equal(iModel[9], "weaponbox.mdl") ) // this weaponbox isn't yet ready to be worked with
		return FMRES_IGNORED;
	
	static s_iClassName[11];
	pev(iEnt, pev_classname, s_iClassName, 10);
	
	if( equal(s_iClassName, "weaponbox") ) // is this a weaponbox with what we can work
	{
		static s_iOwner, Float:s_fVelocity[3], s_bAlive, Float:s_fAngle[3];
		s_iOwner = pev(iEnt, pev_owner);
		if( 0<s_iOwner<=g_iMaxPlayers )
			s_bAlive = (CheckPlayerBit(g_iAlive, s_iOwner)?true:false);
		else
			s_bAlive = false;
		
		if( s_bAlive && !g_bVipDrop ) // alive user dropped weapons
		{
			if( get_pcvar_num(g_iCvar_AimDrop) ) // should we change drop direction via player by aim
			{
				static Float:s_fOrigin[3], Float:s_fResult[3];
				pev(s_iOwner, pev_origin, s_fOrigin);
				pev(s_iOwner, pev_v_angle, s_fAngle);
				SphereToCartesian(s_fResult, s_fOrigin, s_fAngle, Float:{0.0, 0.0, 200.0}); // some extraterrestrial math by eDark
				pev(s_iOwner, pev_velocity, s_fVelocity);
				s_fVelocity[0] += (s_fResult[0]-s_fOrigin[0]);
				s_fVelocity[1] += (s_fResult[1]-s_fOrigin[1]);
				s_fVelocity[2] -= (s_fResult[2]-s_fOrigin[2]);
				set_pev(iEnt, pev_velocity, s_fVelocity);
			}
		}
		else if( is_player_connected(s_iOwner) ) // weapon is dropped due to death
		{
			if( get_pcvar_num(g_iCvar_DeathDrop) )
			{
				if( CheckPlayerBit(g_iHamHook_Active, s_iOwner) && 0<=g_iDeathDropsNum[s_iOwner] && g_iDeathDropsNum[s_iOwner]<29 )
				{
					g_iDeathDrops[s_iOwner][g_iDeathDropsNum[s_iOwner]] = iEnt; // sometimes not all the weapons have speed set right,
					g_iDeathDropsNum[s_iOwner]++; // therefor we'll set their speed to again, when we'll be sure it's right
					
					s_fVelocity = Float:{0.0, 0.0, 0.0};
				}
				else
					pev(s_iOwner, pev_velocity, s_fVelocity);
					
				s_fVelocity[0] += random_float(-10.0, 10.0);
				s_fVelocity[1] += random_float(-10.0, 10.0);
				s_fVelocity[2] += random_float(-5.0, 5.0);
				set_pev(iEnt, pev_velocity, s_fVelocity);
			}
		}
		else if( get_pcvar_num(g_iCvar_DisconnectDrop) ) // weapon is dropped due to disconnect
		{
			s_fVelocity = Float:{0.0, 0.0, 0.0};
			s_fVelocity[0] = random_float(-10.0, 10.0);
			s_fVelocity[1] = random_float(-10.0, 10.0);
			s_fVelocity[2] = random_float(-5.0, 5.0);
			set_pev(iEnt, pev_velocity, s_fVelocity);
		}
		
		if( 0<s_iOwner<=g_iMaxPlayers ) // should we work a bit more with the weaponbox
		{
			if( !s_bAlive )
			{
				pev(iEnt, pev_angles, s_fAngle);
				s_fAngle[1] = g_fPlayerAngle[s_iOwner];
				set_pev(iEnt, pev_angles, s_fAngle);
			}
			
			if( equal(iModel[9], "flashbang.mdl") ) // this weaponbox includes information about flash grenade
			{
#if defined FAST_METHOD
				set_pdata_int(iEnt, (m_rgiszAmmo+AMMO_FLASHBANG), m_rgiszAmmoNames[AMMO_FLASHBANG], 4);
#else
				set_pdata_int(iEnt, (m_rgiszAmmo+AMMO_FLASHBANG), engfunc(EngFunc_AllocString, g_iAmmoNames[AMMO_FLASHBANG]), 4);
#endif
				if( s_bAlive )
				{
					set_pdata_int(iEnt, (m_rgAmmo+AMMO_FLASHBANG), 1, 4); // not working (glitch with grenades)
					if( g_iBulletsDropped[s_iOwner][AMMO_FLASHBANG]>0 )
					{
						static s_iFwdMsg_AmmoPickup, s_iFwdMsg_WeapPickup;
						s_iFwdMsg_AmmoPickup = register_message(g_iMsgId_AmmoPickup, "Message_Block");
						s_iFwdMsg_WeapPickup = register_message(g_iMsgId_WeapPickup, "Message_Block");
						
						ham_give_item(s_iOwner, "weapon_flashbang");
						set_pdata_int(s_iOwner, (m_rgAmmo_player+AMMO_FLASHBANG), g_iBulletsDropped[s_iOwner][AMMO_FLASHBANG], 5);
						engclient_cmd(s_iOwner, "weapon_flashbang");
						
						unregister_message(g_iMsgId_AmmoPickup, s_iFwdMsg_AmmoPickup);
						unregister_message(g_iMsgId_WeapPickup, s_iFwdMsg_WeapPickup);
					}
				}
				else
					set_pdata_int(iEnt, (m_rgAmmo+AMMO_FLASHBANG), g_iBulletsDropped[s_iOwner][AMMO_FLASHBANG], 4); // not working (glitch with grenades)
				
				message_begin(MSG_ALL, SVC_TEMPENTITY, _, _); // yep, lets include support for grenade trail plugin
				write_byte(TE_KILLBEAM);
				write_short(iEnt);
				message_end();
			}
			else if( equal(iModel[9], "hegrenade.mdl") ) // this weaponbox includes information about he grenade
			{
				message_begin(MSG_ALL, SVC_TEMPENTITY, _, _); // yep, lets include support for grenade trail plugin
				write_byte(TE_KILLBEAM);
				write_short(iEnt);
				message_end();
				
				pev(iEnt, pev_angles, s_fAngle);
				s_fAngle[1] += 90.0;
				set_pev(iEnt, pev_angles, s_fAngle);
			}
			else if( equal(iModel[9], "smokegrenade.mdl") ) // this weaponbox includes information about smoke grenade
			{
				message_begin(MSG_ALL, SVC_TEMPENTITY, _, _); // yep, lets include support for grenade trail plugin
				write_byte(TE_KILLBEAM);
				write_short(iEnt);
				message_end();
				
				pev(iEnt, pev_angles, s_fAngle);
				s_fAngle[1] += 45.0;
				set_pev(iEnt, pev_angles, s_fAngle);
			}
			else if( equal(iModel[9], "knife.mdl") ) // dropped knife - lets set bullets info into it
			{
				pev(iEnt, pev_angles, s_fAngle);
				s_fAngle[1] += 180.0;
				set_pev(iEnt, pev_angles, s_fAngle);
				
				static s_iLoop;
				for( s_iLoop=1; s_iLoop<11; s_iLoop++ )
				{
#if defined FAST_METHOD
					set_pdata_int(iEnt, (m_rgiszAmmo+s_iLoop), m_rgiszAmmoNames[s_iLoop], 4);
#else
					set_pdata_int(iEnt, (m_rgiszAmmo+s_iLoop), engfunc(EngFunc_AllocString, g_iAmmoNames[s_iLoop]), 4);
#endif
					set_pdata_int(iEnt, (m_rgAmmo+s_iLoop), g_iBulletsDropped[s_iOwner][s_iLoop], 4);
				}
				
				engfunc(EngFunc_SetModel, iEnt, AMMO_MODEL); // and change model to custom one of course
				return FMRES_SUPERCEDE;
			}
			else if( get_pcvar_num(g_iCvar_ModelAngleFix) ) // lets fix angle of the weaponbox model
			{
				pev(iEnt, pev_angles, s_fAngle);
				
				if( equal(iModel[9], "glock18.mdl") )
					s_fAngle[1] -= 110.0;
				else if( equal(iModel[9], "usp.mdl") )
					s_fAngle[1] -= 65.0;
				else if( equal(iModel[9], "deagle.mdl") )
					s_fAngle[1] -= 110.0;
				else if( equal(iModel[9], "p228.mdl") )
					s_fAngle[1] -= 60.0;
				else if( equal(iModel[9], "elite.mdl") )
					s_fAngle[1] -= 180.0;
				else if( equal(iModel[9], "fiveseven.mdl") )
					s_fAngle[1] -= 50.0;
				else if( equal(iModel[9], "m3.mdl") )
					s_fAngle[1] -= 125.0;
				else if( equal(iModel[9], "xm1014.mdl") )
					s_fAngle[1] -= 5.0;
				else if( equal(iModel[9], "mp5.mdl") )
					s_fAngle[1] += 10.0;
				else if( equal(iModel[9], "tmp.mdl") ) // mac10 has a perfect angle - no need to fix
					s_fAngle[1] -= 135.0;
				else if( equal(iModel[9], "p90.mdl") )
					s_fAngle[1] -= 125.0;
				else if( equal(iModel[9], "ump45.mdl") )
					s_fAngle[1] -= 70.0;
				else if( equal(iModel[9], "galil.mdl") )
					s_fAngle[1] += 15.0;
				else if( equal(iModel[9], "famas.mdl") )
					s_fAngle[1] -= 30.0;
				else if( equal(iModel[9], "ak47.mdl") )
					s_fAngle[1] -= 105.0;
				else if( equal(iModel[9], "m4a1.mdl") )
					s_fAngle[1] -= 60.0;
				else if( equal(iModel[9], "sg552.mdl") )
					s_fAngle[1] -= 130.0;
				else if( equal(iModel[9], "aug.mdl") )
					s_fAngle[1] -= 125.0;
				else if( equal(iModel[9], "scout.mdl") )
					s_fAngle[1] -= 70.0;
				else if( equal(iModel[9], "awp.mdl") )
					s_fAngle[1] -= 110.0;
				else if( equal(iModel[9], "g3sg1.mdl") )
					s_fAngle[1] -= 110.0;
				else if( equal(iModel[9], "sg550.mdl") )
					s_fAngle[1] -= 115.0;
				else if( equal(iModel[9], "m249.mdl") )
					s_fAngle[1] -= 95.0;
				
				set_pev(iEnt, pev_angles, s_fAngle);
			}
		}
	}
	
	return FMRES_IGNORED;
}

public Ham_Spawn_Player_Post(iPlrId)
{
	if( is_user_alive(iPlrId) )
		SetPlayerBit(g_iAlive, iPlrId);
	else
		ClearPlayerBit(g_iAlive, iPlrId);
}

public Ham_Killed_player_Pre(iPlrId, iAttackerId, iShouldGib)
{
	g_iDeathDropsNum[iPlrId] = 0;
	if( !g_iHamHook_Active )
		EnableHamForward(g_iHamHook_Think);
	SetPlayerBit(g_iHamHook_Active, iPlrId);
	
	if( get_pcvar_num(g_iCvar_DeathDrop) )
	{
		static s_iArmedGrenade, s_iWeaponType;
		s_iArmedGrenade = get_pdata_cbase(iPlrId, m_pActiveItem, 5);
		if( s_iArmedGrenade>0 && pev_valid(s_iArmedGrenade) )
		{
			s_iWeaponType = get_pdata_int(s_iArmedGrenade, m_iId, 4);
			if( s_iWeaponType==CSW_FLASHBANG || s_iWeaponType==CSW_HEGRENADE || s_iWeaponType==CSW_SMOKEGRENADE )
			{
				if( get_pdata_float(s_iArmedGrenade, m_flStartThrow, 3) && get_pdata_float(s_iArmedGrenade, m_flTimeWeaponIdle, 4)<=0.0 )
					s_iArmedGrenade = s_iWeaponType; // a grenade is ready to explode - save information what grenade it is
				else
					s_iArmedGrenade = 0;
			}
			else
				s_iArmedGrenade = 0;
		}
		else
		{
			s_iWeaponType = 0;
			s_iArmedGrenade = 0;
		}
		
		static s_iVip;
		s_iVip = get_pdata_int(iPlrId, m_bIsVIP, 5);
		set_pdata_int(iPlrId, m_bIsVIP, (s_iVip&~FLAG_VIP), 5);
		force_weapon_drop(iPlrId, s_iArmedGrenade, s_iWeaponType);
		set_pdata_int(iPlrId, m_bIsVIP, s_iVip, 5);
	}
}

public Ham_Killed_player_Post(iPlrId, iAttackerId, iShouldGib)
{
	if( is_user_alive(iPlrId) )
		SetPlayerBit(g_iAlive, iPlrId);
	else
		ClearPlayerBit(g_iAlive, iPlrId);
}

public Ham_Think_player_Pre(iPlrId)
{
	if( g_iDeathDropsNum[iPlrId] )
	{
		static Float:s_fVelocity[3];
		pev(iPlrId, pev_velocity, s_fVelocity);
		
		static s_iDeathDrops, s_iEnt;
		for( s_iDeathDrops=0; s_iDeathDrops<g_iDeathDropsNum[iPlrId]; s_iDeathDrops++ )
		{
			s_iEnt = g_iDeathDrops[iPlrId][s_iDeathDrops];
			if( s_iEnt>0 && pev_valid(s_iEnt) )
				set_pev(s_iEnt, pev_velocity, s_fVelocity);
		}
	}
	
	ClearPlayerBit(g_iHamHook_Active, iPlrId);
	if( !g_iHamHook_Active )
		DisableHamForward(g_iHamHook_Think);
}

public Ham_Touch_safezone_Pre(iEnt, iPlrId)
{
	if( iPlrId>0 && iPlrId<=g_iMaxPlayers )
	{
		static s_iVip;
		s_iVip = get_pdata_int(iPlrId, m_bIsVIP, 5);
		if( s_iVip&FLAG_VIP )
		{
			g_bVipDrop = true;
			set_pdata_int(iPlrId, m_bIsVIP, (s_iVip&~FLAG_VIP), 5);
			force_weapon_drop(iPlrId, 0, 0);
			set_pdata_int(iPlrId, m_bIsVIP, s_iVip, 5);
			g_bVipDrop = false;
		}
	}
}

public Ham_Item_CanDrop_Pre(iEnt) // allow drop of various items when needed
{
	if( g_bInAutoDrop )
		SetHamReturnInteger(1);
	else if( get_pcvar_num(g_iCvar_GrenadeDrop) )
	{
		static s_iOwner;
		s_iOwner = get_pdata_cbase(iEnt, m_pPlayer, 4);
		
		if( 0<s_iOwner<=g_iMaxPlayers )
		{
			if( get_pdata_int(s_iOwner, m_bIsVIP, 5)&FLAG_VIP ) // yep, if somehow VIP gets a grenade, don't allow it to be dropped
				return HAM_IGNORED;
			
			static s_iWeaponType;
			s_iWeaponType = get_pdata_int(iEnt, m_iId, 4);
			
			if( s_iWeaponType==CSW_KNIFE )
				return HAM_IGNORED; // yep, don't allow manual drop of knife
			else if( s_iWeaponType==CSW_FLASHBANG )
				g_iBulletsDropped[s_iOwner][AMMO_FLASHBANG] = (clamp(get_pdata_int(s_iOwner, (m_rgAmmo_player+AMMO_FLASHBANG), 5), 1, 2)-1);
			SetHamReturnInteger(1);
		}
		else
			return HAM_IGNORED;
	}
	else
		return HAM_IGNORED;
	
	return HAM_OVERRIDE;
}

public Ham_Touch_wpnbox_Pre(iEnt, iPlrId) // when weaponbox is touched
{
	if( 0<iPlrId<=g_iMaxPlayers )
	{
		if( get_pdata_int(iPlrId, m_bIsVIP, 5)&FLAG_VIP || ~pev(iEnt, pev_flags)&FL_ONGROUND ) // weaponbox can have an effect on the player
			return HAM_SUPERCEDE;
		
		static s_iBoxAmmo, s_iUserAmmo;
		if( (s_iBoxAmmo=get_pdata_int(iEnt, (m_rgAmmo+AMMO_FLASHBANG), 4))>0 ) // weaponbox has flashbang information inside
		{
			if( (s_iUserAmmo=get_pdata_int(iPlrId, (m_rgAmmo_player+AMMO_FLASHBANG), 5))>=2 )
				return HAM_SUPERCEDE;
			else if( (s_iUserAmmo<=0 && s_iBoxAmmo>=2) )
			{
				ham_give_item(iPlrId, "weapon_flashbang");
				ham_give_item(iPlrId, "weapon_flashbang");
				
				emit_sound(iPlrId, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				emit_sound(iPlrId, CHAN_ITEM, "items/9mmclip1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			
				set_pev(iEnt, pev_solid, SOLID_NOT);
				set_pev(iEnt, pev_effects, EF_NODRAW);
				dllfunc(DLLFunc_Think, iEnt);
				
				return HAM_SUPERCEDE;
			}
			else if( (s_iUserAmmo==1 && s_iBoxAmmo==1) )
			{
				ham_give_item(iPlrId, "weapon_flashbang");
				
				emit_sound(iPlrId, CHAN_ITEM, "items/9mmclip1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
			
				set_pev(iEnt, pev_solid, SOLID_NOT);
				set_pev(iEnt, pev_effects, EF_NODRAW);
				dllfunc(DLLFunc_Think, iEnt);
				
				return HAM_SUPERCEDE;
			}
			else if( s_iUserAmmo==1 && s_iBoxAmmo>=2 )
			{
				set_pdata_int(iEnt, (m_rgAmmo+AMMO_FLASHBANG), (s_iBoxAmmo-1), 4);
				ham_give_item(iPlrId, "weapon_flashbang");
				
				emit_sound(iPlrId, CHAN_ITEM, "items/9mmclip1.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				
				return HAM_SUPERCEDE;
			}
			else if( s_iUserAmmo<=0 && ham_give_item(iPlrId, "weapon_flashbang")>0 )
			{
				emit_sound(iPlrId, CHAN_ITEM, "items/gunpickup2.wav", VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
				
				set_pev(iEnt, pev_solid, SOLID_NOT);
				set_pev(iEnt, pev_effects, EF_NODRAW);
				dllfunc(DLLFunc_Think, iEnt);
				
				return HAM_SUPERCEDE;
			}
			
			return HAM_IGNORED;
		}
		else // now check for actual bullets
		{
			static s_iTemp;
			s_iTemp = get_pdata_cbase(iEnt, (m_rgpPlayerItems+3), 4);
			
			if( s_iTemp>0 && pev_valid(s_iTemp) )
			{
				if( get_pdata_int(s_iTemp, m_iId, 4)==CSW_KNIFE ) // check passed - this weaponbox should include information about the bullets
				{
					static s_iFwdMsg_AmmoPickup;
					s_iFwdMsg_AmmoPickup = register_message(g_iMsgId_AmmoPickup, "Message_AmmoPickup"); // yes, we'll have to edit hud value
					
					g_iBulletsDropped[0][0] = g_iBulletsDropped[iPlrId][0] = 0;
					for( s_iTemp=1; s_iTemp<11; s_iTemp++ )
					{
						if( (s_iBoxAmmo=get_pdata_int(iEnt, (m_rgAmmo+s_iTemp), 4))>0 )
						{
							if( (s_iUserAmmo=clamp(get_pdata_int(iPlrId, (m_rgAmmo_player+s_iTemp), 5), 0, g_iMaxAmmo[s_iTemp]))>=g_iMaxAmmo[s_iTemp] )
								g_iBulletsDropped[0][0] = 1; // weaponbox still has ammo - don't remove the entity
							else
							{
								if( (s_iUserAmmo+s_iBoxAmmo)<=g_iMaxAmmo[s_iTemp] )
								{
									g_iBulletsDropped[iPlrId][s_iTemp] = s_iBoxAmmo;
									s_iUserAmmo += s_iBoxAmmo;
									set_pdata_int(iEnt, (m_rgAmmo+s_iTemp), 0, 4);
								}
								else
								{
									g_iBulletsDropped[0][0] = 1; // weaponbox still has ammo - don't remove the entity
									
									g_iBulletsDropped[iPlrId][s_iTemp] = (g_iMaxAmmo[s_iTemp]-s_iUserAmmo);
									s_iUserAmmo = g_iMaxAmmo[s_iTemp];
									set_pdata_int(iEnt, (m_rgAmmo+s_iTemp), (s_iBoxAmmo-g_iBulletsDropped[iPlrId][s_iTemp]), 4);
								}
								g_iBulletsDropped[iPlrId][0] += g_iBulletsDropped[iPlrId][s_iTemp]; // we need to save that some bullets were given
								
								fm_give_item(iPlrId, g_iAmmoEntityNames[s_iTemp]); // we must give ammo this way, else weapon
								set_pdata_int(iPlrId, (m_rgAmmo_player+s_iTemp), s_iUserAmmo, 5); // wont be able to reload
							}
						}
					}
					unregister_message(g_iMsgId_AmmoPickup, s_iFwdMsg_AmmoPickup);
					
					if( g_iBulletsDropped[iPlrId][0] ) // bullets were given - emit bullet pick-up sound
						emit_sound(iPlrId, CHAN_ITEM, AMMO_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
					
					if( !g_iBulletsDropped[0][0] ) // weaponbox has no more ammo - remove it
					{
						set_pev(iEnt, pev_solid, SOLID_NOT);
						set_pev(iEnt, pev_effects, EF_NODRAW);
						dllfunc(DLLFunc_Think, iEnt);
					}
					
					return HAM_SUPERCEDE;
				}
			}
		}
	}
	
	return HAM_IGNORED;
}

force_weapon_drop(iPlrId, iArmedGrenade, iWeaponType)
{
	if( g_bChangingMap )
		return;
	
	g_bInAutoDrop = true; // allow death drop of grenades and knife
	
	static s_iUserWeapons, Float:s_fAngle[3];
	s_iUserWeapons = pev(iPlrId, pev_weapons);
	pev(iPlrId, pev_v_angle, s_fAngle);
	g_fPlayerAngle[iPlrId] = s_fAngle[1];
	
	if( iArmedGrenade!=CSW_HEGRENADE && get_pdata_int(iPlrId, (m_rgAmmo_player+AMMO_HEGRENADE), 5)>0 )
		engclient_cmd(iPlrId, "drop", "weapon_hegrenade");
	
	if( (g_iBulletsDropped[iPlrId][AMMO_FLASHBANG]=(clamp(get_pdata_int(iPlrId, (m_rgAmmo_player+AMMO_FLASHBANG), 5), 0, 2)-((iArmedGrenade==CSW_FLASHBANG)?1:0)))>0 )
	{
		engclient_cmd(iPlrId, "drop", "weapon_flashbang");
		
		if( iArmedGrenade==CSW_FLASHBANG ) // oh, ya, by dropping one flash, we disarm the other one, so we have to bypass it
		{
			set_pdata_int(iPlrId, (m_rgAmmo_player+AMMO_FLASHBANG), 1, 5); // just to be on the safe side, in case user had more than 2 flashes
			iArmedGrenade = ham_give_item(iPlrId, "weapon_flashbang");
			set_pdata_int(iPlrId, (m_rgAmmo_player+AMMO_FLASHBANG), 1, 5); // if magically user doesn't die, let him have one flash (not two)
			
			if( iArmedGrenade>0 && pev_valid(iArmedGrenade) )
			{
				set_pdata_cbase(iPlrId, m_pActiveItem, iArmedGrenade, 5); // yep, lets set it to be the active item
				set_pdata_float(iArmedGrenade, m_flStartThrow, 1.0, 3); // now arm the grenade, so at death it'll be dropped
				set_pdata_float(iArmedGrenade, m_flTimeWeaponIdle, -0.001, 4);
			}
			iArmedGrenade = 0;
		}
	}
	
	if( iArmedGrenade!=CSW_SMOKEGRENADE && get_pdata_int(iPlrId, (m_rgAmmo_player+AMMO_SMOKENADE), 5)>0 )
		engclient_cmd(iPlrId, "drop", "weapon_smokegrenade");
	
	static s_iLoop;
	g_iBulletsDropped[iPlrId][0] = 0; // this will be higher, if player has any bullets at all
	for( s_iLoop=1; s_iLoop<11; s_iLoop++ ) // yep, here we get information of specific bullet types
	{
		g_iBulletsDropped[iPlrId][s_iLoop] = clamp(get_pdata_int(iPlrId, (m_rgAmmo_player+s_iLoop), 5), 0, g_iMaxAmmo[s_iLoop]);
		set_pdata_int(iPlrId, (m_rgAmmo_player+s_iLoop), 0, 5);
		g_iBulletsDropped[iPlrId][0] += g_iBulletsDropped[iPlrId][s_iLoop];
	
	}
	
	if( g_iBulletsDropped[iPlrId][0] ) // if player has any bullets at all
	{
		if( ~s_iUserWeapons&(1<<CSW_KNIFE) ) // if user has no knife - give one
			ham_give_item(iPlrId, "weapon_knife");
		engclient_cmd(iPlrId, "drop", "weapon_knife");
		ham_give_item(iPlrId, "weapon_knife"); // after dropping the knife, to be safe, lets give 1 knife back
	}
	
	g_bInAutoDrop = false; // disallow death drop of grenades and knife
	
	if( s_iUserWeapons&(1<<CSW_P228) && iWeaponType!=CSW_P228 ) // just drop all the weapons
		engclient_cmd(iPlrId, "drop", "weapon_p228");
	if( s_iUserWeapons&(1<<CSW_SCOUT) && iWeaponType!=CSW_SCOUT )
		engclient_cmd(iPlrId, "drop", "weapon_scout");
	if( s_iUserWeapons&(1<<CSW_XM1014) && iWeaponType!=CSW_XM1014 )
		engclient_cmd(iPlrId, "drop", "weapon_xm1014");
	if( s_iUserWeapons&(1<<CSW_MAC10) && iWeaponType!=CSW_MAC10 )
		engclient_cmd(iPlrId, "drop", "weapon_mac10");
	if( s_iUserWeapons&(1<<CSW_AUG) && iWeaponType!=CSW_AUG )
		engclient_cmd(iPlrId, "drop", "weapon_aug");
	if( s_iUserWeapons&(1<<CSW_ELITE) && iWeaponType!=CSW_ELITE )
		engclient_cmd(iPlrId, "drop", "weapon_elite");
	if( s_iUserWeapons&(1<<CSW_FIVESEVEN) && iWeaponType!=CSW_FIVESEVEN )
		engclient_cmd(iPlrId, "drop", "weapon_fiveseven");
	if( s_iUserWeapons&(1<<CSW_UMP45) && iWeaponType!=CSW_UMP45 )
		engclient_cmd(iPlrId, "drop", "weapon_ump45");
	if( s_iUserWeapons&(1<<CSW_SG550) && iWeaponType!=CSW_SG550 )
		engclient_cmd(iPlrId, "drop", "weapon_sg550");
	if( s_iUserWeapons&(1<<CSW_GALIL) && iWeaponType!=CSW_GALIL )
		engclient_cmd(iPlrId, "drop", "weapon_galil");
	if( s_iUserWeapons&(1<<CSW_FAMAS) && iWeaponType!=CSW_FAMAS )
		engclient_cmd(iPlrId, "drop", "weapon_famas");
	if( s_iUserWeapons&(1<<CSW_USP) && iWeaponType!=CSW_USP )
		engclient_cmd(iPlrId, "drop", "weapon_usp");
	if( s_iUserWeapons&(1<<CSW_GLOCK18) && iWeaponType!=CSW_GLOCK18 )
		engclient_cmd(iPlrId, "drop", "weapon_glock18");
	if( s_iUserWeapons&(1<<CSW_AWP) && iWeaponType!=CSW_AWP )
		engclient_cmd(iPlrId, "drop", "weapon_awp");
	if( s_iUserWeapons&(1<<CSW_MP5NAVY) && iWeaponType!=CSW_MP5NAVY )
		engclient_cmd(iPlrId, "drop", "weapon_mp5navy");
	if( s_iUserWeapons&(1<<CSW_M249) && iWeaponType!=CSW_M249 )
		engclient_cmd(iPlrId, "drop", "weapon_m249");
	if( s_iUserWeapons&(1<<CSW_M3) && iWeaponType!=CSW_M3 )
		engclient_cmd(iPlrId, "drop", "weapon_m3");
	if( s_iUserWeapons&(1<<CSW_M4A1) && iWeaponType!=CSW_M4A1 )
		engclient_cmd(iPlrId, "drop", "weapon_m4a1");
	if( s_iUserWeapons&(1<<CSW_TMP) && iWeaponType!=CSW_TMP )
		engclient_cmd(iPlrId, "drop", "weapon_tmp");
	if( s_iUserWeapons&(1<<CSW_G3SG1) && iWeaponType!=CSW_G3SG1 )
		engclient_cmd(iPlrId, "drop", "weapon_g3sg1");
	if( s_iUserWeapons&(1<<CSW_DEAGLE) && iWeaponType!=CSW_DEAGLE )
		engclient_cmd(iPlrId, "drop", "weapon_deagle");
	if( s_iUserWeapons&(1<<CSW_SG552) && iWeaponType!=CSW_SG552 )
		engclient_cmd(iPlrId, "drop", "weapon_sg552");
	if( s_iUserWeapons&(1<<CSW_AK47) && iWeaponType!=CSW_AK47 )
		engclient_cmd(iPlrId, "drop", "weapon_ak47");
	if( s_iUserWeapons&(1<<CSW_P90) && iWeaponType!=CSW_P90 )
		engclient_cmd(iPlrId, "drop", "weapon_p90");
	if( s_iUserWeapons&(1<<CSW_C4) && iWeaponType!=CSW_C4 )
		engclient_cmd(iPlrId, "drop", "weapon_c4");
}

ham_give_item(iPlrId, iClassName[]) // ham fowrad is useful, cause it doesn't emit no item sound
{
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, iClassName));
	if( iEnt<=0 || !pev_valid(iEnt) )
		return 0;
	
	set_pev(iEnt, pev_spawnflags, SF_NORESPAWN);
	dllfunc(DLLFunc_Spawn, iEnt);
	
	if( ExecuteHamB(Ham_AddPlayerItem, iPlrId, iEnt) )
	{
		ExecuteHamB(Ham_Item_AttachToPlayer, iEnt, iPlrId);
		return iEnt;
	}
	
	if( pev_valid(iEnt) )
		set_pev(iEnt, pev_flags, (pev(iEnt, pev_flags)|FL_KILLME));
	
	return -1;
}

fm_give_item(iPlrId, iClassName[]) // fakemeta forward is useful, cause it can be used with ammo_ items
{
	new iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, iClassName));
	if( !pev_valid(iEnt) )
		return 0;
	
	set_pev(iEnt, pev_spawnflags, (pev(iEnt, pev_spawnflags)|SF_NORESPAWN));
	dllfunc(DLLFunc_Spawn, iEnt);
	
	new iSolidType = pev(iEnt, pev_solid);
	dllfunc(DLLFunc_Touch, iEnt, iPlrId);
	if( pev(iEnt, pev_solid)!=iSolidType )
		return iEnt;
	
	set_pev(iEnt, pev_flags, (pev(iEnt, pev_flags)|FL_KILLME));
	
	return -1;
}

bool:is_player_connected(iPlrId)
{
	if( 0<iPlrId<=g_iMaxPlayers )
	{
		if( CheckPlayerBit(g_iConnected, iPlrId) )
			return true;
	}
	
	return false;
}

bool:SphereToCartesian(Float:fDest[3], Float:fOrigin[3], Float:fView[3], Float:fAngle[3])
{
	fView[1] *= (M_PI/180.0); // and now angle[0] and angle[1] has no effect?
	fView[0] *= (M_PI/180.0); // yes, this code is eDarks, so I don't remember why I added that comment above
	
	fAngle[0] *= (M_PI/-180.0);
	fAngle[1] *= (M_PI/180.0);
	
	static Float:s_fSin0, Float:s_fCos0, Float:s_fSin1, Float:s_fCos1;
	s_fSin0 = floatsin((fAngle[0]+(M_PI*0.5)), radian);
	
	fDest[0] = fAngle[2]*s_fSin0*floatcos(fAngle[1], radian);
	fDest[1] = fAngle[2]*s_fSin0*floatsin(fAngle[1], radian);
	fDest[2] = fAngle[2]*floatcos((fAngle[0]+(M_PI*0.5)), radian);
	
	
	s_fSin0 = floatsin(fView[0], radian);
	s_fCos0 = floatcos(fView[0], radian);
	s_fSin1 = floatsin(fView[1], radian);
	s_fCos1 = floatcos(fView[1], radian);
	
	static Float:s_fTemp[3];
	s_fTemp[0] = (fDest[0]*s_fCos0*s_fCos1)-(fDest[1]*s_fSin1)+(fDest[2]*s_fSin0*s_fCos1);
	s_fTemp[1] = (fDest[0]*s_fCos0*s_fSin1)+(fDest[1]*s_fCos1)+(fDest[2]*s_fSin1*s_fSin0);
	s_fTemp[2] = (fDest[2]*s_fCos0)-(fDest[0]*s_fSin0);
	
	fDest[0] = (fOrigin[0]+s_fTemp[0]);
	fDest[1] = (fOrigin[1]+s_fTemp[1]);
	fDest[2] = (fOrigin[2]-s_fTemp[2]);
	
	return true;
}
