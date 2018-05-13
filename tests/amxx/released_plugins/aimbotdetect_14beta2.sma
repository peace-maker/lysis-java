/*	
	Aimbot Detection
	   by bugsy

Console Commands:
 - amx_aimwatch		Enable\Disable watch on player. Call with no arguments to display active player watch.
			Usage: amx_aimwatch bugs 1 - Begin watching player
			       amx_aimwatch bugs 0 - Stop watching player  
			       amx_aimwatch        - Display currently watched player

 - amx_aimstatus	Display aimbot detection status for all connected players.
			Usage: amx_aimstatus
			
Required Modules:
 - FakeMeta
 - HamSandwich
 - CSX

Languages:
 - English	bugsy
 - Lithuanian	PauliusBa
 - Swedish	WildSoft
 - German	ExKiLL
 - Dutch	lucius

CVars:
 - amx_aimattempts	If bot is spawned (and not shot) [cvar#] times, the watch on player is removed.
 - amx_aimautowatch	Enable\Disable aimbot auto-watch option
 - amx_aimenable	Enable\Disable plugin

Forum thread:
   http://forums.alliedmods.net/showthread.php?t=77821

Credits:
   xOR,Owyn - Beta testing
   Misc help\ideas\bug reports: brad, alka, stupok, freamer, ehha, xor, mats, Lenfitz, WildSoft, joaquimandrade, .Owyn., Gizmo,
				supergreg, paulis8a
   
   There were many people in the amxx forum thread that contributed bug reports, comments, and suggestions about the plugin.
   Sorry if I left anyone out.
   
Change Log:
  v1.4beta2
  - Moved all code from client_authorized() to client_putinserver().
  - Removed GetMaxClipAmmo function and replaced with an array.
  - Fixed bug (hopefully) that was causing the detection bot to be partially visible (when set to 0 0 0)
  - Modified functions in which large static strings were being used, this reduced the total requirements of the 
    plugin at compile time from 104,724 to 80,396.
    
  v1.4beta
  - Changed the PrintColorMsg function to allow either printing to just 1 player or to all players. This replaced the need to have
    a for-loop throughout the code whenever a notify was needed. This function now handles all types of notification. To notify just
    one player, the id gets passed in the first param; to notify all players, a 0 is passed. This also fixed the bug where when a watch 
    is issued on a player he was notified in chat that he was being watched. 
  - Changed get_user_ip() usage; added 3rd param of 1 to omit the port. Previously the port was being retrieved and a strfind() was used
    to trim the port off of the retrieved IP\Port string.
  - Added ad_aw_admin cvar to control how auto-watch functions with admins. Set it to 0 to function as normal without paying any special
    consideration to admins. Set to 1 to skip admins. Set to 2 to disable auto-watch totally if any admins are on the server.
  - Added block in Ham_TakeDamage forward to make the bot not take damage if the aiming detection method is being used.
  - Added detection option that will use both the aiming and shooting method. When the detection bot is spawned, the plugin will monitor
    the amount of times the bot was shot and aimed at and then will calculate the percentage of aims-counted/aims-needed + shots-counted/
    shots-needed. If the sum of this is >= 1.0 then we count it as a detection.
  - It was brought to my attention that some aimbots will check whether a player is visible before deciding if it will act upon the player. 
    Added option to set the detection bots visibility via cvar ad_botcolor which is in RGB format. Default is "0 0 0" which is invisible. 
  - A bug was fixed that was causing an error with podbots. This fix is experimental, podbot users please report back to advise if this 
    is fixed.
  - Misc minor efficiency improvements
  
  v1.3b
  - Fixed bug where if you were using a shoot blanks punishment, all players would shoot blanks. Knives and grenades still did
    work. 
   
  v1.3a
  - Changed 1-line fm functions to macros
  - Fixed a bug where auto-watch may have been applied on players when it shouldn't have.
  - Fixed bug pointed out by xor which would cause an 'index out of bounds' error if you are using SHOOT_BLANKS_IP punishment and
    the player that was punished has an IP address with each octet 3 numbers long. ie. "255.255.255.255".
  - Added external config file. Location: amxmodx/configs/aimbotdetection.cfg
  - Reduced default ad_aimnumneeded to 2. 4 seemed a bit too high and I noticed if the player tried to drag his aim away from the bot
    he could avoid a detection. Being set to 2 has a much better chance of detecting the player.
  
  v1.3
  - Added a block so the plugin will not recognize the bot taking damage for detection if not inflicted by a bullet or if 
    not by the watched player. Previously, HAM_IGNORED was returnd which made the bot still take damage but not let the player 
    get detected; now HAM_SUPERCEDE is returned so all damage is ignored if not by the watched player and via a bullet. Also 
    added HAM_SUPERCEDE at the end of the takedamage forward so the bot will not get hurt even if shot by the watched player. 
    This will allow it to take an unlimited number of shots without dying.
  - Added blockage of bot being spawned if the watched players victim is killed with a grenade
  - Removed checking if victim ground distance is too close to killer. Now only the aiming angle is checked from the 
    watched player to the location where the bot will be spawned. If the bot spawn origin is outside of the acceptable angle 
    range, we do not spawn the bot. The angle ranges currently being used are (Angle <= 50) & (Angle >= 5). This solves the bug 
    where a player gets falsely detected because his gun is already in the aiming direction of where the bot is spawned. 
    This error has been reported a few times on cs_assault when the watched player is on the ground outside and has killed 
    an enemy that was standing on the roof. The player kills the enemy and then the bot gets spawned and hit by shots because
    the player is already aiming in the direction. Thanks to owyn for his reports and stupok for the angle calculation code.
  - Added colorization of the 'Aimbot Detection' chat header when a player is detectd. This will now appear in green, all other
    chat messages remain in normal chat color.
  - Owyn reported that some aimbot hacks will only aim at the other player if they have a weapon. When the bot is spawned it 
    is now given a deagle.
  - Added verbose mode cvar so you can now limit the amount of notification that is printed in chat. See enum below for levels.
  - Added a 2nd detection method. This new method will spawn the detection bot and check if the watched player is aiming at the 
    bot every 0.25 second for a total of (cvar ad_aimnumneeded [default 4]) checks. If the watched player was aiming at the bot 
    during each check, the player gets detected. To enable this method, set cvar ad_detectmethod to 1. Setting the detection 
    requirement cvar for this method (ad_aimnumneeded) will determine how long the bot stays on the server. The time is equal to
    the cvar value times 0.25 so for the default of 4 would be: 4 x 0.25 = 1 second. This method is still experimental

  v1.2
  - Removed get_user_attacker because of a bug that was causing the gun and hitzone params to return 0. Hitzones are now determined 
    via fakemeta call get_pdata_int(g_BotID, m_LastHitGroup). Re-added get_user_weapon to retrieve what weapon the bot was shot with 
    for determining hit-points.
  - Changed get\set origin to fakemeta; all origins are now floats.
  - Removed fun module; it was being used only for set_user_hitzones. Replaced with fm_set_user_hitzones (written by samurai),
    slightly edited. As with the ham forwards that are enabled\disabled when needed, the same is done for the fm_traceline forward 
    used in fm_set_user_hitzones. The forward is enabled if 1+ players have shootblanks punishment and is disabled when all
    shootblanks-punished players disconnect.
  - Removed HIT_GENERIC hitzone as it was added in an attempt to fix the v1.0-v1.1 hitzone bug. This bug was resolved via m_LastHitGroup.
  - Added priority-checking to applying auto-watches. When applying an auto watch, we first check players that have not yet passed
    a watch session. If no watchable players are found in the passed-watch players, we then check players that have previously passed 
    a watch.
  - Changed all configuration to cvar. See PUNISHMENT enum for setting punishment.
    
  v1.1
  - Multilingual support.
  - Added BAN_TIME to punishment config section so you can now specify how long a player gets banned. Default: 0 (permanent)
  - Fixed bug in Ham_Killed forward if-statement that was supposed to block if not watching a player but the code was still
    being executed causing invalid player index error. "if( !g_PlayerToWatch && " should have been "if( !g_PlayerToWatch || "
  - Added\adjusted blocking for when the victim and watched player are too close together and at a different height in the
    map (Z-coord). Per bug reported by .Owyn., a watched player was on top of a building, shooting down, killed his
    victim. The bot was then spawned and was hit by the players shots since the player was already aiming down at the bot.
    The bot will no longer be spawned if its Z coord will be >= watched-player-Z + 30. 
  - Removed get_user_weapon call in Ham_TakeDamage forward. Was using 2 separate functions to retrieve enemy weapon and 
    bot hitzones that were shot. Both of these are now retrieved with get_user_attacker.
  - Added HIT_GENERIC as a bot hitzone. While testing, I noticed at times I was shooting the bot multiple times, with each
    shot blood poured out of the bot, yet I was not getting detected. I determined that regardless of where the bot was shot, 
    get_user_attacker hitzone was always returning HIT_GENERIC. This is a strange and inconsistent bug that occurs randomly, 
    a simple mapchange usually fixes it. To reproduce this bug I keep doing map changes until I see HIT_GENERIC gets returned
    on bot all shots. By default I set GENERICHIT to the same value as a leg hit (1). This may be the cause of the problem some 
    users have of not seeing many detections. There is a demo in the forum thread on page 28 that shows this bug.
  - Removed LogDetection function, replaced with log_to_file native.
  - Added enabling\disabling of Ham TakeDamage and Ham_Killed forwards so they will only be active when needed. When a player 
    is being watched, the HamKilled forward is activated. When the bot is spawned, the TakeDamage forward is activated. When 
    the bot is removed or watch is stopped, the respective forward is disabled. Thanks to leonardofilipemartins on the forums
    for the tip.
  v1.0
  - Adjusted body hit-point values. Now to be detected, a total of 4 points must be reached. Head=4, chest=2, legs=1.
  - Fixed bug in kill\death ratio calculating in auto-watch checking. This ratio was always being returned true because 
    usage of float() was incorrect. 
  - Changed method for applying auto-watch. Now, each time auto-watch criteria is met, an auto-watch point is added to
    the players counter variable, g_AutoWatchPts[]. If the counter variable reaches AW_POINTSNEEDED (default 3), an 
    auto-watch gets applied to the player. This method also allows auto-watches to be queued because round stat ratios 
    will now be calculated even if there is already an on-going watch; previously stats were only checked at round-end 
    if there were no active watches. At the end of every round, if there is no active watch and a players auto-watch 
    counter variable is >= AW_POINTSNEEDED, an auto-watch will get applied to the player. 
  - Hits\Shots ratio was re-added for auto-watch ratio checking.
  - Auto-watch previously would only do ratio checking if there were a set constant number of players playing on the server. 
    Now, the plugin will check the # of enemies and only check ratios if the player has an appropriate % of round kills respective
    to the # of enemies. This allows accurate functionality on a server with any number of players. Below is the current config:
    [ ENEMIES ; KILLS NEEDED ] - [ <= 2 ; 100% ] [ > 2 & <= 4 ; 50% ] [ >=5 ; 33.3% ]
  - Added compatibility for custom-mods that do not use rounds. To use this method, set CUSTOMMOD to 1 and set CHECKINTERVAL 
    to your desired check interval (in seconds, default 3 minutes). This will make auto-watch check a players performance 
    statistics at each interval instead of at round-end. If you are using the plugin on counter-strike without any other 
    custom-mod installed then this change does not effect you. I have not fully tested this new method because I do not run
    these mods. If you have any issues please post to the forum.
  - Added amx_aimstatus command. This will display a MOTD with watch\detection\punishment info for all currently connected players.
  - Added variable to limit # of times an auto-watch can be applied to a player if he passes all detection tests. g_PassedWatch[id]
    holds the number of times player passed all tests within a watch and AW_MAXWATCHES is the max auto-watches that can be applied.
    If g_PassedWatch[id] reaches AW_MAXWATCHES, the player will no longer get auto-watched. A manual watch can still be applied. 
  - Changed the way we accept damage in the ham_takedamage forward; now we only register damage inflicted to the bot if via 
    bullet. Previously, it was accepting all damage except for grenade and knife. Per bug report from WildSoft, this was causing 
    a bug in WC3FT-mod servers because players explode; this explosion was killing the bot and registering it as a aimbot detection.
  - Added option of DETECTSNEEDED (default 1) aimbot detections needed for the player to be punished. If\when the watched 
    player shoots the bot and satisfies the 'detection' criteria, a counter is added to the detection variables; g_Detected holds
    the # of detections per aimbot-watch session, g_Detections[] holds each players entire # of detections per connection to the server.
    Upon a detection, if the counter is >= DETECTSNEEDED, the player gets punished. If you choose to punish with only 1 detection,  
    keep DETECTSNEEDED at the default of 1. Detections stick between multiple watches, the only time the detections variable gets 
    reset is when the player disconnects. I may make this save to the vault so, for example, if DETECTSNEEDED is set to 3 and a 
    player gets 2 detections on monday and then gets another detection on friday, he will then be punished on fridays detection. 
    This was added to make the plugin a bit more lenient\safe for 24/7 server usage for less false detections since a player would 
    need to be caught more than once to be punished. On the negative side, using a DETECTSNEEDED value higher than 1 can allow an 
    aimbot player to realize he is possibly getting caught (if using AUTOSHOOT) and can then turn off the aimbot and avoid detection. 
  - Removed array of bot names. Since the bot is on the server for such a short period of time, it really doesn't need a realistic name.
  - Changed variable used in Ham_TakeDamage forward from inflictor to attacker. Per the hamsandwich include, inflictor is the weapon
    that is inflicting the damage, not the player. The inflictor variable was functioning correctly because if the carrier of the weapon
    (inflictor) is the attacker, inflictor returns the player id of attacker.
  - Removed email option.
  - Added ability to start an aimbot watch on a player while there is already an existing watch. When this happens, the current watch
    is stopped and the new watch is started.
  - Removed multiple RemoveBot calls. Now the bot will only be removed via the task set in HamKilled forward. This was causing an issue
    with the timing of the bot being removed and deathmsg display. At times, a deathmsg was being displayed when the bot was killed 
    because g_BotID was being reset before the hlengine went to display the deathmsg.
  - Fixed the way StatusText was blocked. Occasionally the bots name was showing when being aimed at. 
*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <csx>

new const Version[] = "1.4beta2";

//Comment the below line if you are not testing the plugin. When testing, plugin action info is printed to all players
//#define TESTING

enum _:PUNISHMENT
{
	LOG_ONLY = 0,
	KICK_ONLY,
	KICK_AND_BANID,
	KICK_AND_BANIP,
	KICK_AND_AMXBAN,
	SHOOT_BLANKS_ID,
	SHOOT_BLANKS_IP,
}

enum _:VERBOSE_MODE
{
	VERBOSE_0 = 0,
	VERBOSE_1,
	VERBOSE_2,
	VERBOSE_3
}
 
enum _:MESSAGE_TYPE
{
	NORMAL_MSG = 0,
	COLOR_MSG
}

enum _:DETECT_METHOD
{
	DETECT_SHOTS = 0,
	DETECT_AIMING,
	DETECT_BOTH
}

enum _:AW_ADMIN_PRESENT
{
	NOACTION = 0,
	IGNORE_ADMINS,
	DISABLE_AUTOWATCH
}

enum _:TEAMS
{
	TERRORIST = 1,
	CT
}

//Fakemeta
#define EXTRAOFFSET_WEAPONS	4 
#define OFFSET_CLIPAMMO		51 
#define OFFSET_TEAM		114
#define m_LastHitGroup		75
#define	m_bitsDamageType	76

//Macros
#define	fm_find_ent_by_class(%1,%2)	engfunc(EngFunc_FindEntityByString, %1, "classname", %2)
#define fm_cs_get_user_team(%1)		get_pdata_int(%1, OFFSET_TEAM)
#define fm_cs_get_weapon_ammo(%1)	get_pdata_int(%1, OFFSET_CLIPAMMO, EXTRAOFFSET_WEAPONS)
#define fm_cs_set_weapon_ammo(%1,%2)	set_pdata_int(%1, OFFSET_CLIPAMMO, %2, EXTRAOFFSET_WEAPONS)
#define IsPlayer(%1)			(1<=%1<=g_MaxClients)

//Task-id's for use with set_task\remove_task
#define TASK_AUTOSHOOT		8581
#define	TASK_REMOVEBOT		1812
#define TASK_CHECKAIM		1218

//Command\Notify admin flags
#define FLAG_NOTIFY	ADMIN_RCON	//Admin level required to be notified of plugin actions
#define FLAG_COMMAND	ADMIN_RCON	// . . . . . . . . . . to use commands

//For detecting grenade damage
#define DMG_GRENADE		(1<<24)

//  **** Global Variables ****
new g_PlayerToWatch	//id of player being watched
new g_BotID		//id of detection bot
new g_MaxClients	//Max # of clients the server allows
new g_HitPoints		//Counts hit area points when bot is shot; [head = 4] [mid-body = 2] [legs = 1] - [4+ = punishment]
new g_AimPoints		//Counts number of times player caught aiming at bot
new g_AimChecks		//Number of times player was checked if aiming at bot
new g_AimPasses		//# times bot spawned and player does not shoot bot. If reaches amx_aimattempts, aimbot watch removed & g_PassedWatch[id]++	
new g_Detected		//# times bot spawned and player detected.
new bool:g_bModSet	//Set to true when first player connects and the appropriate RoundEnd checking method is set for autowatch.
new g_Admins		//Bit-field for online admin id's
new g_msgTeamInfo	//TeamInfo message id
new g_msgSayText	//SayText message id

new g_PassedWatch[ 33 ]		//# times player passed [amx_aimattempts] tests. If reaches AW_MAXWATCHES, player will no longer get autowatched.		
new g_Detections[ 33 ]		//# of times a player has hit bot and been detected. Needs to be >= DETECTSNEEDED detections to be punished.
new bool:g_bPunished[ 33 ]	//Players that were detected and punished. (used only for non-kick\ban punishments)
new g_AutoWatchPts[ 33 ]		//Number of times player has met auto-watch criteria. If reaches AW_POINTSNEEDED, autowatch gets applied
new g_AutoWatched[ 33 ]		//Counts # times a player has been auto-watched
new g_RoundKills[ 33 ]		//Count round kills
new g_HeadshotKills[ 33 ]	//Count number of round kills via headshot.
new bool:g_bAdminNotify[ 33 ]	//Set to true for admins with NOTIFY access @ client_authorized. This will be used for all admin notifications.
new bool:g_bShootsBlanks[ 33 ]	//Set to true if player shoots blanks
new g_NumShootsBlanks		//Stores # of players who currently shoot blanks. Used to enable\disable traceline forward
new g_BodyHits[ 33 ][ 33 ]	//For fm_set_user_hitzones

new const MaxClipAmmo[ CSW_P90 + 1 ] =
{
	0,   //empty
	13,  //p228
	0,   //empty
	10,  //scout
	0,   //hegrenade
	7,   //xm1014
	0,   //c4
	30,  //mac10
	30,  //aug
	0,   //smokegrenade
	15,  //elite
	20,  //fiveseven
	25,  //ump45
	30,  //sg550
	35,  //galil
	25,  //famas
	12,  //usp
	20,  //glock
	10,  //awp
	30,  //mp5navy
	100, //m249
	8,   //m3
	30,  //m4a1
	30,  //tmp
	20,  //g3sg1
	0,   //flashbang
	7,   //deagle
	30,  //sg552
	30,  //ak47
	0,   //knife
	50,  //p90
}

//Handles for Ham\FM forwards
new HamHook:g_Ham_TakeDamage
new HamHook:g_Ham_Killed_Player
new g_FM_TraceLine

//CVAR pointers
new g_pAimAttempts
new g_pAutoWatch
new g_pEnabled
new g_pVerboseMode
new g_pPunishment
new g_pBotColor
new g_pDetectsNeeded
new g_pBanTime
new g_pDetectMethod
new g_pBotStayTime
new g_pForceShoot
new g_pCustomMod
new g_pAWAdmin
new g_pCheckInterval
new g_pAWRRoundKills
new g_pAWRKillDeath
new g_pAWRHitsShots
new g_pAWRHSKill
new g_pAWRHeadBody
new g_pAWRChestBody
new g_pAWPKillDeath
new g_pAWPHitsShots
new g_pAWPHSKill
new g_pAWPHeadBody
new g_pAWPChestBody
new g_pAWPRPointsNeeded
new g_pAWPointsNeeded
new g_pAWMaxAutoWatches
new g_pAimNumNeeded	 		
new g_pHPHead
new g_pHPMidBody
new g_pHPLegs
new g_pHPHitsNeeded

public plugin_init() 
{
	register_plugin( "Aimbot Detection" , Version , "bugsy" )
	register_cvar( "aimbot_detection" , Version , FCVAR_SERVER )
	
	register_dictionary( "aimbotdetect.txt" )
	
	register_concmd( "amx_aimwatch" , "WatchPlayer" , FLAG_COMMAND , "<player> <1=On 0=Off> - Add\Remove aimbot watch on player." )
	register_concmd( "amx_aimstatus" ,"ShowStatus"  , FLAG_COMMAND , "- Show aimbot detection plugin status." )
 
	register_message( get_user_msgid( "DeathMsg" ) , "fwDeathMsg" )
	register_message( get_user_msgid( "StatusValue" ) , "fwStatusValue" )

	g_Ham_TakeDamage = RegisterHam( Ham_TakeDamage , "player" , "fw_HamTakeDamage" )
	g_Ham_Killed_Player = RegisterHam( Ham_Killed , "player" , "fw_HamKilled" )
	DisableHamForward( g_Ham_TakeDamage )
	DisableHamForward( g_Ham_Killed_Player )

	g_pEnabled = register_cvar( "ad_enabled" , "1" )	
	g_pAutoWatch = register_cvar( "ad_autowatch" , "1" )
	g_pVerboseMode = register_cvar("ad_verbosemode" , "3" )
	g_pDetectMethod = register_cvar( "ad_detectmethod" , "2" )	
	g_pDetectsNeeded = register_cvar( "ad_detectsneeded" , "1" )
	g_pAimAttempts = register_cvar( "ad_aimattempts" , "3" )
	g_pPunishment = register_cvar( "ad_punishment" , "0" )
	g_pBotColor = register_cvar( "ad_botcolor" , "0 0 0" )
	g_pBanTime = register_cvar( "ad_bantime" , "0" )	
	g_pAWAdmin = register_cvar( "ad_aw_admin" , "0" )
	g_pCustomMod = register_cvar( "ad_custommod" , "0" )	
	g_pCheckInterval = register_cvar( "ad_checkinterval" , "180.0" )
	g_pAWRRoundKills = register_cvar( "ad_awr_roundkills" , "0.33" )
	g_pAWRKillDeath = register_cvar( "ad_awr_killdeath" , "3.0" )
	g_pAWRHitsShots = register_cvar( "ad_awr_hitsshots" , "0.4" )
	g_pAWRHSKill = register_cvar( "ad_awr_hskill" , "0.5" )
	g_pAWRHeadBody = register_cvar( "ad_awr_headbody" , "0.33" )
	g_pAWRChestBody = register_cvar( "ad_awr_chestbody" , "0.6" )
	g_pAWPKillDeath = register_cvar( "ad_awp_killdeath" , "1" )	
	g_pAWPHitsShots = register_cvar( "ad_awp_hitsshots" , "1" )
	g_pAWPHSKill = register_cvar( "ad_awp_hskill" , "1" )
	g_pAWPHeadBody = register_cvar( "ad_awp_headbody" , "1" )
	g_pAWPChestBody = register_cvar( "ad_awp_chestbody" , "1" )	
	g_pAWPRPointsNeeded = register_cvar( "ad_awp_rpointsneeded" , "3" )	
	g_pAWMaxAutoWatches = register_cvar( "ad_aw_maxautowatches" , "2" )
	g_pAWPointsNeeded = register_cvar( "ad_aw_pointsneeded" , "3" )	
	g_pAimNumNeeded = register_cvar( "ad_aimnumneeded" , "3" )
	g_pBotStayTime = register_cvar( "ad_botstaytime" , "1.5" )
	g_pForceShoot = register_cvar( "ad_forceshoot" , "1" )
	g_pHPHead = register_cvar( "ad_hp_head" , "4" )	
	g_pHPMidBody = register_cvar( "ad_hp_midbody" , "2" )	
	g_pHPLegs = register_cvar( "ad_hp_legs" , "1" )	
	g_pHPHitsNeeded = register_cvar( "ad_hp_hitsneeded" , "4" )	
	
	g_MaxClients = get_maxplayers()
	g_msgSayText = get_user_msgid( "SayText" )
	g_msgTeamInfo = get_user_msgid( "TeamInfo" )
}

public plugin_cfg()
{
	new szConfigDir[ 64 ]
	
	get_configsdir( szConfigDir , 63 )
	server_cmd( "exec %s/aimbotdetection.cfg" , szConfigDir ) 
	server_exec()
}

public client_putinserver( id )
{	
	if ( !get_pcvar_num( g_pEnabled ) || is_user_bot( id ) )
		return PLUGIN_CONTINUE

	if ( !g_bModSet && get_pcvar_num( g_pAutoWatch ) )
	{
		g_bModSet = true

		if ( !get_pcvar_num( g_pCustomMod ) )
			register_logevent( "fwRoundEnd" , 2 , "1=Round_End" )
		else
			set_task( get_pcvar_float( g_pCheckInterval ) , "fwRoundEnd", _, _, _, "b" )
	}
	
	//Set the users notify flag here so we do not have to do an admin and flag check for each chat notify.
	if ( is_user_admin( id ) )
	{
		g_Admins |= ( 1 << ( id & 31 ) )
		g_bAdminNotify[ id ] = bool:!!( get_user_flags( id ) & FLAG_NOTIFY )
	
		//An admin has connected and there is a current watch; notify the admin.
		if ( g_PlayerToWatch && g_bAdminNotify[ id ] && ( get_pcvar_num( g_pVerboseMode) >= VERBOSE_2 ) )
			set_task( 7.0 , "NotifyAdmin" , id )
	}
	
	if ( ( get_pcvar_num( g_pPunishment ) >= SHOOT_BLANKS_ID ) && ShootsBlanks( id ) )
	{		
		g_bPunished[ id ] = true
		
		if ( get_pcvar_num( g_pVerboseMode ) == VERBOSE_3 )
		{
			new szName[ 33 ];
			get_user_name( id , szName , charsmax( szName ) )
			PrintColorMsg( 0 , NORMAL_MSG , "%L" , LANG_PLAYER , "AIMBOTDETECT_SHOOTBLANKSREAPPLIED" , szName )
		}
	
		if ( !g_FM_TraceLine )
			g_FM_TraceLine = register_forward( FM_TraceLine , "fw_TraceLine" , 1 )
	
		g_NumShootsBlanks++
		g_bShootsBlanks[ id ] = true;
		fm_set_user_hitzones( id , 0 , 0 )
	}
	
	return PLUGIN_CONTINUE
}

public client_disconnect( id )
{
	if ( !get_pcvar_num( g_pEnabled ) || is_user_bot( id ) )
		return PLUGIN_CONTINUE
		
	static szName[ 33 ]

	//Disconnecting player is admin, remove his id from bitfield (if exists)
	g_Admins &= ~( 1 << ( id & 31 ) )
		
	g_bPunished[ id ] = false
	g_AutoWatchPts[ id ] = 0
	g_AutoWatched[ id ] = 0
	g_PassedWatch[ id ] = 0
	g_Detections[ id ] = 0
	g_RoundKills[ id ] = 0
	g_HeadshotKills[ id ] = 0
	g_bAdminNotify[ id ] = false
	
	fm_hitzones_reset( id )
	
	//If shoot-blanks punishment is enabled, we re-apply the punishment if the player re-connects.
	if ( g_bShootsBlanks[ id ] && ( get_pcvar_num( g_pPunishment ) >= SHOOT_BLANKS_ID ) )
	{
		g_NumShootsBlanks--
		g_bShootsBlanks[ id ] = false

		if ( !g_NumShootsBlanks && g_FM_TraceLine )
		{
			unregister_forward( FM_TraceLine , g_FM_TraceLine )
			g_FM_TraceLine = 0
		}
	}

	//Our watched player has disconnected, disable aimbot watch on him.
	if ( id == g_PlayerToWatch )
	{
		if ( get_pcvar_num( g_pVerboseMode ) == VERBOSE_3 )
		{
			get_user_name( id , szName , charsmax( szName ) )
			PrintColorMsg( 0 , NORMAL_MSG , "%L" , LANG_PLAYER , "AIMBOTDETECT_DISCONNECT" , szName )
		}
		
		DisableHamForward( g_Ham_Killed_Player )
		
		g_PlayerToWatch = 0
	}

	return PLUGIN_CONTINUE
}

public NotifyAdmin( id )
{
	if ( is_user_connected( id ) && is_user_connected( g_PlayerToWatch ) )
	{
		static szName[ 33 ]
		get_user_name( g_PlayerToWatch , szName , charsmax( szName ) )
		PrintColorMsg( id , NORMAL_MSG , "%L" , LANG_PLAYER , "AIMBOTDETECT_NOTIFYADMIN" , szName )
	}
}

public fwRoundEnd()
{
	new iAdminVal = get_pcvar_num( g_pAWAdmin )
	
	//We do not want to auto-watch check if the plugin or auto-watch is disabled.
	if ( !get_pcvar_num( g_pEnabled ) ||  				//Plugin disabled  OR
		!get_pcvar_num( g_pAutoWatch ) || 			//Autowatch disabled  OR
		( g_Admins && ( iAdminVal == DISABLE_AUTOWATCH ) ) )	//An admin is present and DISABLE_AUTOWATCH option is set
		return PLUGIN_HANDLED

	new iPlayers[ 32 ] , iPlayer , iT , iCT , iNum , iTeam
	
	//Get # of players on each team
	get_players( iPlayers , iT  ,"e" ,"TERRORIST" )
	get_players( iPlayers , iCT ,"e" ,"CT" )
	get_players( iPlayers , iNum , "c" )
	
	for ( new i = 0 ; i < iNum ; i++ )
	{
		iPlayer = iPlayers[ i ]
		iTeam = fm_cs_get_user_team( iPlayer );
		
		if ( ( iPlayer != g_PlayerToWatch ) && //Player not currently being watched
			!g_bPunished[ iPlayer ] && //Player has not yet been punished
			( TERRORIST <= iTeam <= CT ) && //Player is on a team
			( !( (g_Admins & ( 1 << ( iPlayer & 31 ) ) ) && ( iAdminVal == IGNORE_ADMINS ) ) ) && //Player is not an admin if IGNORE_ADMINS option is set
			( g_PassedWatch[ iPlayer ] < get_pcvar_num( g_pAWMaxAutoWatches ) ) ) //Player has not passed AW_MAXWATCHES watch sessions.
		{
			AutoWatchCheck( iPlayer , ( iTeam == TERRORIST ) ? iT : iCT )
	
			//Reset round-counter vars
			g_RoundKills[ iPlayer ] = 0
			g_HeadshotKills[ iPlayer ] = 0
		}
	}

	if ( g_PlayerToWatch )
		return PLUGIN_CONTINUE
		
	//Go through all players twice. The first time around we are looking at players who have not yet passed an aimbot watch session.
	//If no players are being watched after the first loop, we check players who have already passed a watch on the 2nd loop.
	//This will make players who have not yet passed an aimwatch at a higher priority.
	new szName[ 33 ]
	
	for ( new iPassedWatch = 0 ; iPassedWatch <= 1 ; iPassedWatch++ )
	{
		for ( new i = 0 ; i < iNum ; i++ )
		{
			iPlayer = iPlayers[ i ]

			if ( ( ( !iPassedWatch && !g_PassedWatch[ iPlayer ] ) ||					//First pass and current player has not yet passed an autowatch session OR
				( iPassedWatch && g_PassedWatch[ iPlayer ] ) ) && 				//Second pass and player has passed an autowatch session ) AND
					( g_AutoWatchPts[ iPlayer ] >= get_pcvar_num( g_pAWPointsNeeded ) ) )	//Player has accumulated enough points to get autowatched 
			{	
				g_PlayerToWatch = iPlayer
			
				EnableHamForward( g_Ham_Killed_Player )
				
				g_AimPasses = 0
				g_Detected = 0
		
				g_AutoWatched[ g_PlayerToWatch ]++
				g_AutoWatchPts[ g_PlayerToWatch ] = 0
	
				if ( get_pcvar_num( g_pVerboseMode ) >= VERBOSE_2 )
				{
					get_user_name( g_PlayerToWatch , szName , charsmax( szName ) )
					PrintColorMsg( 0 , NORMAL_MSG , "%L" , LANG_PLAYER , "AIMBOTDETECT_AWNOWWATCHING" , szName )
				}
				
				#if defined TESTING
				client_print( 0 , print_chat, "[Testing] Applying. iPassedWatch=%d" , iPassedWatch )
				#endif
				
				return PLUGIN_CONTINUE
			}
		}
	}
	
	return PLUGIN_CONTINUE
}

public AddBot()
{		
	new szTeam[ 2 ] , szName[ 6 ] , szRejectReason[ 128 ]
	
	formatex( szName , 5 , "xyz%2d" , random_num( 10 , 99 ) )
	g_BotID = engfunc( EngFunc_CreateFakeClient , szName )
	
	if ( !g_BotID ) 
		return PLUGIN_HANDLED
	
	engfunc( EngFunc_FreeEntPrivateData, g_BotID )
	dllfunc( DLLFunc_ClientConnect , g_BotID , szName , "127.0.0.1" , szRejectReason )
	dllfunc( DLLFunc_ClientPutInServer , g_BotID )
	set_pev( g_BotID , pev_spawnflags, pev( g_BotID , pev_spawnflags ) | FL_FAKECLIENT )
	set_pev( g_BotID , pev_flags , pev( g_BotID , pev_flags ) | FL_FAKECLIENT )

	//Bot created, assign to appropriate team. 
	num_to_str( ( fm_cs_get_user_team( g_PlayerToWatch ) == TERRORIST ) ? CT : TERRORIST , szTeam , charsmax( szTeam ) );
	
	engclient_cmd( g_BotID , "jointeam" , szTeam )
	engclient_cmd( g_BotID , "joinclass" , "1" )
	
	//Spawn bot
	fm_user_spawn( g_BotID )
	
	//Make bot invisible
	new szRGB[ 12 ] , szRed[ 4 ] , szGreen[ 4 ] , szBlue[ 4 ] , bool:bInvisible
	get_pcvar_string( g_pBotColor , szRGB , charsmax( szRGB ) )
	trim( szRGB )
	parse( szRGB , szRed , charsmax( szRed ) , szGreen , charsmax( szGreen ) , szBlue , charsmax( szBlue ) )
	
	bInvisible = bool:equal( szRGB , "0 0 0" );
	
	#if defined TESTING 
	fm_set_rendering( g_BotID , kRenderFxNone , 255 , 255 , 255  , kRenderNormal , 16 )
	#else
	fm_set_rendering( g_BotID , kRenderFxNone , clamp( str_to_num( szRed ) , 0 , 255 ) , clamp( str_to_num( szGreen ) , 0 , 255 ) , clamp( str_to_num( szBlue ) , 0 , 255 ) , bInvisible ? kRenderTransAlpha : kRenderNormal , bInvisible ? 0 : 16 )
	#endif
	
	//Make our bot appear as a spectator on scoreboard
	message_begin( MSG_ALL , g_msgTeamInfo , _ , 0 )
	write_byte( g_BotID )
	write_string( "SPECTATOR" )
	message_end()

	EnableHamForward( g_Ham_TakeDamage )

	return PLUGIN_HANDLED
}


public RemoveBot() 
{
	if ( !g_BotID )
		return PLUGIN_HANDLED
	
	new iDetectMethod = get_pcvar_num( g_pDetectMethod )
	new Float: fTotalDetectPoints
	
	remove_task( TASK_AUTOSHOOT )
	remove_task( TASK_CHECKAIM )
	
	//The bot did not take any damage nor was it aimed at so we give the player an aimpass point.
	//This adds to the variable that counts how many times the detection test was passed.
	//Once the cvar is reached, we remove the aimbot watch from the player.
	if ( !g_HitPoints && !g_AimPoints )
	{
		g_AimPasses++

		if ( g_AimPasses == get_pcvar_num( g_pAimAttempts ) )
		{ 
			new szName[ 33 ]
			
			g_PassedWatch[ g_PlayerToWatch ]++

			get_user_name( g_PlayerToWatch , szName , charsmax( szName ) )
			
			if ( get_pcvar_num( g_pVerboseMode ) >= VERBOSE_2 )
			{
				PrintColorMsg( 0 , NORMAL_MSG , "%L" , LANG_PLAYER , "AIMBOTDETECT_PASSEDALL" , szName )
				
				if ( (g_PassedWatch[ g_PlayerToWatch ] >= get_pcvar_num( g_pAWMaxAutoWatches ) ) && get_pcvar_num( g_pAutoWatch ) )
					PrintColorMsg( 0 , NORMAL_MSG , "%L" , LANG_PLAYER , "AIMBOTDETECT_NOAUTOWATCH" , szName , g_PassedWatch[ g_PlayerToWatch ] )
			}
			
			DisableHamForward( g_Ham_Killed_Player )
			g_PlayerToWatch = 0
		}
	}
	//The bot was aimed at or hit, if detect-both is being used we check the ratios of bot hits and aims and if
	//it combines to 100% then we consider the player detected.
	else 
	{
		if ( iDetectMethod == DETECT_BOTH )
		{
			fTotalDetectPoints = float( g_HitPoints ) / get_pcvar_float( g_pHPHitsNeeded ) 
			fTotalDetectPoints += float( g_AimPoints ) / get_pcvar_float( g_pAimNumNeeded )
			
			#if defined TESTING	
			client_print( g_PlayerToWatch , print_chat , "HitPoints=%d/%d AimPoints=%d/%d" , g_HitPoints  , get_pcvar_num( g_pHPHitsNeeded )  , g_AimPoints , get_pcvar_num( g_pAimNumNeeded ) )
			client_print( g_PlayerToWatch , print_chat , "%f = hits=%f + aims=%f" , fTotalDetectPoints , float( g_HitPoints ) / get_pcvar_float( g_pHPHitsNeeded )  , float( g_AimPoints ) / get_pcvar_float( g_pAimNumNeeded ) )
			#endif
			
			if ( fTotalDetectPoints >= 1.0 )
				AddDetection()
		}
	}
	
	DisableHamForward( g_Ham_TakeDamage )

	//Fix podbot bug?
	fm_set_user_rendering( g_BotID , kRenderFxNone , 255 , 255 , 255 , kRenderNormal , 16 );
	
	server_cmd( "kick #%d" , get_user_userid( g_BotID ) )
	
	g_BotID = 0
	
	return PLUGIN_HANDLED
}
 
public ShowStatus( id , level , cid )
{
	if ( !cmd_access( id , level , cid , 1 ) )
		return PLUGIN_HANDLED;
	
	if ( !get_pcvar_num( g_pEnabled ) )
	{
		console_print( id , "[Aimbot Detector] %L" , LANG_PLAYER , "AIMBOTDETECT_DISABLED" );
		return PLUGIN_HANDLED;
	}

	static szMOTD[ 106 ];
	new iPlayers[ 32 ] , iPlayersNum , iPlayer;
	new szName[ 33 ];

	if ( file_exists( "tmpStatus.txt" ) )
		delete_file( "tmpStatus.txt" );
		
	write_file( "tmpStatus.txt" , "<html><body bgcolor=#000000><font size=3><pre>" );
	
	formatex( szMOTD , charsmax( szMOTD ) ,"<font color=white><b>%3s %-33.33s %13s %11s %9s</b></font>" , "#" , "Name" , "Auto-Watches" , "Detections" , "Punished" );
	write_file( "tmpStatus.txt" , szMOTD );
	
	get_players( iPlayers , iPlayersNum , "c" );
	for ( new i = 0 ; i < iPlayersNum ; i++ )
	{
		iPlayer = iPlayers[ i ];
		get_user_name( iPlayer , szName , charsmax( szName ) );
		formatex( szMOTD , charsmax( szMOTD ) , "<font color=#0099FF>%2d. %-33.33s %-13.13d %-11.11d %-3.3s</font>" , i+1 , szName , g_AutoWatched[ iPlayer ] , g_Detections[ iPlayer ] , g_bPunished[ iPlayer ] ? "Yes" : "No" );
		write_file( "tmpStatus.txt" , szMOTD );
	}

	formatex( szMOTD , charsmax( szMOTD ) , "</pre></font></body></html>" );
	write_file( "tmpStatus.txt" , szMOTD );
	
	show_motd( id , "tmpStatus.txt" , "Aimbot Detection Status" );
	
	return PLUGIN_HANDLED;
}


public WatchPlayer( id , level , cid )
{
	if ( !cmd_access( id , level , cid , 1 ) )
		return PLUGIN_HANDLED
	
	if ( !get_pcvar_num( g_pEnabled ) )
	{
		console_print( id , "[Aimbot Detector] %L" , LANG_PLAYER , "AIMBOTDETECT_DISABLED" )
		return PLUGIN_HANDLED
	}
	
	new szName[ 33 ]
	new iArgs = read_argc()

	//No arguments were passed so the user is checking active watches
	if ( iArgs == 1 )
	{
		if ( g_PlayerToWatch )
		{
			get_user_name( g_PlayerToWatch , szName , charsmax( szName ) )
			console_print( id , "[Aimbot Detector] %L" , LANG_PLAYER , "AIMBOTDETECT_CURRENTWATCH" , szName )
		}
		else
		{
			console_print( id , "[Aimbot Detector] %L" , LANG_PLAYER , "AIMBOTDETECT_NOPLAYERWATCH" )
		}

		return PLUGIN_HANDLED
	}
	else if ( ( iArgs != 1 ) && ( read_argc() != 3 ) )
	{
		console_print( id , "[Aimbot Detector] %L" , LANG_PLAYER , "AIMBOTDETECT_PROPERUSAGE" )
		return PLUGIN_HANDLED
	}
	
	new szVal[ 2 ]
	
	//Read player name and enable\disable value
	read_argv( 1 , szName , 32 )
	read_argv( 2 , szVal , 1 )
	
	new iPlayer = cmd_target( id , szName , 8 )
	
	if ( !iPlayer || !is_user_connected(iPlayer) )
		return PLUGIN_HANDLED
	
	get_user_name( iPlayer , szName , charsmax( szName ) )
	
	//Enable monitoring on player
	if ( szVal[ 0 ] == '1' )
	{
		//Admin is trying to initiate a new watch and there is already an existing watch. We either advise that the selected
		//player is already being watched, or remove the watch from the current player and assign it to the new player.
		if ( g_PlayerToWatch )
		{
			if ( iPlayer == g_PlayerToWatch  )
			{
				console_print( id , "[Aimbot Detector] %L" , LANG_PLAYER , "AIMBOTDETECT_ALREADYWATCHING" , szName )
				return PLUGIN_HANDLED
			}
			else
			{
				new szWatchName[ 33 ]
				get_user_name( g_PlayerToWatch , szWatchName, charsmax( szWatchName ) )
				console_print( id , "[Aimbot Detector] %L" , LANG_PLAYER , "AIMBOTDETECT_MONITORINGSTOPPED" , szWatchName )
				
				if ( get_pcvar_num( g_pVerboseMode) >= VERBOSE_2 )
					PrintColorMsg( 0 , NORMAL_MSG ,"%L", LANG_PLAYER, "AIMBOTDETECT_MONITORINGSTOPPED" , szWatchName  )
			}
		}
		
		console_print(id , "[Aimbot Detector] %L" , LANG_PLAYER , "AIMBOTDETECT_NOWMONITORING" , szName )
		
		if ( get_pcvar_num( g_pVerboseMode ) >= VERBOSE_2 )
			PrintColorMsg( 0 , NORMAL_MSG ,"%L" , LANG_PLAYER , "AIMBOTDETECT_NOWMONITORING" , szName )
		
		g_PlayerToWatch = iPlayer
		
		EnableHamForward( g_Ham_Killed_Player )
	}
	else if ( szVal[ 0 ] == '0' )
	{
		if ( !g_PlayerToWatch )
		{
			console_print( id , "[Aimbot Detector] %L" , LANG_PLAYER , "AIMBOTDETECT_NOPLAYERWATCH" )
			return PLUGIN_HANDLED
		}
		else if ( iPlayer != g_PlayerToWatch )
		{
			console_print( id , "[Aimbot Detector] %L" , LANG_PLAYER , "AIMBOTDETECT_NOTWATCHING" , szName )
			return PLUGIN_HANDLED
		}
			
		console_print( id , "[Aimbot Detector] %L" , LANG_PLAYER , "AIMBOTDETECT_NOLONGERMONITOR" , szName )
		
		if ( get_pcvar_num( g_pVerboseMode ) >= VERBOSE_2 )
			PrintColorMsg( 0 , NORMAL_MSG ,"%L" , LANG_PLAYER , "AIMBOTDETECT_NOLONGERMONITOR" , szName  )
			
		DisableHamForward( g_Ham_Killed_Player )
		g_PlayerToWatch = 0
	}
	
	//Whether we are setting a new watch or removing a watch, we reset the counter variables.
	g_RoundKills[ iPlayer ] = 0
	g_HeadshotKills[ iPlayer ] = 0
	g_AutoWatchPts[ iPlayer ] = 0
	g_Detected = 0
	g_AimPasses = 0

	return PLUGIN_HANDLED
}

public AddDetection( )
{
	new szName[ 33 ]
	
	get_user_name( g_PlayerToWatch , szName , charsmax( szName ) )
	
	//To avoid multiple detections within the same bot spawn, set the hit-point counter variable to
	//a value that will not allow it to reach HITSNEEDED again.
	g_HitPoints = -100
	
	//Add a detection to the current auto-watch counter.
	g_Detected++
	
	//Add a detection to players total detection counter
	g_Detections[ g_PlayerToWatch ]++
	
	//Enough detections have occurred to warrant a punishment
	if ( g_Detected >= get_pcvar_num( g_pDetectsNeeded ) )
	{
		if ( get_pcvar_num( g_pVerboseMode ) )
			PrintColorMsg( 0 , COLOR_MSG ,"%L" , LANG_PLAYER , "AIMBOTDETECT_ISUSINGAIMBOT" , szName  )
			
		Punish( g_PlayerToWatch )
		
		//Disable watch on our punished player
		DisableHamForward( g_Ham_Killed_Player )
		g_PlayerToWatch = 0
	}
	else
	{
		//More than 1 detection is required  before issuing a punishment. This will notify admins that 
		//the player was detected and how many more detections are needed for punishment
		if ( get_pcvar_num( g_pVerboseMode ) )
		{
			PrintColorMsg( 0 , COLOR_MSG , "%L" , LANG_PLAYER , "AIMBOTDETECT_PLR_DETECTED" , szName )
			PrintColorMsg( 0 , COLOR_MSG , "%L" , LANG_PLAYER , "AIMBOTDETECT_MOREDETECTIONS" , get_pcvar_num( g_pDetectsNeeded ) - g_Detected , ( ( get_pcvar_num( g_pDetectsNeeded ) - g_Detected ) > 1 ) ? "s" : "" )
		}
	}
}

public AutoWatchCheck( id , iNumEnemies )
{	
/*      [iStats]	 [iBHits]
	0 - kills        0 - Generic 
	1 - deaths       1 - Head 
	2 - headshots    2 - Chest	
	4 - shots 	 3 - Stomach 
	5 - hits 	 4 - LeftArm
			 5 - RightArm
			 6 - LeftLeg 
			 7 - RightLeg */

	new iPoints , iBodyHits
	new iStats[ 8 ] , iBHits[ 8 ]
	new iKills , iDeaths
	new i
	
	get_user_rstats( id , iStats , iBHits ) 
	iKills = get_user_frags( id )
	iDeaths = get_user_deaths( id )	
	
	//Kill/Death ratio.
	//If has 10+ kills and 1+ deaths, ratio is calculated
	//If has 10+ kills and 0 deaths, ratio is automatically met
	if ( iKills >= 10 )
	{
		if ( iDeaths )
		{
			if ( ( float( iKills ) / float( iDeaths ) ) >= get_pcvar_float( g_pAWRKillDeath ) ) 
			{
				iPoints += get_pcvar_num( g_pAWPKillDeath )

				#if defined TESTING	
				client_print( 0 , print_chat , "*[Testing] Kill\Death ratio met. %d kills, %d deaths. Ratio pts=%d" , iKills, iDeaths, iPoints )
				#endif
			}
		}
		else
		{
			iPoints += get_pcvar_num( g_pAWPKillDeath )

			#if defined TESTING	
			client_print( 0 , print_chat , "*[Testing] Kill\Death ratio met. 10+ kills, 0 deaths. Ratio pts=%d" , iPoints)
			#endif
		}
	}

	/*This will adjust the kill requirement needed to check performance ratios. The more enemies there
	are, the lower the ratio is; likewise, less enemies requires a higher ratio. Below is a breakdown of 
 	enemies and % of kills required. 
	
	#Enemies %Kills-Needed
	  1   	 100
	  2   	 100
	  3   	 50
	  4   	 50
	  5+   	 33 (defined by ROUNDKILLS) */

	new Float:fRoundKills
	if ( iNumEnemies <= 2 ) 
		fRoundKills = 1.0
	else if ( ( iNumEnemies > 2 ) && ( iNumEnemies <= 4 ) )
		fRoundKills = 0.5
	else 
		fRoundKills = get_pcvar_float( g_pAWRRoundKills )

	#if defined TESTING	
	client_print( 0 , print_chat , "*[Testing] Round-kill percentage required: %f" , fRoundKills )
	#endif

	//Hits\Shots, Headshot-kills\kills, and Shots to the head/all body parts
	//Must kill atleast fRoundKills percentage of all enemies to check these ratios.
	if ( float( g_RoundKills[ id ] ) >= ( float( iNumEnemies ) * fRoundKills ) )
	{
		if ( ( float( iStats[ 5 ] ) / float( iStats[ 4 ] ) ) >= get_pcvar_float( g_pAWRHitsShots ) ) 
		{
			iPoints += get_pcvar_num( g_pAWPHitsShots )

			#if defined TESTING	
			client_print( 0 , print_chat , "*[Testing] Hits\Shots ratio met. Ratio pts=%d" , iPoints )
			#endif
		}
	
		if ( g_HeadshotKills[ id ] )  
		{
			if ( ( float( g_HeadshotKills[ id ] ) / float( g_RoundKills[ id ] ) ) >= get_pcvar_float( g_pAWRHSKill ) )
			{
				iPoints += get_pcvar_num( g_pAWPHSKill )

				#if defined TESTING	
				client_print( 0 , print_chat , "*[Testing] HS-Kill\Kill ratio met. Ratio pts=%d" , iPoints )
				#endif
			}
		}
	
	
		//Shots to the head/all body parts ratio
		//Must have atleast 5 total body hits (anywhere on body)
		for ( i = 0 ; i < 8 ; i++ )
			iBodyHits += iBHits[ i ]
		
		if ( iBodyHits >= 5 )
		{
			if ( iBHits[ 1 ] )
			{
				if ( ( float( iBHits[ 1 ] ) / float( iBodyHits ) ) >= get_pcvar_float( g_pAWRHeadBody ) )
				{
					iPoints += get_pcvar_num( g_pAWPHeadBody )
					
					#if defined TESTING	
					client_print( 0 , print_chat , "*[Testing] HeadHits\All Hits ratio met. Ratio pts=%d", iPoints )
					#endif
				}
			}
			
			if ( iBHits[ 2 ] )
			{
				if ( ( float( iBHits[ 2 ] ) / float( iBodyHits ) ) >= get_pcvar_float( g_pAWRChestBody ) )
				{
					iPoints += get_pcvar_num( g_pAWPChestBody )

					#if defined TESTING	
					client_print( 0 , print_chat , "*[Testing] ChestHits\All Hits ratio met. Ratio pts=%d" , iPoints  )
					#endif
				}
			}
		}
	}
	
	//If player met auto-watch criteria, add auto-watch point
	if ( iPoints >= get_pcvar_num( g_pAWPRPointsNeeded ) )
	{
		g_AutoWatchPts[ id ]++

		#if defined TESTING	
		client_print( 0 , print_chat , "*[Testing] Auto-Watch check met. AutoWatch Points = %d" , g_AutoWatchPts[ id ] )
		#endif
	}
	
	return PLUGIN_HANDLED
}


