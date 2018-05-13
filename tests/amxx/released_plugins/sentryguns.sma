new const PLUGINNAME[] = "Sentry guns"
new const VERSION[] = "0.5.4 beta 4"
new const AUTHOR[] = "JGHG"

/*
Copyleft 2004
Plugin topic: http://www.amxmodx.org/forums/viewtopic.php?p=67628

SENTRY GUNS
===========
Sentries in TFC were cool. Sentries in CS are cool.
Sentry guns are stationary engineering wonders that fire bullets at and kill your enemies.
Sentry guns can be upgraded twice, with the help of a team member, to be bigger and meaner.
You can remotely choose to detonate a specific sentry, or all of them.
You can also remotely look through the spycam mounted on your sentry.


INSTALLATION
============
1. Make sure the folling modules are running on your server: CSTRIKE, FUN, ENGINE, FAKEMETA (check configs/modules.ini)
2. Copy all models and sounds in place.
3. Scroll down to "Adjust below settings to your liking", do your dirty stuff, scroll up here and continue.
4. Compile and install plugin. (configs/plugins.ini)
- Done.


USAGE
=====
client command: sentry_menu
- Build/detonate/upgrade sentry guns with this one-for-all menu. You can also spy through your sentries using this menu.

client command: sentry_build
- Quickie to build a sentry without going through menu. Since version 0.2 you can now also point at a sentry and upgrade it with this command, if the sentry is close enough.
Note that you can also run into an upgradeable sentry gun to upgrade it.

client command: "/sentryhelp", or just "sentryhelp" in chat
- Displays info on how to bind buttons, what they do, etc.


VERSIONS
========
Released	Version		Comment
041105		0.5.4beta	Um this is only a beta release...

041102		0.5.3		Always some bugs with new features eh? There were some issues with the spycam, those should be fixed.
						When a sentry explodes the spycam now also does so that if the owner is looking through it his view will be
						set back directly.

041030		0.5.2		With several sentries built you can now cycle through them using the menu, and then select an appropriate action to perform on that sentry.

						You can now spy through your sentries. A small camera is mounted on all sentries. Activate through menu.

						Fixed a couple of run time errors occuring if you shot the sentry base to pieces before the sentry head was built.

						Level typo fixed in hud msg.

041027		0.5.1		Lots of fixes and tweaks as always, I'm listing the ones I can remember:

						When someone on your team builds a sentry, the location for the construction will flash shortly on radar.
						Also when using menu to remotely detonate the closest of your sentries, you can see the closest sentry flashing on your radar.

						You now get money if your sentry kills an enemy. You can define this, but right now the builder gets $300, and each upgrader $150,
						so if you are using the settings where you can upgrade your sentry all the way to level 3 you will get $600 for each kill. :-)
						Maybe an incentive for people to upgrade sentries even if they are low on money... It's a gamble! :-)

						Bots shouldn't build large clusters of sentries anymore but spread them out more evenly across maps...
						Having bots be able to fire at the sentries seems now more impossible than ever, I had a chat with the guys at Bots United and
						possibly the easiest solution would be to build my own bot, or modify an existing opensource bot. Doh.

041026		0.5			Now uses fakemeta again. Long time no see! :-)

						Sentry doesn't lose its target if another enemy runs into the line of fire; the other enemy will now be the current target of the sentry.

						Should now not be able to run onto a sentry base while building to mess things up.

						Upgrade sentry text in center was off by one level...

						Rewrote some parts to make for smoother sentry rotation... and stuff... :-)

						Fatter explosions.

						Can now only upgrade sentries your team has built. :-)

						You can now just run into a sentry and it will be upgraded if you have the money for it.

						Look at a sentry your team has built and you will see its health and level printed in center of screen.

						Bots can and will now build sentries. Too bad they can't decide to shoot at them yet. :-P This was mostly created so I
						can easier stress test this plugin, so don't expect too much but generally bots will build sentries randomly across maps
						AND build sentries at objective critical places like bomb targets, hostage rescue points and such.

041021		0.4.3		Fixed sentryhelp page which was messed up

041021		0.4.2		Fixed a few bugs:
						- Fatal bug crashing server if a sentry's base was destroyed at end of round.
						- DISALLOW_* defines didn't work as stated.
						- Sentry builder's death count would get messed up when sentry killed an enemy

041021		0.4.1		You can now shoot a sentry's base for some funny action. Watch your sentry go nuts.

						In case you didn't notice not all weapons were blown away in previous versions (weapons default on map). They are now also blasted away... :-P

041021		0.4			Removed use of fakemeta, however compatibility with AMX Mod X 0.16 cannot be achieved because a lot of math functions in core and engine modules aren't there.
						Upgrade to AMX Mod X 0.20 strongly encouraged.

						Doubled default health of sentries. Should make'em a little more useful?

						Menu now always closes when an option is picked

						Sentries should be able to find targets a lot better. Earlier it couldn't really find a target very well if it was below the sentry.
						A sentry now literally fires through its own base when necessary...

041020		0.3			*** Warning: Paths to models and sounds changed! Be sure to update your directories: sound/turrets is now sound/sentries, and models/turrets is now models/sentries.

						Money now only payed when you actually build a sentry.

						Fixed a bug that caused this error message: [AMXX] Run time error 10 (native) on line 824

						By default breaking sentries now explode and push nearby people away and hurt them. Possibly removed what was causing a crash with this in previous version.

						You must now stand on ground to build a sentry.

						Added info to player when they log on so they know how they can build sentries (added /sentryhelp)

						You can choose to have sentries survive rounds by uncommenting the new SENTRIES_SURVIVE_ROUNDS define. Note that they can build sentries in your spawn, so
						you might want to leave this off. ;-)

						Tracers (visual representation of sentry fire) weren't showing in 0.2 and maybe also 0.1, they should now show.

						More small fixes and tweaks...

041019		0.2			Commands changed! You can now build and upgrade sentries with the one command sentry_build, so you don't have to use the menu.
						Point at a sentry and press sentry_build to upgrade it, if you are near enough and have the money.
						You can also upgrade using the menu, just point at the sentry first beforing running sentry_menu cmd.

						Sentries and upgrades now cost money! I do make these plugins for free, but I will charge you for each sentry you build. ;-)

						Colors: Sentries have different colors, based on team and if you want also a random color. You can specify how you want this with the defines...

						Bug fixes:
						- Fixed upgrading sentries far from them by invoking the menu and running away from them...
						- Removed debug info when building a sentry
						- Lots more forgotten fixes and tweaks, check all the defines below again

						Note: Sentries don't explode + generate shock effect no more when they break, because there were some problems with this that caused crashing.
						I'll have to fix this later. You can still turn exploding and all on, but do so at your own risk. It usually works OK, but crashes sometimes,
						mostly when you break sentry with your knife.

041019		0.1			First release


TO DO / WISH LIST
=================
- lots of different weapons/powerups for sentries (normal bullets, rockets, tesla coils, firethrowers, grenade lobbers, webs (gets stuck) etc)
- vicinity alarms (aside from sentries) (you buy a small cheap device, and throw it somewhere, and it activates in the next 3 seconds. If anyone moves within its
vicinity a terrible alarm goes off and sounds for a while until its batteries run out ;-). You could buy a more expensive device that will only trigger when the opposite team
gets near it) also vicinity grenades with: explosions, gas, flashes and stuff could be made. (hmm this is a different plugin)
- wall/ceiling-mounted sentries
- fire from sentry should obey shields and also know what bodypart it hit (hs more dmg etc)
- dismantle sentry (nicely without detonating)
- turn it remotely and make it react slower to enemies moving behind its current aim angle
- obey ff, so you can't destroy your teammates' sentries (maybe this isn't possible ;-( )
- repair a sentry
- building in tight places should not get sentries stuck in ceiling (TraceCheckCollides)
- remote cam view from sentry for builder... or something

- regenarate hp slowly to 100 when hit.
- make a lot of settings adjustable ingame...
- missing shots aren't calculated right

	  - Johnny got his gun
*/
//#define DEBUG

#include <amxmodx>
#include <engine>
#include <fun>
#include <cstrike>
#include <fakemeta>
#if defined DEBUG
	#include <amxmisc>
#endif

// ---------- Adjust below settings to your liking ---------------------------------------------------------------------------------------------------------------------------------
#define MAXPLAYERSENTRIES		2				// how many sentries each player can build
#define DMG_EXPLOSION_TAKE		90				// how much HP at most an exploding sentry takes from a player - the further away the less dmg is dealt to player
#define SENTRYEXPLODERADIUS		250.0			// how far away it is safe to be from an exploding sentry without getting kicked back and hurt
#define THINKFIREFREQUENCY		0.1				// the rate in seconds between each bullet when firing at a locked target
#define SENTRYTILTRADIUS		830.0			// likely you won't need to touch this. it's how accurate the cannon will aim at the target vertically (up/down, just for looks, aim is calculated differently)
#if !defined DEBUG
	#define DISALLOW_OWN_UPGRADES				// you cannot upgrade your own sentry to level 2 (only to level 3 if someone else upgraded it already) (only have this commented in debug mode)
	#define DISALLOW_TWO_UPGRADES				// the upgrader cannot upgrade again, builder must upgrade to level 3 (only have this commented in debug mode)
#endif
//#define SENTRIES_SURVIVE_ROUNDS				// comment this define to have sentries removed between rounds, else they will stay where they are.
//#define RANDOM_TOPCOLOR						// sentries have two colors, one top and one bottom. The top one will be random if you leave this define be, else always red for T and blue for CT.
//#define RANDOM_BOTTOMCOLOR					// sentries have two colors, one top and one bottom. The bottom one will be random if you leave this define be, else always red for T and blue for CT.
#define EXPLODINGSENTRIES						// comment this out if you don't want the sentries to explode, push people away and hurt them (should now be stable!)
// These are per sentry level, 1-3
new const g_SENTRYFRAGREWARDS[3] = {300, 150, 150}		// how many $ you get if your sentry frags someone. If you built and upgraded to level 3 you would get $300 + $150 = $450. If built and upgraded all you would get $600.
new const g_DMG[3] = {5, 10, 15}						// how much damage a bullet from a sentry does per hit
new const Float:g_THINKFREQUENCIES[3] = {2.0, 1.0, 0.5}	// how often, in seconds, a sentry searches for targets when not locked at a target, a lower value means a sentry will lock on targets faster
new const Float:g_HITRATIOS[3] = {0.6, 0.75, 0.85}		// how good a sentry is at hitting its target. 1.0 = always hit, 0.0 = never hit
new const Float:g_HEALTHS[3] = {400.0, 800.0, 1600.0}	// how many HP a sentry has. Increase to make sentry sturdier
new const g_COST[3] = {1000, 500, 250}					// fun has a price, first is build cost, the next two upgrade costs
// ---------- Adjust above settings to your liking ---------------------------------------------------------------------------------------------------------------------------------

#if !defined PI
#define PI						3.141592654 // feel free to find a PI more exact than this
#endif

#define MENUBUTTON1				(1<<0)
#define MENUBUTTON2				(1<<1)
#define MENUBUTTON3				(1<<2)
#define MENUBUTTON4				(1<<3)
#define MENUBUTTON5				(1<<4)
#define MENUBUTTON6				(1<<5)
#define MENUBUTTON7				(1<<6)
#define MENUBUTTON8				(1<<7)
#define MENUBUTTON9				(1<<8)
#define MENUBUTTON0				(1<<9)
#define MENUSELECT1				0
#define MENUSELECT2				1
#define MENUSELECT3				2
#define MENUSELECT4				3
#define MENUSELECT5				4
#define MENUSELECT6				5
#define MENUSELECT7				6
#define MENUSELECT8				7
#define MENUSELECT9				8
#define MENUSELECT0				9
#define MAXHTMLSIZE				1536

#define MAXSENTRIES				32 * MAXPLAYERSENTRIES


// 6 bits is needed per player (0-32)
// 10 bits is needed per entity (0-1004, 1005 is maxents as of 041109)

// delete these later
/*
#define SENTRY_VEC_PEOPLE			EV_VEC_vuser1
#define OWNER						0
#define UPGRADER_1					1
#define UPGRADER_2					2

GetSentryPeople(sentry, who) {
	new Float:people[3]
	entity_get_vector(sentry, SENTRY_VEC_PEOPLE, people)
	return floatround(people[who])
}
SetSentryPeople(sentry, who, is) {
	new Float:people[3]
	entity_get_vector(sentry, SENTRY_VEC_PEOPLE, people)
	people[who] = is + 0.0
	entity_set_vector(sentry, SENTRY_VEC_PEOPLE, people)
}
*/
//#define SENTRY_ENT_TARGET		EV_ENT_euser1
#define SENTRY_ENT_BASE			EV_ENT_euser1
#define SENTRY_ENT_SPYCAM		EV_ENT_euser2

#define SENTRY_INT_PEOPLE		EV_INT_iuser2 // max 5 users using 6 bits!
#define SENTRY_PEOPLE_BITS		6
#define OWNER					0
#define UPGRADER_1				1
#define UPGRADER_2				2
#define TARGET					3
#define MASK_OWNER				0xFFFFFFC0 // 11111111111111111111111111000000
#define MASK_UPGRADER_1			0xFFFFF03F // 11111111111111111111000000111111
#define MASK_UPGRADER_2			0xFFFC0FFF // 11111111111111000000111111111111
#define MASK_TARGET				0xFF03FFFF // 11111111000000111111111111111111
//unused mask:					0xC0FFFFFF // 11000000111111111111111111111111
new const MASKS_PEOPLE[4] = {MASK_OWNER, MASK_UPGRADER_1, MASK_UPGRADER_2, MASK_TARGET}
GetSentryPeople(const SENTRY, const WHO) {
	new data = entity_get_int(SENTRY, SENTRY_INT_PEOPLE)
	data |= MASKS_PEOPLE[WHO]
	data ^= MASKS_PEOPLE[WHO]
	data = (data>>(WHO*SENTRY_PEOPLE_BITS))
	return data
}
SetSentryPeople(const SENTRY, const WHO, const IS) {
	new data = entity_get_int(SENTRY, SENTRY_INT_PEOPLE)
	data &= MASKS_PEOPLE[WHO] // nullify the setting
	data |= (IS<<(WHO*SENTRY_PEOPLE_BITS)) // set the setting
	entity_set_int(SENTRY, SENTRY_INT_PEOPLE, data) // store
}

#define SENTRY_INT_SETTINGS		EV_INT_iuser1
#define SENTRY_SETTINGS_BITS	2
#define SENTRY_SETTING_FIREMODE	0
#define SENTRY_SETTING_TEAM		1
#define SENTRY_SETTING_LEVEL	2
#define SENTRY_SETTING_PENDDIR	3
#define MASK_FIREMODE			0xFFFFFFFC // 11111111111111111111111111111100 = FFFFFFFC
#define MASK_TEAM				0xFFFFFFF3 // 11111111111111111111111111110011 = FFFFFFF3
#define MASK_LEVEL				0xFFFFFFCF // 11111111111111111111111111001111 = FFFFFFCF
#define MASK_PENDDIR			0xFFFFFF3F // 11111111111111111111111100111111 = FFFFFF3F
new const MASKS_SETTINGS[4] = {MASK_FIREMODE, MASK_TEAM, MASK_LEVEL, MASK_PENDDIR}

GetSentrySettings(const SENTRY, const SETTING) {
	new data = entity_get_int(SENTRY, SENTRY_INT_SETTINGS)
	data |= MASKS_SETTINGS[SETTING]
	data ^= MASKS_SETTINGS[SETTING]
	//data = (data>>(SETTING*SENTRY_SETTINGS_BITS))
	return (data>>(SETTING*SENTRY_SETTINGS_BITS))
}
SetSentrySettings(const SENTRY, const SETTING, const VALUE) {
	new data = entity_get_int(SENTRY, SENTRY_INT_SETTINGS)
	data &= MASKS_SETTINGS[SETTING] // nullify the setting
	//data |= (VALUE<<(SETTING*SENTRY_SETTINGS_BITS)) // set the setting
	entity_set_int(SENTRY, SENTRY_INT_SETTINGS, data | (VALUE<<(SETTING*SENTRY_SETTINGS_BITS))) // store
}

GetSentryFiremode(const SENTRY) {
	return GetSentrySettings(SENTRY, SENTRY_SETTING_FIREMODE)
}
SetSentryFiremode(const SENTRY, const MODE) {
	SetSentrySettings(SENTRY, SENTRY_SETTING_FIREMODE, MODE)
}
CsTeams:GetSentryTeam(const SENTRY) {
	return CsTeams:GetSentrySettings(SENTRY, SENTRY_SETTING_TEAM)
}
SetSentryTeam(const SENTRY, const CsTeams:TEAM) {
	SetSentrySettings(SENTRY, SENTRY_SETTING_TEAM, int:TEAM)
}
GetSentryLevel(const SENTRY) {
	return GetSentrySettings(SENTRY, SENTRY_SETTING_LEVEL)
}
SetSentryLevel(const SENTRY, const LEVEL) {
	SetSentrySettings(SENTRY, SENTRY_SETTING_LEVEL, LEVEL)
}
GetSentryPenddir(const SENTRY) {
	return GetSentrySettings(SENTRY, SENTRY_SETTING_PENDDIR)
}
SetSentryPenddir(const SENTRY, const PENDDIR) {
	SetSentrySettings(SENTRY, SENTRY_SETTING_PENDDIR, PENDDIR)
}

#define SENTRY_FL_ANGLE			EV_FL_fuser1
#define SENTRY_FL_SPINSPEED		EV_FL_fuser2
#define SENTRY_FL_MAXSPIN		EV_FL_fuser3
#define SENTRY_FL_RADARANGLE	EV_FL_fuser4

// These are bits used in SENTRY_INT_PENDDIR
#define SENTRY_DIR_CANNON		0
#define SENTRY_DIR_RADAR		1

#define BASE_ENT_SENTRY			EV_ENT_euser1
#define BASE_ENT_HULL			EV_ENT_euser2
#define BASE_ENT_OWNER			EV_ENT_euser3
#define BASE_INT_TEAM			EV_INT_iuser1

#define HULL_ENT_BASE			EV_ENT_euser1

#define SENTRY_LEVEL_1			0
#define SENTRY_LEVEL_2			1
#define SENTRY_LEVEL_3			2
#define SENTRY_FIREMODE_NO		0
#define SENTRY_FIREMODE_YES		1
#define SENTRY_FIREMODE_NUTS	2
#define TASKID_SENTRYFIRE		1000
#define TASKID_BOTBUILDRANDOMLY	2000
#define TASKID_SENTRYSTATUS		3000
#define TASKID_THINK			4000
#define TASKID_THINKPENDULUM	5000
#define TASKID_SENTRYONRADAR	6000
#define TASKID_SPYCAM			7000
#define TASKID_SENTRYEXPLODE	8000
#define DUCKINGPLAYERDIFFERENCE	18.0
#define TARGETUPMODIFIER		DUCKINGPLAYERDIFFERENCE // if player ducks on ground, traces don't hit...
#define DMG_BULLET				(1<<1)	// shot
#define DMG_BLAST				(1<<6)	// explosive blast damage
#define TE_EXPLFLAG_NONE		0
#define TE_EXPLOSION			3
#define TE_EXPLOSION2			12
#define TE_TAREXPLOSION			4
#define	TE_TRACER				6
#define TE_BREAKMODEL			108
#define BASESENTRYDELAY			2.0 // seconds from base is built until sentry top appears
#define PENDULUM_MAX			45.0 // how far sentry turret turns in each direction when idle, before turning back
#define PENDULUM_INCREMENT		10.0 // speed of turret turning...
#define RADAR_INCREMENT			1.5 // speed of small radar turning on top of sentry level 3...
#define MAXUPGRADERANGE			75.0 // farthest distance to sentry you can upgrade using upgrade command
#define COLOR_BOTTOM_CT			160 // default bottom colour of CT:s sentries
#define COLOR_TOP_CT			150 // default top colour of CT:s sentries
#define COLOR_BOTTOM_T			0 // default bottom colour of T:s sentries
#define COLOR_TOP_T				0 // default top colour of T:s sentries
#define SENTRYSHOCKPOWER		3.0 // multiplier, increase to make exploding sentries throw stuff further away
#define CANNONHEIGHTFROMFEET	20.0 // tweakable to make tracer originate from the same height as the sentry's cannon. Also traces rely on this Y-wise offset.
#define PLAYERORIGINHEIGHT		36.0 // this is the distance from a player's EV_VEC_origin to ground, if standing up
#define HEIGHTDIFFERENCEALLOWED	20.0 // increase value to allow building in slopes with higher angles. You can set to 0.0 and you will only be able to build on exact flat ground. note: mostly applies to downhill building, uphill is still likely to "collide" with ground...

// Bots will build sentries at objective critical locations (around dropped bombs, at bomb targets, near hostages etc)
// They can also build randomly around maps using these values:
#define BOT_WAITTIME_MIN		0.0				// waittime = the time a bot will wait after he's decided to build a sentry, before actually building (seconds)
#define BOT_WAITTIME_MAX		15.0
#define BOT_NEXT_MIN			0.0				// next = after building a sentry, this specifies the time a bot will wait until considering about waittime again (seconds)
#define BOT_NEXT_MAX			120.0
// This cannot account for sentries which are still under construction (only base, no sentry head yet):
// How many (or more) sentries:
#define BOT_MAXSENTRIESNEAR		1
// cannot be in the vicinity of this radius:
#define BOT_MAXSENTRIESDISTANCE	1500.0
// for a bot to build at a location. Use higher values and bots will build sentries less close to other sentries on same team.

#define BOT_OBJECTIVEWAIT		10 // nr of seconds that must pass after a bot has built an objective related sentry until he can build such a sentry again.

#define SENTRY_TILT_TURRET			EV_BYTE_controller2
#define SENTRY_TILT_LAUNCHER		EV_BYTE_controller3
#define SENTRY_TILT_RADAR			EV_BYTE_controller4
#define PEV_SENTRY_TILT_TURRET		pev_controller_1
#define PEV_SENTRY_TILT_LAUNCHER	pev_controller_2
#define PEV_SENTRY_TILT_RADAR		pev_controller_3

#define STATUSINFOTIME			0.5 // the frequency of hud message updates when spectating a sentry, don't set too low or it could overflow clients. Data should now always send again as soon as it updates though.
#define SENTRY_RADAR			20 // use as high as possible but should still be working (ie be able to see sentries plotted on radar while in menu, too high values doesn't seem to work)
#define SENTRY_RADAR_TEAMBUILT	21 // same as above

#define SPYCAMTIME				5.0 // nr of seconds the spycam is active

#define RESETSPEEDTIME			0.5 // the time to wait after the sentry head has been built until creator's speed is reset to normal

enum OBJECTTYPE {
	OBJECT_GENERIC,
	OBJECT_GRENADE,
	OBJECT_PLAYER,
	OBJECT_ARMOURY
}

// Global vars below
new g_sentriesNum = 0
new g_sentries[MAXSENTRIES]
new g_playerSentries[32] = {0, ...}
new g_playerSentriesEdicts[32][MAXPLAYERSENTRIES]
new g_sModelIndexFireball
new g_msgDamage
new g_msgDeathMsg
new g_msgScoreInfo
new g_msgHostagePos
new g_msgHostageK
new g_MAXPLAYERS
//new g_MAXENTITIES
new Float:g_ONEEIGHTYTHROUGHPI
//new g_hasSentries = 0
new Float:g_sentryOrigins[32][3]
new g_aimSentry[32]
new bool:g_inBuilding[32]
new bool:g_lastInBuilding[32]
new bool:g_resetArmouryThisRound = true
new bool:g_hasArmouries = false
new Float:g_lastGameTime = 1.0 // dunno, looks like get_systime() is always 1.0 first time...
new Float:g_gameTime
new Float:g_deltaTime
new g_sentryStatusBuffer[32][256]
new g_sentryStatusTrigger
new g_selectedSentry[32] = {-1, ...}
new g_menuId // used to store index of menu
new g_lastObjectiveBuild[32]
new g_inSpyCam[32]
new Float:g_spyCamOffset[3] = {26.0, 29.0, 26.0} // for the three levels, just what looks good...
new g_FIRESOUNDS[2][] = {
	"weapons/m249-1.wav",
	"weapons/m249-2.wav"
}
new Float:g_maxSpeeds[32]
// Global vars above


public createsentryhere(id) {
	new sentry = AimingAtSentry(id, true)
	// if a valid sentry
	// if within range
	// we can try to upgrade/repair...
	if (sentry && entity_range(sentry, id) <= MAXUPGRADERANGE)
	{
		//client_print(id, print_chat, "Sentry level: %d, last upgrader: %d", GetSentryLevel(sentry) + 1, entity_get_edict(sentry, SENTRY_ENT_LASTUPGRADER))
		#if defined DISALLOW_OWN_UPGRADES
		// Don't allow builder to upgrade his own sentry first time.
		if (GetSentryLevel(sentry) == SENTRY_LEVEL_1 && id == GetSentryPeople(sentry, OWNER)) {
			client_print(id, print_center, "You cannot upgrade your own sentry gun to level 2, a team mate must do this!")
			return PLUGIN_HANDLED
		}
		#endif
		#if defined DISALLOW_TWO_UPGRADES
		// Don't allow upgrader to upgrade again.
		if (GetSentryLevel(sentry) == SENTRY_LEVEL_2 && id == GetSentryPeople(sentry, UPGRADER_1)) {
			client_print(id, print_center, "You cannot upgrade this sentry gun another time to level 3, a team mate must do this!")
			return PLUGIN_HANDLED
		}
		#endif
		g_aimSentry[id - 1] = sentry
		//if (entity_
		sentry_upgrade(id, sentry)
	}
	else {
		sentry_build(id)
	}

	return PLUGIN_HANDLED
}

public sentry_build(id) {
	if (!is_user_alive(id)) {
		return
	}
	else if (GetSentryCount(id) >= MAXPLAYERSENTRIES) {
		new wordnumbers[128]
		getnumbers(MAXPLAYERSENTRIES, wordnumbers, 127)
		new const maxsentries = MAXPLAYERSENTRIES // stupid, but compiler gives warning on next line if a defined constant is used
		client_print(id, print_center, "You can only build %s sentry gun%s!", wordnumbers, maxsentries != 1 ? "s" : "")
		return
	}
	else if (g_inBuilding[id - 1]) {
		client_print(id, print_center, "Wow, you're a fast builder...")
		return
	}
	else if (cs_get_user_money(id) < g_COST[0]) {
		client_print(id, print_center, "You don't have enough money to build a sentry gun! ($%d needed)", g_COST[0])
		return
	}
	else if (!entity_is_on_ground(id)) {
		client_print(id, print_center, "You must stand on the ground to build a sentry gun!")
		return
	}
	//else if (entity_get_int(id, EV_INT_flags) & FL_DUCKING) {
	else if (entity_get_int(id, EV_INT_bInDuck) != 0) {
		client_print(id, print_center, "Yeah, right, try building a sentry gun sitting on your ***!")
		return
	}

	new Float:playerOrigin[3]
	entity_get_vector(id, EV_VEC_origin, playerOrigin)

  	new Float:vNewOrigin[3]
	new Float:vTraceDirection[3]
	new Float:vTraceEnd[3]
	new Float:vTraceResult[3]
	velocity_by_aim(id, 64, vTraceDirection) // get a velocity in the directino player is aiming, with a multiplier of 64...
	vTraceEnd[0] = vTraceDirection[0] + playerOrigin[0] // find the new max end position
	vTraceEnd[1] = vTraceDirection[1] + playerOrigin[1]
	vTraceEnd[2] = vTraceDirection[2] + playerOrigin[2]
	trace_line(id, playerOrigin, vTraceEnd, vTraceResult) // trace, something can be in the way, use hitpoint from vTraceResult as new origin, if nothing's in the way it should be same as vTraceEnd
	vNewOrigin[0] = vTraceResult[0]// just copy the new result position to new origin
	vNewOrigin[1] = vTraceResult[1]// just copy the new result position to new origin
	vNewOrigin[2] = playerOrigin[2] // always build in the same height as player.

	if (CreateSentryBase(vNewOrigin, id)) {
		cs_set_user_money(id, cs_get_user_money(id) - g_COST[0])
		//SetHasSentry(id, true)
		//client_print(id, print_chat, "Done creating a sentry at %f %f %f!", vNewOrigin[0], vNewOrigin[1], vNewOrigin[2])
	}
	else {
		//SetHasSentry(id, false)
		client_print(id, print_center, "Cannot build sentry here")
	}
}

GetSentryCount(id) {
	return g_playerSentries[id - 1]

	//else

	/*
	if (id < 1 || id > get_maxplayers())
		return false

	//spambits(id, g_hasSentries)

	return g_hasSentries & (1<<(id - 1)) ? true : false // g_hasSentries[id - 1] //
	*/
}

bool:GetStatusTrigger(player) {
	if (!is_user_alive(player))
		return false

	return g_sentryStatusTrigger & (1<<(player-1)) ? true : false
}
SetStatusTrigger(player, bool:onOrOff) {
	if (onOrOff)
		g_sentryStatusTrigger |= (1<<(player - 1))
	else
		g_sentryStatusTrigger &= ~(1<<(player - 1))
}

IncreaseSentryCount(id, sentryEntity) {
	g_playerSentriesEdicts[id - 1][g_playerSentries[id - 1]] = sentryEntity
	g_playerSentries[id - 1] = g_playerSentries[id - 1] + 1
	new Float:sentryOrigin[3], iSentryOrigin[3]
	entity_get_vector(sentryEntity, EV_VEC_origin, sentryOrigin)
	FVecIVec(sentryOrigin, iSentryOrigin)

	new name[32]
	get_user_name(id, name, 31)
	new CsTeams:builderTeam = cs_get_user_team(id)
	for (new i = 1; i <= g_MAXPLAYERS; i++) {
		if (!is_user_connected(i) || !is_user_alive(i) || cs_get_user_team(i) != builderTeam || id == i)
			continue
		client_print(i, print_center, "%s has built a sentry gun %d units away from you", name, floatround(entity_range(i, sentryEntity)))

		//client_print(parm[0], print_chat, "Plotting closest sentry %d on radar: %f %f %f", parm[1], sentryOrigin[0], sentryOrigin[1], sentryOrigin[2])
		message_begin(MSG_ONE, g_msgHostagePos, {0,0,0}, i)
		write_byte(i)
		write_byte(SENTRY_RADAR_TEAMBUILT)
		write_coord(iSentryOrigin[0])
		write_coord(iSentryOrigin[1])
		write_coord(iSentryOrigin[2])
		message_end()

		message_begin(MSG_ONE, g_msgHostageK, {0,0,0}, i)
		write_byte(SENTRY_RADAR_TEAMBUILT)
		message_end()
	}
	//client_print(0, print_chat, "%s has built a sentry gun", name)
}

DecreaseSentryCount(id, sentry) {
	// Note that sentry does not exist at this moment, it's just an old index that should get zeroed where it occurs in g_playerSentriesEdicts[id - 1][]
	g_selectedSentry[id - 1] = -1

	for (new i = 0; i < g_playerSentries[id - 1]; i++) {
		if (g_playerSentriesEdicts[id - 1][i] == sentry) {
			// Copy last sentry edict index to this one
			g_playerSentriesEdicts[id - 1][i] = g_playerSentriesEdicts[id - 1][g_playerSentries[id - 1] - 1]
			// Zero out last sentry index
			g_playerSentriesEdicts[id - 1][g_playerSentries[id - 1] - 1] = 0
			break
		}
	}
	g_playerSentries[id - 1] = g_playerSentries[id - 1] - 1
}

/*
SetHasSentry(id, bool:trueOrFalse) {
	//g_hasSentries[id - 1] = trueOrFalse
	//spambits(id, g_hasSentries)
	if (trueOrFalse) {
		g_hasSentries |= (1<<(id - 1))
		new name[32]
		get_user_name(id, name, 31)
		new CsTeams:builderTeam = cs_get_user_team(id)
		for (new i = 0; i < g_MAXPLAYERS; i++) {
			if (!is_user_connected(i) || !is_user_alive(i) || cs_get_user_team(i) != builderTeam || id == i)
				continue
			client_print(i, print_center, "%s has built a sentry gun", name)
		}
	}
	else
		g_hasSentries &= ~(1<<(id - 1))

	//spambits(id, g_hasSentries)
}
*/