public fw_HamTakeDamage( victim , inflictor , attacker , Float:fDamage , bitDamage ) 
{     
	new iDetectMethod = get_pcvar_num( g_pDetectMethod )
	
	//Block if:
	if ( !IsPlayer( attacker ) ||    //Attacker is not a player OR
		!g_BotID || 		//Bot does not exist OR
		( victim != g_BotID ) )  //The player taking damage is not the bot
		return HAM_IGNORED
	
	//Block bot damage if:
	if ( ( iDetectMethod == DETECT_AIMING ) ||  	//Aiming detection method is being used OR
		( attacker != g_PlayerToWatch ) || 	//The player issuing damage is not the watched player OR
			!( bitDamage & DMG_BULLET ) )	//Damage is not inflicted with a bullet
		return HAM_SUPERCEDE
	
	new iHitzone = get_pdata_int( g_BotID , m_LastHitGroup )
	new iGun = get_user_weapon( g_PlayerToWatch )

	#if defined TESTING
	switch( iHitzone )
	{
		case HIT_GENERIC: client_print( 0 , print_chat,"*[Testing] Attacker=%d Gun=%d Hit=Generic" , attacker , iGun)
		case HIT_HEAD: client_print( 0 , print_chat,"*[Testing] Attacker=%d Gun=%d Hit=Head" ,  attacker , iGun)
		case HIT_CHEST: client_print( 0 , print_chat,"*[Testing] Attacker=%d Gun=%d Hit=Chest" , attacker ,  iGun)
		case HIT_STOMACH: client_print( 0 , print_chat,"*[Testing] Attacker=%d Gun=%d Hit=Stomach" ,  attacker , iGun)
		case HIT_LEFTARM: client_print( 0 , print_chat,"*[Testing] Attacker=%d Gun=%d Hit=Left Arm" ,  attacker , iGun)
		case HIT_RIGHTARM: client_print( 0 , print_chat,"*[Testing] Attacker=%d Gun=%d Hit=Right Arm" ,  attacker , iGun)
		case HIT_LEFTLEG: client_print( 0 , print_chat,"*[Testing] Attacker=%d Gun=%d Hit=Left Leg" ,  attacker , iGun)
		case HIT_RIGHTLEG: client_print( 0 , print_chat,"*[Testing] Attacker=%d Gun=%d Hit=Right Leg" ,  attacker , iGun)
		default: client_print( 0 , print_chat,"*[Testing] Attacker=%d Gun=%d Hit=?????" ,  attacker , iGun)
	}
	#endif
	
	//If user is using a sniper or pistol then there is a good chance he is using aimbot so
	//player gets punished no matter what bodypart of bot is hit. If hit by a non-pistol or
	//non-sniper rifle then we count body-part hit points.
	switch( iGun )
	{
		//Pistols and primary weapons with little to no recoil
		case CSW_AWP,CSW_G3SG1,CSW_SG550,CSW_SCOUT,CSW_GLOCK18,CSW_DEAGLE,CSW_P228,CSW_ELITE,CSW_FIVESEVEN,CSW_USP: 
		{
			g_HitPoints += get_pcvar_num( g_pHPHitsNeeded )
		}
		default: 
		{	
			//Accumulate body hit points depending on which part of body is hit.
			switch( iHitzone )
			{
				case HIT_HEAD: g_HitPoints += get_pcvar_num( g_pHPHead )
				case HIT_LEFTARM, HIT_STOMACH, HIT_CHEST, HIT_RIGHTARM: g_HitPoints += get_pcvar_num( g_pHPMidBody )
				case HIT_LEFTLEG, HIT_RIGHTLEG: g_HitPoints += get_pcvar_num( g_pHPLegs )
			}
		}
	}
	
	#if defined TESTING	
	client_print( 0 , print_chat , "*[Testing] Bot body-hit points = %d" , g_HitPoints )
	#endif

	if ( iDetectMethod == DETECT_BOTH )
		return PLUGIN_HANDLED
		
	g_AimPasses = 0

	//If we have enough hit points, add a detection
	if ( g_HitPoints >= get_pcvar_num( g_pHPHitsNeeded ) )
		AddDetection()
	
	//Block bot from taking damage.
	return HAM_SUPERCEDE
}			

	
public fw_HamKilled(victim, killer, shouldgib)
{
	//Block if:
	if ( !g_PlayerToWatch || 		//Not currently watching a player OR
		( killer != g_PlayerToWatch ) || //Player that killed is not our watched player OR
		( victim == g_PlayerToWatch ) )  //Player killed is our watched player
		return HAM_IGNORED
	
	#if defined TESTING
	new Float: fV[ 3 ] , Float: fW[ 3 ]
	pev( victim , pev_origin , fV )
	pev( g_PlayerToWatch , pev_origin , fW )
	fV[ 2 ] = 0.0
	fW[ 2 ] = 0.0
	client_print( 0 , print_chat , "*[Testing] Ground distance between watched player & victim = %f" , get_distance_f(fV,fW) )
	#endif
	
	//Block if:
	if ( g_BotID || 								//Detection bot currently exists OR
		!( get_pdata_int( victim , m_bitsDamageType ) & DMG_BULLET ) ||  //Bullet was not cause of death OR
		( get_user_weapon( killer ) == CSW_KNIFE ) )		         //Knife was used to make kill (Knife damage returns DMG_BULLET so a knife check is still needed)
		return HAM_IGNORED
	
	//Server currently full so we cannot add bot
	if ( get_playersnum() == g_MaxClients )
	{
		if ( get_pcvar_num( g_pVerboseMode ) == VERBOSE_3 )
			PrintColorMsg( 0 , NORMAL_MSG ,"%L" , LANG_PLAYER , "AIMBOTDETECT_SERVERFULL" )
			
		return HAM_IGNORED
	}

	//Calculate the Z coordinate at which the detection bot will be spawned. If the bot is spawnable, this will
	//return an integer. If 0 is returned, the bot cannot be spawned due to the victims location.
	new Float:fHeight = Calculate_Z( g_PlayerToWatch , victim , 100.0 , 300.0 , 3000.0 )
	
	//Check angle of line between player origin and spawn bot origin. If outside of spec, we do not spawn the bot.
	if ( fHeight == 0.0 )
	{
		//Calculate_Z returned 0 which means the location of the victim will not allow a bot to be spawned.
		//This can happen if the victim is in a doorway\room\cave or in an area high in the map where if the bot was
		//spawned, it would be outside the confines of the map and not shootable.	
		if ( get_pcvar_num( g_pVerboseMode ) )
			PrintColorMsg( 0 , NORMAL_MSG , "%L" , LANG_PLAYER , "AIMBOTDETECT_VICTIMLOCATION" )
			
		return HAM_IGNORED
	}
	
	new Float: fVictimOrigin[ 3 ] , Float: fWatchedOrigin[ 3 ]
	new iDetectMethod
	
	pev( victim , pev_origin, fVictimOrigin )
	pev( g_PlayerToWatch , pev_origin, fWatchedOrigin )
	fVictimOrigin[ 2 ] = fHeight
	
	new Float:fAngle = GetAngleOrigins( fWatchedOrigin , fVictimOrigin )
	
	if ( ( fAngle > 50.0 ) || ( fAngle < 5.0 ) )
	{		
		if ( get_pcvar_num( g_pVerboseMode ) == VERBOSE_3 )
			PrintColorMsg( 0 , NORMAL_MSG , "%L" , LANG_PLAYER , "AIMBOTDETECT_VICTIMLOCATION" )
			
		return HAM_IGNORED
	}

	AddBot()

	//Error spawning bot
	if ( !g_BotID )
	{
		//Error spawning bot
		if ( get_pcvar_num( g_pVerboseMode ) == VERBOSE_3 )	
			PrintColorMsg( 0 , NORMAL_MSG , "%L" , LANG_PLAYER , "AIMBOTDETECT_ERRORBOT" )
			
		return HAM_IGNORED
	}
	
	//Reset our hit\aim counters
	g_HitPoints = 0
	g_AimPoints = 0
	g_AimChecks = 0
	
	//Bot was successfully spawned, set its origin and and give it a weapon
	fm_entity_set_origin( g_BotID , fVictimOrigin )
	fm_give_item( g_BotID , random( 2 ) ? "weapon_deagle" : "weapon_ak47" )
	
	iDetectMethod = get_pcvar_num( g_pDetectMethod )
	
	if( ( iDetectMethod == DETECT_SHOTS ) || ( iDetectMethod == DETECT_BOTH ) )
	{
		if ( get_pcvar_num( g_pForceShoot )  )
		{
			new iWeaponID
			new iClip
			new rparam[ 3 ]
	
			//Get current weapon and amount of ammo in clip
			iWeaponID = get_user_weapon( g_PlayerToWatch , iClip , _ )
	
			//Reload current weapon to max ammo
			rparam[ 0 ] = g_PlayerToWatch
			rparam[ 1 ] = iWeaponID
			rparam[ 2 ] = MaxClipAmmo[ iWeaponID ];
			set_task( 0.1 , "ReloadClip" , _, rparam , 3 )
	
			//Set our delay shoot task
			set_task( ( get_pcvar_float( g_pBotStayTime ) / 3.0 ) , "ForceShoot" , TASK_AUTOSHOOT )
			
			//Reset ammo to the original amount prior to our reload
			rparam[ 2 ] = iClip
			set_task( get_pcvar_float( g_pBotStayTime ) + 0.1 , "ReloadClip" , _ , rparam , 3 )
		}
		
		set_task( get_pcvar_float( g_pBotStayTime ) , "RemoveBot" , TASK_REMOVEBOT ) 
	}
	
	if ( ( iDetectMethod == DETECT_AIMING ) || ( iDetectMethod == DETECT_BOTH ) )
	{                                                              
		set_task( 0.25 , "CheckAiming" , TASK_CHECKAIM , _, _, "a" , get_pcvar_num( g_pAimNumNeeded ) )
	}
		
	return HAM_IGNORED
}