stock bool:CreateSentryBase(Float:origin[3], creator) {
	// Check contents of point, also trace lines from center to each of the eight ends
	if (point_contents(origin) != CONTENTS_EMPTY || TraceCheckCollides(origin, 24.0)) {
		return false
	}

	// Check that a trace from origin straight down to ground results in a distance which is the same as player height over ground?
	new Float:hitPoint[3], Float:originDown[3]
	originDown = origin
	originDown[2] = -5000.0 // dunno the lowest possible height...
	trace_line(0, origin, originDown, hitPoint)
	new Float:baDistanceFromGround = vector_distance(origin, hitPoint)
	//client_print(creator, print_chat, "Base distance from ground: %f", baDistanceFromGround)

	new Float:difference = PLAYERORIGINHEIGHT - baDistanceFromGround
	if (difference < -1 * HEIGHTDIFFERENCEALLOWED || difference > HEIGHTDIFFERENCEALLOWED) {
		//client_print(creator, print_chat, "You can't build here! %f", difference)
		return false
	}

	new entbase = create_entity("func_breakable") // func_wall
	if (!entbase)
		return false

	new hull = create_entity("func_wall")
	if (!hull)
		return false

	// Set sentrybase health
	new healthstring[16]
	num_to_str(floatround(g_HEALTHS[0]), healthstring, 15)
	DispatchKeyValue(entbase, "health", healthstring)
	DispatchKeyValue(entbase, "material", "6")

	DispatchSpawn(entbase)
	// Change classname
	entity_set_string(entbase, EV_SZ_classname, "sentrybase")

	entity_set_string(hull, EV_SZ_classname, "sentryhull")
	// Set model
	entity_set_model(entbase, "models/sentries/base.mdl")

	entity_set_model(hull, "models/sentries/base.mdl") // don't draw this
	entity_set_int(hull, EV_INT_rendermode, kRenderTransColor)
	entity_set_float(hull, EV_FL_renderamt, 0.0)
	entity_set_int(hull, EV_INT_renderfx, kRenderFxNone)

	// Set size, hull will be a tad bigger later but we need to make this size also the same tad bigger because otherwise you'll get stuck to the sentry if you stand beside it
	// while it's in production.
	new Float:mins[3], Float:maxs[3]
	mins[0] = -17.0
	mins[1] = -17.0
	mins[2] = 0.0
	maxs[0] = 17.0
	maxs[1] = 17.0
	maxs[2] = 1000.0 // Set to 16.0 later.
	entity_set_size(entbase, mins, maxs)

	//client_print(creator, print_chat, "Creating sentry %d with bounds %f", ent, BOUNDS)
	// Set origin
	entity_set_origin(entbase, origin)

	// Set starting angle
	//entity_get_vector(creator, EV_VEC_angles, origin)
	//origin[0] = 0.0
	//origin[1] += 180.0
	//origin[2] = 0.0
	//entity_set_vector(ent, EV_VEC_angles, origin)
	// Set solidness
	entity_set_int(entbase, EV_INT_solid, SOLID_SLIDEBOX) // SOLID_SLIDEBOX
	entity_set_int(hull, EV_INT_solid, SOLID_SLIDEBOX) // SOLID_SLIDEBOX

	// Set movetype
	entity_set_int(entbase, EV_INT_movetype, MOVETYPE_TOSS) // head flies, base falls
	entity_set_int(hull, EV_INT_movetype, MOVETYPE_TOSS) // head flies, base falls

	// Set team
	entity_set_int(entbase, BASE_INT_TEAM, int:cs_get_user_team(creator))
	entity_set_int(hull, BASE_INT_TEAM, int:cs_get_user_team(creator))
	// Set base owner
	entity_set_edict(entbase, BASE_ENT_OWNER, creator)
	// Set hull owner
	entity_set_edict(hull, HULL_ENT_BASE, entbase)

	new parms[3]
	parms[2] = hull
	parms[0] = entbase
	parms[1] = creator

	set_task(BASESENTRYDELAY, "createsentryhead", 0, parms, 3)

	g_inBuilding[creator - 1] = true
	g_sentryOrigins[creator - 1] = origin
	emit_sound(creator, CHAN_AUTO, "sentries/building.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

	// Set user maxspeed 1.0 ...
	//g_maxSpeeds[creator - 1] = entity_get_float(creator, EV_FL_maxspeed)
	//entity_set_float(creator, EV_FL_maxspeed, 1.0)
	
	// Also set velocity of builder to 0 in case he's running down a hill and could get stuck in the parts........
	new Float:vector[3]
	vector[0] = 0.0
	vector[1] = 0.0
	vector[2] = 0.0
	entity_set_vector(creator, EV_VEC_velocity, vector)

	return true
}

public createsentryhead(parms[3]) {
	new entbase = parms[0]
	new creator = parms[1]
	new hull = parms[2]

	if (!g_inBuilding[creator - 1] || !is_user_alive(creator)) {
		// g_inBuilding is reset upon new round, then don't continue with building sentry head. Remove base and return.
		if (is_valid_ent(entbase))
			remove_entity(entbase)

		if (is_valid_ent(hull))
			remove_entity(hull)
		return
	}

	new Float:origin[3]
	origin = g_sentryOrigins[creator - 1]

	new ent = create_entity("func_breakable")
	if (!ent) {
		if (is_valid_ent(entbase))
			remove_entity(entbase)

		if (is_valid_ent(hull))
			remove_entity(hull)

		return
	}

	new Float:mins[3], Float:maxs[3]
	// Set true	size of base... if it exists!
	// Also set sentry <-> base connections, if base still exists
	new bool:entbaseIsValid = is_valid_ent(entbase) == 1 ? true : false

	if (is_valid_ent(hull)) {
		// Size is a tad bigger so that traces hit this entity first
		mins[0] = -16.1
		mins[1] = -16.1
		mins[2] = 0.0
		maxs[0] = 16.1
		maxs[1] = 16.1
		maxs[2] = 16.1 // Set to 48.0 + 16.1 when head hits base
		entity_set_size(hull, mins, maxs)
		if (entbaseIsValid) {
			entity_set_edict(entbase, BASE_ENT_HULL, hull) // invalid entity 101
			new Float:baseOrigin[3]
			entity_get_vector(entbase, EV_VEC_origin, baseOrigin) // invalid entity 101
			entity_set_origin(hull, baseOrigin)
		}
	}
	if (entbaseIsValid) {
		mins[0] = -16.0
		mins[1] = -16.0
		mins[2] = 0.0
		maxs[0] = 16.0
		maxs[1] = 16.0
		maxs[2] = 16.0
		entity_set_size(entbase, mins, maxs)

		entity_set_edict(ent, SENTRY_ENT_BASE, entbase)
		entity_set_edict(entbase, BASE_ENT_SENTRY, ent)
	}

	// Store our sentry in array
	g_sentries[g_sentriesNum] = ent

	new healthstring[16]
	num_to_str(floatround(g_HEALTHS[0]), healthstring, 15)
	DispatchKeyValue(ent, "health", healthstring)
	DispatchKeyValue(ent, "material", "6")

	DispatchSpawn(ent)
	// Change classname
	entity_set_string(ent, EV_SZ_classname, "sentry")
	// Set model
	entity_set_model(ent, "models/sentries/sentry1.mdl") // later set according to level
	// Set size
	mins[0] = -16.0
	mins[1] = -16.0
	mins[2] = 0.0
	maxs[0] = 16.0
	maxs[1] = 16.0
	maxs[2] = 48.0
	entity_set_size(ent, mins, maxs)
	//client_print(creator, print_chat, "Creating sentry %d with bounds %f", ent, BOUNDS)
	// Set origin
	entity_set_origin(ent, origin)
	// Set starting angle
	entity_get_vector(creator, EV_VEC_angles, origin)
	origin[0] = 0.0
	origin[1] += 180.0
	entity_set_float(ent, SENTRY_FL_ANGLE, origin[1])
	origin[2] = 0.0
	entity_set_vector(ent, EV_VEC_angles, origin)
	// Set solidness
	entity_set_int(ent, EV_INT_solid, SOLID_SLIDEBOX) // SOLID_SLIDEBOX
	// Set movetype
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS) // head flies, base doesn't
	// Set tilt of cannon
	set_pev(ent, PEV_SENTRY_TILT_TURRET, 127) //entity_set_byte(ent, SENTRY_TILT_TURRET, 127) // 127 is horisontal
	// Tilt of rocket launcher barrels at level 3
	set_pev(ent, PEV_SENTRY_TILT_LAUNCHER, 127) //entity_set_byte(ent, SENTRY_TILT_LAUNCHER, 127) // 127 is horisontal
	// Angle of small radar at level 3
	entity_set_float(ent, SENTRY_FL_RADARANGLE, 127.0)
	set_pev(ent, PEV_SENTRY_TILT_RADAR, 127) //entity_set_byte(ent, SENTRY_TILT_RADAR, 127) // 127 is middle


	// Set owner
	//entity_set_edict(ent, SENTRY_ENT_OWNER, creator)
	SetSentryPeople(ent, OWNER, creator)

	// Set team
	SetSentryTeam(ent, cs_get_user_team(creator)) // entity_set_int(ent, SENTRY_INT_TEAM, int:cs_get_user_team(creator))

	// Set level (not really necessary, but for looks)
	SetSentryLevel(ent, SENTRY_LEVEL_1) //entity_set_int(ent, SENTRY_INT_LEVEL, SENTRY_LEVEL_1)

	// Top color
	#if defined RANDOM_TOPCOLOR
	new topColor = random_num(0, 255)
	#else
	new topColor = cs_get_user_team(creator) == CS_TEAM_CT ? COLOR_TOP_CT : COLOR_TOP_T
	#endif
	// Bottom color
	#if defined RANDOM_BOTTOMCOLOR
	new bottomColor = random_num(0, 255)
	#else
	new bottomColor = cs_get_user_team(creator) == CS_TEAM_CT ? COLOR_BOTTOM_CT : COLOR_BOTTOM_T
	#endif

	// Set color
	new map = topColor | (bottomColor<<8)
	//spambits(creator, topColor)
	//spambits(creator, bottomColor)
	//spambits(creator, map)
	entity_set_int(ent, EV_INT_colormap, map)

	g_sentriesNum++

	emit_sound(ent, CHAN_AUTO, "sentries/turrset.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

	IncreaseSentryCount(creator, ent)

	new parm[1]
	parm[0] = ent
	set_task(g_THINKFREQUENCIES[0], "sentry_think", TASKID_THINK + parm[0], parm, 1)

	//parm[1] = random_num(0, 1)
	//parm[2] = 0
	//parm[3] = 0
	new directions = (random_num(0, 1)<<SENTRY_DIR_CANNON) | (random_num(0, 1)<<SENTRY_DIR_RADAR)
	SetSentryPenddir(ent, directions) //entity_set_int(ent, SENTRY_INT_PENDDIR, directions)

	//entity_set_float(ent, SENTRY_FL_RADARDIR, random_num(0, 1) + 0.0)

	g_inBuilding[creator - 1] = false

	if (!entbaseIsValid) {
		// Someone probably destroyed the base before head was built!
		// Sentry should go nuts. :-P
		SetSentryFiremode(ent, SENTRY_FIREMODE_NUTS) //entity_set_int(ent, SENTRY_INT_FIRE, SENTRY_FIREMODE_NUTS)
	}
}

public server_frame() {
	g_gameTime = get_gametime()
	g_deltaTime = g_gameTime - g_lastGameTime
	//server_print("Gametime: %f, Last gametime: %f", g_gameTime, g_lastGameTime)

	new tempSentries[MAXSENTRIES], Float:angles[3], tempSentriesNum = 0

	for (new i = 0; i < g_sentriesNum; i++) {
		//sentry_pendulum(g_sentries[i], g_deltaTime)
		tempSentries[i] = g_sentries[i]
		tempSentriesNum++
	}

	for (new i = 0; i < tempSentriesNum; i++) {
		//if (entity_get_float(tempSentries[i], EV_FL_nextthink) < g_game
		if (!is_valid_ent(tempSentries[i]))
			continue

		// "Crazy/spinning" sentries are destroyed when they reach a high enough speed in sentry_pendulum.
		// sentry_pendulum returns false when sentry was destroyed!
		if (!sentry_pendulum(tempSentries[i], g_deltaTime))
			continue

		if (entity_get_edict(tempSentries[i], SENTRY_ENT_SPYCAM) != 0) {
			entity_get_vector(tempSentries[i], EV_VEC_angles, angles)
			entity_set_vector(entity_get_edict(tempSentries[i], SENTRY_ENT_SPYCAM), EV_VEC_angles, angles)
		}
	}

	g_lastGameTime = g_gameTime
	return PLUGIN_CONTINUE
}

// sentry_pendulum should return false when sentry was destroyed!
bool:sentry_pendulum(sentry, Float:deltaTime) {
	switch (GetSentryFiremode(sentry)) {
		case SENTRY_FIREMODE_NO: {
			new Float:angles[3]
			entity_get_vector(sentry, EV_VEC_angles, angles)
			new Float:baseAngle = entity_get_float(sentry, SENTRY_FL_ANGLE)
			new directions = GetSentryPenddir(sentry) // entity_get_int(sentry, SENTRY_INT_PENDDIR)
			if (directions & (1<<SENTRY_DIR_CANNON)) {
				angles[1] -= (PENDULUM_INCREMENT * deltaTime) // PENDULUM_INCREMENT get_cvar_float("pend_inc")
				if (angles[1] < baseAngle - PENDULUM_MAX) {
					angles[1] = baseAngle - PENDULUM_MAX
					directions &= ~(1<<SENTRY_DIR_CANNON)
					SetSentryPenddir(sentry, directions) // entity_set_int(sentry, SENTRY_INT_PENDDIR, directions)
				}
			}
			else {
				angles[1] += (PENDULUM_INCREMENT * deltaTime) // PENDULUM_INCREMENT get_cvar_float("pend_inc")
				if (angles[1] > baseAngle + PENDULUM_MAX) {
					angles[1] = baseAngle + PENDULUM_MAX
					directions |= (1<<SENTRY_DIR_CANNON)
					SetSentryPenddir(sentry, directions) // entity_set_int(sentry, SENTRY_INT_PENDDIR, directions)
				}
			}

			entity_set_vector(sentry, EV_VEC_angles, angles);

			if (GetSentryLevel(sentry) == SENTRY_LEVEL_3) {
				//new radarAngle = entity_get_byte(sentry, SENTRY_TILT_RADAR)
				//SENTRY_FL_RADARANGLE
				new Float:radarAngle = entity_get_float(sentry, SENTRY_FL_RADARANGLE)

				if (directions & (1<<SENTRY_DIR_RADAR)) {
					radarAngle = radarAngle - RADAR_INCREMENT // get_cvar_float("radar_increment")
					if (radarAngle < 0.0) {
						radarAngle = 0.0
						directions &= ~(1<<SENTRY_DIR_RADAR)
						SetSentryPenddir(sentry, directions) // entity_set_int(sentry, SENTRY_INT_PENDDIR, directions)
					}
				}
				else {
					radarAngle = radarAngle + RADAR_INCREMENT // get_cvar_float("radar_increment")
					if (radarAngle > 255.0) {
						radarAngle = 255.0
						directions |= (1<<SENTRY_DIR_RADAR)
						SetSentryPenddir(sentry, directions) // entity_set_int(sentry, SENTRY_INT_PENDDIR, directions)
					}
				}
				entity_set_float(sentry, SENTRY_FL_RADARANGLE, radarAngle)
				set_pev(sentry, PEV_SENTRY_TILT_RADAR, floatround(radarAngle)) //entity_set_byte(sentry, SENTRY_TILT_RADAR, floatround(radarAngle))
			}

			return true
		}
		case SENTRY_FIREMODE_NUTS: {
			new Float:angles[3]
			entity_get_vector(sentry, EV_VEC_angles, angles)

			new Float:spinSpeed = entity_get_float(sentry, SENTRY_FL_SPINSPEED)
			if (GetSentryPenddir(sentry) /*entity_get_int(sentry, SENTRY_INT_PENDDIR)*/ & (1<<SENTRY_DIR_CANNON)) {
				angles[1] -= (spinSpeed * deltaTime)
				if (angles[1] < 0.0) {
					angles[1] = 360.0 + angles[1]
				}
			}
			else {
				angles[1] += (spinSpeed * deltaTime)
				if (angles[1] > 360.0) {
					angles[1] = angles[1] - 360.0
				}
			}
			// Increment speed raise
			entity_set_float(sentry, SENTRY_FL_SPINSPEED, (spinSpeed += random_float(1.0, 2.0)))

			new Float:maxSpin = entity_get_float(sentry, SENTRY_FL_MAXSPIN)
			if (maxSpin == 0.0) {
				// Set rotation speed to explode at
				entity_set_float(sentry, SENTRY_FL_MAXSPIN, maxSpin = random_float(500.0, 750.0))
				//client_print(0, print_chat, "parm3 set to %d", parm[3])
			}
			else if (spinSpeed >= maxSpin) {
				//client_print(0, print_chat, "Detonating!")
				sentry_detonate(sentry, false, false)
				//remove_entity(parm[0])
				return false
			}
			entity_set_vector(sentry, EV_VEC_angles, angles);

			return true
		}
	}
	
	return true
}

// Checks the contents of eight points corresponding to the bbox around ent origin. Also does a trace from origin to each point. If anything goes wrong, report a hit.
// TODO: high bounds should get higher, so that building in tight places not gets sentries stuck in roof... TraceCheckCollides
bool:TraceCheckCollides(Float:origin[3], const Float:BOUNDS) {
	new Float:traceEnds[8][3], Float:traceHit[3], hitEnt

	// x, z, y
	traceEnds[0][0] = origin[0] - BOUNDS
	traceEnds[0][1] = origin[1] - BOUNDS
	traceEnds[0][2] = origin[2] - BOUNDS

	traceEnds[1][0] = origin[0] - BOUNDS
	traceEnds[1][1] = origin[1] - BOUNDS
	traceEnds[1][2] = origin[2] + BOUNDS

	traceEnds[2][0] = origin[0] + BOUNDS
	traceEnds[2][1] = origin[1] - BOUNDS
	traceEnds[2][2] = origin[2] + BOUNDS

	traceEnds[3][0] = origin[0] + BOUNDS
	traceEnds[3][1] = origin[1] - BOUNDS
	traceEnds[3][2] = origin[2] - BOUNDS
	//
	traceEnds[4][0] = origin[0] - BOUNDS
	traceEnds[4][1] = origin[1] + BOUNDS
	traceEnds[4][2] = origin[2] - BOUNDS

	traceEnds[5][0] = origin[0] - BOUNDS
	traceEnds[5][1] = origin[1] + BOUNDS
	traceEnds[5][2] = origin[2] + BOUNDS

	traceEnds[6][0] = origin[0] + BOUNDS
	traceEnds[6][1] = origin[1] + BOUNDS
	traceEnds[6][2] = origin[2] + BOUNDS

	traceEnds[7][0] = origin[0] + BOUNDS
	traceEnds[7][1] = origin[1] + BOUNDS
	traceEnds[7][2] = origin[2] - BOUNDS

	for (new i = 0; i < 8; i++) {
		if (point_contents(traceEnds[i]) != CONTENTS_EMPTY)
			return true

		hitEnt = trace_line(0, origin, traceEnds[i], traceHit)
		if (hitEnt != 0)
			return true
		for (new j = 0; j < 3; j++) {
			if (traceEnds[i][j] != traceHit[j])
				return true
		}
	}

	return false
}


//#define	TE_TRACER			6		// tracer effect from point to point
// coord, coord, coord (start)
// coord, coord, coord (end)

tracer(Float:start[3], Float:end[3]) {
	//new start_[3]
	new start_[3], end_[3]
	FVecIVec(start, start_)
	FVecIVec(end, end_)
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY) //  MSG_PAS MSG_BROADCAST
	write_byte(TE_TRACER)
	write_coord(start_[0])
	write_coord(start_[1])
	write_coord(start_[2])
	write_coord(end_[0])
	write_coord(end_[1])
	write_coord(end_[2])
	message_end()
}

/*
#define TE_BREAKMODEL		108		// box of models or sprites
// coord, coord, coord (position)
// coord, coord, coord (size)
// coord, coord, coord (velocity)
// byte (random velocity in 10's)
// short (sprite or model index)
// byte (count)
// byte (life in 0.1 secs)
// byte (flags)
*/

stock create_explosion(Float:origin_[3]) {
	new origin[3]
	FVecIVec(origin_, origin)
	//client_print(0, print_chat, "Creating explosion at %d %d %d", origin[0], origin[1], origin[2])

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, origin) // MSG_PAS not really good here
	write_byte(TE_EXPLOSION)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_short(g_sModelIndexFireball)
	write_byte(random_num(0, 20) + 50) // scale * 10 // random_num(0, 20) + 20
	write_byte(12) // framerate
	write_byte(TE_EXPLFLAG_NONE)
	message_end()

	/*
	write_byte(TE_EXPLOSION2) lame too
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	write_byte(1) // (starting color)
	write_byte(200) // (num colors)
	message_end()
	*/

	/*
	write_byte(TE_TAREXPLOSION) // hmm this one is really ugly :)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2])
	message_end()
	*/

	// Blast stuff away
	genericShock(origin_, SENTRYEXPLODERADIUS, "weaponbox", 32, SENTRYSHOCKPOWER, OBJECT_GENERIC)
	genericShock(origin_, SENTRYEXPLODERADIUS, "armoury_entity", 32, SENTRYSHOCKPOWER, OBJECT_ARMOURY)
	genericShock(origin_, SENTRYEXPLODERADIUS, "player", 32, SENTRYSHOCKPOWER, OBJECT_PLAYER)
	genericShock(origin_, SENTRYEXPLODERADIUS, "grenade", 32, SENTRYSHOCKPOWER, OBJECT_GRENADE)
	genericShock(origin_, SENTRYEXPLODERADIUS, "hostage_entity", 32, SENTRYSHOCKPOWER, OBJECT_GENERIC)

	// Hurt ppl in vicinity

	new Float:playerOrigin[3], Float:distance, Float:flDmgToDo, Float:dmgbase = DMG_EXPLOSION_TAKE + 0.0, newHealth
	for (new i = 1; i <= g_MAXPLAYERS; i++) {
		if (!is_user_alive(i) || get_user_godmode(i))
			continue

		entity_get_vector(i, EV_VEC_origin, playerOrigin)
		distance = vector_distance(playerOrigin, origin_)
		if (distance <= SENTRYEXPLODERADIUS) {
			flDmgToDo = dmgbase - (dmgbase * (distance / SENTRYEXPLODERADIUS))
			//client_print(i, print_chat, "flDmgToDo = %f, dmgbase = %f, distance = %f, SENTRYEXPLODERADIUS = %f", flDmgToDo, dmgbase, distance, SENTRYEXPLODERADIUS)
			newHealth = get_user_health(i) - floatround(flDmgToDo)
			if (newHealth <= 0) {
				// Somehow if player is killed here server crashes out saying some message (Damage or Death) has not been sent yet when trying to send another message.
				// By delaying death with 0.0 (huuh?) seconds this seems to be fixed.
				set_task(0.0, "TicketToHell", i)
				continue
			}

			set_user_health(i, newHealth)

			message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, {0,0,0}, i)
			write_byte(floatround(flDmgToDo))
			write_byte(floatround(flDmgToDo))
			write_long(DMG_BLAST)
			write_coord(origin[0])
			write_coord(origin[1])
			write_coord(origin[2])
			message_end()
		}
	}
}

// Hacks, damn you!
public TicketToHell(player) {
	if (!is_user_connected(player))
		return
	new frags = get_user_frags(player)
	user_kill(player, 1) // don't decrease frags
	new parms[4]
	parms[0] = player
	parms[1] = frags
	parms[2] = cs_get_user_deaths(player)
	parms[3] = int:cs_get_user_team(player)
	set_task(0.0, "DelayedScoreInfoUpdate", 0, parms, 4)
}

public DelayedScoreInfoUpdate(parms[4]) {
	scoreinfo_update(parms[0], parms[1], parms[2], parms[3])
}

stock genericShock(Float:hitPointOrigin[3], Float:radius, classString[], maxEntsToFind, Float:power, OBJECTTYPE:objecttype) { // bool:isthisplayer, bool:isthisarmouryentity, bool:isthisgrenade/*, Float:pullup*/) {
	new entList[32]
	if (maxEntsToFind > 32)
		maxEntsToFind = 32

	new entsFound = find_sphere_class(0, classString, radius, entList, maxEntsToFind, hitPointOrigin)

	new Float:entOrigin[3]
	new Float:velocity[3]
	new Float:cOrigin[3]

	for (new j = 0; j < entsFound; j++) {
		switch (objecttype) {
			case OBJECT_PLAYER: {
				if (!is_user_alive(entList[j])) // Don't move dead players
					continue
			}
			case OBJECT_GRENADE: {
				new l_model[16]
				entity_get_string(entList[j], EV_SZ_model, l_model, 15)
				if (equal(l_model, "models/w_c4.mdl")) // don't move planted c4s :-P
					continue
			}
		}

		entity_get_vector(entList[j], EV_VEC_origin, entOrigin) // get_entity_origin(entList[j],entOrigin)

		new Float:distanceNadePl = vector_distance(entOrigin, hitPointOrigin)

		// Stuff on ground AND below explosion are "placed" a distance above explosion Y-wise ([2]), so that they fly off ground etc.
		if (entity_is_on_ground(entList[j]) && entOrigin[2] < hitPointOrigin[2])
			entOrigin[2] = hitPointOrigin[2] + distanceNadePl

		entity_get_vector(entList[j], EV_VEC_velocity, velocity)

		cOrigin[0] = (entOrigin[0] - hitPointOrigin[0]) * radius / distanceNadePl + hitPointOrigin[0]
		cOrigin[1] = (entOrigin[1] - hitPointOrigin[1]) * radius / distanceNadePl + hitPointOrigin[1]
		cOrigin[2] = (entOrigin[2] - hitPointOrigin[2]) * radius / distanceNadePl + hitPointOrigin[2]

		velocity[0] += (cOrigin[0] - entOrigin[0]) * power
		velocity[1] += (cOrigin[1] - entOrigin[1]) * power
		velocity[2] += (cOrigin[2] - entOrigin[2]) * power

		entity_set_vector(entList[j], EV_VEC_velocity, velocity)
	}
}

stock entity_is_on_ground(entity) {
	return entity_get_int(entity, EV_INT_flags) & FL_ONGROUND
}


// NO message sending in this one!
public message_tempentity() {
	if (get_msg_args() != 15 && get_msg_arg_int(1) != TE_BREAKMODEL)
		return PLUGIN_CONTINUE

	//server_print("A sentry broke start... params = %d", read_datanum())
	// Something broke, maybe it was one of our sentries. Loop through all sentries to see if any of them has health <=0.
	//new parms[3]
	for (new i = 0; i < g_sentriesNum; i++) {
		if (entity_get_float(g_sentries[i], EV_FL_health) <= 0.0) {

			// Way 1:
			/*
			parms[0] = i
			parms[1] = false
			parms[2] = true
			set_task(5.0, "DetonateSentryLater", TASKID_SENTRYEXPLODE + i, parms, 3)
			server_print("Sentry %d detonated...", g_sentries[i])
			*/
			
			// Way 2:
			sentry_detonate(i, false, true)

			// Rewind iteration loop; the last sentry may have been destroyed also
			i--
		}
	}

	//server_print("A sentry broke end...")

	return PLUGIN_CONTINUE
}

/*
public DetonateSentryLater(parms[3]) {
	sentry_detonate(parms[0], bool:parms[1], bool:parms[2])
}
*/


/*
public think_sentry(ent) {
	// Hmm this place can be used to tell when a sentry breaks...

	sentry_detonate(ent, false)
	// All of these always give 0 values :-(
	//client_print(0, print_chat, "%d thinks: inflictor: %d, EV_ENT_enemy: %d, EV_ENT_aiment: %d, EV_ENT_chain: %d, EV_ENT_owner: %d", ent, entity_get_edict(ent, EV_ENT_dmg_inflictor), entity_get_edict(ent, EV_ENT_enemy), entity_get_edict(ent, EV_ENT_aiment), entity_get_edict(ent, EV_ENT_chain), entity_get_edict(ent, EV_ENT_owner))

	return PLUGIN_CONTINUE
}
*/
public think_sentrybase(sentrybase) {
	// Hmm this place can be used to tell when a sentrybase breaks...
	sentrybase_broke(sentrybase)

	return PLUGIN_CONTINUE
}

sentrybase_broke(sentrybase) {
	// Get relations
	new hull = entity_get_edict(sentrybase, BASE_ENT_HULL)
	new sentry = entity_get_edict(sentrybase, BASE_ENT_SENTRY)

	if (is_valid_ent(sentrybase)) {
		if (hull) {
			//entity_set_edict(hull, HULL_ENT_BASE, 0)
			remove_entity(hull)
		}
		remove_entity(sentrybase)
	}

	// Sentry could be 0 which should mean it has not been built yet. No need to do anything in that case.
	if (sentry == 0)
		return

	entity_set_edict(sentry, SENTRY_ENT_BASE, 0)

	SetSentryFiremode(sentry, SENTRY_FIREMODE_NUTS) // entity_set_int(sentry, SENTRY_INT_FIRE, SENTRY_FIREMODE_NUTS)
	// Set cannon tower straight, calculate tower tilt offset to angles later... entityviewhitpoint fn needs changing for this to use a custom angle vector
	set_pev(sentry, PEV_SENTRY_TILT_TURRET, 127) //entity_set_byte(sentry, SENTRY_TILT_TURRET, 127)
}

sentry_detonate(sentry, bool:quiet, bool:isIndex) {
	// Explode!
	new i
	if (isIndex) {
		i = sentry
		sentry = g_sentries[sentry]
		if (!is_valid_ent(sentry))
			return
	}
	else {
		if (!is_valid_ent(sentry))
			return
		// Find index of this sentry
		for (new j = 0; j < g_sentriesNum; j++) {
			if (g_sentries[j] == sentry) {
				i = j
				break
			}
		}
	}


	// Kill tasks
	remove_task(TASKID_THINK + sentry) // removes think
	remove_task(TASKID_THINKPENDULUM + sentry) // removes think
	remove_task(TASKID_SENTRYONRADAR + sentry) // in case someone's displaying this on radar

	new owner = GetSentryPeople(sentry, OWNER)

	// If sentry has a spycam, call the stuff to remove it now
	if (entity_get_edict(sentry, SENTRY_ENT_SPYCAM) != 0) {
		remove_task(TASKID_SPYCAM + owner) // remove the ongoing task...
		// And call this now on our own...
		new parms[3]
		parms[0] = owner
		parms[1] = entity_get_edict(sentry, SENTRY_ENT_SPYCAM)
		parms[2] = sentry
		DestroySpyCam(parms)
	}

	if (!quiet) {
		#if defined EXPLODINGSENTRIES
		new Float:origin[3]
		entity_get_vector(sentry, EV_VEC_origin, origin)
		
		//server_print("[%s] sentry_detonate, Creating explosion because sentry detonates...", PLUGINNAME)
		create_explosion(origin)
		//server_print("[%s] sentry_detonate, Done creating explosion because sentry detonated!", PLUGINNAME)

		/*
		new parms[4]
		entity_get_vector(sentry, EV_VEC_origin, origin)
		parms[0] = int:origin[0]
		parms[1] = int:origin[1]
		parms[2] = int:origin[2]
		parms[3] = owner
		set_task(0.0, "ExplodeAfterThis", 0, parms, 4)
		*/

		client_print(owner, print_center, "Your sentry gun detonated!")
		#endif
	}
	DecreaseSentryCount(owner, sentry)
	//SetHasSentry(GetSentryPeople(sentry, OWNER), false)

	// Remove base first, and before that its hull
	if (GetSentryFiremode(sentry) != SENTRY_FIREMODE_NUTS) {
		new base = entity_get_edict(sentry, SENTRY_ENT_BASE)
		remove_entity(entity_get_edict(base, BASE_ENT_HULL))
		remove_entity(base)
	}

	// Remove this entity
	remove_entity(sentry) // set_task(0.0, "delayedremovalofentity", sentry)

	// Put the last sentry in the deleted entity's place
	g_sentries[i] = g_sentries[g_sentriesNum - 1]
	// Lower nr of sentries
	g_sentriesNum--
}

/*
#if defined EXPLODINGSENTRIES
public ExplodeAfterThis(parms[4]) {
	new Float:origin[3]
	origin[0] = Float:parms[0]
	origin[1] = Float:parms[1]
	origin[2] = Float:parms[2]
	server_print("[%s] ExplodeAfterThis, Creating explosion because sentry detonates...", PLUGINNAME)
	create_explosion(origin)
	server_print("[%s] ExplodeAfterThis, Done creating explosion because sentry detonated!", PLUGINNAME)
	// Report to owner that it broke
	client_print(parms[3], print_center, "Your sentry gun detonated!")
}
#endif
*/

sentry_detonate_by_owner(owner, bool:quiet) {
	//server_print("[%s] sentry_detonate_by_owner quiet: %d", PLUGINNAME, quiet)
	/*
	for (new i = g_MAXPLAYERS + 1, classname[7]; i < g_MAXENTITIES; i++) {
		if (!is_valid_ent(i))
			continue
		entity_get_string(i, EV_SZ_classname, classname, 6)
		if (!equal(classname, "sentry"))
			continue

		if (entity_get_edict(i, SENTRY_ENT_OWNER) == owner) {
			sentry_detonate(i, quiet)
			return
		}
	}
	*/

	for(new i = 0; i < g_sentriesNum; i++) {
		if (GetSentryPeople(g_sentries[i], OWNER) == owner) {
			//server_print("[%s] DEBUG - sentry_detonate_by_owner - removing sentry %d (with index %d) as %d is the owner of it... Quiet: %s", PLUGINNAME, g_sentries[i], i, owner, quiet ? "yes" : "no")
			sentry_detonate(i, quiet, true)
			break
		}
	}
}

public client_disconnect(id) {
	while (GetSentryCount(id) > 0) {
		//server_print("[%s] client_disconnect: calling sentry_detonate_by_owner quiet: no, player %d's sentrycount: %d", PLUGINNAME, id, GetSentryCount(id))
		sentry_detonate_by_owner(id, false)
	}
}