public Punish(id)
{
	new szName[ 33 ] , szAuthID[ 35 ] , szIP[ 16 ] , szMap[ 21 ];
	
	get_user_name( id , szName , charsmax( szName ) )
	get_user_authid( id , szAuthID, charsmax( szAuthID ) )
	get_user_ip( id , szIP , charsmax( szIP ) , 1 )
	get_mapname( szMap , charsmax( szMap ) )

	log_to_file( "aimbotdetections.log" , "An aimbot was detected on %s [%s] [%s] [%s]" , szName , szAuthID , szIP  , szMap )
	
	g_bPunished[ id ] = true
	
	switch ( get_pcvar_num( g_pPunishment ) )
	{
		case KICK_ONLY:
		{
			KickPlayer( id , "[Aimbot Detector]", "An aimbot was detected on your system." , "You have been kicked" ) 
		}
		case KICK_AND_BANID:
		{
			//amx_ban <name or #userid> <minutes> [reason]
			server_cmd( "amx_ban #%d %d ^"Aimbot Detected^"" , get_user_userid( id ) , get_pcvar_num( g_pBanTime ) )
		}
		case KICK_AND_BANIP:
		{
			//amx_banip <name or #userid> <minutes> [reason]
			server_cmd( "amx_banip #%d %d ^"Aimbot Detected^"" , get_user_userid( id ) , get_pcvar_num( g_pBanTime ) )
		}
		case KICK_AND_AMXBAN:
		{
			server_cmd( "amx_ban %d #%d ^"Aimbot Detected^"" , get_pcvar_num( g_pBanTime ) , get_user_userid( id ) )
		}
		case SHOOT_BLANKS_ID , SHOOT_BLANKS_IP:
		{
			if ( !g_FM_TraceLine )
				g_FM_TraceLine = register_forward( FM_TraceLine , "fw_TraceLine" , 1 )

			g_NumShootsBlanks++
			g_bShootsBlanks[ id ] = true
			fm_set_user_hitzones( id , 0 , 0 )

			if ( !ShootsBlanks( id ) )
				AddShootBlanks( id )
			
			if ( get_pcvar_num( g_pVerboseMode) == VERBOSE_3 )
				PrintColorMsg( 0 , COLOR_MSG , "%L" , LANG_PLAYER , "AIMBOTDETECT_NOWSHOOTBLANKS" , szName  )
		}
	}
}

public CheckAiming()
{	
	new iDetectMethod = get_pcvar_num( g_pDetectMethod );
	
	g_AimChecks++
	
	if( g_PlayerToWatch && g_BotID )
	{
		if( fm_is_aiming_at_player( g_PlayerToWatch , g_BotID ) )
		{
			g_AimPoints++
			g_AimPasses = 0

			if ( iDetectMethod == DETECT_BOTH )
				return PLUGIN_HANDLED
				
			if( g_AimPoints == get_pcvar_num( g_pAimNumNeeded ) )
				AddDetection()
		}
	}
	
	if( ( iDetectMethod != DETECT_BOTH ) && ( g_AimChecks >= get_pcvar_num( g_pAimNumNeeded ) ) )
		RemoveBot()
		
	return PLUGIN_HANDLED
}

public ForceShoot()
{
	if ( g_BotID && g_PlayerToWatch && is_user_connected( g_PlayerToWatch ) )
	 	client_cmd( g_PlayerToWatch , "+attack;wait;wait;wait;-attack;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;wait;+attack;wait;wait;wait;-attack" ) 	
}

public ReloadClip( param[ 3 ] )
{
	new id = param[ 0 ]
	new iWeaponID = param[ 1 ]
	//param[2] = ammo amount
	
	new szWeapon[ 32 ]
	new iWeaponIdx = -1

	if ( !iWeaponID || ( iWeaponID == CSW_C4 ) || ( iWeaponID == CSW_KNIFE ) )
		return PLUGIN_HANDLED
		
	get_weaponname( iWeaponID , szWeapon , 31 )
		
	while( ( iWeaponIdx = fm_find_ent_by_class( iWeaponIdx , szWeapon ) ) != 0 )
	{
		if ( id == pev( iWeaponIdx , pev_owner ) )
		{
			fm_cs_set_weapon_ammo( iWeaponIdx , param[ 2 ] )
			break
		}
	}
	
	return PLUGIN_HANDLED
}