public sentry_think(parm[1]) {
	if (!is_valid_ent(parm[0])) {
		client_print(0, print_chat, "%d is not a valid ent, ending sentry_think!", parm[0])
		return
	}

	new ent = parm[0]

	// Check that our owner is still on the same team as us. Else explode! (must be quiet here!!)
	if (cs_get_user_team(GetSentryPeople(ent, OWNER)) != GetSentryTeam(ent)) {
		// Act as if client disconnected... all sentries should be removed properly?
		client_disconnect(GetSentryPeople(ent, OWNER))
		/*
		// Just don't call client_disconnect() here! Because that destroys sentries non-quietly, so that "msg 23 not been started" bail happens.
		new owner = GetSentryPeople(ent, OWNER)
		while (GetSentryCount(owner) > 0) {
			//server_print("[%s] team mismatch: calling sentry_detonate_by_owner quiet: yes, player %d's sentrycount: %d", PLUGINNAME, owner, GetSentryCount(owner))
			sentry_detonate_by_owner(owner, true)
		}
		*/

		return
	}

	new Float:sentryOrigin[3], Float:hitOrigin[3], hitent
	entity_get_vector(ent, EV_VEC_origin, sentryOrigin)
	sentryOrigin[2] += CANNONHEIGHTFROMFEET // Move up some, this should be the Y origin of the cannon

	// If fire, do a trace and fire
	new target = GetSentryPeople(ent, TARGET) // entity_get_edict(ent, SENTRY_ENT_TARGET)
	new firemode = GetSentryFiremode(ent)
	if (firemode == SENTRY_FIREMODE_YES && cs_get_user_team(target) != GetSentryTeam(ent) /*CsTeams:entity_get_int(ent, SENTRY_INT_TEAM)*/) { // temp removed team check:
		if (!is_user_alive(target)) {
			SetSentryFiremode(ent, SENTRY_FIREMODE_NO)
			goto Rethink // pasta code :-)
		}

		new sentryLevel = GetSentryLevel(ent)

		// Is target still visible?
		new Float:targetOrigin[3]
		entity_get_vector(target, EV_VEC_origin, targetOrigin)

		// Adjust for ducking. This is still not 100%. :-(
		if (entity_get_int(target, EV_INT_flags) & FL_DUCKING) {
			//client_print(0, print_chat, "%d: Target %d is ducking, moving its origin up by %f", ent, target, TARGETUPMODIFIER)
			targetOrigin[2] += TARGETUPMODIFIER
		}

		hitent = trace_line(ent, sentryOrigin, targetOrigin, hitOrigin)
		if (hitent == entity_get_edict(ent, SENTRY_ENT_BASE)) {
			// We traced into our base, do another trace from there
			hitent = trace_line(hitent, hitOrigin, targetOrigin, hitOrigin)
			//client_print(0, print_chat, "%d: I first hit my own base, and after doing another trace I hit %d, target: %d", ent, hitent, target)
		}

		if (hitent != target && is_user_alive(hitent) && GetSentryTeam(ent) /*CsTeams:entity_get_int(ent, SENTRY_INT_TEAM)*/ != cs_get_user_team(hitent)) {
			// Another new enemy target got into scope, pick this new enemy as a new target...
			target = hitent
			SetSentryPeople(ent, TARGET, hitent) //entity_set_edict(ent, SENTRY_ENT_TARGET, hitent)
		}
		if (hitent == target) {
			// Fire here
			//client_print(0, print_chat, "%d: I see %d, will fire. Dist: %f, Hitorigin: %f %f %f", ent, hitent, dist, hitOrigin[0], hitOrigin[1], hitOrigin[2])
			sentry_turntotarget(ent, sentryOrigin, target, targetOrigin)
			// Firing sound
			emit_sound(ent, CHAN_WEAPON, g_FIRESOUNDS[random_num(0, 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)

			new Float:hitRatio = random_float(0.0, 1.0) - g_HITRATIOS[sentryLevel] // ie 0.5 - 0.7 = -0.2, a hit and 0.8 - 0.7 = a miss by 0.1

			if (!get_user_godmode(target) && hitRatio <= 0.0) {
				// Do damage to player
				sentry_damagetoplayer(ent, sentryLevel, sentryOrigin, target)
				// Tracer effect to target
			}
			else {
				// Tracer hitOrigin adjusted for miss... (hmm don't think this part is right yet)
				/*
				MAKE_VECTORS(pEnt->v.v_angle);
				vVector = gpGlobals->v_forward * iVelocity;

				vRet[0] = amx_ftoc(vVector.x);
				vRet[1] = amx_ftoc(vVector.y);
				vRet[2] = amx_ftoc(vVector.z);
				*/
				new Float:sentryAngle[3] = {0.0, 0.0, 0.0}

				new Float:x = hitOrigin[0] - sentryOrigin[0]
				new Float:z = hitOrigin[1] - sentryOrigin[1]
				new Float:radians = floatatan(z/x, radian)
				sentryAngle[1] = radians * g_ONEEIGHTYTHROUGHPI
				if (hitOrigin[0] < sentryOrigin[0])
					sentryAngle[1] -= 180.0

				new Float:h = hitOrigin[2] - sentryOrigin[2]
				new Float:b = vector_distance(sentryOrigin, hitOrigin)
				radians = floatatan(h/b, radian)
				sentryAngle[0] = radians * g_ONEEIGHTYTHROUGHPI;

				sentryAngle[0] += random_float(-10.0 * hitRatio, 10.0 * hitRatio) // aim is a little off here :-)
				sentryAngle[1] += random_float(-10.0 * hitRatio, 10.0 * hitRatio) // aim is a little off here :-)
				engfunc(EngFunc_MakeVectors, sentryAngle)
				new Float:vector[3]
				get_global_vector(GL_v_forward, vector)
				for (new i = 0; i < 3; i++)
					vector[i] *= 1000;

				new Float:traceEnd[3]
				for (new i = 0; i < 3; i++)
					traceEnd[i] = vector[i] + sentryOrigin[i]

				new hitEnt = ent
				while((hitEnt = trace_line(hitEnt, hitOrigin, traceEnd, hitOrigin))) {
					// continue tracing until hit nothing...
				}

				//for (new i = 0; i < 3; i++)
					//hitOrigin[i] += random_float(-5.0, 5.0)
			}
			tracer(sentryOrigin, hitOrigin)

			// Don't do any more here
			//set_task(THINKFIREFREQUENCY, "sentry_think", ent)
			set_task(THINKFIREFREQUENCY, "sentry_think", TASKID_THINK + parm[0], parm, 1)
			return
		}
		else {
			//client_print(target, print_chat, "%d: Lost track of you! Hit: %d", ent, target, hitent)
			//client_print(0, print_chat, "%d: I can't see %d, i see %d... will not fire. Dist: %f, Hitorigin: %f %f %f", ent, entity_get_edict(ent, SENTRY_ENT_TARGET), hitent, dist, hitOrigin[0], hitOrigin[1], hitOrigin[2])
			// Else target isn't still visible, unset fire state.
			SetSentryFiremode(ent, SENTRY_FIREMODE_NO) // entity_set_int(ent, SENTRY_INT_FIRE, SENTRY_FIREMODE_NO)
			// vvvv - Not really necessary but it's cleaner. Leave it out for now and be sure to set a fresh target each time SENTRY_INT_FIRE is set to 1!!!
			// vvvv - Else this is breaking this think altogether! :-(
			//entity_set_edict(ent, SENTRY_ENT_TARGET, 0)

			// Don't return here, continue with searching for targets below...
		}
	}
	else if (firemode == SENTRY_FIREMODE_NUTS) {
		//client_print(0, print_chat, "Gone nuts firing... spin speed: %f", entity_get_float(ent, SENTRY_FL_SPINSPEED))
		new hitEnt = entityviewhitpoint(ent, sentryOrigin, hitOrigin)
		// Firing sound
		emit_sound(ent, CHAN_WEAPON, "weapons/m249-1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		// Tracer effect
		tracer(sentryOrigin, hitOrigin)

		if (is_user_connected(hitEnt) && is_user_alive(hitEnt) && !get_user_godmode(hitEnt)) {
			// Do damage to player
			sentry_damagetoplayer(ent, GetSentryLevel(ent), sentryOrigin, hitEnt)
		}

		// Don't do any more here
		set_task(THINKFIREFREQUENCY, "sentry_think", TASKID_THINK + parm[0], parm, 1)
		return
	}
	else {
		//client_print(0, print_chat, "My firemode: %d", firemode)
		// Either wasn't meant to fire or target was not a valid entity or dead, set both to 0.
		//client_print(target, print_chat, "%d: Fire: %d Target: %d (%s)", ent, GetSentryFiremode(ent), target, is_valid_ent(target) ? (is_user_alive(target) ? "alive" : "dead") : "invalid")

		//entity_set_int(ent, SENTRY_INT_FIRE, 0)
		//entity_set_edict(ent, SENTRY_ENT_TARGET, 0)
	}

	// Tell what players you see
	if (random_num(0, 99) < 10)
		emit_sound(ent, CHAN_AUTO, "sentries/turridle.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)

	new closestTarget = 0, Float:closestDistance, Float:distance, Float:closestOrigin[3], Float:playerOrigin[3], CsTeams:sentryTeam = GetSentryTeam(ent) /*entity_get_int(ent, SENTRY_INT_TEAM)*/
	for (new i = 1; i <= g_MAXPLAYERS; i++) {
		if (!is_user_connected(i) || !is_user_alive(i) || cs_get_user_team(i) == CsTeams:sentryTeam) // temporarily dont check team:
			continue

		entity_get_vector(i, EV_VEC_origin, playerOrigin)

		// Adjust for ducking. This is still not 100%. :-(
		if (entity_get_int(i, EV_INT_flags) & FL_DUCKING) {
			//client_print(0, print_chat, "%d: Target %d is ducking, moving its origin up by %f", ent, target, TARGETUPMODIFIER)
			playerOrigin[2] += TARGETUPMODIFIER
		}

		//playerOrigin[2] += TARGETUPMODIFIER

		hitent = trace_line(ent, sentryOrigin, playerOrigin, hitOrigin)
		if (hitent == entity_get_edict(ent, SENTRY_ENT_BASE)) {
			// We traced into our base, do another trace from there
			hitent = trace_line(hitent, hitOrigin, playerOrigin, hitOrigin)
			//client_print(0, print_chat, "%d (scanning): I first hit my own base, and after doing another trace I hit %d, target: %d", ent, hitent, i)
		}
		//client_print(0, print_chat, "%d: t: %f %f %f - %f %f %f - %f %f %f, i: %d hitent: %d", ent, sentryOrigin[0], sentryOrigin[1], sentryOrigin[2], playerOrigin[0], playerOrigin[1], playerOrigin[2], hitOrigin[0], hitOrigin[1], hitOrigin[2], i, hitent)
		if (hitent == i) {
			//len += format(seethese[len], 63 - len, "%d,", hitent)

			distance = vector_distance(sentryOrigin, playerOrigin)
			closestOrigin = playerOrigin

			if (distance < closestDistance || closestTarget == 0) {
				closestTarget = i
				closestDistance = distance
			}
		}
	}

	if (closestTarget) {
		// We found a target, play sound and turn to target
		emit_sound(ent, CHAN_AUTO, "sentries/turrspot.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		sentry_turntotarget(ent, sentryOrigin, closestTarget, closestOrigin)

		// Set to fire mode and set target (always set also a new target when setting fire mode 1!!!)
		SetSentryFiremode(ent, SENTRY_FIREMODE_YES) // entity_set_int(ent, SENTRY_INT_FIRE, SENTRY_FIREMODE_YES)
		SetSentryPeople(ent, TARGET, closestTarget) // entity_set_edict(ent, SENTRY_ENT_TARGET, closestTarget)
		// Set radar straight...
		entity_set_float(ent, SENTRY_FL_RADARANGLE, 127.0)
		set_pev(ent, PEV_SENTRY_TILT_RADAR, 127)
	}
	else // this shouldn't be necessary, but...
		SetSentryFiremode(ent, SENTRY_FIREMODE_NO) // entity_set_int(ent, SENTRY_INT_FIRE, SENTRY_FIREMODE_NO)

	Rethink:
	set_task(g_THINKFREQUENCIES[GetSentryLevel(ent)], "sentry_think", TASKID_THINK + parm[0], parm, 1)
}

stock sentry_damagetoplayer(sentry, sentryLevel, Float:sentryOrigin[3], target) {
	new newHealth = get_user_health(target) - g_DMG[sentryLevel]

	if (newHealth <= 0) {
		new targetFrags = get_user_frags(target) + 1
		new owner = GetSentryPeople(sentry, OWNER)
		new ownerFrags = get_user_frags(owner) + 1
		set_user_frags(target, targetFrags) // otherwise frags are subtracted from victim for dying (!!)
		set_user_frags(owner, ownerFrags)
		// Give money to player here
		new contributors[3], moneyRewards[33] = {0, ...}
		contributors[0] = owner
		contributors[1] = GetSentryPeople(sentry, UPGRADER_1)
		contributors[2] = GetSentryPeople(sentry, UPGRADER_2)
		for (new i = SENTRY_LEVEL_1; i <= sentryLevel; i++) {
			moneyRewards[contributors[i]] += g_SENTRYFRAGREWARDS[i]
		}
		for (new i = 1; i <= g_MAXPLAYERS; i++) {
			if (moneyRewards[i] && is_user_connected(i))
				cs_set_user_money(i, cs_get_user_money(i) + moneyRewards[i])
		}

		message_begin(MSG_ALL, g_msgDeathMsg, {0, 0, 0} ,0)
		write_byte(owner)
		write_byte(target)
		write_byte(0)
		write_string("sentry gun")
		message_end()

		scoreinfo_update(owner, ownerFrags, cs_get_user_deaths(owner), int:cs_get_user_team(owner))
		//scoreinfo_update(target, targetFrags, targetDeaths, targetTeam) // dont need to update frags of victim, because it's done after set_user_health

		set_msg_block(g_msgDeathMsg, BLOCK_ONCE)

		set_user_health(target, newHealth)

		return // don't send dmg message to dying player... I think.
	}

	set_user_health(target, newHealth)

	message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, {0,0,0}, target) //
	write_byte(g_DMG[sentryLevel]) // write_byte(DMG_SAVE)
	write_byte(g_DMG[sentryLevel])
	write_long(DMG_BULLET)
	write_coord(floatround(sentryOrigin[0]))
	write_coord(floatround(sentryOrigin[1]))
	write_coord(floatround(sentryOrigin[2]))
	message_end()
}

scoreinfo_update(id, frags, deaths, team) {
	// Send msg to update ppls scoreboards.
	/*
	MESSAGE_BEGIN( MSG_ALL, gmsgScoreInfo );
		WRITE_BYTE( params[1] );
		WRITE_SHORT( pPlayer->v.frags );
		WRITE_SHORT( params[2] );
		WRITE_SHORT( 0 );
		WRITE_SHORT( g_pGameRules->GetTeamIndex( m_szTeamName ) + 1 );
	MESSAGE_END();

	*/
	message_begin(MSG_ALL, g_msgScoreInfo)
	write_byte(id)
	write_short(frags)
	write_short(deaths)
	write_short(0)
	write_short(team)
	message_end()
}

sentry_turntotarget(ent, Float:sentryOrigin[3], target, Float:closestOrigin[3]) {
	if (target) {
		new name[32]
		get_user_name(target, name, 31)

	// Alter ent's angle
		new Float:newAngle[3]
		entity_get_vector(ent, EV_VEC_angles, newAngle)
		new Float:x = closestOrigin[0] - sentryOrigin[0]
		new Float:z = closestOrigin[1] - sentryOrigin[1]
		//new Float:y = closestOrigin[2] - sentryOrigin[2]
		/*
		//newAngle[0] = floatasin(x/floatsqroot(x*x+y*y), degrees)
		newAngle[1] = floatasin(z/floatsqroot(x*x+z*z), degrees)
		*/

		new Float:radians = floatatan(z/x, radian)
		newAngle[1] = radians * g_ONEEIGHTYTHROUGHPI
		if (closestOrigin[0] < sentryOrigin[0])
			newAngle[1] -= 180.0

		entity_set_float(ent, SENTRY_FL_ANGLE, newAngle[1])
		// Tilt is handled thorugh the EV_BYTE_controller1 member. 0-255 are the values, 127ish should be horisontal aim, 255 is furthest down (about 50 degrees off)
		// and 0 is also about 50 degrees up. Scope = ~100 degrees

		// Set tilt
		new Float:h = closestOrigin[2] - sentryOrigin[2]
		new Float:b = vector_distance(sentryOrigin, closestOrigin)
		radians = floatatan(h/b, radian)
		new Float:degs = radians * g_ONEEIGHTYTHROUGHPI;
		// Now adjust EV_BYTE_controller1
		// Each degree corresponds to about 100/256 "bytes", = ~0,39 byte / degree (ok this is not entirely true, just tweaked for now with SENTRYTILTRADIUS)
		new Float:RADIUS = SENTRYTILTRADIUS // get_cvar_float("sentry_tiltradius");
		new Float:degreeByte = RADIUS/256.0; // tweak radius later
		new Float:tilt = 127.0 - degreeByte * degs; // 127 is center of 256... well, almost
		//client_print(GetSentryPeople(ent, OWNER), print_chat, "%d: Setting tilt to %d", ent, floatround(tilt))
		set_pev(ent, PEV_SENTRY_TILT_TURRET, floatround(tilt)) //entity_set_byte(ent, SENTRY_TILT_TURRET, floatround(tilt))
		entity_set_vector(ent, EV_VEC_angles, newAngle)
	}
	else {
		//entity_set_int(ent, SENTRY_INT_FIRE, 0)
		//entity_set_edict(ent, SENTRY_ENT_TARGET, 0)
		//client_print(0, print_chat, "%d: I don't see anyone.", ent)
	}
}

public menumain(id) {
	if (!is_user_alive(id))
		return PLUGIN_HANDLED

	menumain_starter(id)

	return PLUGIN_HANDLED
}

AimingAtSentry(id, bool:alwaysReturn = false) {
	//new Float:hitOrigin[3]
	//new hitEnt = userviewhitpoint(id, hitOrigin)
	new hitEnt, bodyPart
	//
	if (get_user_aiming(id, hitEnt, bodyPart) == 0.0)
		return 0

	//if (get_user_aiming_func(id, hitEnt, bodyPart) == 0.0)
		//return 0

	new sentry = 0
	while (hitEnt) {
		new classname[32], l_sentry
		entity_get_string(hitEnt, EV_SZ_classname, classname, 31)
		if (equal(classname, "sentrybase"))
			l_sentry = entity_get_edict(hitEnt, BASE_ENT_SENTRY)
		else if (equal(classname, "sentry"))
			l_sentry = hitEnt
		else if (equal(classname, "sentryhull"))
			l_sentry = entity_get_edict(entity_get_edict(hitEnt, HULL_ENT_BASE), BASE_ENT_SENTRY)
		else
			break

		if (alwaysReturn)
			return l_sentry

		new sentryLevel = GetSentryLevel(l_sentry)
		new owner = GetSentryPeople(l_sentry, OWNER)
		if (cs_get_user_team(owner) == cs_get_user_team(id) && sentryLevel < 2) {
#if defined DISALLOW_OWN_UPGRADES
			// Don't allow builder to upgrade his own sentry first time.
			if (sentryLevel == SENTRY_LEVEL_1 && id == owner)
				break
#endif
#if defined DISALLOW_TWO_UPGRADES
			// Don't allow upgrader to upgrade again.
			if (sentryLevel == SENTRY_LEVEL_2 && id == GetSentryPeople(l_sentry, UPGRADER_1))
				break
#endif
			sentry = l_sentry
		}
		break
	}

	return sentry
}

menumain_starter(id) {
	if (g_inSpyCam[id - 1])
		return

	g_aimSentry[id - 1] = 0
	new menuBuffer[256], len = 0, flags = MENUBUTTON0
	len += format(menuBuffer[len], 255 - len, "\ySentry gun menu^n^n")

	len += format(menuBuffer[len], 255 - len, "%s1. Build sentry, $%d^n", GetSentryCount(id) < MAXPLAYERSENTRIES && cs_get_user_money(id) >= g_COST[0] ? "\w" : "\d", g_COST[0])

	//if (GetSentryCount(id) == 1)
		//g_selectedSentry[id - 1] = g_playerSentriesEdicts[id - 1][0]
	//g_selectedSentry[id - 1] = GetClosestSentry(id)
	if (GetSentryCount(id) > 0 && g_selectedSentry[id - 1] == -1)
		g_selectedSentry[id - 1] = g_playerSentriesEdicts[id - 1][0]
	// g_playerSentriesEdicts[id - 1]

	if (g_selectedSentry[id - 1]) {
		new parm[2]
		parm[0] = id
		parm[1] = g_selectedSentry[id - 1]
		set_task(0.0, "SentryRadarBlink", TASKID_SENTRYONRADAR + g_selectedSentry[id - 1], parm, 2)
	}

	//len += format(menuBuffer[len], 255 - len, "%s2. Detonate %ssentry^n", GetSentryCount(id) > 0 ? "\w" : "\d", GetSentryCount(id) > 1 ? "closest " : "")
	len += format(menuBuffer[len], 255 - len, "%s2. Detonate sentry flashing on radar^n", GetSentryCount(id) > 0 ? "\w" : "\d")

	while (len) {
		new sentry = AimingAtSentry(id)
		if (!sentry)
			break
		new sentryLevel = GetSentryLevel(sentry)

		if (entity_range(sentry, id) <= MAXUPGRADERANGE) {
			if (cs_get_user_money(id) >= g_COST[sentryLevel + 1]) {
				len += format(menuBuffer[len], 255 - len, "\w3. Upgrade this sentry, $%d^n", g_COST[sentryLevel + 1])
				flags |= MENUBUTTON3
				g_aimSentry[id - 1] = sentry
			}
			else
				len += format(menuBuffer[len], 255 - len, "\d3. Upgrade this sentry (needs $%d)^n", g_COST[sentryLevel + 1])
		}
		else
			len += format(menuBuffer[len], 255 - len, "\d3. Upgrade this sentry, $%d (out of range)^n", g_COST[sentryLevel + 1])
		//}

		break
	}
	if (GetSentryCount(id) > 1) {
		len += format(menuBuffer[len], 255 - len, "\w4. Detonate all sentries^n")
		len += format(menuBuffer[len], 255 - len, "^n\w5. Select previous sentry^n")
		len += format(menuBuffer[len], 255 - len, "\w6. Select next sentry^n")
		flags |= MENUBUTTON4 | MENUBUTTON5 | MENUBUTTON6
	}

	len += format(menuBuffer[len], 255 - len, "%s7. View from sentry flashing on radar^n", g_selectedSentry[id - 1] != -1 ? "\w" : "\d")
	if (g_selectedSentry[id - 1] != -1)
		flags |= MENUBUTTON7

	//len += format(menuBuffer[len], 255 - len, "%s4. View from sentry^n", HasSentry(id) ? "\w" : "\d")

	len += format(menuBuffer[len], 255 - len, "^n\w0. Exit")

	if (GetSentryCount(id) > 0) {
		flags |= MENUBUTTON2
	}
	if (GetSentryCount(id) < MAXPLAYERSENTRIES && cs_get_user_money(id) >= g_COST[SENTRY_LEVEL_1])
		flags |= MENUBUTTON1

	show_menu(id, flags, menuBuffer)
}

public SentryRadarBlink(parm[2]) {
	// 0 = player
	// 1 = sentry
	if (!is_user_connected(parm[0]) || !is_valid_ent(parm[1]))
		return

	new Float:sentryOrigin[3]
	entity_get_vector(parm[1], EV_VEC_origin, sentryOrigin)
	//client_print(parm[0], print_chat, "Plotting closest sentry %d on radar: %f %f %f", parm[1], sentryOrigin[0], sentryOrigin[1], sentryOrigin[2])
	message_begin(MSG_ONE, g_msgHostagePos, {0,0,0}, parm[0])
	write_byte(parm[0])
	write_byte(SENTRY_RADAR)
	write_coord(floatround(sentryOrigin[0]))
	write_coord(floatround(sentryOrigin[1]))
	write_coord(floatround(sentryOrigin[2]))
	message_end()

	message_begin(MSG_ONE, g_msgHostageK, {0,0,0}, parm[0])
	write_byte(SENTRY_RADAR)
	message_end()

	new usermenuid, keys
	get_user_menu(parm[0], usermenuid, keys)
	if (g_menuId == usermenuid)
		set_task(1.5, "SentryRadarBlink", TASKID_SENTRYONRADAR + parm[1], parm, 2)
}

stock GetClosestSentry(id) {
	// Find closest sentry
	new sentry = 0, closestSentry = 0, Float:closestDistance, Float:distance
	while ((sentry = find_ent_by_class(sentry, "sentry"))) {
		if (GetSentryPeople(sentry, OWNER) != id)
			continue

		distance = entity_range(id, sentry)
		if (distance < closestDistance || closestSentry == 0) {
			closestSentry = sentry
			closestDistance = distance
		}
	}

	return closestSentry
}

public menumain_handle(id, key) {
	new bool:stayInMenu = false
	switch (key) {
		case MENUSELECT1: {
			// Build if still not has
			if (GetSentryCount(id) < MAXPLAYERSENTRIES) {
				sentry_build(id)
			}
			/*
			else {
				new numwords[128]
				getnumbers(MAXPLAYERSENTRIES, numwords, MAXPLAYERSENTRIES)
				client_print(id, print_center, "You can only build %s sentry gun!", numwords)
			}
			*/
		}
		case MENUSELECT2: {
			// Detonate if still has
			new sentryCount = GetSentryCount(id)

			if (sentryCount == 1)
				sentry_detonate_by_owner(id, false)
			else if (sentryCount > 1) {
				sentry_detonate(g_selectedSentry[id - 1], false, false)
			}
		}
		case MENUSELECT3: {
			// Upgrade sentry
			new sentry = g_aimSentry[id - 1]
			if (is_valid_ent(sentry) && entity_range(sentry, id) <= MAXUPGRADERANGE) {
				sentry_upgrade(id, sentry)
			}
		}
		case MENUSELECT4: {
			while(GetSentryCount(id) > 0)
				sentry_detonate_by_owner(id, false)
		}
		case MENUSELECT5: {
			// one back
			CycleSelectedSentry(id, -1)
			stayInMenu = true
		}
		case MENUSELECT6: {
			// one forward
			CycleSelectedSentry(id, 1)
			stayInMenu = true
		}
		case MENUSELECT7: {
			if (g_selectedSentry[id - 1] != -1) {
				new spycam = CreateSpyCam(id, g_selectedSentry[id - 1])
				if (!spycam)
					return PLUGIN_HANDLED

				new parms[3]
				parms[0] = id
				parms[1] = spycam
				parms[2] = g_selectedSentry[id - 1]
				set_task(SPYCAMTIME, "DestroySpyCam", TASKID_SPYCAM + id, parms, 3)
			}
		}
		case MENUSELECT0: {
			// nothing
			//stayInMenu = false
		}
	}

	if (stayInMenu)
		menumain_starter(id)

	return PLUGIN_HANDLED
}

CreateSpyCam(id, sentry) {
	new spycam = create_entity("info_target")
	if (!spycam)
		return 0

	// Set connection from sentry to this spycam
	entity_set_edict(sentry, SENTRY_ENT_SPYCAM, spycam)

	// Set classname
	entity_set_string(spycam, EV_SZ_classname, "spycam")

	// Set origin, pull up some
	new Float:origin[3]
	entity_get_vector(sentry, EV_VEC_origin, origin)
	origin[2] += g_spyCamOffset[GetSentryLevel(sentry)]
	entity_set_vector(spycam, EV_VEC_origin, origin)

	// Set model, has to have one... but make it invisible with the stuff below
	entity_set_model(spycam, "models/sentries/base.mdl")
	entity_set_int(spycam, EV_INT_rendermode, kRenderTransColor)
	entity_set_float(spycam, EV_FL_renderamt, 0.0)
	entity_set_int(spycam, EV_INT_renderfx, kRenderFxNone)

	// Set initial angle, this is also done in server_frame
	new Float:angles[3]
	entity_get_vector(sentry, EV_VEC_angles, angles)
	entity_set_vector(spycam, EV_VEC_angles, angles)

	// Set view of player
	engfunc(EngFunc_SetView, id, spycam)
	g_inSpyCam[id - 1] = true

	return spycam
}

public DestroySpyCam(parms[3]) {
	new id = parms[0]
	new spycam = parms[1]
	new sentry = parms[2]
	g_inSpyCam[id - 1] = false

	// If user is still around, set his view back
	if (is_user_connected(id))
		engfunc(EngFunc_SetView, id, id)

	// Remove connection from sentry (this sentry could've been removed because of a newround, or it was destroyed...)
	if (is_valid_ent(sentry) && entity_get_edict(sentry, SENTRY_ENT_SPYCAM) == spycam)
		entity_set_edict(sentry, SENTRY_ENT_SPYCAM, 0)

	remove_entity(spycam)
}

CycleSelectedSentry(id, steps) {
	// Find current index
	new index = -1
	for (new i = 0; i < g_playerSentries[id - 1]; i++) {
		if (g_playerSentriesEdicts[id - 1][i] == g_selectedSentry[id - 1]) {
			index = i
			break
		}
	}
	if (index == -1)
		return // error :-P

	remove_task(TASKID_SENTRYONRADAR + g_selectedSentry[id - 1])

	if (steps > 0) {
		do {
			index++
			steps--
			if (index == g_playerSentries[id - 1])
				index = 0
		}
		while(steps > 0)
	}
	else if (steps < 0) {
		do {
			index--
			steps++
			if (index == -1)
				index = g_playerSentries[id - 1] - 1
		}
		while(steps < 0)
	}

	g_selectedSentry[id - 1] = g_playerSentriesEdicts[id - 1][index]
}

sentry_upgrade(id, sentry) {
	new sentryLevel = GetSentryLevel(sentry)
	if (GetSentryFiremode(sentry) == SENTRY_FIREMODE_NUTS) {
		client_print(id, print_center, "This sentry cannot be upgraded.")
		return
	}
	else if (cs_get_user_team(id) != GetSentryTeam(sentry) /*CsTeams:entity_get_int(sentry, SENTRY_INT_TEAM)*/) {
		client_print(id, print_center, "You can only upgrade your own team's sentries.")
		return
	}
#if defined DISALLOW_OWN_UPGRADES
	else if (sentryLevel == SENTRY_LEVEL_1 && GetSentryPeople(sentry, OWNER) == id) {
		// Don't print anything here, it could get spammy
		//client_print(id, print_center, "")
		return
	}
#endif
#if defined DISALLOW_TWO_UPGRADES
	else if (sentryLevel == SENTRY_LEVEL_2 && GetSentryPeople(sentry, UPGRADER_1) == id) {
		// Don't print anything here, it could get spammy
		//client_print(id, print_center, "")
		return
	}
#endif
	sentryLevel++
	new bool:newLevelIsOK = true, upgraderField
	switch (sentryLevel) {
		case SENTRY_LEVEL_2: {
			entity_set_model(sentry, "models/sentries/sentry2.mdl")
			upgraderField = UPGRADER_1
		}
		case SENTRY_LEVEL_3: {
			entity_set_model(sentry, "models/sentries/sentry3.mdl")
			upgraderField = UPGRADER_2
		}
		default: {
			// Error... can only upgrade to level 2 and 3... so far! ;-)
			newLevelIsOK = false
		}
	}

	if (newLevelIsOK) {
		if (cs_get_user_money(id) - g_COST[sentryLevel] < 0) {
			client_print(id, print_center, "You don't have enough money to upgrade this sentry gun! (needed $%d)", g_COST[sentryLevel])
			return
		}

		cs_set_user_money(id, cs_get_user_money(id) - g_COST[sentryLevel])


		// Need to reset sizes here
		new Float:mins[3], Float:maxs[3]
		mins[0] = -16.0
		mins[1] = -16.0
		mins[2] = 0.0
		maxs[0] = 16.0
		maxs[1] = 16.0
		maxs[2] = 48.0 // 4.0
		entity_set_size(sentry, mins, maxs)

		emit_sound(sentry, CHAN_AUTO, "sentries/turrset.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		SetSentryLevel(sentry, sentryLevel) // entity_set_int(sentry, SENTRY_INT_LEVEL, sentryLevel)
		entity_set_float(sentry, EV_FL_health, g_HEALTHS[sentryLevel])
		entity_set_float(entity_get_edict(sentry, SENTRY_ENT_BASE), EV_FL_health, g_HEALTHS[0])
		SetSentryPeople(sentry, upgraderField, id)

		if (id != GetSentryPeople(sentry, OWNER)) {
			new upgraderName[32]
			get_user_name(id, upgraderName, 31)
			client_print(GetSentryPeople(sentry, OWNER), print_center, "%s upgraded your sentry gun to level %d", upgraderName, sentryLevel + 1)
		}
	}
}

stock userviewhitpoint(index, Float:hitorigin[3]) {
	if (!is_user_connected(index)) {
		// Error
		log_amx("ERROR in plugin - %d is not a valid player index", index)
		return 0
	}
	new Float:origin[3], Float:pos[3], Float:v_angle[3], Float:vec[3], Float:f_dest[3]

	entity_get_vector(index, EV_VEC_origin, origin)
	entity_get_vector(index, EV_VEC_view_ofs, pos)

	pos[0] += origin[0]
	pos[1] += origin[1]
	pos[2] += origin[2]

	entity_get_vector(index, EV_VEC_v_angle, v_angle)

	engfunc(EngFunc_AngleVectors, v_angle, vec, 0, 0)

	f_dest[0] = pos[0] + vec[0] * 9999
	f_dest[1] = pos[1] + vec[1] * 9999
	f_dest[2] = pos[2] + vec[2] * 9999

	return trace_line(index, pos, f_dest, hitorigin)
}
stock entityviewhitpoint(index, Float:origin[3], Float:hitorigin[3]) {
	if (!is_valid_ent(index)) {
		// Error
		log_amx("ERROR in plugin - %d is not a valid entity index", index)
		return 0
	}
	new Float:angle[3], Float:vec[3], Float:f_dest[3]

	//entity_get_vector(index, EV_VEC_origin, origin)
	/*
	entity_get_vector(index, EV_VEC_view_ofs, pos)

	pos[0] += origin[0]
	pos[1] += origin[1]
	pos[2] += origin[2]
	*/

	entity_get_vector(index, EV_VEC_angles, angle)

	engfunc(EngFunc_AngleVectors, angle, vec, 0, 0)

	f_dest[0] = origin[0] + vec[0] * 9999
	f_dest[1] = origin[1] + vec[1] * 9999
	f_dest[2] = origin[2] + vec[2] * 9999

	return trace_line(index, origin, f_dest, hitorigin)
}

public newround_event(id) {
	//server_print("[%s] newround_event: %d spawns...", PLUGINNAME, id)
	g_inBuilding[id - 1] = false

#if !defined SENTRIES_SURVIVE_ROUNDS
	while(GetSentryCount(id) > 0)
		sentry_detonate_by_owner(id, true)
#endif

	if (!g_resetArmouryThisRound && g_hasArmouries) {
		ResetArmoury()
		g_resetArmouryThisRound = true
	}

	return PLUGIN_CONTINUE
}

public endround_event() {
	if (!g_hasArmouries)
		return PLUGIN_CONTINUE

	set_task(4.0, "ResetArmouryFalse")

	return PLUGIN_CONTINUE
}

public ResetArmouryFalse() {
	//client_print(0, print_chat, "Setting g_resetArmouryThisRound to false!")
	g_resetArmouryThisRound = false
}

public client_putinserver(id) {
	if (is_user_bot(id)) {
		new parm[1]
		parm[0] = id
		botbuildsrandomly(parm)

	}
	else
		set_task(15.0, "dispInfo", id)

	return PLUGIN_CONTINUE
}

public dispInfo(id)
{
	client_print(id, print_chat, "In this server you can build sentries! For help on how to bind the necessary buttons, say 'sentryhelp'!")
}

public check_say(id){
	new said[32]
	read_args(said, 31)

	if (equali(said, "^"sentryhelp^"") || equali(said, "^"/sentryhelp^"")) {
		const SIZE = MAXHTMLSIZE
		new msg[SIZE + 1], len = 0

		len += format(msg[len], SIZE - len, "<html><body>")
		len += format(msg[len], SIZE - len, "<p>Sentries in TFC were cool. Sentries in CS are cool.<br/>")
		len += format(msg[len], SIZE - len, "Sentry guns are stationary engineering wonders that fire bullets at and kill your enemies.<br/>")
		len += format(msg[len], SIZE - len, "Sentry guns can be upgraded twice, with the help of a team member, to be bigger and meaner.</p>")
		len += format(msg[len], SIZE - len, "<p>Open console and type ^"bind j sentry_menu^" to bind the menu button to J. You can also bind ^"sentry_build^".<br/>")
		len += format(msg[len], SIZE - len, "Note that you can bind to any button you choose. To bind the fast build/update command to a mouse button 4, write ^"bind mouse4 sentry_build^".</p>")
#if defined DISALLOW_OWN_UPGRADES
		len += format(msg[len], SIZE - len, "<p>You <b>cannot</b> upgrade your own sentry from level 1 to level 2. A team mate must do this.</p>")
#else
		len += format(msg[len], SIZE - len, "<p>You <b>can</b> upgrade your own sentry from level 1 to level 2.</p>")
#endif
#if defined DISALLOW_TWO_UPGRADES
		len += format(msg[len], SIZE - len, "<p>A sentry at level 2 <b>cannot</b> be upgraded to level 3 by the same player that performed the first upgrade. A team mate must do this (original builder is OK).</p>")
#else
		len += format(msg[len], SIZE - len, "<p>A sentry at level 2 <b>can</b> be further upgraded to level 3 by the the same player that performed the first upgrade.</p>")
#endif
		len += format(msg[len], SIZE - len, "<center>")
		len += format(msg[len], SIZE - len, "<table width=^"50%^" border=^"1^">")
		len += format(msg[len], SIZE - len, "<tr><td><b>Command</b></td><td><b>Description</b></td>")
		len += format(msg[len], SIZE - len, "<tr><td>sentry_menu</td><td>From this menu you can build, upgrade and detonate sentry guns. To upgrade a sentry, first point at it, then open menu.</td>")
		len += format(msg[len], SIZE - len, "<tr><td>sentry_build</td><td>Quick button to build and upgrade sentry guns. To upgrade a sentry, first point at it, then press this button.</td>")
		len += format(msg[len], SIZE - len, "</table>")
		len += format(msg[len], SIZE - len, "<table width=^"50%^" border=^"1^">")
		len += format(msg[len], SIZE - len, "<tr><td><b>Sentry gun level</b></td><td><b>Cost to build/upgrade to</b></td>")
		len += format(msg[len], SIZE - len, "<tr><td>1</td><td>%d</td>", g_COST[0])
		len += format(msg[len], SIZE - len, "<tr><td>2</td><td>%d</td>", g_COST[1])
		len += format(msg[len], SIZE - len, "<tr><td>3</td><td>%d</td>", g_COST[2])
		len += format(msg[len], SIZE - len, "</table>")
		len += format(msg[len], SIZE - len, "</center>")
		len += format(msg[len], SIZE - len, "</body></html>")
		show_motd(id, msg, "Sentry guns help")
	}
	else if (containi(said, "sentr") != -1) {
		dispInfo(id)
	}

	return PLUGIN_CONTINUE
}

public plugin_modules() {
	require_module("engine")
	require_module("fun")
	require_module("cstrike")
	require_module("fakemeta")
}

public plugin_precache() {
	// Sentries below
	precache_model("models/sentries/base.mdl")
	precache_model("models/sentries/sentry1.mdl")
	precache_model("models/sentries/sentry2.mdl")
	precache_model("models/sentries/sentry3.mdl")

	g_sModelIndexFireball = precache_model("sprites/zerogxplode.spr") // explosion

	precache_sound("debris/bustmetal1.wav") // metal, computer breaking
	precache_sound("debris/bustmetal2.wav") // metal, computer breaking
	precache_sound("debris/metal1.wav") // metal breaking (needed for comp also?!)
//	precache_sound("debris/metal2.wav") // metal breaking
	precache_sound("debris/metal3.wav") // metal breaking (needed for comp also?!)
//	precache_model("models/metalplategibs.mdl") // metal breaking
	precache_model("models/computergibs.mdl") // computer breaking

	precache_sound("sentries/asscan1.wav")
	precache_sound("sentries/asscan2.wav")
	precache_sound("sentries/asscan3.wav")
	precache_sound("sentries/asscan4.wav")
	precache_sound("sentries/turridle.wav")
	precache_sound("sentries/turrset.wav")
	precache_sound("sentries/turrspot.wav")
	precache_sound("sentries/building.wav")

	precache_sound(g_FIRESOUNDS[0])
	precache_sound(g_FIRESOUNDS[1])
}


stock spambits(to, bits) {
	new buffer[512], len = 0
	for (new i = 31; i >= 0; i--) {
		len += format(buffer[len], 511 - len, "%d", bits & (1<<i) ? 1 : 0)
	}
	//client_print(to, print_chat, buffer)
	server_print(buffer)
}

public forward_traceline_post(Float:start[3], Float:end[3], noMonsters, player) {
	if (is_user_bot(player) || player < 1 || player > g_MAXPLAYERS)
		return FMRES_IGNORED

	if (!is_user_alive(player))
		return FMRES_IGNORED

	SetStatusTrigger(player, false)

	new hitEnt = get_tr(TR_pHit)
	if (hitEnt <= g_MAXPLAYERS)
		return FMRES_IGNORED

	new classname[11], sentry = 0, base = 0, hull //, spec = -1
	entity_get_string(hitEnt, EV_SZ_classname, classname, 10)
	if (equal(classname, "sentryhull")) {
		//spec = 2
		hull = hitEnt
		base = entity_get_edict(hull, HULL_ENT_BASE)
		//server_print("Setting base to %d in sentryhull...", base)
		sentry = entity_get_edict(base, BASE_ENT_SENTRY)
	}
	else if (equal(classname, "sentrybase")) {
		//spec = 1
		base = hitEnt
		//server_print("Setting base to %d in sentrybase...", base)
		sentry = entity_get_edict(base, BASE_ENT_SENTRY)
		//hull = entity_get_edict(base, BASE_ENT_HULL)
		//entity_set_edict(hitEnt, EV_ENT_owner, player)
		//if (sentry)
			//entity_set_edict(sentry, EV_ENT_owner, player)
	}
	else if (equal(classname, "sentry")) {
		//spec = 0
		sentry = hitEnt
		//entity_set_edict(hitEnt, EV_ENT_owner, player)
		base = entity_get_edict(sentry, SENTRY_ENT_BASE)
		//server_print("Setting base to %d in sentry...", base)
		//if (base)
			//entity_set_edict(base, EV_ENT_owner, player)
			//hull = entity_get_edict(base, BASE_ENT_HULL)
	}
	// If base is allright...
	if (base) {
		// And it does belong to the same team as player does...
		if (CsTeams:entity_get_int(base, BASE_INT_TEAM) == cs_get_user_team(player)) {
			// And player didn't build it...
			if (entity_get_edict(base, BASE_ENT_OWNER) != player) {
				// Then player shouldn't be able to harm it.
				entity_set_edict(base, EV_ENT_owner, player);
			}
		}
	}
	if (!sentry || !base || GetSentryFiremode(sentry) == SENTRY_FIREMODE_NUTS)
		return FMRES_IGNORED

	new Float:health = entity_get_float(sentry, EV_FL_health)
	if (health <= 0)
		return FMRES_IGNORED
	new Float:basehealth = entity_get_float(base, EV_FL_health)
	if (basehealth <= 0)
		return FMRES_IGNORED
	new CsTeams:team = GetSentryTeam(sentry) // entity_get_int(sentry, SENTRY_INT_TEAM)
	if (team != cs_get_user_team(player))
		return FMRES_IGNORED

	if (GetSentryPeople(sentry, OWNER) != player) {
		// Set aiming player as "owner" of this, they're not really the owner as in SENTRY_ENT_OWNER, but the owner of a func_breakable doesn't seem to be able to hit it with trace_line:s
		// which would make it impossible for them to hit it with bullets... too bad you can only have one owner per breakable... so this will be (re)set all the time really when
		// different people aim at this sentry.. not sure it will work :-P
		entity_set_edict(sentry, EV_ENT_owner, player)
		entity_set_edict(base, EV_ENT_owner, player)
	}

	// Display health
	new level = GetSentryLevel(sentry)
	new upgradeInfo[128]
	if (PlayerCanUpgradeSentry(player, sentry))
		format(upgradeInfo, 127, "^n(Run into me to upgrade me to level %d for $%d)", level + 2, g_COST[level + 1])
	else if (level < SENTRY_LEVEL_3)
		format(upgradeInfo, 127, "^n(Upgrade cost: $%d)", g_COST[level + 1])
	else
		upgradeInfo = ""

	new tempStatusBuffer[256]

	format(tempStatusBuffer, 255, "Health: %d/%d^nBase health: %d/%d^nLevel: %d%s", floatround(health), floatround(g_HEALTHS[level]), floatround(basehealth), floatround(g_HEALTHS[0]), level + 1, upgradeInfo/*, spec*/)
	SetStatusTrigger(player, true)
	if (!task_exists(TASKID_SENTRYSTATUS + player) || !equal(tempStatusBuffer, g_sentryStatusBuffer[player - 1])) {
		// may still exist if !equal was true, so we remove previous task. This happens when sentry is being fired upon, player gets enough money to upgrade or sentry
		// suddenly is upgradeable because another teammate upgraded it or something. This should make for instant updates to message without risking sending a lot of messages
		// just in case data updated, now we only send more often if data changed often enough.
		//client_print(player, print_chat, "Starting to send: %s", tempStatusBuffer)
		remove_task(TASKID_SENTRYSTATUS + player)

		g_sentryStatusBuffer[player - 1] = tempStatusBuffer
		new parms[2]
		parms[0] = player
		parms[1] = int:team
		set_task(0.0, "displaysentrystatus", TASKID_SENTRYSTATUS + player, parms, 2)
	}

	return FMRES_IGNORED
}

// Counting level, team, money and DEFINES
bool:PlayerCanUpgradeSentry(player, sentry) {
	if (GetSentryFiremode(sentry) == SENTRY_FIREMODE_NUTS)
		return false

	new level = GetSentryLevel(sentry)
	switch(level) {
		case SENTRY_LEVEL_1: {
			#if defined DISALLOW_OWN_UPGRADES
			if (player == GetSentryPeople(sentry, OWNER))
				return false
			#endif
			return cs_get_user_team(player) == GetSentryTeam(sentry) && cs_get_user_money(player) >= g_COST[level + 1]
		}
		case SENTRY_LEVEL_2: {
			#if defined DISALLOW_TWO_UPGRADES
			if (player == GetSentryPeople(sentry, UPGRADER_1))
				return false
			#endif
			return cs_get_user_team(player) == GetSentryTeam(sentry) && cs_get_user_money(player) >= g_COST[level + 1]
		}
	}

	return false
}

public displaysentrystatus(parms[2]) {
	// parm 0 = player
	// parm 1 = team
	if (!GetStatusTrigger(parms[0]))
		return

	set_hudmessage(parms[1] == 1 ? 150 : 0, 0, parms[1] == 2 ? 150 : 0, -1.0, 0.35, 0, 0.0, STATUSINFOTIME + 0.1, 0.0, 0.0, 2) // STATUSINFOTIME + 0.1 = overlapping a little..
	show_hudmessage(parms[0], g_sentryStatusBuffer[parms[0] - 1])

	set_task(STATUSINFOTIME, "displaysentrystatus", TASKID_SENTRYSTATUS + parms[0], parms, 2)
}


ResetArmoury() {
	// Find all armoury_entity:s, restore their initial origins
	new entity = 0, Float:NULLVELOCITY[3] = {0.0, 0.0, 0.0}, Float:origin[3]
	while ((entity = find_ent_by_class(entity, "armoury_entity"))) {
		// Reset speed in case it's flying around...
		entity_set_vector(entity, EV_VEC_velocity, NULLVELOCITY)

		// Get origin and set it.
		entity_get_vector(entity, EV_VEC_vuser1, origin)
		entity_set_origin(entity, origin)
	}
}

public InitArmoury() {
	// Find all armoury_entity:s, store their initial origins
	new entity = 0, Float:origin[3], counter = 0
	while ((entity = find_ent_by_class(entity, "armoury_entity"))) {
		entity_get_vector(entity, EV_VEC_origin, origin)
		entity_set_vector(entity, EV_VEC_vuser1, origin)
		counter++
	}
	if (counter > 0)
		g_hasArmouries = true
}

stock getnumbers(number, wordnumbers[], length) {
	if (number < 0) {
		format(wordnumbers, length, "error")
		return
	}

	new numberstr[20]
	num_to_str(number, numberstr, 19)
	new stlen = strlen(numberstr), bool:getzero = false, bool:jumpnext = false
	if (stlen == 1)
		getzero = true

	do {
		if (jumpnext)
			jumpnext = false
		else if (numberstr[0] != '0') {
			switch (stlen) {
				case 9: {
					if (getsingledigit(numberstr[0], wordnumbers, length))
						format(wordnumbers, length, "%s hundred%s", wordnumbers, numberstr[1] == '0' && numberstr[2] == '0' ? " million" : "")
				}
				case 8: {
					jumpnext = gettens(wordnumbers, length, numberstr)
					if (jumpnext)
						format(wordnumbers, length, "%s million", wordnumbers)
				}
				case 7: {
					getsingledigit(numberstr[0], wordnumbers, length)
					format(wordnumbers, length, "%s million", wordnumbers)
				}
				case 6: {
					if (getsingledigit(numberstr[0], wordnumbers, length))
						format(wordnumbers, length, "%s hundred%s", wordnumbers, numberstr[1] == '0' && numberstr[2] == '0' ? " thousand" : "")
				}
				case 5: {
					jumpnext = gettens(wordnumbers, length, numberstr)
					if (numberstr[0] == '1' || numberstr[1] == '0')
						format(wordnumbers, length, "%s thousand", wordnumbers)
				}
				case 4: {
					getsingledigit(numberstr[0], wordnumbers, length)
					format(wordnumbers, length, "%s thousand", wordnumbers)
				}
				case 3: {
					getsingledigit(numberstr[0], wordnumbers, length)
					format(wordnumbers, length, "%s hundred", wordnumbers)
				}
				case 2: jumpnext = gettens(wordnumbers, length, numberstr)
				case 1: {
					getsingledigit(numberstr[0], wordnumbers, length, getzero)
					break // could've trimmed, but of no use here
				}
				default: {
					format(wordnumbers, length, "%s TOO LONG", wordnumbers)
					break
				}
			}
		}

		jghg_trim(numberstr, length, 1)
		stlen = strlen(numberstr)
	}
	while (stlen > 0)

	// Trim a char from left if first char is a space (very likely)
	if (wordnumbers[0] == ' ')
		jghg_trim(wordnumbers, length, 1)
}

// Returns true if next char should be jumped
stock bool:gettens(wordnumbers[], length, numberstr[]) {
	new digitstr[11], bool:dont = false, bool:jumpnext = false
	switch (numberstr[0]) {
		case '1': {
			jumpnext = true
			switch (numberstr[1]) {
				case '0': digitstr = "ten"
				case '1': digitstr = "eleven"
				case '2': digitstr = "twelve"
				case '3': digitstr = "thirteen"
				case '4': digitstr = "fourteen"
				case '5': digitstr = "fifteen"
				case '6': digitstr = "sixteen"
				case '7': digitstr = "seventeen"
				case '8': digitstr = "eighteen"
				case '9': digitstr = "nineteen"
				default: digitstr = "TEENSERROR"
			}
		}
		case '2': digitstr = "twenty"
		case '3': digitstr = "thirty"
		case '4': digitstr = "fourty"
		case '5': digitstr = "fifty"
		case '6': digitstr = "sixty"
		case '7': digitstr = "seventy"
		case '8': digitstr = "eighty"
		case '9': digitstr = "ninety"
		case '0': dont = true // do nothing
		default : digitstr = "TENSERROR"
	}
	if (!dont)
		format(wordnumbers, length, "%s %s", wordnumbers, digitstr)

	return jumpnext
}

// Returns true when sets, else false
stock getsingledigit(digit[], numbers[], length, bool:getzero = false) {
	new digitstr[11]
	switch (digit[0]) {
		case '1': digitstr = "one"
		case '2': digitstr = "two"
		case '3': digitstr = "three"
		case '4': digitstr = "four"
		case '5': digitstr = "five"
		case '6': digitstr = "six"
		case '7': digitstr = "seven"
		case '8': digitstr = "eight"
		case '9': digitstr = "nine"
		case '0': {
			if (getzero)
				digitstr = "zero"
			else
				return false
		}
		default : digitstr = "digiterror"
	}
	format(numbers, length, "%s %s", numbers, digitstr)

	return true
}

stock jghg_trim(stringtotrim[], len, charstotrim, bool:fromleft = true) {
	if (charstotrim <= 0)
		return

	if (fromleft) {
		new maxlen = strlen(stringtotrim)
		if (charstotrim > maxlen)
			charstotrim = maxlen

		format(stringtotrim, len, "%s", stringtotrim[charstotrim])
	}
	else {
		new maxlen = strlen(stringtotrim) - charstotrim
		if (maxlen < 0)
			maxlen = 0

		format(stringtotrim, maxlen, "%s", stringtotrim)
	}
}


BotBuild(bot, Float:closestTime = 0.1, Float:longestTime = 5.0) {
	// This function should only be used to build sentries at objective related targets.
	// So as to not try to build all the time if recently started a build task when touched a objective related target
	if (task_exists(bot))
		return

	new teamSentriesNear = GetStuffInVicinity(bot, BOT_MAXSENTRIESDISTANCE, true, "sentry") + GetStuffInVicinity(bot, BOT_MAXSENTRIESDISTANCE, true, "sentrybase")
	if (teamSentriesNear >= BOT_MAXSENTRIESNEAR) {
		new name[32]
		get_user_name(bot, name, 31)
		//client_print(0, print_chat, "There are already %d sentries near me, I won't build here, %s says. (objective)", teamSentriesNear, name)
		return
	}

	new Float:ltime = random_float(closestTime, longestTime)
	set_task(ltime, "sentry_build", bot)
	//server_print("Bot task %d set to %f seconds", bot, ltime)

	/*new tempname[32]
	get_user_name(bot, tempname, 31)
	client_print(0, print_chat, "Bot %s will build a sentry in %f seconds...", tempname, ltime)*/
}
public sentry_build_randomlybybot(taskid_and_id) {
	if (!is_user_alive(taskid_and_id - TASKID_BOTBUILDRANDOMLY))
		return

	// Now finally do a short check if there already are enough (2-3 sentries) in this vicinity... then don't build.
	new teamSentriesNear = GetStuffInVicinity(taskid_and_id - TASKID_BOTBUILDRANDOMLY, BOT_MAXSENTRIESDISTANCE, true, "sentry") + GetStuffInVicinity(taskid_and_id - TASKID_BOTBUILDRANDOMLY, BOT_MAXSENTRIESDISTANCE, true, "sentrybase")
	if (teamSentriesNear >= BOT_MAXSENTRIESNEAR) {
		//new name[32]
		//get_user_name(taskid_and_id - TASKID_BOTBUILDRANDOMLY, name, 31)
		//client_print(0, print_chat, "There are already %d sentries near me, I won't build here, %s says. (random)", teamSentriesNear, name)
		return
	}

	sentry_build(taskid_and_id - TASKID_BOTBUILDRANDOMLY)
}

GetStuffInVicinity(entity, const Float:RADIUS, bool:followTeam, STUFF[]) {
	new classname[32], CsTeams:sentryTeam, nrOfStuffNear = 0
	entity_get_string(entity, EV_SZ_classname, classname, 31)
	if (followTeam) {
		if (equal(classname, "player"))
			sentryTeam = cs_get_user_team(entity)
		else if (equal(classname, "sentry"))
			sentryTeam = GetSentryTeam(entity)
	}

	if (followTeam) {
		if (equal(STUFF, "sentry")) {
			for (new i = 0; i < g_sentriesNum; i++) {
				if (g_sentries[i] == entity || (followTeam && GetSentryTeam(g_sentries[i]) /*entity_get_int(g_sentries[i], SENTRY_INT_TEAM)*/ != sentryTeam) || entity_range(g_sentries[i], entity) > RADIUS)
					continue

				nrOfStuffNear++
			}
		}
		else if (equal(STUFF, "sentrybase")) {
			new ent = 0
			while ((ent = find_ent_by_class(ent, STUFF))) {
				// Don't count if:
				// If follow team then if team is not same
				// If ent is the same as what we're searching from, which is entity
				// Don't count a base if it has a head, we consider sentry+base only as one item (a sentry)
				// Or if out of range
				if ((followTeam && CsTeams:entity_get_int(ent, BASE_INT_TEAM) != sentryTeam)
				|| ent == entity
				|| entity_get_edict(ent, BASE_ENT_SENTRY) != 0
				|| entity_range(ent, entity) > RADIUS)
					continue

				nrOfStuffNear++
			}
		}
	}

	//client_print(0, print_chat, "Found %d sentries within %f distance of entity %d...", nrOfSentriesNear, RADIUS, entity)
	return nrOfStuffNear
}

BotBuildRandomly(bot, Float:closestTime = 0.1, Float:longestTime = 5.0) {
	// This function is used to stark tasks that will build sentries randomly regardless of map objectives and its targets.
	new Float:ltime = random_float(closestTime, longestTime)
	set_task(ltime, "sentry_build_randomlybybot", TASKID_BOTBUILDRANDOMLY + bot)

	new tempname[32]
	get_user_name(bot, tempname, 31)
	//client_print(0, print_chat, "Bot %s will build a random sentry in %f seconds...", tempname, ltime)
	//server_print("Bot %s will build a random sentry in %f seconds...", tempname, ltime)
}

public playerreachedtarget(target, bot) {
	if (!is_user_bot(bot) || GetSentryCount(bot) >= MAXPLAYERSENTRIES || entity_get_int(bot, EV_INT_bInDuck) || cs_get_user_vip(bot) || get_systime() < g_lastObjectiveBuild[bot - 1] + BOT_OBJECTIVEWAIT)
		return PLUGIN_CONTINUE

	//client_print(bot, print_chat, "You touched bombtarget %d!", bombtarget)
	BotBuild(bot)
	g_lastObjectiveBuild[bot - 1] = get_systime()

	return PLUGIN_CONTINUE
}

public playertouchedweaponbox(weaponbox, bot) {
	if (!is_user_bot(bot) || GetSentryCount(bot) >= MAXPLAYERSENTRIES || cs_get_user_team(bot) != CS_TEAM_CT)
		return PLUGIN_CONTINUE

	new model[22]
	entity_get_string(weaponbox, EV_SZ_model, model, 21)
	if (!equal(model, "models/w_backpack.mdl"))
		return PLUGIN_CONTINUE

	// A ct will build near a dropped bomb
	BotBuild(bot, 0.0, 2.0)

	return PLUGIN_CONTINUE
}

public playerreachedhostagerescue(target, bot) {
	if (!is_user_bot(bot) || GetSentryCount(bot) >= MAXPLAYERSENTRIES) //  || cs_get_user_team(bot) != CS_TEAM_T
		return PLUGIN_CONTINUE

	// ~5% chance that a ct will build a sentry here, a t always builds
	if (cs_get_user_team(bot) == CS_TEAM_CT) {
		if (random_num(0, 99) < 95)
			return PLUGIN_CONTINUE
	}

	BotBuild(bot)


	return PLUGIN_CONTINUE
}

public playertouchedhostage(hostage, bot) {
	if (!is_user_bot(bot) || GetSentryCount(bot) >= MAXPLAYERSENTRIES || cs_get_user_team(bot) != CS_TEAM_T)
		return PLUGIN_CONTINUE

	// Build a sentry close to a hostage
	BotBuild(bot)

	return PLUGIN_CONTINUE
}

public sentryhulltouchedsentry(sentryhull, sentry) {
	//client_print(0, print_chat, "Sentryhull %d touched sentry %d! setting size", sentryhull, sentry)
	//server_print("Sentryhull %d touched sentry %d!", sentryhull, sentry)
	// Set hull size...
	//new hull = entity_get_edict(sentrybase, BASE_ENT_HULL)
	new Float:mins[3], Float:maxs[3]
	mins[0] = -16.1 // sizes are a tad bigger...
	mins[1] = -16.1
	mins[2] = 0.0
	maxs[0] = 16.1
	maxs[1] = 16.1
	maxs[2] = 48.1 + 16.0
	entity_set_size(sentryhull, mins, maxs)
	//entity_set_float(GetSentryPeople(sentry, OWNER), EV_FL_maxspeed, g_maxSpeeds[GetSentryPeople(sentry, OWNER) - 1])

	return PLUGIN_CONTINUE
}
public sentrybasetouchedsentry(sentrybase, sentry) {
	//client_print(0, print_chat, "Sentrybase %d touched sentry %d! setting size", sentrybase, sentry)
	//server_print("Sentrybase %d touched sentry %d!", sentrybase, sentry)

	new Float:mins[3], Float:maxs[3]
	mins[0] = -16.1 // sizes are a tad bigger...
	mins[1] = -16.1
	mins[2] = 0.0
	maxs[0] = 16.1
	maxs[1] = 16.1
	maxs[2] = 48.1 + 16.0
	entity_set_size(entity_get_edict(sentrybase, BASE_ENT_HULL), mins, maxs)
	//entity_set_float(GetSentryPeople(sentry, OWNER), EV_FL_maxspeed, g_maxSpeeds[GetSentryPeople(sentry, OWNER) - 1])

	return PLUGIN_CONTINUE
}

public playertouchedhull(hull, player) {
	new base = entity_get_edict(hull, HULL_ENT_BASE)
	new sentry = entity_get_edict(base, BASE_ENT_SENTRY)
	if (!sentry)
		return PLUGIN_CONTINUE

	if (GetSentryTeam(sentry) /*CsTeams:entity_get_int(sentry, SENTRY_INT_TEAM)*/ == cs_get_user_team(player) && GetSentryPeople(sentry, OWNER) != player) {
		entity_set_edict(sentry, EV_ENT_owner, player)
		if (entity_get_edict(sentry, SENTRY_ENT_BASE) != 0)
			entity_set_edict(entity_get_edict(sentry, SENTRY_ENT_BASE), EV_ENT_owner, player)
	}

	if (PlayerCanUpgradeSentry(player, sentry))
		sentry_upgrade(player, sentry)

	//client_print(player, print_chat, "You touched a hull %d with sentry %d!", hull, sentry)

	return PLUGIN_CONTINUE
}
public playertouchedsentry(sentry, player) {
	if (GetSentryTeam(sentry) /*CsTeams:entity_get_int(sentry, SENTRY_INT_TEAM)*/ == cs_get_user_team(player) && GetSentryPeople(sentry, OWNER) != player) {
		entity_set_edict(sentry, EV_ENT_owner, player)
		if (entity_get_edict(sentry, SENTRY_ENT_BASE) != 0)
			entity_set_edict(entity_get_edict(sentry, SENTRY_ENT_BASE), EV_ENT_owner, player)
	}

	if (PlayerCanUpgradeSentry(player, sentry))
		sentry_upgrade(player, sentry)

	//client_print(bot, print_chat, "You touched a sentry %d!", sentry)

	return PLUGIN_CONTINUE
}
public playertouchedsentrybase(sentrybase, player) {
	new sentry = entity_get_edict(sentrybase, BASE_ENT_SENTRY)
	if (!sentry)
		return PLUGIN_CONTINUE

	if (GetSentryTeam(sentry) /*CsTeams:entity_get_int(sentry, SENTRY_INT_TEAM)*/ == cs_get_user_team(player) && GetSentryPeople(sentry, OWNER) != player) {
		entity_set_edict(sentry, EV_ENT_owner, player)
		entity_set_edict(sentrybase, EV_ENT_owner, player)
	}

	if (PlayerCanUpgradeSentry(player, sentry))
		sentry_upgrade(player, sentry)

	//client_print(bot, print_chat, "You touched a sentrybase %d!", sentry)

	return PLUGIN_CONTINUE
}

public botbuildsrandomly(parm[1]) {
	if (!is_user_connected(parm[0])) {
		//server_print("********* %d is no longer in server!", parm[0])
		return
	}

	new Float:ltime = random_float(BOT_WAITTIME_MIN, BOT_WAITTIME_MAX)
	new Float:ltime2 = ltime + random_float(BOT_NEXT_MIN, BOT_NEXT_MAX)
	BotBuildRandomly(parm[0], ltime, ltime2)

	set_task(ltime2, "botbuildsrandomly", 0, parm, 1)
}

#if defined DEBUG
public botbuild_fn(id, level, cid) {
	if (!cmd_access(id, level, cid, 1))
		return PLUGIN_HANDLED

	new asked = 0
	for(new i = 1; i <= g_MAXPLAYERS; i++) {
		if (!is_user_connected(i) || !is_user_bot(i) || !is_user_alive(i))
			continue

		sentry_build(i)
		asked++
	}
	console_print(id, "Asked %d bots to build sentries (not counting money etc)", asked)

	return PLUGIN_HANDLED
}
public getfiremode_fn(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[5]
	read_argv(1, arg, 4)
	new sentry = str_to_num(arg)
	if (!is_valid_ent(sentry)) {
		console_print(id, "Invalid ent %d!", sentry)
		return PLUGIN_HANDLED
	}
	new cln[64]
	entity_get_string(sentry, EV_SZ_classname, cln, 63)
	if (!equal(cln, "sentry")) {
		console_print(id, "%d is not a sentry! (%s)", sentry, cln)
		return PLUGIN_HANDLED
	}
	console_print(id, "Sentry %d's firemode = %d", sentry, GetSentryFiremode(sentry))

	return PLUGIN_HANDLED
}
#endif

public holdwpn_event(id) {
	if (!g_inBuilding[id - 1])
		return PLUGIN_CONTINUE

	entity_set_float(id, EV_FL_maxspeed, 1.0)

	return PLUGIN_CONTINUE
}

public client_PostThink(id) {
	if (!g_inBuilding[id - 1] && g_lastInBuilding[id - 1]) {
		set_task(RESETSPEEDTIME, "resetspeed", id) // entity_set_float(id, EV_FL_maxspeed, g_maxSpeeds[id - 1])
	}
	else if (g_inBuilding[id - 1] && !g_lastInBuilding[id - 1]) {
		g_maxSpeeds[id - 1] = entity_get_float(id, EV_FL_maxspeed)
		entity_set_float(id, EV_FL_maxspeed, 1.0)
	}

	g_lastInBuilding[id - 1] = g_inBuilding[id - 1]
	
	return PLUGIN_CONTINUE
}

public resetspeed(who) {
	entity_set_float(who, EV_FL_maxspeed, g_maxSpeeds[who - 1])
}

public plugin_init() {
	register_plugin(PLUGINNAME, VERSION, AUTHOR)

	register_clcmd("sentry_build", "createsentryhere", 0, "- build a sentry gun where you are")
	register_clcmd("sentry_menu", "menumain", 0, "- displays Sentry gun menu")
	register_clcmd("say", "check_say")
	register_clcmd("say_team", "check_say")

#if defined DEBUG
	register_concmd("0botbuild", "botbuild_fn", ADMIN_CFG, "- force bots to build right where they are (debug)")
	register_concmd("0getfirmode", "getfiremode_fn", ADMIN_CFG, "<sentry>")
#endif

	//register_cvar("pend_inc", "30")
	//register_cvar("radar_increment", "4.56")
	//register_cvar("spycamoffset", "24.0")

	register_event("CurWeapon", "holdwpn_event", "be", "1=1")
	register_event("ResetHUD", "newround_event", "b")
	register_event("SendAudio", "endround_event", "a", "2&%!MRAD_terwin", "2&%!MRAD_ctwin", "2&%!MRAD_rounddraw")
	register_event("TextMsg", "endround_event", "a", "2&#Game_C", "2&#Game_w")
	register_event("TextMsg", "endround_event", "a", "2&#Game_will_restart_in")

	register_forward(FM_TraceLine, "forward_traceline_post", 1)

	//new bool:foundSomething = false
	if (find_ent_by_class(0, "func_bomb_target")) {
		register_touch("func_bomb_target", "player", "playerreachedtarget")
		register_touch("weaponbox", "player", "playertouchedweaponbox")
		//foundSomething = true
	}
	if (find_ent_by_class(0, "func_hostage_rescue")) {
		register_touch("func_hostage_rescue", "player", "playerreachedhostagerescue")
		//foundSomething = true
	}
	if (find_ent_by_class(0, "func_vip_safetyzone")) {
		register_touch("func_vip_safetyzone", "player", "playerreachedtarget")
		//foundSomething = true
	}
	if (find_ent_by_class(0, "hostage_entity")) {
		register_touch("hostage_entity", "player", "playertouchedhostage")
		//foundSomething = true
	}

	register_touch("sentry", "player", "playertouchedsentry")
	register_touch("sentrybase", "player", "playertouchedsentrybase")
	register_touch("sentryhull", "sentry", "sentryhulltouchedsentry")
	register_touch("sentryhull", "player", "playertouchedhull")
	register_touch("sentrybase", "sentry", "sentrybasetouchedsentry")

	g_menuId = register_menuid("\ySentry gun menu")
	register_menucmd(g_menuId, 1023, "menumain_handle")

	register_message(23, "message_tempentity") // <-- works for 0.16 as well
	//register_think("sentry", "message_tempentity") // <-- only 0.20+ can do this
	//register_event("23", "message_tempentity", "ab", "1=108") // TE_BREAKMODEL = 108
	register_think("sentrybase", "think_sentrybase")

	g_msgDamage = get_user_msgid("Damage")
	g_msgDeathMsg = get_user_msgid("DeathMsg")
	g_msgScoreInfo = get_user_msgid("ScoreInfo")
	g_msgHostagePos = get_user_msgid("HostagePos")
	g_msgHostageK = get_user_msgid("HostageK")

	g_MAXPLAYERS = get_global_int(GL_maxClients)
	//g_MAXENTITIES = get_global_int(GL_maxEntities)
	g_ONEEIGHTYTHROUGHPI = 180.0 / PI

	// Add menu item to menufront (client's menu, if you have AMX Mod X 1.0 you likely get a warning on the line below. It's ok for now :-))
	#if defined AddMenuItem
	AddMenuItem("Sentry guns", "sentry_menu", ADMIN_CFG, PLUGINNAME, true) // if you get a wrong number of args warning, it's no problem..... :-)
	#endif

	// InitArmoury saves the location of all onground weapons. Later we restore them to these origins when a newround begin.
	set_task(5.0, "InitArmoury")
}