public fwDeathMsg( msg_id , msg_dest , msg_entity )
{
	if ( !get_pcvar_num( g_pEnabled ) )
		return PLUGIN_CONTINUE

	//Block a deathmsg when bot is killed.
	if ( g_BotID && ( get_msg_arg_int( 2 ) == g_BotID ) )
		return PLUGIN_HANDLED

	new iKiller = get_msg_arg_int( 1 )

	if ( !get_pcvar_num( g_pAutoWatch ) || is_user_bot( iKiller ) )
		return PLUGIN_CONTINUE
		
	//If auto-watch is enabled, we increment counters for roundkills and headshotkills (if applicable)
	//Add a kill to counter
	g_RoundKills[ iKiller ]++

	//Add a headshot to counter if kill was via headshot
	g_HeadshotKills[ iKiller ] += get_msg_arg_int( 3 )  
	
	return PLUGIN_CONTINUE
}

public fwStatusValue()
{	
	if ( !get_pcvar_num( g_pEnabled ) || !g_BotID )
		return PLUGIN_CONTINUE

	//Block watched player from seeing detection-bots statustext when aiming.
	if ( ( get_msg_arg_int( 2 ) == g_BotID ) && ( get_msg_arg_int( 1 ) == 2 ) )
	{
		set_msg_arg_int( 1 , get_msg_argtype( 1 ) , 1 )
		set_msg_arg_int( 2 , get_msg_argtype( 2 ) , 0 )
	}	

	return PLUGIN_CONTINUE
}  

public Float: Calculate_Z( killer , victim , Float:fMinHeight , Float:fMaxHeight , Float:fMaxDistance )
{
	//Calculate the Z coord based on distance from watched player and victim.
	
	new Float:fVictimOrigin[ 3 ]
	new Float:fKillerOrigin[ 3 ]
	new Float:fVictimZ

	//Get users origins
	pev( victim , pev_origin , fVictimOrigin )
	pev( killer , pev_origin , fKillerOrigin )

	//Save the Z of the victim for later use
	fVictimZ = fVictimOrigin[ 2 ]
	
	//Set Z coord to 0 since we only want actual ground distance between players
	fKillerOrigin[ 2 ] = 0.0
	fVictimOrigin[ 2 ] = 0.0
	
	//Get ground distance (Z coord was set to 0 to not consider difference in height)
	new Float:fDistance = get_distance_f( fKillerOrigin , fVictimOrigin )
	
	//Make sure our distance is within 1.0 -> fMaxDistance
	fDistance = floatclamp( fDistance , 1.0 , fMaxDistance )
	
	//Since we add min_height in the calculation we subtract it from the result otherwise result could be
	//higher than the max specified.
	fMaxHeight -= fMinHeight

	new Float:fSpawnHeight = fMinHeight + ( ( fDistance / fMaxDistance ) * fMaxHeight )

	#if defined TESTING
	client_print( 0 , print_chat , "*[Testing] Victim Z = %f, addl Z = %f, bot Z = %f" , fVictimZ , fSpawnHeight , fVictimZ + fSpawnHeight )
	#endif

	//Final height value for spawning our bot
	fVictimOrigin[ 2 ] = fVictimZ + fSpawnHeight

	return ( ( engfunc( EngFunc_PointContents , fVictimOrigin ) == CONTENTS_SOLID ) ? 0.0 : fVictimOrigin[ 2 ] )
}

public Float: GetAngleOrigins( Float:fOrigin1[ 3 ] , Float:fOrigin2[ 3 ] )
{
	//This function calculates the angle of a line between origin1 and origin2.
	//thx stupok
	new Float:fVector[ 3 ] , Float:fAngle[ 3 ]
	
	xs_vec_sub( fOrigin2 , fOrigin1 , fVector )
	vector_to_angle( fVector , fAngle )
	
	return ( fAngle[ 0 ] > 90.0 ) ?  -( 360.0 - fAngle[ 0 ] ) : fAngle[ 0 ]
}

public KickPlayer( target , szReason[] , szLine2[] , szLine3[] ) 
{     
	//* Credit to Teyut from amx forums for multi-line kick message *
	
	static msg_content[ 80 ]    
           
	formatex( msg_content , charsmax( msg_content ) , "%s^n%s^n%s" , szReason , szLine2 , szLine3 )   
	message_begin( MSG_ONE_UNRELIABLE , 2 , _, target )   
	write_string( msg_content )    
	message_end()      
}

public PrintColorMsg( id , iColor , const szMsg[] , any:... )
{
	static szMessage[ 256 ], iLen;
	
	iLen = formatex( szMessage , charsmax( szMessage ) , ( iColor == COLOR_MSG ) ? "^x01[^x04%s^x01] " : "[Aimbot Detector] " , "Aimbot Detector" ) 

	vformat( szMessage[ iLen ] , charsmax( szMessage ) - iLen , szMsg , 4 )
	
	if ( id )
	{
		emessage_begin( MSG_ONE_UNRELIABLE , g_msgSayText , _, id )
		ewrite_byte( id )		
		ewrite_string( szMessage )
		emessage_end()
	}
	else
	{
		static iPlayers[ 32 ] , iPlayersNum , iPlayer
		
		get_players( iPlayers , iPlayersNum , "c" )
		
		for ( new i = 0 ; i < iPlayersNum ; i++ )
		{
			iPlayer = iPlayers[ i ]
			
			if ( g_bAdminNotify[ iPlayer ] )
			{
				emessage_begin( MSG_ONE_UNRELIABLE , g_msgSayText , _, iPlayer )
				ewrite_byte( iPlayer )		
				ewrite_string( szMessage )
				emessage_end()
			}
		}
	}
	
	return PLUGIN_HANDLED
}

public ShootsBlanks(id)
{
	new szBlanksFile[ 64 ]
	new szItem[ 35 ]
	new szAuthID[ 35 ]
	new iItems
	new iLen

	switch ( get_pcvar_num( g_pPunishment ) )
	{
		case SHOOT_BLANKS_ID: get_user_authid( id , szAuthID , charsmax( szAuthID ) )
		case SHOOT_BLANKS_IP: get_user_ip( id , szAuthID , charsmax( szAuthID ) , 1 )
	}
	
	copy( szBlanksFile[ get_configsdir( szBlanksFile , charsmax( szBlanksFile ) ) ] , charsmax( szBlanksFile ) , "/aim_shootblanks.txt" )
	
	iItems = file_size( szBlanksFile , 1 )
	
	if ( iItems != -1 )
	{	
		if ( file_size( szBlanksFile , 2 ) == 1 )
			iItems--

		if ( !iItems )
			return 0
		
		for ( new i = 0 ; i < iItems ; i++ )
		{
			read_file( szBlanksFile , i , szItem , charsmax( szItem ) , iLen )
			
			if ( equal( szAuthID , szItem , iLen ) )
				return 1
		}	
	}
	
	return 0
}

public AddShootBlanks(id)
{
	new szBlanksFile[ 64 ] , szAuthID[ 35 ]
	
	switch( get_pcvar_num( g_pPunishment ) )
	{
		case SHOOT_BLANKS_ID: get_user_authid( id , szAuthID , charsmax( szAuthID ) )
		case SHOOT_BLANKS_IP: get_user_ip( id , szAuthID , charsmax( szAuthID ) , 1 )
	}	
	
	copy( szBlanksFile[ get_configsdir( szBlanksFile , charsmax( szBlanksFile ) ) ] , charsmax( szBlanksFile ) , "/aim_shootblanks.txt" )
		
	write_file( szBlanksFile , szAuthID )
}

public fm_is_aiming_at_player( index , index2 ) 
{
	new Float:start[ 3 ] , Float:view_ofs[ 3 ]

	pev( index , pev_origin , start )
	pev( index , pev_view_ofs , view_ofs )
	xs_vec_add( start , view_ofs , start )

	new Float:dest[ 3 ]
	pev( index , pev_v_angle , dest )
	engfunc( EngFunc_MakeVectors , dest )
	global_get( glb_v_forward , dest )
	xs_vec_mul_scalar( dest, 9999.0 , dest )
	xs_vec_add( start , dest , dest )

	engfunc( EngFunc_TraceLine , start , dest , DONT_IGNORE_MONSTERS , index , 0 )

	return ( get_tr2( 0 , TR_pHit ) == index2 )
}

public fw_TraceLine( Float:v1[ 3 ] , Float:v2[ 3 ] , NoMonsters , shooter , ptr )
{
	if ( !IsPlayer( shooter ) )
		return FMRES_IGNORED

	static iPlayerHit; iPlayerHit = get_tr2( ptr , TR_pHit )
	
	if ( !IsPlayer( iPlayerHit ) )
		 return FMRES_IGNORED
		 
	static iHitzone; iHitzone = get_tr2( ptr , TR_iHitgroup )
		
	if ( !(g_BodyHits[ shooter ][ iPlayerHit ] & ( 1 << iHitzone ) ) )
		set_tr2( ptr , TR_flFraction , 1.0 )

	return FMRES_IGNORED
}

public fm_set_user_hitzones( index , target , body )
{
	if ( !index && !target ) 
	{
		for ( new i = 1 ; i <= g_MaxClients ; i++ ) 
			for (new j = 1 ; j <= g_MaxClients ; j++ ) 
				g_BodyHits[ i ][ j ] = body
	}
	else if ( !index && target )
	{
		for ( new i = 1 ; i <= g_MaxClients ; i++ ) 
			g_BodyHits[ i ][ target ] = body
	}
	else if ( index && !target ) 
	{
		for ( new i = 1 ; i <= g_MaxClients ; i++ ) 
			g_BodyHits[ index ][ i ] = body
	}
	else if ( index && target ) 
	{
		g_BodyHits[ index ][ target ] = body
	}
}

public fm_hitzones_reset( index )
{
	for ( new i = 1 ; i <= g_MaxClients ; i++ )
	{
		g_BodyHits[ index ][ i ] =	(1<<HIT_GENERIC) | (1<<HIT_HEAD) | (1<<HIT_CHEST) | 
						(1<<HIT_STOMACH) | (1<<HIT_LEFTARM) | (1<<HIT_RIGHTARM)| 
						(1<<HIT_LEFTLEG) | (1<<HIT_RIGHTLEG)
	}
				
}

public fm_user_spawn(id) 
{ 
	set_pev( id , pev_deadflag , DEAD_RESPAWNABLE )
	dllfunc( DLLFunc_Spawn , id )
	set_pev( id , pev_iuser1 , 0 )
}
