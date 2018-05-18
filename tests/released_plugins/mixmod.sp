/* Mixmod Created by iDragon *
Updates:

- 29-07-12 (v4.3)
	* Fixed a bug with sm_mmute command! - Sometimes, when players spawn, the mute is gone.
	* Add command to enable/disable the commands: sm_mmute / sm_mgag:
	- 	sm_mixmod_enable_voice_commands (Default: "1")

- 20-07-12 (v4.3)
	* Fixed a bug with the MVP system - When RR'ing mvp scores weren't reseted.
	* Support for not removing props from specified maplist has been added.
	- 	sm_mixmod_dont_remove_props_maplist (Default: "de_inferno,")
	* Fixed a bug with sm_ko3 command - which caused the plugin to swap teams at the end of the first round.

- 08-07-12 (v4.2b)
	* sm_last has been added - This command will show the last player that joined steamid and name.

- 07-06-12 (v4.2)
	* sm_mvp has been added to show mvp kills during a game.
	
- 02-06-12 (v4.1b):
	* Fixed a bug with auto-recording. (A new record wasn't started right after a mix ended).

- 19-05-12 (V4.1):
	* Fixed a bug with sm_pause (Gives 0$ and no gun to a player who joins the game when sm_pause is being used!)
	* Added sm_mgag and sm_mungag.

- 17-05-12 (V4.0):
	* sm_st will not decrease scores when sm_pcw running!
	* Warn the user that entered in the middle of a mix, that mix is running.
	* 3 Score points added when defusing the bomb.
	* 3 Score points added when the bomb explodes.

- 16-05-12 (V3.9):
	* MVP Display at round End will show only from 3 kills or above...
	* TK won't be counted as a score/death.
	* Random Teams bug (Only CT players can be randomized - not spec) has been fixed.

- 13-05-12 (V3.8a):
	* MVP System Will show now if an ace was done.
	* sm_random Fixed! (Creating random teams)
	* Added sm_mmute and sm_munmute. - I've got about 5 requests to add these commands...
	* Fixed the MVP System.
	* sm_pcw Added to Mix-Help menu. (sm_pcw - Will remember the game scores, even after RR).
	* Enable/Disable MVP Stats has been added to admin menu.
	
- 12-05-12 (V3.8):
	* Added support for MVP.
	- 	sm_mixmod_show_mvp (Default: "1")
	* Can remove the password automaticaly when mix is ending (not by sm_stop command).
	- 	sm_mixmod_remove_password_on_mix_end (Default: "1")

- 04-06-2011 - 11-05-12 (v3.6-v3.7b)
	* Some changes. I don't remember them...
	
- 03-09-2011 (v3.5):
	* Fixed some problems that musosoft helped me find (I don't remember them - few days has left already and I forgot to note them).
	* TK-Damage is now showing the armor damage that has been done too!
	* TK-Damage not showing the self-damage that has been done (self-grenade damage and etc...)

- 30-08-2011 (v3.4c):
	* TK-damage wasn't working properly ... Now it's fixed!

- 30-08-2011 (v3.4b):
	* The plugin is using now MaxClients instead of the variable maxClients

- 29-08-2011 (v3.4):
	* Option to see that a player is attacking another player in his same team has been added!
	- 	sm_mixmod_show_tk_damage (Default: "1")

- 19-08-2011 (v3.3):
	* Fixed an issue with disabling players ability to change their team (when player is retrying to the server, he get stuck in the spec team).
	* Fixed compile warnings! (in v3.2, I didn't try to compile the plugin so I haven't notice all the warnings).

- 15-08-2011 (v3.2):
	* The plugin will wait now <sm_mixmod_time_before_swapping_teams> seconds before swapping teams when half ends!
	- 	sm_mixmod_time_before_swapping_teams (Default: "0.1")
	* Option to disable players ability to change their team (jointeam command) when mix is running has been added! (When disabled, only admins can change players team).
	- 	sm_mixmod_manual_switch_enable (Default: "1" - They can change their team).
	* Knife vote (for the winning team of the knife round) is now enabled only when sm_start has been used! if the admin just used !ko3, the vote will not be a vote.

- 14-08-2011 (v3.1):
	* Bug found! - When removing props in de_inferno, some objects are removed, but they are still there invisible (I hope to fix it soon),
	* Command to see all the admin and player commands (and how to use them) has been added!
	- 	sm_mixhelp
	* After knife round (ko3) has ended, if auto-half-live is on, the live will start automatically.
	* When knife round (ko3) is running, only knife can be used.
	* sm_st and sm_swapteams has been updated! now admin can change player team with them!
	-sm_st <player> [team] (legal teams: ct/t/spec/1/2/3)
	* Fixed: when random password is shown only to admins, players can use sm_pw to see the password.

- 12-08-2011 (v3.0):
	* New admin commands has been added!
	- 	sm_record (start a record).
	- 	sm_stoprecord (stop the record).
	* Option to let the winning team in knife round to choose their team has been added!
	- 	sm_mixmod_knife_round_win_vote (Default: "0")
	* Auto-Record option has been added!
	- 	sm_mixmod_autorecord_enable (Default: "0")
	- 	sm_mixmod_autorecord_save_dir (Default: "mix_records")

- 07-08-2011 (v3.0Beta):
	* When player is disconnecting from the server when Auto-Mix is running, option to ban him has been added!
	- 	sm_mixmod_auto_warmod_ban <time> (time in minutes) (Default: "-1")
	(If <time> is negative (< 0) it won't ban, if <time> its 0 it will permanently ban, if time is positive (> 0) it will ban for <time> minutes)
	* Sub system has been added, but it's disabled in this version.
	* Option to random the team players when there are 10 ready players has been added!
	- 	sm_mixmod_auto_warmod_random (Default: "1")
	* sm_teams has been added! players can see the teams in auto-war.
	* sm_pw and sm_password has been changed! now any player can type them to see the server password (only admins can change password).
	* Ready system has been added (Beta system).

- 04-08-2011(v2.6):
	* Players money list at round_start is now sorted! (from highest to lowest).
	* Option to remove all props from the map (every round_start) when mix is running has been added!
	- 	sm_mixmod_remove_props (Default: "1")

- 02-08-2011(v2.5):
	* I forgot to save the vest and armor in the sm_pause command... (Has been added).
	* sm_pause is now working correctly! scores, weapons and client money is now being saved and will be regained the next round.
	* sm_npw has been added! Password can be removed now through this command. (v2.4)

- 27-07-2011 (v2.3):
	* Big issue with wrong team scores has been fixed!
	* Option to show random password to everyone or only to the admin who performed the sm_rpw has been added:
	- 	sm_mixmod_rpw_show_pass (Default: "1")
	* sm_pause is working now (it didn't work before).

- 26-07-2011 (v2.2):
	* After switching teams in half1 zb_lo3 or mp_restartgame will be executed to give some time to "breathe".
	* Text has been changed to ko3 round.
	* Bug fixed: wrong round number in the first round of half 2
	* Mr3 fixed (- Can now be played like it supposed to be played). - TY karil.
	* sm_pause added: see the info above.
	* sm_disablechat added: disable or enable public chat (view info above).

- 25-07-2011 (v2.1):
	* Fixed an issue: Score has been added to the "winning team" when swapping teams at the end of half1 (swapping teams slays all the players).
	* Option added: When mix has ended, the winning team could be displayed in panel or in chat (0 - chat, 1 - panel).
	- 	sm_mixmod_show_winner_in (Default: "1")
	* Bug fixed: After the mix has ended, it told that there was a DRAW instead of telling the name of the winning team.
	* Bug fixed: the plugin wrote that sm_live is needed to start the match although <sm_mixmod_half_auto_live> is set to "1".
	* Fixed an issue with wrong round number (round 2 after !nl, !live and !rr) (v2.0)
	* sm_mix command has been added (opens a menu)
	* Option to Use zb_ko3 instead of mp_restartgame when knife round starts has been added:
	- 	sm_mixmod_use_zb_ko3 (Default: "0")
	* Option to start the match with knife round has been added (sm_live after knife round is finished):
	- 	sm_mixmod_enable_knife_round (Default: "0")
	* sm_spec , sm_ko3 , sm_knifes added (v1.9)

- 24-07-2011 (v1.8):
	* sm_kickct , sm_kickt , sm_maps has been added.
	- 	sm_mixmod_kick_admins (Default: "0")
	* Cvars for using custom names cfg are added (Beta) (v1.7)
	- 	sm_mixmod_custom_mr15_cfg (Default: "mr15.cfg")
	- 	sm_mixmod_custom_prac_cfg (Default: "prac.cfg")
	- 	sm_mixmod_custom_mr3_cfg (Default: "mr3.cfg")

- 23-07-2011 (v1.6):
	* Hook to freeze-time end event, has been removed.
	* You can choose now if you want the sm_live command to be auto-performed when new half begins, or the admin should type sm_live to start the new half.
	- 	sm_mixmod_half_auto_live (Default: "0")
	* You can choose now where to display the money of each team, through chat, or through panel (menu).
	- 	sm_mixmod_show_cash_in_panel (Default: "0")
	* You can now decide in which way the plugin will tell the people not to change their teams (Through chat, or through panel (menu)).
	- 	sm_mixmod_show_swap_in_panel (Default: "1")
	* When using sm_stop command, stop.cfg could be loaded instead of prac / warmup config.
	- 	sm_mixmod_custom_stop_cfg (Default: "0")
	* Fixed bug: when all the players in one have been died in freeze-time, the round has been "skipped".
	* Mr3 can now be played when there is a tie (15-15):
	- 	sm_mixmod_mr3_enable (Default: "1")

- 21-07-2011 (v1.4):
	* Fixed bug: The version of this plugin wasn't being updated.
	* Added option to run zb_lo3 instead of mp_restartgame if zb_warmode is enabled (Version updated: v1.4):
	- 	sm_mixmod_use_zb_lo3 (Default: "0")
	* Restarts the game after <sm_mixmod_live_restart_time> seconds (Version updated: 1.3)
	* Custom team name added (Version updated: 1.2):
	- 	sm_mixmod_custom_name_ct (Default: "Team A")
	- 	sm_mixmod_custom_name_t (Default: "Team B")
	* Fixed bug: When restarting the game in the middle of freeze-time, 1 is being added to the current round (first round = 2nd round in the plugin).

- 18-07-2011 (v1.0):
	* Loose idantation warnings when compiling - fixed!

- 17-07-2011 (v1.0):
	* Released this plugin. 
	
	
*/

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <cstrike>

// Access flag that admins needs to have, to use the admin commands.
#define ACCESS_FLAG ADMFLAG_KICK
// Team indexes.
#define TEAM_T 2
#define TEAM_CT 3
#define TEAM_ONE 2
#define TEAM_TWO 3
// Maximum guns num - CSS
#define MAX_GUNS   17
#define MAX_PISTOLS   6
// Plugin name:
#define MODNAME "Mix"
// Plugin version:
#define PLUGIN_VERSION "4.3"

// Variables for round count and scores
new g_CurrentRound = 1;
new g_CurrentHalf = 1;
new g_nCTScore = 0, g_nTScore = 0, g_nCTScore2 = 0, g_nTScore2 = 0;
new g_nCTScoreH1 = 0, g_nTScoreH1 = 0;

new bool:hasMixStarted = false;
new bool:didLiveStarted = false;
new bool:g_SwapNow = false;
new bool:isKo3Running = false;
new bool:isPauseBeingUsed = false;
new bool:isRandomPasswordWasLastPw = false;
new bool:isBuyZoneDisabled = false;
new bool:isRandomBeingUsed = false;

// Enum ,Arr and offest for players money and weapons for sm_pause command
// Thanks to Zombie:Reloaded for this enum.
enum WeaponAmmoGrenadeType
{
    GrenadeType_Invalid         = -1,   /** Invalid grenade slot. */
    GrenadeType_HEGrenade       = 11,   /** HEGrenade slot */
    GrenadeType_Flashbang       = 12,   /** Flashbang slot. */
    GrenadeType_Smokegrenade    = 13,   /** Smokegrenade slot. */
}

new String:guns[MAX_GUNS][20] = {"weapon_m4a1","weapon_ak47","weapon_awp","weapon_mp5navy","weapon_famas","weapon_scout","weapon_p90","weapon_ump45","weapon_mac10","weapon_xm1014","weapon_m3","weapon_sg550","weapon_g3sg1","weapon_tmp","weapon_sg552","weapon_aug","weapon_m249"};
new String:pistols[MAX_PISTOLS][20] = {"weapon_glock","weapon_usp","weapon_p228","weapon_deagle","weapon_elite","weapon_fiveseven"};

new g_ArrPause[MAXPLAYERS+1][10];
/* Indexes:
	0 = Money.
	1 = Pistol number.
	2 = Primary gun number.
	3 = Number of flashes.
	4 = Has grenade.
	5 = Has smoke.
	6 = Kills.
	7 = Frags.
	8 = Has vest.
	9 = Armor value.
*/	
new g_iToolsAmmo = -1;


// IF you know what you'r doing - enable or disable: sm_setmixscore
new bool:ENABLE_PLUGIN_CHECKING = false;

// Map list settings ...
new bool:isMapListGenerated = false;
new Handle:g_MapListMenu = INVALID_HANDLE;

// Mix menu settings ...
new bool:isMixMenuGenerated = false;
new Handle:g_MixMenu = INVALID_HANDLE;
new Handle:g_AdminMenu = INVALID_HANDLE;

// Winning team panel ...
new Handle:g_WinTeamPanel = INVALID_HANDLE;

// Help panel ...
new Handle:g_HelpPanel = INVALID_HANDLE;

// Plugin's cvar handles.
new Handle:g_CvarEnabled = INVALID_HANDLE;
new Handle:g_CvarShowMoneyAndWeapons = INVALID_HANDLE;
new Handle:g_CvarShowScores = INVALID_HANDLE;
new Handle:g_CvarEnableRRCommand = INVALID_HANDLE;
new Handle:g_CvarPlayTeamSwapedSound = INVALID_HANDLE;
new Handle:g_CvarCusomNameTeamCT = INVALID_HANDLE;
new Handle:g_CvarCusomNameTeamT = INVALID_HANDLE;
new Handle:g_CvarRestartTimeInLiveCommand = INVALID_HANDLE;
new Handle:g_CvarUseZBMatchCommand = INVALID_HANDLE;
new Handle:g_CvarMr3Enabled = INVALID_HANDLE;
new Handle:g_CvarStopCustomCfg = INVALID_HANDLE;
new Handle:g_CvarShowSwitchInPanel = INVALID_HANDLE;
new Handle:g_CvarShowCashInPanel = INVALID_HANDLE;
new Handle:g_CvarHalfAutoLiveStart = INVALID_HANDLE;
new Handle:g_CvarCustomLiveCfg = INVALID_HANDLE;
new Handle:g_CvarCustomPracCfg = INVALID_HANDLE;
new Handle:g_CvarCustomMr3Cfg = INVALID_HANDLE;
new Handle:g_CvarKickAdmins = INVALID_HANDLE;
new Handle:g_CvarDisableSayCommand = INVALID_HANDLE;
new Handle:g_CvarMapListFrom = INVALID_HANDLE;
new Handle:g_CvarEnableKnifeRound = INVALID_HANDLE;
new Handle:g_CvarUseKo3Command = INVALID_HANDLE;
new Handle:g_CvarInformWinnerInPanel = INVALID_HANDLE;
new Handle:g_CvarRpwShowPass = INVALID_HANDLE;
new Handle:g_CvarRemoveProps = INVALID_HANDLE;
new Handle:g_CvarAutoMixEnabled = INVALID_HANDLE;
new Handle:g_CvarAutoMixRandomize = INVALID_HANDLE;
new Handle:g_CvarAutoMixBan = INVALID_HANDLE;
new Handle:g_CvarEnableAutoSourceTVRecord = INVALID_HANDLE;
new Handle:g_CvarAutoSourceTVRecordSaveDir = INVALID_HANDLE;
new Handle:g_CvarKnifeWinTeamVote = INVALID_HANDLE;
new Handle:g_CvarEnablePasswords = INVALID_HANDLE;
new Handle:g_CvarAllowManualSwitching = INVALID_HANDLE;
new Handle:g_CvarDelayBeforeSwapping = INVALID_HANDLE;
new Handle:g_CvarShowTkMessage = INVALID_HANDLE;
new Handle:g_CvarRemovePassWhenMixIsEnded = INVALID_HANDLE;
new Handle:g_CvarShowMVP = INVALID_HANDLE;
new Handle:g_CvarDontRemovePropsMaps = INVALID_HANDLE;
new Handle:g_CvarEnableVoiceCommands = INVALID_HANDLE;
//new Handle:g_CvarEnableStats = INVALID_HANDLE;
new Handle:g_hPluginVersion = INVALID_HANDLE;

// Handles for game cvars or offests
new Handle:g_hRestartGame = INVALID_HANDLE;
new Handle:g_hPassword = INVALID_HANDLE;
new Handle:g_hFreezeTime = INVALID_HANDLE;
new Handle:g_hHostName = INVALID_HANDLE;
new g_iAccount = -1;

// For the Auto-War settings ...
new g_ReadyCount = 0;
new bool:g_ReadyPlayers[MAXPLAYERS+1] = {false, ...};
new g_ReadyPlayersData[MAXPLAYERS+1] = {-1, ...};
new bool:g_AllowReady = true;
new bool:g_IsItManual = true;
new String:g_HostName[150];
new Handle:readyStatus = INVALID_HANDLE;

// Auto-Record ...
new bool:g_IsRecording = false;
new bool:g_IsRecordManual = false;

// Save client scores when RR-ing...
new bool:g_SaveClientsScore = false;

// MVP 
new g_ScoresOfTheRound[MAXPLAYERS+1] = {0, ...};
new g_ScoresOfTheGame[MAXPLAYERS+1] = {0, ...};
new g_DeathsOfTheGame[MAXPLAYERS+1] = {0, ...};

// Gag or Mute
new bool:g_MutedPlayers[MAXPLAYERS+1] = {false, ...};
new bool:g_GaggedPlayers[MAXPLAYERS+1] = {false, ...};

// Last entered
static String:g_LastEntered_SteamID[35];
static String:g_LastEntered_Name[35];

// A variable to determine, if in the current map the props can be removed.
new g_IsMapValidToRemoveProps = true;

// Ranking System
// new Handle:db;


// T and CT models to use for random model assignment
static const String:ctmodels[4][] = 
	{
		"models/player/ct_urban.mdl",
		"models/player/ct_gsg9.mdl",
		"models/player/ct_sas.mdl",
		"models/player/ct_gign.mdl"
	};
	
static const String:tmodels[4][] = 
	{
		"models/player/t_phoenix.mdl",
		"models/player/t_leet.mdl",
		"models/player/t_arctic.mdl",
		"models/player/t_guerilla.mdl"
	};

public Plugin:myinfo =
{
	name = "Mix-Plugin",
	author = "iDragon",
	description = "Makes the admin's work easier to run a mix (team match or clan war) And Auto-Mix system.",
	version = PLUGIN_VERSION
};

public OnPluginStart()
{
	// Load translations for ProcessTargetString() command...
	LoadTranslations("common.phrases");
	
	// Create the ConVars.
	g_CvarEnabled = CreateConVar("sm_mixmod_enable", "1", "Enable or disable this mixmod plugin and its features: 0 - Disable, 1 - Enable.");
	g_CvarShowMoneyAndWeapons = CreateConVar("sm_mixmod_showmoney", "1", "Show players money and if they have primary weapon to their team-mates? 0 - No, 1 - Yes.");
	g_CvarShowScores = CreateConVar("sm_mixmod_showscores", "1", "Show mix scores at round_start? 0 - No, 1 - Yes.");
	g_CvarEnableRRCommand = CreateConVar("sm_mixmod_enable_rr_command", "1", "Enable the sm_rr command in this mix plugin? (Disable if you have another plugin who uses sm_rr) 0 - No, 1 - Yes.");
	g_CvarPlayTeamSwapedSound = CreateConVar("sm_mixmod_enable_st_sound", "1", "Play sound when teams are switched when half ends? 0 - No, 1 - Yes.");
	g_CvarCusomNameTeamCT = CreateConVar("sm_mixmod_custom_name_ct", "Team A", "Set counter terrorists team custom name. (Can not be longer than 32 characters!)");
	g_CvarCusomNameTeamT = CreateConVar("sm_mixmod_custom_name_t", "Team B", "Set terrorists team custom name. (Can not be longer than 32 characters!)");
	g_CvarRestartTimeInLiveCommand = CreateConVar("sm_mixmod_live_restart_time", "1", "In seconds, set mp_restartgame <time> in live command. (Num > 0)");
	g_CvarUseZBMatchCommand = CreateConVar("sm_mixmod_use_zb_lo3", "0", "Use zb_lo3 command instead of mp_restartgame (Only if zb_warmod is enabled!) ? 0 - No, 1 - Yes.");
	g_CvarMr3Enabled = CreateConVar("sm_mixmod_mr3_enable", "1", "Enable or disable mr3 settings (when there is a tie 15-15): 0 - Disable, 1 - Enable.");
	g_CvarStopCustomCfg = CreateConVar("sm_mixmod_custom_stop_cfg", "0", "Use stop.cfg instead of prac or warmup cfg when sm_stop command is performed? 0 - No, 1 - Yes");
	g_CvarShowSwitchInPanel = CreateConVar("sm_mixmod_show_swap_in_panel", "1", "In the last round of the current half, tell the players not to switch their teams in? 0 - Chat, 1 - Panel(menu)");
	g_CvarShowCashInPanel = CreateConVar("sm_mixmod_show_cash_in_panel", "0", "When round starts, show players money in? 0 - Chat, 1 - Panel(menu)");
	g_CvarHalfAutoLiveStart = CreateConVar("sm_mixmod_half_auto_live", "0", "When new half begins, automatically start live? 0 - No, 1 - Yes");
	g_CvarCustomLiveCfg = CreateConVar("sm_mixmod_custom_live_cfg", "mr15.cfg", "Custom name of the mr15 (live or match) config: (If the name doesn't exist, the plugin will try to execute match/live/mr15/esl5on5 cfg)");
	g_CvarCustomPracCfg = CreateConVar("sm_mixmod_custom_prac_cfg", "prac.cfg", "Custom name of the prac (warmup) config: (If the name doesn't exist, the plugin will try to execute prac / warmup config)");
	g_CvarCustomMr3Cfg = CreateConVar("sm_mixmod_custom_mr3_cfg", "mr3.cfg", "Custome name of the mr3 config: (If the name doesn't exist, the plugin will try to execute mr3.cfg)");
	g_CvarKickAdmins = CreateConVar("sm_mixmod_kick_admins", "0", "When admin performs sm_kickct or sm_kickt , kick the admins too? 0 - No, 1 - Yes.");
	g_CvarDisableSayCommand = CreateConVar("sm_mixmod_disable_public_chat", "0", "Disable public chat (Only team chat will be shown)? 0 - No, 1 - Yes, 2 - Only when live");
	g_CvarMapListFrom = CreateConVar("sm_mixmod_maplist_from", "1", "Generate maplist from: 0 - maps dir, 1 - mapcycle.txt");
	g_CvarEnableKnifeRound = CreateConVar("sm_mixmod_enable_knife_round", "0", "Before the mix starts, do knife round? 0 - Disable, 1 - Enable.");
	g_CvarUseKo3Command = CreateConVar("sm_mixmod_use_zb_ko3", "0", "Use zb_ko3 command instead of mp_restartgame for knife round (Only if zb_warmode is enabled!) ? 0 - No, 1 - Yes.");
	g_CvarInformWinnerInPanel = CreateConVar("sm_mixmod_show_winner_in", "1", "When mix is ended, show winning team in? 0 - Chat, 1 - Panel(menu)");
	g_CvarRpwShowPass = CreateConVar("sm_mixmod_rpw_show_pass", "1", "Show the random password to everyone? 0 - No (only to the admin), 1 - Yes.");
	g_CvarRemoveProps = CreateConVar("sm_mixmod_remove_props", "0", "Remove map props (like barrels) at round start when mix is running? 0 - No, 1 - Yes.");
	g_CvarAutoMixEnabled = CreateConVar("sm_mixmod_auto_warmod_enable", "0", "Enable Auto-Warmod and ready system? 0 - No, 1 - Yes.");
	g_CvarAutoMixRandomize = CreateConVar("sm_mixmod_auto_warmod_random", "1", "After 10 players are ready, random the team players and start? 0 - No, 1 - Yes.");
	g_CvarAutoMixBan = CreateConVar("sm_mixmod_auto_warmod_ban", "-1", "In minutes: how long to ban players who has left the server? <Negetive number> - Don't ban, <Positive Number> - Time, 0 - Permanent ban");
	g_CvarEnableAutoSourceTVRecord = CreateConVar("sm_mixmod_autorecord_enable", "0", "Auto record the game when match is live? 0 - No, 1 - Yes.");
	g_CvarAutoSourceTVRecordSaveDir = CreateConVar("sm_mixmod_autorecord_save_dir", "mix_records", "Save directatory for the auto-records (if folder doesn't exist, the record will be saved at: cstrike/ )");
	g_CvarKnifeWinTeamVote = CreateConVar("sm_mixmod_knife_round_win_vote", "0", "Let the wining team in the knife round decide in which team they want to be? 0 - No, 1 - Yes.");
	g_CvarEnablePasswords = CreateConVar("sm_mixmod_password_commands_enable", "1", "Enable password commands (sm_pw or sm_npw or sm_rpw)? 0 - No, 1 - Yes.");
	g_CvarAllowManualSwitching = CreateConVar("sm_mixmod_manual_switch_enable", "1", "Allow players to switch their team manualy when mix is running? 0 - No, 1 - Yes.");
	g_CvarDelayBeforeSwapping = CreateConVar("sm_mixmod_time_before_swapping_teams", "0.1", "In seconds: how long should the plugin wait before swapping teams when half ends?");
	g_CvarShowTkMessage = CreateConVar("sm_mixmod_show_tk_damage", "1", "Inform all the players in the server when TK (Team killing / team damage) has been done? 0 - No, 1 - Yes.");
	g_CvarRemovePassWhenMixIsEnded = CreateConVar("sm_mixmod_remove_password_on_mix_end", "1", "Remove the password when mix is ended (not by sm_stop command)? 0 - No, 1 - Yes.");
	g_CvarShowMVP = CreateConVar("sm_mixmod_show_mvp", "1", "Show the mvp? 0 - No, 1 - Yes.");
	g_CvarDontRemovePropsMaps = CreateConVar("sm_mixmod_dont_remove_props_maplist", "de_inferno,", "Don't remove props from those maps: (syntax: 'de_inferno, anotherMap2, anotherMap3 ,...' ");
	g_CvarEnableVoiceCommands = CreateConVar("sm_mixmod_enable_voice_commands", "1", "Enable sm_mmute and sm_mgag commands? 0 - No, 1 - Yes.");
	// Working on this ...
	//g_CvarEnableStats = CreateConVar("sm_mixmod_enable_ranking_system", "1", "Enable Ranking System? 0 - No, 1 - Yes.");

	// This plugin version
	g_hPluginVersion = CreateConVar("sm_mixmod_version", PLUGIN_VERSION, "Mix Plugin version.", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	SetConVarString(g_hPluginVersion, PLUGIN_VERSION);
	
	// Auto-Generate this plugin config.
	AutoExecConfig(true, "sm_mixmod");
	
	// Hook Version changed...
	HookConVarChange(g_hPluginVersion, VersionHasBeenChanged);
	
	// Offest - To show players money at round_start event.
	g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");

	if (g_iAccount == -1)
		PrintToChatAll("\x04[%s]:\x03 Can't find the m_iAccount offest! - Money wont be shown in the mix!", MODNAME);
	
	// I need to hook the restartgame cvar (So I could restart the mix settings every time the game restarts).
	g_hRestartGame = FindConVar("mp_restartgame");
	if (g_hRestartGame == INVALID_HANDLE)
	{
		PrintToChatAll("\x04[%s]:\x03 Couldn't find the cvar mp_restartgame !", MODNAME);
		SetFailState("[%s]: Couldn't find the cvar mp_restartgame !", MODNAME);
	}
	HookConVarChange(g_hRestartGame, OnGameRestarted);
	
	g_hFreezeTime = FindConVar("mp_freezetime");
	if (g_hFreezeTime == INVALID_HANDLE)
	{
		PrintToChatAll("\x04[%s]:\x03 Couldn't find the cvar mp_freezetime !", MODNAME);
		SetFailState("[%s]: Couldn't find the cvar mp_freezetime !", MODNAME);
	}
	
	// Thank you Zombie:Reloaded.
	// If offset "m_iAmmo" can't be found, then stop the plugin.
	g_iToolsAmmo = FindSendPropInfo("CBasePlayer", "m_iAmmo");
	if (g_iToolsAmmo == -1)
	{
		PrintToChatAll("\x04[%s]:\x03 Couldn't find the offest: m_iAmmo!", MODNAME);
		SetFailState("Offset CBasePlayer::m_iAmmo was not found");
	}
	
	// To get the server password - sm_pw.
	g_hPassword = FindConVar("sv_password");
	
	// To change the server password (We can get it too by that: GetClientName(0, hostname, sizeof(hostname)) )
	g_hHostName = FindConVar("hostname");
	GetConVarString(g_hHostName, g_HostName, sizeof(g_HostName));
	
	// Events that will be used in this plugin.
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("bomb_exploded", EventBombExploded);
	HookEvent("bomb_defused", EventBombDefused);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("player_death",Event_PlayerDeath);
//	HookEvent("player_team", Event_PlayerTeam);
	
	// For ready-system...
	HookEvent("player_disconnect", Event_PlayerDisconnect);
	
	// Admins commands...
	RegAdminCmd("sm_start",
		Command_Start,
		ACCESS_FLAG,
		"Starts a new mix.");
		
	RegAdminCmd("sm_pcw",
		Command_Pcw,
		ACCESS_FLAG,
		"Starts a new pcw.");
		
	RegAdminCmd("sm_stop",
		Command_Stop,
		ACCESS_FLAG,
		"Stops the current mix.");
		
	RegAdminCmd("sm_live",
		Command_Live,
		ACCESS_FLAG,
		"Starts the game (live ...).");
		
	RegAdminCmd("sm_notlive",
		Command_NotLive,
		ACCESS_FLAG,
		"Pause the current mix untill !live is typed again.");
		
	RegAdminCmd("sm_nl",
		Command_NotLive,
		ACCESS_FLAG,
		"Pause the current mix untill !live is typed again.");
	
	RegAdminCmd("sm_mr15",
		Command_Mr15,
		ACCESS_FLAG,
		"Executes the mr15 config.");
		
	RegAdminCmd("sm_match",
		Command_Mr15,
		ACCESS_FLAG,
		"Executes the mr15 config.");
		
	RegAdminCmd("sm_prac",
		Command_Prac,
		ACCESS_FLAG,
		"Executes the prac config.");

	RegAdminCmd("sm_warmup",
		Command_Prac,
		ACCESS_FLAG,
		"Executes the prac config.");
		
	RegAdminCmd("sm_mr3",
		Command_Mr3,
		ACCESS_FLAG,
		"Executes mr3 config.");
		
	RegAdminCmd("sm_knifes",
		Command_KO3,
		ACCESS_FLAG,
		"Starts knife round");
		
	RegAdminCmd("sm_ko3",
		Command_KO3,
		ACCESS_FLAG,
		"Starts knife round");

	RegAdminCmd("sm_swapteams",
		Command_SwapTeams,
		ACCESS_FLAG,
		"Swaps each player team.");

	RegAdminCmd("sm_st",
		Command_SwapTeams,
		ACCESS_FLAG,
		"Swaps each player team.");
		
	RegAdminCmd("sm_rpw",
		Command_GenerateRandomPassword,
		ACCESS_FLAG,
		"Set a random password to the server.");
		
	RegAdminCmd("sm_rr",
		Command_RestartTheGame,
		ACCESS_FLAG,
		"Restarting the game.");

	RegAdminCmd("sm_kickct",
		Command_KickCT,
		ACCESS_FLAG,
		"Kick ct team.");

	RegAdminCmd("sm_kickt",
		Command_KickT,
		ACCESS_FLAG,
		"Kick t team.");
	
	RegAdminCmd("sm_maps",
		Command_Maps,
		ACCESS_FLAG,
		"Show maps menu, to changelevel.");
		
	RegAdminCmd("sm_spec",
		Command_Spec,
		ACCESS_FLAG,
		"Move player to spectors team.");
		
	RegAdminCmd("sm_mix",
		Command_MixMenu,
		ACCESS_FLAG,
		"Opens mix menu.");
		
	RegAdminCmd("sm_pause",
		Command_Pause,
		ACCESS_FLAG,
		"Pause the mix for the current round.");
		
	RegAdminCmd("sm_disablechat",
		Command_DisableChat,
		ACCESS_FLAG,
		"Allows admins to change chat settings through command.");
		
	RegAdminCmd("sm_npw",
		Command_RemovePass,
		ACCESS_FLAG,
		"Remove the server password.");
		
	RegAdminCmd("sm_mmute",
		Command_MutePlayer,
		ACCESS_FLAG,
		"Mutes player.");
		
	RegAdminCmd("sm_munmute",
		Command_UnMutePlayer,
		ACCESS_FLAG,
		"UnMutes player.");
		
	RegAdminCmd("sm_mgag",
		Command_GagPlayer,
		ACCESS_FLAG,
		"Gags player.");
		
	RegAdminCmd("sm_mungag",
		Command_UnGagPlayer,
		ACCESS_FLAG,
		"UnGags player.");
	
	RegAdminCmd("sm_last",
		Command_Last,
		ACCESS_FLAG,
		"Show the last player that connected.");

	// Record admin-commands:
	/* Crashes the sever...
	RegAdminCmd("tv_record",
		Command_TvRecord,
		ACCESS_FLAG,
		"Take control of the source-tv records.");
		
	RegAdminCmd("tv_stoprecord",
		Command_TvStopRecord,
		ACCESS_FLAG,
		"Take control of the source-tv records.");*/
		
	RegAdminCmd("sm_record",
		Command_TvRecord,
		ACCESS_FLAG,
		"Start a record.");
		
	RegAdminCmd("sm_stoprecord",
		Command_TvStopRecord,
		ACCESS_FLAG,
		"Stop the record.");
		
	RegAdminCmd("sm_random",
		Command_RandomTeams,
		ACCESS_FLAG,
		"Random The Players.");
		
	RegAdminCmd("sm_rnd",
		Command_RandomTeams,
		ACCESS_FLAG,
		"Random The Players.");
	
		
	// Players command:
	RegConsoleCmd("sm_score", 
		ShowScores, 
		"Show the score of the mix.");
		
	RegConsoleCmd("sm_teams", 
		Command_ShowTeams, 
		"Show teams when auto-live is running.");
		
	RegConsoleCmd("sm_pw",
		Command_Pass,
		"Change or view the current password.");

	RegConsoleCmd("sm_password",
		Command_Pass,
		"Change or view the server password.");
		
	RegConsoleCmd("sm_ready",
		Command_Ready,
		"Become ready command");
		
	RegConsoleCmd("sm_rdy",
		Command_Ready,
		"Become ready command");
	
	RegConsoleCmd("sm_unready",
		Command_UnReady,
		"Become Un-Ready command");
		
	RegConsoleCmd("sm_urdy",
		Command_UnReady,
		"Become Un-Ready command");

	RegConsoleCmd("sm_notready",
		Command_UnReady,
		"Become Un-Ready command");
		
	RegConsoleCmd("sm_nrdy",
		Command_UnReady,
		"Become Un-Ready command");
		
	RegConsoleCmd("sm_mvp",
		Command_ShowMvp,
		"Show MVP and player score");
		
	RegConsoleCmd("sm_mixhelp",
		Command_MixHelp,
		"Show plugins commands");
		
	RegConsoleCmd("say", Command_SayChat);
	RegConsoleCmd("say_team", Command_SayChat);
	RegConsoleCmd("jointeam", Command_JoinTeam);
		
	// For testing this plugin ...
	if (ENABLE_PLUGIN_CHECKING)
	{
		RegAdminCmd("sm_setmixscore",
			Command_SetMixScore,
			ACCESS_FLAG,
			"Set the mix score...");
			
		RegAdminCmd("sm_forceready",
			Command_ForceReady,
			ACCESS_FLAG,
			"Force players to be ready.");
	}
	
	CheckPropsForCurrentMap();
	
	// Need to create map list ...
	isMapListGenerated = false;
	CreateMapList(); // Create the map list for: sm_maps command.
	
	isMixMenuGenerated = false;
	CreateMixMenu(); // Create the mix menu for: sm_mix command.
	
	CreateHelpPanel();
	
	//InitDB(db);
}
/*
InitDB(&Handle:DbHNDL)
{

	// Errormessage Buffer
	new String:Error[255];
	// COnnect to the DB
	DbHNDL = SQL_ConnectEx(SQL_GetDriver("sqlite"), "", "", "", "mixmod", Error, sizeof(Error), true, 0);
	// If something fails we quit
	if(DbHNDL == INVALID_HANDLE)
	{
		SetFailState(Error);
	}
	
	// Querystring
	new String:Query[255];
	Format(Query, sizeof(Query), "CREATE TABLE IF NOT EXISTS mixmod_ranking (steamid TEXT UNIQUE, name TEXT, kills INTEGER, deaths INTEGER, mvp_times INTEGER);");
	
	// Database lock
	SQL_LockDatabase(DbHNDL);
	
	// Execute the query
	SQL_FastQuery(DbHNDL, Query);
	
	// Database unlock
	SQL_UnlockDatabase(DbHNDL);
	
} */

public OnClientAuthorized(client, const String:auth[])
{
	if (!IsFakeClient(client))
	{
		decl String:name[35], String:auth2[35];
		GetClientName(client, name, sizeof(name));
		
		// "error 047: array sizes do not match, or destination array is too small" -.-
		Format(auth2, sizeof(auth2), "%s", auth);
		// -------------------------------------------
		
		g_LastEntered_SteamID = auth2;
		g_LastEntered_Name = name;
		
		if (hasMixStarted)
		{
			// Inform him that mix is running...
			CreateTimer(60.0, InformPlayerAboutTheMix, client);
			
			// If pause has been used before he spawned, we need him to get a gun, right?
			g_ArrPause[client][0] = 800; // Lets start with 800$ ...
			g_ArrPause[client][1] = GetRandomInt(0,1); // Give USP / Glock (We don't know yet in which team he will start).
		}
	}
}

public Action:InformPlayerAboutTheMix(Handle:timer, any:client)
{
	if (hasMixStarted)
	{
		PrintToChat(client, "\x04[%s]:x\03 Mix is running! \x01Good Luck \x03And\x01 Have Fun!", MODNAME);
		PrintToChat(client, "\x04[%s]:x\03 Mix is running! \x01Good Luck \x03And\x01 Have Fun!", MODNAME);
		PrintToChat(client, "\x04[%s]:x\03 Mix is running! \x01Good Luck \x03And\x01 Have Fun!", MODNAME);
		PrintToChat(client, "\x04[%s]:x\03 Mix is running! \x01LIVE-LIVE-\x04LIVE\x01-LIVE-LIVE", MODNAME);
	}
}

public Action:Command_GagPlayer(client, args) {
	if (args < 1) {
		ReplyToCommand(client, "[%s]: Usage: sm_mgag <player>", MODNAME);
		return Plugin_Handled;
	}

	decl String:pattern[64],String:buffer[64],String:targetName[33];
	GetCmdArg(1,pattern,sizeof(pattern));

	new targets[64],bool:mb;

	new count = ProcessTargetString(pattern,client,targets,sizeof(targets),0,buffer,sizeof(buffer),mb);
	if (count <= 0)
	{
		PrintToChat(client,"\x04[%s] |\x03No such a target %d", MODNAME, pattern);
		return Plugin_Handled;
	}
	else
	{
		for (new i = 0; i < count; i++)
		{
			g_GaggedPlayers[targets[i]] = true;
			
			GetClientName(targets[i], targetName, sizeof(targetName));
			PrintToChat(client, "\x04[%s]:\x03 You have gagged %s !", MODNAME, targetName);
			PrintToChat(targets[i], "\x04[%s]:\x03 You have been gagged!", MODNAME);
		}
	}
	return Plugin_Handled;
}

public Action:Command_UnGagPlayer(client, args) {
	if (args < 1) {
		ReplyToCommand(client, "[%s]: Usage: sm_mungag <player>", MODNAME);
		return Plugin_Handled;
	}

	decl String:pattern[64],String:buffer[64],String:targetName[33];
	GetCmdArg(1,pattern,sizeof(pattern));

	new targets[64],bool:mb;

	new count = ProcessTargetString(pattern,client,targets,sizeof(targets),0,buffer,sizeof(buffer),mb);
	if (count <= 0)
	{
		PrintToChat(client,"\x04[%s] |\x03No such a target %d", MODNAME, pattern);
		return Plugin_Handled;
	}
	else
	{
		for (new i = 0; i < count; i++)
		{
			g_GaggedPlayers[targets[i]] = false;
			
			GetClientName(targets[i], targetName, sizeof(targetName));
			PrintToChat(client, "\x04[%s]:\x03 You have un-gagged %s !", MODNAME, targetName);
			PrintToChat(targets[i], "\x04[%s]:\x03 You have been un-gagged!", MODNAME);
		}
	}
	return Plugin_Handled;
}

public Action:Command_MutePlayer(client, args)
{
	if (!GetConVarBool(g_CvarEnableVoiceCommands))
		return Plugin_Continue;
		
	if (args < 1) {
		ReplyToCommand(client, "[%s]: Usage: sm_mmute <player>", MODNAME);
		return Plugin_Handled;
	}

	decl String:pattern[64],String:buffer[64],String:targetName[33];
	GetCmdArg(1,pattern,sizeof(pattern));

	new targets[64],bool:mb;

	new count = ProcessTargetString(pattern,client,targets,sizeof(targets),0,buffer,sizeof(buffer),mb);
	if (count <= 0)
	{
		PrintToChat(client,"\x04[%s] |\x03No such a target %d", MODNAME, pattern);
		return Plugin_Handled;
	}
	else
	{
		for (new i = 0; i < count; i++)
		{
			g_MutedPlayers[targets[i]] = true;
			SetClientListeningFlags(targets[i], VOICE_MUTED);
			
			GetClientName(targets[i], targetName, sizeof(targetName));
			PrintToChat(client, "\x04[%s]:\x03 You have muted %s !", MODNAME, targetName);
			PrintToChat(targets[i], "\x04[%s]:\x03 You have been muted!", MODNAME);
		}
	}
	return Plugin_Handled;
}

public Action:Command_UnMutePlayer(client, args)
{
	if (!GetConVarBool(g_CvarEnableVoiceCommands))
		return Plugin_Continue;
		
	if (args < 1) {
		ReplyToCommand(client, "[%s]: Usage: sm_munmute <player>", MODNAME);
		return Plugin_Handled;
	}

	decl String:pattern[64],String:buffer[64],String:targetName[33];
	GetCmdArg(1,pattern,sizeof(pattern));

	new targets[64],bool:mb;

	new count = ProcessTargetString(pattern,client,targets,sizeof(targets),0,buffer,sizeof(buffer),mb);
	if (count <= 0)
	{
		PrintToChat(client,"\x04[%s] |\x03No such a target %d", MODNAME, pattern);
		return Plugin_Handled;
	}
	else
	{
		for (new i = 0; i < count; i++)
		{
			g_MutedPlayers[targets[i]] = false;
			SetClientListeningFlags(targets[i], VOICE_NORMAL);
			
			GetClientName(targets[i], targetName, sizeof(targetName));
			PrintToChat(client, "\x04[%s]:\x03 You have un-muted %s !", MODNAME, targetName);
			PrintToChat(targets[i], "\x04[%s]:\x03 You have been un-muted!", MODNAME);
		}
	}
	return Plugin_Handled;
}

public Action:Command_Last(client, args)
{
	if (StrContains(g_LastEntered_SteamID, "STEAM") == -1)
	{
		PrintToChat(client, "\x04[%s]:\x03 No player has joined since the plugin loaded...", MODNAME);
		return Plugin_Handled;
	}
	
	PrintToChatAll("\x04[%s]:\x03 The last player that joined is:", MODNAME);
	PrintToChatAll("\x04[\x03%s\x04] \x03%s .", g_LastEntered_SteamID, g_LastEntered_Name);

	return Plugin_Handled;
}

public VersionHasBeenChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	SetConVarString(convar, PLUGIN_VERSION);
}

public OnMapEnd()
{
	if (GetConVarInt(g_CvarEnableAutoSourceTVRecord) == 1) // Need to enable sourceTv ...
		ServerCommand("tv_enable 1");
		
	g_IsRecording = false;
	g_IsRecordManual = false;
		
}

public OnMapStart()
{
	if (isBuyZoneDisabled)
	{
		if (EnableBuyZone())
			isBuyZoneDisabled = false;
	}
	
	if (!IsSoundPrecached("ambient/misc/brass_bell_C.wav"))
		PrecacheSound("ambient/misc/brass_bell_C.wav", true);
		
	// Reset the gagged/muted players:
	for (new i=0; i<=MaxClients; i++)
	{
		g_GaggedPlayers[i] = false;
		g_MutedPlayers[i] = false;
	}

	hasMixStarted = false;
	didLiveStarted = false;
	isKo3Running = false;
	g_IsItManual = true;
	isRandomBeingUsed = false;
	
	g_LastEntered_SteamID = "NOT_VALID";
	g_LastEntered_Name = "NOT_VALID";
	
	g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");

	if (g_iAccount == -1)
		PrintToChatAll("\x04[%s]:\x03 Can't find the m_iAccount offest! - Money wont be shown in the mix!", MODNAME);
		
	g_hRestartGame = FindConVar("mp_restartgame");
	if (g_hRestartGame == INVALID_HANDLE)
	{
		PrintToChatAll("\x04[%s]:\x03 Couldn't find the cvar mp_restartgame !", MODNAME);
		SetFailState("[%s]: Couldn't find the cvar mp_restartgame !", MODNAME);
	}
	HookConVarChange(g_hRestartGame, OnGameRestarted);
	
	GetConVarString(g_hHostName, g_HostName, sizeof(g_HostName));
	
	isMapListGenerated = false;
	CreateMapList();
	
	CheckPropsForCurrentMap();
}

CheckPropsForCurrentMap()
{
	decl String:mapName[64], String:propMaplist[2048];
	GetCurrentMap(mapName, sizeof(mapName));
	GetConVarString(g_CvarDontRemovePropsMaps, propMaplist, sizeof(propMaplist));
	
	g_IsMapValidToRemoveProps = true;
	if (StrContains(propMaplist, mapName) != -1)
		g_IsMapValidToRemoveProps = false;
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (g_MutedPlayers[GetClientOfUserId(GetEventInt(event, "userid"))])
		SetClientListeningFlags(GetClientOfUserId(GetEventInt(event, "userid")), VOICE_MUTED);
	
	if (GetConVarInt(g_CvarShowMVP) == 1)
		g_ScoresOfTheRound[GetClientOfUserId(GetEventInt(event, "userid"))] = 0;
		
	if (g_SaveClientsScore && (GetConVarInt(g_CvarShowMVP) == 1))
	{
		new c = GetClientOfUserId(GetEventInt(event, "userid"));
		if (IsClientInGame(c))
		{
			SetEntProp(c, Prop_Data, "m_iFrags", g_ScoresOfTheGame[c]);
			SetEntProp(c, Prop_Data, "m_iDeaths", g_DeathsOfTheGame[c]);
		}
	}

	if (isPauseBeingUsed && hasMixStarted)
	{
	/* Indexes:
	0 = Money.
	1 = Pistol number.
	2 = Primary gun number.
	3 = Number of flashes.
	4 = Has grenade.
	5 = Has smoke.
	6 = Kills (frags).
	7 = Deaths.
	8 = Has vest.
	9 = Armor value. 
	*/
		new i = GetClientOfUserId(GetEventInt(event, "userid"));
			
		if (IsClientInGame(i))
		{
			SetEntProp(i, Prop_Send, "m_iAccount", g_ArrPause[i][0]);
			
			if (IsPlayerAlive(i))
			{
				RemovePlayerGuns(i);
				if (g_ArrPause[i][1] != -1) // He had secondery.
					GivePlayerItem(i, pistols[g_ArrPause[i][1]]); // Give his pistol.
				if (g_ArrPause[i][2] != -1) // He had primary.
					GivePlayerItem(i, guns[g_ArrPause[i][2]]); // Give his primary.
				if (g_ArrPause[i][3] > 0) // He had flashbang.
					for (new num = 1; num <= g_ArrPause[i][3]; num++)
						GivePlayerItem(i, "weapon_flashbang");
				if (g_ArrPause[i][4] == 1) // Ha had grenade.
					GivePlayerItem(i, "weapon_hegrenade");
				if (g_ArrPause[i][5] == 1) // He had smoke.
					GivePlayerItem(i, "weapon_smokegrenade");
				
				SetEntProp(i, Prop_Send, "m_bHasHelmet", g_ArrPause[i][8]);
				SetEntProp(i, Prop_Send, "m_ArmorValue", g_ArrPause[i][9]);
			}
			
			if (!g_SaveClientsScore) // If it's true, the score has already been set a few lines before...
			{
				SetEntProp(i, Prop_Data, "m_iFrags", g_ArrPause[i][6]);
				SetEntProp(i, Prop_Data, "m_iDeaths", g_ArrPause[i][7]);
			}
			
			PrintToChat(i, "\x04[%s]:\x03 Your weapons, money and score has been refreshed!", MODNAME);
		}
		
		// isPauseBeingUsed = false; // New round begins! pause has been reseted.
	}
	else if (hasMixStarted)
	{
		new i = GetClientOfUserId(GetEventInt(event, "userid"));
		// Pause settings will be saved now!
		if (IsClientInGame(i))
		{
			g_ArrPause[i][0] = GetEntProp(i, Prop_Send, "m_iAccount"); // Get his money.
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
			else // The player is alive!
			{
				g_ArrPause[i][1] = GetPistolNum(GetPlayerWeaponSlot(i, 1));
				g_ArrPause[i][2] = GetPrimaryNum(GetPlayerWeaponSlot(i, 0));
				g_ArrPause[i][3] = WeaponAmmoGetGrenadeCount(i, GrenadeType_Flashbang);
				g_ArrPause[i][4] = WeaponAmmoGetGrenadeCount(i, GrenadeType_HEGrenade);
				g_ArrPause[i][5] = WeaponAmmoGetGrenadeCount(i, GrenadeType_Smokegrenade);
				g_ArrPause[i][8] = GetEntProp(i, Prop_Send, "m_bHasHelmet");
				g_ArrPause[i][9] = GetEntProp(i, Prop_Send, "m_ArmorValue");
				if (g_ArrPause[i][8] == -1)
					g_ArrPause[i][8] = 0;
				if (g_ArrPause[i][9] == -1)
					g_ArrPause[i][9] = 0;
			}

			g_ArrPause[i][6] = GetEntProp(i, Prop_Data, "m_iFrags");
			if (g_ArrPause[i][6] == -1)
				g_ArrPause[i][6] = 0;
			g_ArrPause[i][7] = GetEntProp(i, Prop_Data, "m_iDeaths");
			if (g_ArrPause[i][7] == -1)
				g_ArrPause[i][7] = 0;
		}
	}
}

/* Disabled...
public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(g_CvarShowMVP) == 1)
		g_ScoresOfTheRound[GetClientOfUserId(GetEventInt(event, "userid"))] = 0;
		
	if (hasMixStarted && g_IsFirstRoundOfHalfTwoStarted)
	{
		new i = GetClientOfUserId(GetEventInt(event, "userid"));
			
		if (IsClientInGame(i))
		{
			SetEntProp(i, Prop_Data, "m_iFrags", g_ArrPause[i][6]);
			SetEntProp(i, Prop_Data, "m_iDeaths", g_ArrPause[i][7]);
		}
	}
	if (isPauseBeingUsed && hasMixStarted)
	{
	// ---
	Indexes:
	0 = Money.
	1 = Pistol number.
	2 = Primary gun number.
	3 = Number of flashes.
	4 = Has grenade.
	5 = Has smoke.
	6 = Kills (frags).
	7 = Deaths.
	8 = Has vest.
	9 = Armor value. 
	// ----
	
		new i = GetClientOfUserId(GetEventInt(event, "userid"));
			
		if (IsClientInGame(i))
		{
			SetEntProp(i, Prop_Send, "m_iAccount", g_ArrPause[i][0]);
			
			if (IsPlayerAlive(i))
			{
				RemovePlayerGuns(i);
				if (g_ArrPause[i][1] != -1) // He had secondery.
					GivePlayerItem(i, pistols[g_ArrPause[i][1]]); // Give his pistol.
				if (g_ArrPause[i][2] != -1) // He had primary.
					GivePlayerItem(i, guns[g_ArrPause[i][2]]); // Give his primary.
				if (g_ArrPause[i][3] > 0) // He had flashbang.
					for (new num = 1; num <= g_ArrPause[i][3]; num++)
						GivePlayerItem(i, "weapon_flashbang");
				if (g_ArrPause[i][4] == 1) // Ha had grenade.
					GivePlayerItem(i, "weapon_hegrenade");
				if (g_ArrPause[i][5] == 1) // He had smoke.
					GivePlayerItem(i, "weapon_smokegrenade");
				
				SetEntProp(i, Prop_Send, "m_bHasHelmet", g_ArrPause[i][8]);
				SetEntProp(i, Prop_Send, "m_ArmorValue", g_ArrPause[i][9]);
			}
			
			SetEntProp(i, Prop_Data, "m_iFrags", g_ArrPause[i][6]);
			SetEntProp(i, Prop_Data, "m_iDeaths", g_ArrPause[i][7]);
				
			PrintToChat(i, "\x04[%s]:\x03 Your weapons, money and score has been refreshed!", MODNAME);
		}
		
		// isPauseBeingUsed = false; // New round begins! pause has been reseted.
	}
	else if (hasMixStarted && didLiveStarted)
	{
		new i = GetClientOfUserId(GetEventInt(event, "userid"));
		// Pause settings will be saved now!
		if (IsClientInGame(i))
		{
			g_ArrPause[i][0] = GetEntProp(i, Prop_Send, "m_iAccount"); // Get his money.
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
			else // The player is alive!
			{
				g_ArrPause[i][1] = GetPistolNum(GetPlayerWeaponSlot(i, 1));
				g_ArrPause[i][2] = GetPrimaryNum(GetPlayerWeaponSlot(i, 0));
				g_ArrPause[i][3] = WeaponAmmoGetGrenadeCount(i, GrenadeType_Flashbang);
				g_ArrPause[i][4] = WeaponAmmoGetGrenadeCount(i, GrenadeType_HEGrenade);
				g_ArrPause[i][5] = WeaponAmmoGetGrenadeCount(i, GrenadeType_Smokegrenade);
				g_ArrPause[i][8] = GetEntProp(i, Prop_Send, "m_bHasHelmet");
				g_ArrPause[i][9] = GetEntProp(i, Prop_Send, "m_ArmorValue");
				if (g_ArrPause[i][8] == -1)
					g_ArrPause[i][8] = 0;
				if (g_ArrPause[i][9] == -1)
					g_ArrPause[i][9] = 0;
			}

			g_ArrPause[i][6] = GetEntProp(i, Prop_Data, "m_iFrags");
			if (g_ArrPause[i][6] == -1)
				g_ArrPause[i][6] = 0;
			g_ArrPause[i][7] = GetEntProp(i, Prop_Data, "m_iDeaths");
			if (g_ArrPause[i][7] == -1)
				g_ArrPause[i][7] = 0;
		}
	}
	else if (hasMixStarted && !g_SaveClientsScore)
	{
		new i = GetClientOfUserId(GetEventInt(event, "userid"));
		// Pause settings will be saved now!
		if (IsClientInGame(i))
		{
			g_ArrPause[i][0] = GetEntProp(i, Prop_Send, "m_iAccount"); // Get his money.
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
			else // The player is alive!
			{
				g_ArrPause[i][1] = GetPistolNum(GetPlayerWeaponSlot(i, 1));
				g_ArrPause[i][2] = GetPrimaryNum(GetPlayerWeaponSlot(i, 0));
				g_ArrPause[i][3] = WeaponAmmoGetGrenadeCount(i, GrenadeType_Flashbang);
				g_ArrPause[i][4] = WeaponAmmoGetGrenadeCount(i, GrenadeType_HEGrenade);
				g_ArrPause[i][5] = WeaponAmmoGetGrenadeCount(i, GrenadeType_Smokegrenade);
				g_ArrPause[i][8] = GetEntProp(i, Prop_Send, "m_bHasHelmet");
				g_ArrPause[i][9] = GetEntProp(i, Prop_Send, "m_ArmorValue");
				if (g_ArrPause[i][8] == -1)
					g_ArrPause[i][8] = 0;
				if (g_ArrPause[i][9] == -1)
					g_ArrPause[i][9] = 0;
			}

			g_ArrPause[i][6] = GetEntProp(i, Prop_Data, "m_iFrags");
			if (g_ArrPause[i][6] == -1)
				g_ArrPause[i][6] = 0;
			g_ArrPause[i][7] = GetEntProp(i, Prop_Data, "m_iDeaths");
			if (g_ArrPause[i][7] == -1)
				g_ArrPause[i][7] = 0;
		}
	}
}*/ // The first */ is after the indexes ...

public Action:DisablePause(Handle:timer, any:team)
{
	isPauseBeingUsed = false;
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if ((GetConVarInt(g_CvarAutoMixEnabled) == 1) && !hasMixStarted) // Inform the clients about the ready system and status...
		{
			UpdateReadyPanel();
			for (new i=1; i<=MaxClients; i++)
				if (IsClientInGame(i) && !IsFakeClient(i))
					ShowReadyPanel(i);
		}
		
		if (isKo3Running) // Knife is running and its own text will be shown.
		{
			if (GetConVarInt(g_CvarHalfAutoLiveStart) == 1)
				PrintToChatAll("\x04[%s]:\x03 Ko3 is running...", MODNAME);
			else if (hasMixStarted)
				PrintToChatAll("\x04[%s]:\x03 Ko3 is running... type !live to start the match", MODNAME);
				
			for (new i=1; i<=MaxClients; i++)
			{
				if (!IsClientInGame(i) || !IsPlayerAlive(i))
					continue;
					
				RemovePlayerGuns(i);
				SetEntProp(i, Prop_Send, "m_bHasHelmet", 1);
				SetEntProp(i, Prop_Send, "m_ArmorValue", 100);
			}
				
			PrintToChatAll("\x04[%s]:\x03 This round is decisive on who will pick their side.", MODNAME);
			return;
		}
		
		if (hasMixStarted)
		{
			CreateTimer(0.5, DisablePause); // New round begins! pause will be reseted.
			
			if (GetConVarInt(g_CvarRemoveProps) == 1) // Remove the props from the map!
				RemoveProps();
			
			decl String:teamAName[32], String:teamBName[32];
			GetConVarString(g_CvarCusomNameTeamCT, teamAName, sizeof(teamAName));
			GetConVarString(g_CvarCusomNameTeamT, teamBName, sizeof(teamBName));
			if ((g_nTScoreH1 == -1) || (g_nCTScoreH1 == -1))
			{
				g_nTScoreH1 = 0;
				g_nCTScoreH1 = 0;
			}
			
			// The scoreboard will look exactly like the true score (sm_pause requiers that).
			SetTeamScore(3, g_nCTScoreH1);
			SetTeamScore(2, g_nTScoreH1);
			// --------------------------
			
			if (g_CurrentHalf == 1)
			{
				if(g_CurrentRound == 0) // When the game has been restarted in freeze-time, sometimes 1 is being added to CurrentRound - Because of that, I reseted the current round OnGameResarted
					g_CurrentRound = 1;
					
				if (g_CurrentRound > (g_nCTScoreH1 + g_nTScoreH1 + 1))
					g_CurrentRound--;

				if (GetConVarInt(g_CvarShowScores) == 1)
					PrintToChatAll("\x04[%s]:\x03 Round\x03 %d \x04- Half\x03 %d\x04 /\x03 2\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", MODNAME, g_CurrentRound, g_CurrentHalf, teamAName, g_nCTScoreH1, teamBName, g_nTScoreH1);
				
				if (!didLiveStarted)
					PrintToChatAll("\x04[%s]:\x03 Not Live!", MODNAME);
			}
			else if (g_CurrentHalf == 2)
			{
				if(g_CurrentRound == 0) // When the game has been restarted in freeze-time, sometimes 1 is being added to CurrentRound - Because of that, I reseted the current round OnGameResarted
					g_CurrentRound = 1;
					
				if ((g_nCTScore == 16) || (g_nTScore == 16) || ((g_nCTScore == 15) && (g_nTScore == 15) && (GetConVarInt(g_CvarMr3Enabled) == 0))) // If roundEnd failed at finishing the game...
				{
					if (GetConVarInt(g_CvarInformWinnerInPanel) == 1)
					{
						if (g_nCTScore == 16)
							CreateWinningTeamPanel(3);
						else if (g_nTScore == 16)
							CreateWinningTeamPanel(2);
						else if (g_nCTScore == g_nTScore)
							CreateWinningTeamPanel(1);
					}
					else
					{
						if (g_nCTScore == 16)
							CreateTimer(3.0, InformMix, 3);
						else if (g_nTScore == 16)
							CreateTimer(3.0, InformMix, 2);
						else if (g_nCTScore == g_nTScore)
							CreateTimer(3.0, InformMix, 1);
					}
					
					hasMixStarted = false;
					didLiveStarted = false;
					
					g_IsItManual = true;
					if (GetConVarInt(g_CvarAutoMixEnabled) == 1)
					{
						g_AllowReady = true;
						for (new i=0; i<MaxClients; i++)
						{
							g_ReadyPlayers[i] = false;
							g_ReadyPlayersData[i] = -1;
						}
					}
			
					g_CurrentRound = 1;
					g_CurrentHalf = 1;
					g_nTScore = -1;
					g_nCTScore = -1;
					
					g_SaveClientsScore = false;
			
					SetConVarString(g_hHostName, g_HostName); // Reset the hostname ...
			
					Command_Prac(0, 0);
					
					if (GetConVarInt(g_CvarRemovePassWhenMixIsEnded) == 1)
						Command_RemovePass(0, 0);
				}
				else
				{
					if (g_CurrentRound > (g_nCTScoreH1 + g_nCTScoreH1 + 1))
						g_CurrentRound--;
			
					if (GetConVarInt(g_CvarShowScores) == 1)
						PrintToChatAll("\x04[%s]:\x03 Round\x03 %d \x04- Half\x03 %d\x04 /\x03 2\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", MODNAME, g_CurrentRound, g_CurrentHalf, teamAName, g_nCTScore, teamBName, g_nTScore);
					
					if ((g_nCTScore == 15) && (g_nTScore == 15) && (GetConVarInt(g_CvarMr3Enabled) == 1)) // If roundEnd failed at starting the mr3 settings...
					{
						g_nCTScore2 = g_nCTScore;
						g_nTScore2 = g_nTScore;
						
						new Float:time = GetConVarFloat(g_CvarDelayBeforeSwapping);
						if (time < 0.1)
							time = 0.1;
						CreateTimer(time, SwapTimer);
						
						g_CurrentRound = 1;
						g_CurrentHalf = 3;
						if ((GetConVarInt(g_CvarHalfAutoLiveStart) == 0) && g_IsItManual) // Admin need to write: !live to start...
							didLiveStarted = false;
						
						if (GetConVarInt(g_CvarPlayTeamSwapedSound) == 1)
						{
							if (!IsSoundPrecached("ambient/misc/brass_bell_C.wav"))
								PrecacheSound("ambient/misc/brass_bell_C.wav", true);
						
							EmitSoundToAll("ambient/misc/brass_bell_C.wav");
						}
						Command_Mr3(0, 0);
						
						if (GetConVarInt(g_CvarHalfAutoLiveStart) == 0)
							PrintToChatAll("\x04[%s]:\x03 Teams swapped. Mr3 settings are loaded! \x01- \x03Type\x04 !live \x03to start.", MODNAME);
						else
							PrintToChatAll("\x04[%s]:\x03 Teams swapped. Mr3 settings are loaded!", MODNAME);
					}
					else
					{
						if (GetConVarInt(g_CvarMr3Enabled) == 1)
						{
							if ((g_nCTScore == 15) && (g_nTScore == 14))
								PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s - \x04If %s wins, Mr3 will be loaded!", MODNAME, teamAName, teamBName);
							else if ((g_nCTScore == 14) && (g_nTScore == 15))
								PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s - \x04If %s wins, Mr3 will be loaded!", MODNAME, teamBName, teamAName);
							else
							{
								if (g_nCTScore == 15)
									PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", MODNAME, teamAName);
								if (g_nTScore == 15)
									PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", MODNAME, teamBName);
							}
						}
						else
						{
							if (g_nCTScore == 15)
								PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", MODNAME, teamAName);
							if (g_nTScore == 15)
								PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", MODNAME, teamBName);
						}
					}
				}
				
				if (!didLiveStarted)
					PrintToChatAll("\x04[%s]:\x03 Not Live!", MODNAME);
			}
			else if (g_CurrentHalf > 2)
			{
				if(g_CurrentRound == 0) // When the game has been restarted in freeze-time, sometimes 1 is being added to CurrentRound - Because of that, I reseted the current round OnGameResarted
					g_CurrentRound = 1;
					
				if (g_CurrentRound > (g_nCTScoreH1 + g_nTScoreH1 + 1))
					g_CurrentRound--;
					
				if (GetConVarInt(g_CvarShowScores) == 1)
					PrintToChatAll("\x04[%s]:\x03 Round\x03 %d \x04- Half\x03 %d\x04 /\x03 4\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", MODNAME, g_CurrentRound, g_CurrentHalf, teamAName, g_nCTScore, teamBName, g_nTScore);

				if (g_nCTScore == 18)
					PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", MODNAME, teamAName);
				if (g_nTScore == 18)
					PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", MODNAME, teamBName);
					
				if (!didLiveStarted)
					PrintToChatAll("\x04[%s]:\x03 Not Live!", MODNAME);
			}
			
			if ((hasMixStarted) && (didLiveStarted))
			{	
				g_CurrentRound++;
				
				if ((g_CurrentHalf == 1) && (g_CurrentRound == 16))
				{
					g_SwapNow = true;
					
					if (GetConVarInt(g_CvarShowSwitchInPanel) == 1) // 0 = in chat, 1 = in panel.
					{
						decl String:titleFormat[32];
						Format(titleFormat, sizeof(titleFormat), "%s: ", MODNAME);
						new Handle:panel = CreatePanel();
						SetPanelTitle(panel, titleFormat);
						DrawPanelItem(panel, "", ITEMDRAW_SPACER);
						DrawPanelText(panel, " Teams will be swapped AUTOMATICALLY after this round. \n *Do NOT* \n change your team.");
						DrawPanelItem(panel, "", ITEMDRAW_SPACER);

						SetPanelCurrentKey(panel, 10);
						DrawPanelItem(panel, "Close", ITEMDRAW_CONTROL);
					 
						for(new i = 1; i <= MaxClients; i++)
						{
							if(IsClientInGame(i) && !IsFakeClient(i))
							{
								SendPanelToClient(panel, i, Handler_DoNothing, (GetConVarInt(g_hFreezeTime) - 1));
							}
						}

						CloseHandle(panel);
					}
					else
						PrintToChatAll("\x04[%s]:\x03 Teams will be swaped AUTOMATICALLY after this round. Do \x01NOT\x03 change your team.", MODNAME);
				}
				else if ((g_CurrentHalf == 3) && (g_CurrentRound == 4))
				{
					g_SwapNow = true;
					
					if (GetConVarInt(g_CvarShowSwitchInPanel) == 1) // 0 = in chat, 1 = in panel.
					{
						decl String:titleFormat[32];
						Format(titleFormat, sizeof(titleFormat), "%s: ", MODNAME);
						new Handle:panel = CreatePanel();
						SetPanelTitle(panel, titleFormat);
						DrawPanelItem(panel, "", ITEMDRAW_SPACER);
						DrawPanelText(panel, " Teams will be swapped AUTOMATICALLY after this round. \n *Do NOT* \n change your team.");
						DrawPanelItem(panel, "", ITEMDRAW_SPACER);

						SetPanelCurrentKey(panel, 10);
						DrawPanelItem(panel, "Close", ITEMDRAW_CONTROL);
					 
						for(new i = 1; i <= MaxClients; i++)
						{
							if(IsClientInGame(i) && !IsFakeClient(i))
							{
								SendPanelToClient(panel, i, Handler_DoNothing, (GetConVarInt(g_hFreezeTime) - 1));
							}
						}

						CloseHandle(panel);
					}
					else
						PrintToChatAll("\x04[%s]:\x03 Teams will be swapped AUTOMATICALLY after this round. Do \x01NOT\x03 change your team.", MODNAME);
				}
			}
			
			if (GetConVarInt(g_CvarShowMoneyAndWeapons) == 1)
				ShowTeamMoneyAndWeapons();
		}
	}
}

RemovePlayerGuns(client)
{
	new gunEnt;
	for (new i = 0; i < 5; i++)
	{
		if (i == 2) // Do not remove the knife...
			continue; 
			
		while((gunEnt = GetPlayerWeaponSlot(client, i)) != -1) // Loop through all the guns in the current slot - Maybe it's the nade slot...
			RemovePlayerItem(client, gunEnt);
	}
	// Switch to knife - When I will give back the guns, they will automatically be swithced.
	ClientCommand(client, "slot3");
}

/**
 * Get the count of any grenade-type a client has.
 * 
 * @param client    The client index.
 * @param slot      The type of
 * Credit to: Zombie:Reloaded!
 */
stock WeaponAmmoGetGrenadeCount(client, WeaponAmmoGrenadeType:type)
{
	return GetEntData(client, g_iToolsAmmo + (_:type * 4));
}

GetPistolNum(ent)
{
	if (ent == -1)
		return -1;

	decl String:weaponName[20];
	if (!GetEntityClassname(ent, weaponName, sizeof(weaponName)))
		return -1;
	
	for (new i=0; i<MAX_PISTOLS; i++)
		if (StrEqual(pistols[i], weaponName))
			return i;

	return -1;
}

GetPrimaryNum(ent)
{
	if (ent == -1)
		return -1;
		
	decl String:weaponName[20];
	if (!GetEntityClassname(ent, weaponName, sizeof(weaponName)))
		return -1;
	
	for (new i=0; i<MAX_GUNS; i++)
		if (StrEqual(guns[i], weaponName))
			return i;

	return -1;
}

public Handler_DoNothing(Handle:menu, MenuAction:action, param1, param2)
{
	/* Do nothing */
}

PrintToTeamChat(team, const String:message[])
{
	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && (GetClientTeam(i) == team))
			PrintToChat(i, "%s", message);
	}
}

ShowTeamMoneyAndWeapons()
{
	if ((hasMixStarted) && (g_iAccount != -1))
	{
		new show = GetConVarInt(g_CvarShowCashInPanel); // 0 = Show in chat, 1 = Show in panel
		new bool:wasMaxed[MAXPLAYERS+1] = {false, ...};
		if (show == 0)
		{
			decl String:name[MAX_NAME_LENGTH], String:msg[150];
			new team, money, i, max = 0, pos = -1;
			PrintToChatAll("----------------------------");

			while (max != -1)
			{
				max = -1;
				for(i=1;i<=MaxClients;i++)
				{
					if (wasMaxed[i])
						continue;

					if (!IsClientInGame(i) || !IsClientInGame(i))
					{
						wasMaxed[i] = true;
						continue;
					}

					team = GetClientTeam(i);
					if (team <= 1)
					{
						wasMaxed[i] = true;
						continue;
					}
					
					money = GetEntProp(i, Prop_Send, "m_iAccount");
					if (max < money)
					{
						max = money;
						pos = i;
					}
				}
				
				if (max == -1) // Looping has been finished!
					continue;

				GetClientName(pos, name, sizeof(name));
				if (GetPlayerWeaponSlot(pos, 0) != -1)
					Format(msg, sizeof(msg), "\x04 %s:\x03 %d+", name, max);
				else
					Format(msg, sizeof(msg), "\x04 %s:\x03 %d", name, max);
					
				team = GetClientTeam(pos);
				
				PrintToTeamChat(team, msg);
				wasMaxed[pos] = true;
			}
		}
		else if(show == 1) // Show team money in panel ...
		{
			decl String:name[MAX_NAME_LENGTH], String:msg[150];
			new team, money, i, max = 0, pos = -1;
			
			decl String:teamAName[32], String:teamBName[32];
			GetConVarString(g_CvarCusomNameTeamCT, teamAName, sizeof(teamAName));
			GetConVarString(g_CvarCusomNameTeamT, teamBName, sizeof(teamBName));
			
			decl String:titleCtFormat[64], String:titleTFormat[64];
			Format(titleCtFormat, sizeof(titleCtFormat), "%s cash: ", teamAName);
			Format(titleTFormat, sizeof(titleTFormat), "%s cash: ", teamBName);
			
			// Create teams money panel ...
			new Handle:panelT = CreatePanel();
			new Handle:panelCT = CreatePanel();
			SetPanelTitle(panelT, MODNAME);
			DrawPanelText(panelT, titleTFormat);
			DrawPanelItem(panelT, "-------------------------", ITEMDRAW_SPACER);
			SetPanelTitle(panelCT, MODNAME);
			DrawPanelText(panelCT, titleCtFormat);
			DrawPanelItem(panelCT, "-------------------------", ITEMDRAW_SPACER);

			while (max != -1)
			{
				max = -1;
				for(i=1;i<=MaxClients;i++)
				{
					if (wasMaxed[i])
						continue;

					if (!IsClientInGame(i) || !IsClientInGame(i))
					{
						wasMaxed[i] = true;
						continue;
					}

					team = GetClientTeam(i);
					if (team <= 1)
					{
						wasMaxed[i] = true;
						continue;
					}
					
					money = GetEntProp(i, Prop_Send, "m_iAccount");
					if (max < money)
					{
						max = money;
						pos = i;
					}
				}
				
				if (max == -1) // Looping has been ed!
					continue;
				
				GetClientName(pos, name, sizeof(name));
				if (GetPlayerWeaponSlot(pos, 0) != -1)	
					Format(msg, sizeof(msg), "%s: %d+", name, max);
				else
					Format(msg, sizeof(msg), "%s: %d", name, max);
					
				team = GetClientTeam(pos);
				
				// PrintToTeamChat(team, msg);
				if (team == 3)
					DrawPanelItem(panelCT, msg);
				else if (team == 2)
					DrawPanelItem(panelT, msg);
				
				wasMaxed[pos] = true;
			}

			DrawPanelItem(panelT, "-------------------------", ITEMDRAW_SPACER);
			DrawPanelItem(panelT, "Close", ITEMDRAW_CONTROL);
			SetPanelCurrentKey(panelT, 10);
			DrawPanelItem(panelCT, "-------------------------", ITEMDRAW_SPACER);
			DrawPanelItem(panelCT, "Close", ITEMDRAW_CONTROL);
			SetPanelCurrentKey(panelCT, 10);
		
			for (new j = 1; j <= MaxClients; j++)
			{
				if(IsClientInGame(j) && !IsFakeClient(j))
				{
					team = GetClientTeam(j);
					if (team == 2)
						SendPanelToClient(panelT, j, Handler_DoNothing, (GetConVarInt(g_hFreezeTime) - 1));
					else if (team == 3)
						SendPanelToClient(panelCT, j, Handler_DoNothing, (GetConVarInt(g_hFreezeTime) - 1));
				}
			}	
			
			CloseHandle(panelT);
			CloseHandle(panelCT);
		}
	}
}

public Handle_TeamsVoteMenu(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if (action == MenuAction_VoteEnd)
	{
		if (param1 == 0)
		{
			new team;
			for (new i=1; i<=MaxClients; i++)
			{
				if (IsClientInGame(i))
				{
					team = GetClientTeam(i);
					if (team == 2)
						ChangeClientTeam(i, 3);
					else if (team == 3)
						ChangeClientTeam(i, 2);
				}
			}
		}
		
		isKo3Running = false;
		PrintToChatAll("x04[%s]:\x03 Teams has been decided!");
		Command_Mr15(0, 0);
	}
}

public EventBombExploded(Handle:event, const String:name[], bool:dontBroadcast)
{
	if ((GetConVarInt(g_CvarEnabled) == 1) && hasMixStarted && didLiveStarted && (GetConVarInt(g_CvarShowMVP)==1) && (!isPauseBeingUsed))
	{
		new client = GetClientOfUserId(GetEventInt(event,"userid"));
		new bool:flag = false;
		for (new i=1; i<=MaxClients; i++)
		{
			if (IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 3)
			{
				flag = true;
				break;
			}
		}
		
		if (flag)
			g_ScoresOfTheGame[client]+=3;
	}
}

public EventBombDefused(Handle:event, const String:name[], bool:dontBroadcast)
{
	if ((GetConVarInt(g_CvarEnabled) == 1) && hasMixStarted && didLiveStarted && (GetConVarInt(g_CvarShowMVP)==1) && (!isPauseBeingUsed))
	{
		new client = GetClientOfUserId(GetEventInt(event,"userid"));
		
		g_ScoresOfTheGame[client]+=3;
	}
}

public Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (isPauseBeingUsed)
		{
			SetTeamScore(3, g_nCTScoreH1);
			SetTeamScore(2, g_nTScoreH1);
			
			// isPauseBeingUsed = false; // - Will be false in the roundStart event!
			
			return; // Stop the plugin! Pause has been used.
		}
		
		if (isKo3Running) // Knife round has been ended...
		{
			if ((GetConVarInt(g_CvarKnifeWinTeamVote) == 1)) // Lets vote for the side of the teams.
			{
				new Handle:switchteams = CreateMenu(Handle_TeamsVoteMenu);
				new win_team = GetEventInt(event, "winner");
				if (win_team == TEAM_T)
					SetMenuTitle(switchteams, "Switch team side (to ct team)?");
				else if (win_team == TEAM_CT)
					SetMenuTitle(switchteams, "Switch team side (to t team)?");
				AddMenuItem(switchteams, "yes", "Yes");
				AddMenuItem(switchteams, "no", "No");
				SetMenuExitButton(switchteams, false);
				new clientsArr[64], found = 0;
				for (new i=1; i<=MaxClients; i++)
				{
					if (IsClientInGame(i) && (GetClientTeam(i) == win_team))
					{
						clientsArr[found] = i;
						found++;
					}
				}
				VoteMenu(switchteams, clientsArr, found, 12);
				if (win_team == 2)
					PrintToChatAll("\x04[%s]:\x03 Terrorists will choose now their team!", MODNAME);
				else if (win_team == 3)
					PrintToChatAll("\x04[%s]:\x03 Counter-Terrorists will choose now their team!", MODNAME);
				// isKo3Running = false; - Will be disabled when the vote has been ended!
				
				if (EnableBuyZone())
					isBuyZoneDisabled = false;
					
				if (GetConVarInt(g_CvarHalfAutoLiveStart) == 1)
				{
					Command_Live(0, 0);
					didLiveStarted = true;
				}
				
				return;
			}
			
			if ((GetConVarInt(g_CvarHalfAutoLiveStart) == 1) && (hasMixStarted))
			{
				Command_Live(0, 0);
				didLiveStarted = true;
			}
			
			if (EnableBuyZone())
				isBuyZoneDisabled = false;
			
			isKo3Running = false;
			return;
		}
		
		if ((hasMixStarted) && (didLiveStarted)) // Add 1 to the current round win number
		{
			new win_team = GetEventInt(event, "winner");
			if (win_team == TEAM_T)
				g_nTScoreH1++;
			else if (win_team == TEAM_CT)
				g_nCTScoreH1++;
				
			// The scoreboard will look exactly like the true score (sm_pause requiers that).
			SetTeamScore(3, g_nCTScoreH1);
			SetTeamScore(2, g_nTScoreH1);
			// --------------------------
			
			// Show the mvp - if need to...
			if (GetConVarInt(g_CvarShowMVP) == 1)
			{
				new max=0;
				new winnerIndex = -1;
				for (new i=1; i<=MaxClients;i++)
				{
					if (IsClientConnected(i))
					{
						if (g_ScoresOfTheRound[i] > max)
						{
							max = g_ScoresOfTheRound[i];
							winnerIndex = i;
						}
					}
				}
				decl String:attackerName[32];
				GetClientName(winnerIndex, attackerName, sizeof(attackerName));
				new kills = max;
				
				if (kills == 5)
					PrintToChatAll("\x04[%s]:\x03 Round\x01 %d \x03MVP:\x04 %s , \x03Did an \x04ACE!", MODNAME, g_CurrentRound-1, attackerName, kills);
				else if (kills == 4)
					PrintToChatAll("\x04[%s]:\x03 Round\x01 %d \x03MVP:\x04 %s , \x03Did a \x04MINI!", MODNAME, g_CurrentRound-1, attackerName, kills);
				else if (kills == 3)
					PrintToChatAll("\x04[%s]:\x03 Round\x01 %d \x03MVP:\x04 %s , \x03Killed:\x04 %d \x03Enemies!", MODNAME, g_CurrentRound-1, attackerName, kills);
			}
		}
		
		if ((hasMixStarted) && (g_SwapNow) && (didLiveStarted) && (g_CurrentHalf == 1))
		{
			didLiveStarted = false; // Disable it here, so score won't be added...
			g_nCTScore = g_nCTScoreH1;
			g_nTScore = g_nTScoreH1;
			
			g_nCTScore2 = g_nCTScore;
			g_nTScore2 = g_nTScore;
			
			new Float:time = GetConVarFloat(g_CvarDelayBeforeSwapping);
			if (time < 0.1)
				time = 0.1;
			CreateTimer(time, SwapTimer);

			PrintToChatAll("\x04[%s]:\x03 Swapping teams...", MODNAME);
			
			g_nTScoreH1 = 0;
			g_nCTScoreH1 = 0;
			g_CurrentRound = 1;
			g_CurrentHalf = 2;
			if ((GetConVarInt(g_CvarHalfAutoLiveStart) == 0) && g_IsItManual) // Admin need to write: !live to start...
				didLiveStarted = false;
			
			if (GetConVarInt(g_CvarPlayTeamSwapedSound) == 1)
			{
				if (!IsSoundPrecached("ambient/misc/brass_bell_C.wav"))
					PrecacheSound("ambient/misc/brass_bell_C.wav", true);
			
				EmitSoundToAll("ambient/misc/brass_bell_C.wav");
			}
			if (GetConVarInt(g_CvarHalfAutoLiveStart) == 0)
				PrintToChatAll("\x04[%s]:\x03 Teams swapped. HALF 2! \x01- \x03Type\x04 !live \x03to start.", MODNAME);
			else
			{
				new executed = 0;
				if(GetConVarInt(g_CvarUseZBMatchCommand) == 1)
				{
					new Handle:zbWarMode = FindConVar("zb_warmode");
					if(zbWarMode != INVALID_HANDLE) // Zblock is running in this server...
					{
						if(GetConVarInt(zbWarMode) == 1) // Zblock war mode is enabled - can execute zb_lo3 command!
						{
							ServerCommand("zb_lo3");
							executed = 1;
						}
					}
				}
				
				if (executed == 0) // Couldn't execute the zb_lo3 command
				{
					if(GetConVarInt(g_CvarRestartTimeInLiveCommand) > 0)
						ServerCommand("mp_restartgame %d", GetConVarInt(g_CvarRestartTimeInLiveCommand));
					else
						ServerCommand("mp_restartgame 3");
				}
				
				PrintToChatAll("\x04[%s]:\x03 Teams swapped. HALF 2 Will begin in a few seconds!", MODNAME);
				PrintToChatAll("\x04[%s]:\x03 Teams swapped. HALF 2 Will begin in a few seconds!", MODNAME);
				PrintToChatAll("\x04[%s]:\x03 Teams swapped. HALF 2 Will begin in a few seconds!", MODNAME);
			}
			
			g_SwapNow = false;
		}

		if ((hasMixStarted) && (g_CurrentHalf == 2) && (didLiveStarted))
		{
			new win_team = GetEventInt(event, "winner");
			if (win_team == TEAM_T)
				g_nCTScore++;
			else if (win_team == TEAM_CT)
				g_nTScore++;

			if ((g_nCTScore == 16) || (g_nTScore == 16) || ((g_nCTScore == 15) && (g_nTScore == 15) && (GetConVarInt(g_CvarMr3Enabled) == 0)))
			{
				if (GetConVarInt(g_CvarInformWinnerInPanel) == 1)
				{
					if (g_nCTScore == 16)
						CreateWinningTeamPanel(3);
					else if (g_nTScore == 16)
						CreateWinningTeamPanel(2);
					else if (g_nCTScore == g_nTScore)
						CreateWinningTeamPanel(1);
				}
				else
				{
					if (g_nCTScore == 16)
						CreateTimer(3.0, InformMix, 3);
					else if (g_nTScore == 16)
						CreateTimer(3.0, InformMix, 2);
					else if (g_nCTScore == g_nTScore)
						CreateTimer(3.0, InformMix, 1);
				}
				
				hasMixStarted = false;
				didLiveStarted = false;
				
				g_IsItManual = true;
				if (GetConVarInt(g_CvarAutoMixEnabled) == 1)
				{
					g_AllowReady = true;
					for (new i=0; i<MaxClients; i++)
					{
						g_ReadyPlayers[i] = false;
						g_ReadyPlayersData[i] = -1;
					}
				}

				g_nTScoreH1 = 0;
				g_nCTScoreH1 = 0;
				g_CurrentRound = 1;
				g_CurrentHalf = 1;
				g_nTScore = -1;
				g_nCTScore = -1;
				
				g_SaveClientsScore = false;
		
				SetConVarString(g_hHostName, g_HostName); // Reset the hostname ...
		
				Command_Prac(0, 0);
				
				if (GetConVarInt(g_CvarRemovePassWhenMixIsEnded) == 1)
						Command_RemovePass(0, 0);
			}
			else if ((g_nCTScore == 15) && (g_nTScore == 15) && (GetConVarInt(g_CvarMr3Enabled) == 1)) // Mr3 settings will run now...
			{
				didLiveStarted = false; // Disable it here - before swapping teams...
				g_nCTScore2 = g_nCTScore;
				g_nTScore2 = g_nTScore;

				new Float:time = GetConVarFloat(g_CvarDelayBeforeSwapping);
				if (time < 0.1)
					time = 0.1;
				CreateTimer(time, SwapTimer);
				PrintToChatAll("\x04[%s]:\x03 Swapping teams...", MODNAME);

				g_nTScoreH1 = 0;
				g_nCTScoreH1 = 0;
				g_CurrentRound = 1;
				g_CurrentHalf = 3;
				if ((GetConVarInt(g_CvarHalfAutoLiveStart) == 0) && g_IsItManual) // Admin need to write: !live to start...
					didLiveStarted = false;

				if (GetConVarInt(g_CvarPlayTeamSwapedSound) == 1)
				{
					if (!IsSoundPrecached("ambient/misc/brass_bell_C.wav"))
						PrecacheSound("ambient/misc/brass_bell_C.wav", true);
				
					EmitSoundToAll("ambient/misc/brass_bell_C.wav");
				}
				Command_Mr3(0, 0);
				if (GetConVarInt(g_CvarHalfAutoLiveStart) == 0)
					PrintToChatAll("\x04[%s]:\x03 Teams swapped. Mr3 settings are loaded! \x01- \x03Type\x04 !live \x03to start.", MODNAME);
				else
					PrintToChatAll("\x04[%s]:\x03 Teams swapped. Mr3 settings are loaded!", MODNAME);
			}
		}
		else if ((hasMixStarted) && (didLiveStarted))
		{
			new win_team = GetEventInt(event, "winner");
			if (g_CurrentHalf == 3)
			{
				if (win_team == TEAM_CT)
					g_nCTScore++;
				else if (win_team == TEAM_T)
					g_nTScore++;
			}
			else if (g_CurrentHalf == 4)
			{
				if (win_team == TEAM_T)
					g_nCTScore++;
				else if (win_team == TEAM_CT)
					g_nTScore++;
			}
			
			if ((g_CurrentHalf == 3) && (g_SwapNow) && (g_nCTScore < 19) && (g_nTScore < 19))
			{
				didLiveStarted = false; // Disable it here - before swapping teams...
				g_nCTScore2 = g_nCTScore;
				g_nTScore2 = g_nTScore;
				
				new Float:time = GetConVarFloat(g_CvarDelayBeforeSwapping);
				if (time < 0.1)
					time = 0.1;
				CreateTimer(time, SwapTimer);

				PrintToChatAll("\x04[%s]:\x03 Swapping teams...", MODNAME);
				
				g_nTScoreH1 = 0;
				g_nCTScoreH1 = 0;
				g_CurrentRound = 1;
				g_CurrentHalf = 4;
				if ((GetConVarInt(g_CvarHalfAutoLiveStart) == 0) && g_IsItManual) // Admin need to write: !live to start...
					didLiveStarted = false;
				
				if (GetConVarInt(g_CvarPlayTeamSwapedSound) == 1)
				{
					if (!IsSoundPrecached("ambient/misc/brass_bell_C.wav"))
						PrecacheSound("ambient/misc/brass_bell_C.wav", true);
				
					EmitSoundToAll("ambient/misc/brass_bell_C.wav");
				}
				if (GetConVarInt(g_CvarHalfAutoLiveStart) == 0)
					PrintToChatAll("\x04[%s]:\x03 Teams swapped. LAST HALF! \x01- \x03Type\x04 !live \x03to start.", MODNAME);
				else
					PrintToChatAll("\x04[%s]:\x03 Teams swapped. LAST HALF!", MODNAME);
				g_SwapNow = false;
			}
		
			if ((g_nCTScore >= 19) || (g_nTScore >= 19))
			{
				if (GetConVarInt(g_CvarInformWinnerInPanel) == 1)
				{
					if (g_nCTScore == 19)
						CreateWinningTeamPanel(3);
					else if (g_nTScore == 19)
						CreateWinningTeamPanel(2);
				}
				else
				{
					if (g_nCTScore == 19)
						CreateTimer(3.0, InformMix, 3);
					else if (g_nTScore == 19)
						CreateTimer(3.0, InformMix, 2);
				}
			
				hasMixStarted = false;
				didLiveStarted = false;
				
				g_IsItManual = true;
				if (GetConVarInt(g_CvarAutoMixEnabled) == 1)
				{
					g_AllowReady = true;
					for (new i=0; i<MaxClients; i++)
					{
						g_ReadyPlayers[i] = false;
						g_ReadyPlayersData[i] = -1;
					}
				}
					
				g_nTScoreH1 = 0;
				g_nCTScoreH1 = 0;
				g_CurrentRound = 1;
				g_CurrentHalf = 1;
				g_nTScore = -1;
				g_nCTScore = -1;
				
				g_SaveClientsScore = false;

				SetConVarString(g_hHostName, g_HostName); // Reset the hostname ...
				
				Command_Prac(0, 0);
				
				if (GetConVarInt(g_CvarRemovePassWhenMixIsEnded) == 1)
					Command_RemovePass(0, 0);
			}
		}
	}
}

public Event_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	if ((GetConVarInt(g_CvarEnabled) == 1) && (GetConVarInt(g_CvarShowTkMessage) == 1) && (hasMixStarted) && (!g_SaveClientsScore))
	{
		new victim = GetClientOfUserId(GetEventInt(event,"userid"));
		new attacker = GetClientOfUserId(GetEventInt(event,"attacker"));
		if ((attacker > 0) && (attacker <= MaxClients) && (GetClientTeam(victim) == GetClientTeam(attacker)) && (victim != attacker)) // Check to see if it is not by an explosive / fall damage, and he is a teammate.
		{
			decl String:victimName[MAX_NAME_LENGTH], String:attackerName[MAX_NAME_LENGTH];
			GetClientName(victim, victimName, sizeof(victimName));
			GetClientName(attacker, attackerName, sizeof(attackerName));
			PrintToChatAll("\x04[%s]:\x03 %s teamattacked %s with\x01 %d \x03HP,\x01 %d\x03 armor!", MODNAME, attackerName, victimName, GetEventInt(event, "dmg_health"), GetEventInt(event, "dmg_armor"));
		}
	}
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (hasMixStarted && didLiveStarted && (GetConVarInt(g_CvarShowMVP)==1) && (!isPauseBeingUsed))
	{
		new victim = GetClientOfUserId(GetEventInt(event,"userid"));
		new attacker = GetClientOfUserId(GetEventInt(event,"attacker"));

		if ((attacker != 0) && (victim != 0) && IsClientConnected(attacker) && IsClientConnected(victim) && (victim != attacker))
		{
			new victimTeam = GetClientTeam(victim);
			new attackerTeam = GetClientTeam(attacker);
			if (victimTeam != attackerTeam)
			{
				g_ScoresOfTheRound[attacker]++;
				g_ScoresOfTheGame[attacker]++;
			}
		}
		if (IsClientConnected(victim) && (victim != 0) && (GetClientTeam(victim) != GetClientTeam(attacker)))
			g_DeathsOfTheGame[victim]++;
	}
	return Plugin_Continue;
}

public Action:Command_TvRecord(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (g_IsRecording && (client != 0)) // stop him... auto-record is already recording the mix.
		{
			PrintToChat(client, "\x04[%s]:\x03 Source-Tv is already recording. You can either stop the record, or wait for the end of the mix.", MODNAME);
			return Plugin_Handled;
		}
		
		StartRecord();
		g_IsRecordManual = true;
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_TvStopRecord(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		ServerCommand("tv_stoprecord");
		g_IsRecording = false;
		g_IsRecordManual = false;
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

StartRecord()
{
	ServerCommand("tv_stoprecord"); // Stop the current record if running.
			
	decl String:recordDir[128], String:date[32], String:mapName[15], String:recordName[80];
	FormatTime(date, sizeof(date), "%d-%m-%Y-%H%M");
	GetCurrentMap(mapName, sizeof(mapName));
	if (g_IsRecordManual) // Recorded by the plugin or not?
		Format(recordName, sizeof(recordName), "%s-%s", date, mapName);
	else
		Format(recordName, sizeof(recordName), "Auto-%s-%s", date, mapName);
			
	GetConVarString(g_CvarAutoSourceTVRecordSaveDir, recordDir, sizeof(recordDir));
	if (DirExists(recordDir)) // Else, it will be saved in cstrike/ folder.
		ServerCommand("tv_record \"%s/%s.dem\"", recordDir, recordName);
	else
		ServerCommand("tv_record \"%s.dem\"", recordName);
	
	g_IsRecording = true;
}

public Action:Command_Pcw(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is already running.", MODNAME);
			return Plugin_Handled;
		}
		
		if (GetConVarInt(g_CvarShowMVP) != 1)
		{
			PrintToChat(client, "\x04[%s]:\x03 To use sm_pcw, MVP Scores must be shown!", MODNAME);
			return Plugin_Handled;
		}
		
		if ((client == 0) && (GetConVarInt(g_CvarAutoMixEnabled) == 1))
			g_IsItManual = false;
		else
			g_IsItManual = true;

		hasMixStarted = true;
		
		g_nTScoreH1 = 0;
		g_nCTScoreH1 = 0;
		g_CurrentRound = 1;
		g_nCTScore = 0;
		g_nTScore = 0;
		g_CurrentHalf = 1;
		for (new i=0; i<=MaxClients; i++)
		{
			g_ScoresOfTheGame[i] = 0;
			g_DeathsOfTheGame[i] = 0;
		}
		
		// PCW Settings...
		g_SaveClientsScore = true;
		// ----------------
		
		Command_Mr15(client, 0);
		
		if ((GetConVarInt(g_CvarEnableKnifeRound) == 1) && g_IsItManual) // If knife round should be before live, and if it's manual...
		{
			Command_KO3(client, 0);
			return Plugin_Handled;
		}
		
		// For the Auto-Record ...
		if ((GetConVarInt(g_CvarEnableAutoSourceTVRecord) == 1) && (!g_IsRecordManual)) // Auto-Record and it's not manual...
		{
			if (g_IsRecording) // New mix starts = new record starts.
				Command_TvStopRecord(0, 0);

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
		
		if(GetConVarInt(g_CvarUseZBMatchCommand) == 1)
		{
			new Handle:zbWarMode = FindConVar("zb_warmode");
			if(zbWarMode != INVALID_HANDLE) // Zblock is running in this server...
			{
				if(GetConVarInt(zbWarMode) == 1) // Zblock war mode is enabled - can execute zb_lo3 command!
					ServerCommand("zb_lo3");
			}
		}
		else
		{
			if(GetConVarInt(g_CvarRestartTimeInLiveCommand) > 0)
				ServerCommand("mp_restartgame %d", GetConVarInt(g_CvarRestartTimeInLiveCommand));
			else
				ServerCommand("mp_restartgame 1");
		}
		
		return Plugin_Handled;
	}
	else
		PrintToChat(client, "\x04[%s]:\x03 This plugin is disabled ... To enable it: \x01sm_mixmod_enable 1", MODNAME);
	
	return Plugin_Continue;
}

public Action:Command_Start(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is already running.", MODNAME);
			return Plugin_Handled;
		}
		
		if ((client == 0) && (GetConVarInt(g_CvarAutoMixEnabled) == 1))
			g_IsItManual = false;
		else
			g_IsItManual = true;

			
		// Disable ko3 - If was used, and never ended...
		isKo3Running = false;
		
		hasMixStarted = true;
		
		g_nTScoreH1 = 0;
		g_nCTScoreH1 = 0;
		g_CurrentRound = 1;
		g_nCTScore = 0;
		g_nTScore = 0;
		g_CurrentHalf = 1;
		for (new i=0; i<=MaxClients; i++)
		{
			g_ScoresOfTheGame[i] = 0;
			g_DeathsOfTheGame[i] = 0;
		}
		
		g_SaveClientsScore = false;
		
		Command_Mr15(client, 0);
		
		if ((GetConVarInt(g_CvarEnableKnifeRound) == 1) && g_IsItManual) // If knife round should be before live, and if it's manual...
		{
			Command_KO3(client, 0);
			return Plugin_Handled;
		}
		
		// For the Auto-Record ...
		if ((GetConVarInt(g_CvarEnableAutoSourceTVRecord) == 1) && (!g_IsRecordManual)) // Auto-Record and it's not manual...
		{
			if (g_IsRecording) // New mix starts = new record starts.
				Command_TvStopRecord(0, 0);

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
		
		if(GetConVarInt(g_CvarUseZBMatchCommand) == 1)
		{
			new Handle:zbWarMode = FindConVar("zb_warmode");
			if(zbWarMode != INVALID_HANDLE) // Zblock is running in this server...
			{
				if(GetConVarInt(zbWarMode) == 1) // Zblock war mode is enabled - can execute zb_lo3 command!
					ServerCommand("zb_lo3");
			}
		}
		else
		{
			if(GetConVarInt(g_CvarRestartTimeInLiveCommand) > 0)
				ServerCommand("mp_restartgame %d", GetConVarInt(g_CvarRestartTimeInLiveCommand));
			else
				ServerCommand("mp_restartgame 1");
		}
		
		return Plugin_Handled;
	}
	else
		PrintToChat(client, "\x04[%s]:\x03 This plugin is disabled ... To enable it: \x01sm_mixmod_enable 1", MODNAME);
	
	return Plugin_Continue;
}

public Action:Command_Stop(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (isBuyZoneDisabled)
		{
			if (EnableBuyZone())
				isBuyZoneDisabled = false;
		}
		
		if (isKo3Running)
		{
			isKo3Running = false;
			PrintToChat(client, "\x04[%s]:\x03 Knife round has been disabled!", MODNAME);
			return Plugin_Handled;
		}

		if (!hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is not running...", MODNAME);
			return Plugin_Handled;
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
			for (new i=0; i<MaxClients; i++)
			{
				g_ReadyPlayers[i] = false;
				g_ReadyPlayersData[i] = -1;
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
			if (FileExists("cfg/stop.cfg"))
			{
				ServerCommand("exec stop");
				return Plugin_Handled;
			}
			else
				PrintToChatAll("\x04[%s]:\x03 Couldn't find: stop.cfg so prac or warmup cfg will be executed instead!", MODNAME);
		}
		
		SetConVarString(g_hHostName, g_HostName); // Reset the hostname ...
		
		Command_Prac(client, 0);
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_Live(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (didLiveStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Live is already running!", MODNAME);
			return Plugin_Handled;
		}
		if (!hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is not running...", MODNAME);
			return Plugin_Handled;
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
		
		// For the Auto-Record ...
		if ((GetConVarInt(g_CvarEnableAutoSourceTVRecord) == 1) && (!g_IsRecordManual)) // Auto-Record and it's not manual...
		{
			if (!g_IsRecording) // Live is running... need to start the record.
			{
				g_IsRecording = true;
				g_IsRecordManual = false;
				
				StartRecord();
			}
		}
		
		if (isBuyZoneDisabled)
		{
			if (EnableBuyZone())
				isBuyZoneDisabled = false;
		}

		ServerCommand("mp_friendlyfire 1");
		PrintToChatAll("\x04[%s]:\x03 Live is running!", MODNAME);
		
		if(GetConVarInt(g_CvarUseZBMatchCommand) == 1)
		{
			new Handle:zbWarMode = FindConVar("zb_warmode");
			if(zbWarMode != INVALID_HANDLE) // Zblock is running in this server...
			{
				if(GetConVarInt(zbWarMode) == 1) // Zblock war mode is enabled - can execute zb_lo3 command!
				{
					ServerCommand("zb_lo3");
					return Plugin_Handled;
				}
			}
		}

		if(GetConVarInt(g_CvarRestartTimeInLiveCommand) > 0)
			ServerCommand("mp_restartgame %d", GetConVarInt(g_CvarRestartTimeInLiveCommand));
		else
			ServerCommand("mp_restartgame 1");

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_NotLive(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (!didLiveStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Live is not running...", MODNAME);
			return Plugin_Handled;
		}
		if (!hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is not running...", MODNAME);
			return Plugin_Handled;
		}
		
		isKo3Running = false;
		didLiveStarted = false;
		if (g_CurrentHalf == 1)
		{
			g_nCTScore = g_nCTScoreH1;
			g_nTScore = g_nTScoreH1;
		}

		ServerCommand("mp_friendlyfire 0");
		PrintToChatAll("\x04[%s]:\x03 Not Live!", MODNAME);

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_RandomTeams(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is already running. You can't random teams now!", MODNAME);
			return Plugin_Handled;
		}
		
		// Credit to TnTSCS aka ClarkKent - From his BRush plugin!
		// -----------------------------------------------------
		// Move everyone to Terrorist's team
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i))
			{
				SwitchPlayerTeam(i, CS_TEAM_T);
			}
		}
		// -------------------------------------------------------
		
		// Take 5 random Ts and put them on CT team.
		RandomCTPlayers();

		PrintToChatAll("\x04[%s]:\x03 Teams have been randomized!", MODNAME);

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

// -----------------------------------------------------
// Credit to TnTSCS aka ClarkKent - From his BRush plugin!
// -----------------------------------------------------
RandomCTPlayers()
{
	new numSwitched = 0;
	while(numSwitched < 5)
	{
		// Since less than 5 Ts were switched to the CT team, randomly select a few more...
		new client = GetRandomPlayer(TEAM_T);
		
		if(client != -1)
		{
			SwitchPlayerTeam(client, CS_TEAM_CT);
	
			if(IsPlayerAlive(client))
				CS_RespawnPlayer(client);
				
			numSwitched++;
		}
		else
		{
			LogMessage("ERROR with Randomizing CT Players...");
			PrintToChatAll("\x04[%s]:\x01 ERROR: Failed to get a random player from T team!", MODNAME);
			break;
		}
	}
}


public SwitchPlayerTeam(client, team)
{
	if(team > CS_TEAM_SPECTATOR)
	{
		CS_SwitchTeam(client, team);
		set_random_model(client, team);
	}
	else
	{
		ChangeClientTeam(client, team);
	}
}

stock set_random_model(client, team)
{
	// Get a random number between 0 and 3
	new random = GetRandomInt(0, 3);
	
	switch(team)
	{
		case CS_TEAM_T:
		{
			SetEntityModel(client, tmodels[random]);
		}
		case CS_TEAM_CT:
		{
			SetEntityModel(client, ctmodels[random]);
		}
	}
}
// -----------------------------------------------------
// -----------------------------------------------------

GetRandomPlayer(team)
{
	new Players[MaxClients+1], PlayerCount;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == team)
			Players[PlayerCount++] = i;
	}
	if (PlayerCount == 0)
		return -1;
	else
		return Players[GetRandomInt(0, PlayerCount-1)];
}

/*ChangePlayerTeam(client, team)
{
	new frags = GetClientFrags(client);
	new deaths = GetClientDeaths(client);
	ChangeClientTeam(client, team);
	PrintCenterText(client, "You've been auto-assigned to a team.");
	SetEntProp(client, Prop_Data, "m_iFrags", frags);
	SetEntProp(client, Prop_Data, "m_iDeaths", deaths);
}*/

stock GetRandomClientFromSpec()
{
	new bool:clients[MAXPLAYERS+1] = {false, ...};
	new count = 0;
	for (new i=1; i<=MaxClients;i++)
	{
		if ((GetClientTeam(i) == 1) && (!IsFakeClient(i)) && (IsClientAuthorized(i)))
		{
			count++;
			clients[i] = true;
		}
	}
	if (count <= 0)
		return -1;
	
	new clients_in_spec[count], pos=0, i=1;
	while (pos < count && (i<=MaxClients))
	{
		if(clients[i])
		{
			clients_in_spec[pos] = i;
			pos++;
		}
		i++;
	}
	
	return clients_in_spec[GetRandomInt(0, count)];
}

public Action:Command_Pause(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (!didLiveStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Live is not running...", MODNAME);
			return Plugin_Handled;
		}
		if (!hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is not running...", MODNAME);
			return Plugin_Handled;
		}

		if (isPauseBeingUsed)
			return Plugin_Handled;
		
		isPauseBeingUsed = true;
		g_CurrentRound--;
		PrintToChatAll("\x04[%s]:\x03 This round won't be counted!", MODNAME);

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:InformMix(Handle:timer, any:team)
{
	decl String:teamAName[32], String:teamBName[32];
	GetConVarString(g_CvarCusomNameTeamCT, teamAName, sizeof(teamAName));
	GetConVarString(g_CvarCusomNameTeamT, teamBName, sizeof(teamBName));
	
	PrintToChatAll("\x04--- Mix-Plugin created by iDragon ---");
	PrintToChatAll("\x04[%s]:\x03 The mix has Ended!", MODNAME);
	if (team == 3)
		PrintToChatAll("\x04[%s]: \x03The winner is:\x04 %s", MODNAME, teamAName);
	else if (team == 2)
		PrintToChatAll("\x04[%s]: \x03The winner is:\x04 %s", MODNAME, teamBName);
	else if (team == 1)
		PrintToChatAll("\x04[%s]: \x03There was no winner.\x04 IT'S A DRAW!", MODNAME);
		
	CreateTimer(2.0, DisplayScores);
	
	if (isBuyZoneDisabled)
	{
		if (EnableBuyZone())
			isBuyZoneDisabled = false;
	}
}

public Action:DisplayScores(Handle:timer)
{
	new max=0;
	new win=-1;
	for (new i=1; i<=MaxClients;i++)
	{
		if (IsClientConnected(i))
		{
			if (g_ScoresOfTheGame[i] >= max)
			{
				max = g_ScoresOfTheGame[i];
				win = i;
			}
		}
	}
	if (win < 1)
	{
		PrintToChatAll("\x04[%s]:\x03 There was an error trying to find the mvp player...", MODNAME);
		return;
	}
	decl String:winnerName[33];
	GetClientName(win, winnerName, sizeof(winnerName));
	new kills = g_ScoresOfTheGame[win];
	PrintToChatAll("\x04[%s]:\x03 Kills Stat:", MODNAME);
	PrintToChatAll("------------------");
	PrintToChatAll("\x03 - The \x01MVP:\x04 %s , \x03Killed:\x04 %d \x03Enemies!", winnerName, kills);
	
	Command_TvStopRecord(0, 0); // Stop the record ...
}

CreateWinningTeamPanel(team)
{
	if (g_WinTeamPanel != INVALID_HANDLE)
		CloseHandle(g_WinTeamPanel);
	
	decl String:teamAName[32], String:teamBName[32];
	GetConVarString(g_CvarCusomNameTeamCT, teamAName, sizeof(teamAName));
	GetConVarString(g_CvarCusomNameTeamT, teamBName, sizeof(teamBName));
	
	decl String:titleFormat[32], String:teamNameFormat[150];
	Format(titleFormat, sizeof(titleFormat), "%s - Winning team\n --- Plugin created by iDragon", MODNAME);
	
	g_WinTeamPanel = CreatePanel();
	SetPanelTitle(g_WinTeamPanel, titleFormat);
	DrawPanelItem(g_WinTeamPanel, "", ITEMDRAW_SPACER);
	if (team == 3)
		Format(teamNameFormat, sizeof(teamNameFormat), "--------------\nThe mix has ended!\n\n *** The winner is ***\n  -* %s *- \n------------", teamAName);
	else
	{	
		if (team == 2)
			Format(teamNameFormat, sizeof(teamNameFormat), "--------------\nThe mix has ended!\n\n *** The winner is ***\n  -* %s *- \n------------", teamBName);
		if (team == 1)
			Format(teamNameFormat, sizeof(teamNameFormat), "--------------\nThe mix has ended!\n\n *** It's a DRAW! ***\n \n------------");
	}
	
	DrawPanelText(g_WinTeamPanel, teamNameFormat);
	DrawPanelItem(g_WinTeamPanel, "", ITEMDRAW_SPACER);

	SetPanelCurrentKey(g_WinTeamPanel, 10);
	DrawPanelItem(g_WinTeamPanel, "Close", ITEMDRAW_CONTROL);
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			SendPanelToClient(g_WinTeamPanel, i, Handler_DoNothing, 30);
		}
	}
	
	CreateTimer(2.0, DisplayScores);
}

public Action:Command_Mr15(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		decl String:cfgName[128], String:cfgPath[135];
		GetConVarString(g_CvarCustomLiveCfg, cfgName, sizeof(cfgName));
		Format(cfgPath, sizeof(cfgPath), "cfg/%s", cfgName);
		if (FileExists(cfgPath))
			ServerCommand("exec %s", cfgName);
		else if (FileExists("cfg/mr15.cfg"))
			ServerCommand("exec mr15");
		else if (FileExists("cfg/match.cfg"))
			ServerCommand("exec match");
		else if (FileExists("cfg/live.cfg"))
			ServerCommand("exec live");
		else if (FileExists("cfg/esl5on5.cfg"))
			ServerCommand("exec esl5on5");
		else
			PrintToChatAll("\x04[%s]:\x03 Couldn't execute the %s / match / mr15 / live / esl5on5 config!", MODNAME, cfgName);
			
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_Prac(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		decl String:cfgName[128], String:cfgPath[135];
		GetConVarString(g_CvarCustomPracCfg, cfgName, sizeof(cfgName));
		Format(cfgPath, sizeof(cfgPath), "cfg/%s", cfgName);
		if (FileExists(cfgPath))
			ServerCommand("exec %s", cfgName);
		else if (FileExists("cfg/prac.cfg"))
			ServerCommand("exec prac");
		else if (FileExists("cfg/warmup.cfg"))
			ServerCommand("exec warmup");
		else
			PrintToChatAll("\x04[%s]:\x03 Couldn't execute the %s / warmup / prac config!", MODNAME, cfgName);

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_Mr3(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (GetConVarInt(g_CvarMr3Enabled) == 1)
		{
			decl String:cfgName[128], String:cfgPath[135];
			GetConVarString(g_CvarCustomMr3Cfg, cfgName, sizeof(cfgName));
			Format(cfgPath, sizeof(cfgPath), "cfg/%s", cfgName);
			if (FileExists(cfgPath))
			{
				ServerCommand("exec %s", cfgName);
				PrintToChatAll("\x04[%s]:\x03 %s Config has been loaded...", MODNAME, cfgName);
			}
			else if (FileExists("cfg/mr3.cfg"))
			{
				ServerCommand("exec mr3");
				PrintToChatAll("\x04[%s]:\x03 MR3 Config has been loaded...", MODNAME);
			}
			else
				PrintToChatAll("\x04[%s]:\x03 Couldn't execute the mr3 config!", MODNAME);
		}
		else PrintToChat(client, "\x04[%s]:\x03 Mr3 is disabled... mr3 settings will not be loaded!", MODNAME);
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_KO3(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (didLiveStarted) // Match is already running! KO3 won't run!
		{
			PrintToChatAll("\x04[%s]:\x03 Live is running... ko3 settings won't load!", MODNAME);
			return Plugin_Handled;
		}
		
		isKo3Running = true;
		
		if (!isBuyZoneDisabled)
		{
			if (DisableBuyZone())
				isBuyZoneDisabled = true;
		}
		
		if (GetConVarInt(g_CvarUseKo3Command) == 1)
		{
			new Handle:zbWarMode = FindConVar("zb_warmode");
			if(zbWarMode != INVALID_HANDLE) // Zblock is running in this server...
			{
				if(GetConVarInt(zbWarMode) == 1) // Zblock war mode is enabled - can execute zb_lo3 command!
				{
					ServerCommand("zb_ko3");
					return Plugin_Handled;
				}
			}
		}
		
		if(GetConVarInt(g_CvarRestartTimeInLiveCommand) > 0)
			ServerCommand("mp_restartgame %d", GetConVarInt(g_CvarRestartTimeInLiveCommand));
		else
			ServerCommand("mp_restartgame 1");
			
		PrintToChatAll("\x04[%s]:\x03 Knives round!", MODNAME);
		PrintToChatAll("\x04[%s]:\x03 Knives round!", MODNAME);
		PrintToChatAll("\x04[%s]:\x03 Knives round!", MODNAME);
		PrintToChatAll("\x04[%s]:\x03 Knives round!", MODNAME);
		PrintToChatAll("\x04[%s]:\x03 Knives round!", MODNAME);
		PrintToChatAll("\x04[%s]:\x03 Knives round!", MODNAME);
		PrintToChatAll("\x04[%s]:\x03 Knives round!", MODNAME);
		PrintToChatAll("\x04[%s]:\x03 Knives round!", MODNAME);
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_Pass(client, args)
{
	if ((GetConVarInt(g_CvarEnabled) == 1) && (GetConVarInt(g_CvarEnablePasswords) == 1))
	{
		if (args < 1)
		{
			decl String:sPass[64];
			GetConVarString(g_hPassword, sPass, sizeof(sPass));
			if (GetUserAdmin(client) != INVALID_ADMIN_ID)
				PrintToChatAll("\x04[%s]:\x03 The server password is: %s", MODNAME, sPass);
			else
			{
				if ((isRandomPasswordWasLastPw) && (GetConVarInt(g_CvarRpwShowPass) == 0))
				{
					PrintToChat(client, "\x04[%s]:\x03 The server password is: ***RANDOM***", MODNAME);
					if (GetUserAdmin(client) != INVALID_ADMIN_ID)
						PrintToChat(client, "\x04*** %s", sPass);
				}
				else
					PrintToChat(client, "\x04[%s]:\x03 The server password is: %s", MODNAME, sPass);
			}
		}
		else
		{
			if (GetUserAdmin(client) != INVALID_ADMIN_ID)
			{
				new String:pass[64];
				GetCmdArg(1, pass, sizeof(pass));
				
				SetConVarString(g_hPassword, pass);
				PrintToChatAll("\x04[%s]:\x03 Server password is now: %s", MODNAME, pass);
				isRandomPasswordWasLastPw = false;
			}
			else
				PrintToChat(client, "[SM] Only admins can change the password!");
		}

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_GenerateRandomPassword(client, args)
{
	if ((GetConVarInt(g_CvarEnabled) == 1) && (GetConVarInt(g_CvarEnablePasswords) == 1))
	{
		new rnd = GetRandomInt(100, 1000);
		SetConVarInt(g_hPassword, rnd);
		if ((GetConVarInt(g_CvarRpwShowPass) == 1) || (!g_IsItManual && (client == 0))) // Show the password
			PrintToChatAll("\x04[%s]:\x03 The server password is: %d", MODNAME, rnd);
		else if (GetConVarInt(g_CvarRpwShowPass) == 0) // Don't show the password
		{
			PrintToChatAll("\x04[%s]:\x03 The server password is: ***RANDOM***", MODNAME);
			// Show the real password to the admin.
			if (client != 0)
				PrintToChat(client, "\x04*** %d", rnd);
			else
				PrintToServer("[%s]: Random pass: %d", rnd);
			
			isRandomPasswordWasLastPw = true;
		}
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_RemovePass(client, args)
{
	if ((GetConVarInt(g_CvarEnabled) == 1) && (GetConVarInt(g_CvarEnablePasswords) == 1))
	{
		SetConVarString(g_hPassword, "none");
		PrintToChatAll("\x04[%s]:\x03 Password has been removed!", MODNAME);
		isRandomPasswordWasLastPw = false;

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_SwapTeams(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (args == 0)
		{
			new bool:flag = false;
			if (didLiveStarted)
			{
				didLiveStarted = false;
				flag = true;
			}

			new team;
			for(new i=1;i<=MaxClients;i++)
			{
				if (!IsClientInGame(i))
					continue;

				team = GetClientTeam(i);
				if (team == 2)
				{
					ChangeClientTeam(i, 3);
					PrintToChat(client, "\x04[%s]:\x03 You have been swapped to \x01 Counter Terrorists\x03 Team.", MODNAME);
				}
				else if (team == 3)
				{
					ChangeClientTeam(i, 2);
					PrintToChat(client, "\x04[%s]:\x03 You have been swapped to \x01 Terrorists\x03 Team.", MODNAME);
				}
			}
			PrintToChatAll("\x04[%s]:\x03 All players have been swapped.", MODNAME);
			
			if (flag)
				didLiveStarted = true;
				
			return Plugin_Handled;
		}
		else if (args == 1)
		{
			ReplyToCommand(client, "[%s]: Usage: sm_st <player> <team>", MODNAME);
			return Plugin_Handled;
		}
		else if (args >= 2)
		{
			decl String:searchFor[64], String:target_name[64], String:teamNum[8];
			new targetsArr[64], found = 0, team = 1;
			new bool:isML;
			GetCmdArg(1, searchFor, sizeof(searchFor));
			GetCmdArg(2, teamNum, sizeof(teamNum));
			if (StrContains(teamNum, "ct") != -1) // 'ct' contrains 't' too, so it must come before 't' "if".
				team = 3;
			else if (StrContains(teamNum, "t") != -1)
				team = 2;
			else if (StrContains(teamNum, "spec") != -1)
				team = 1;
			else
			{
				team = StringToInt(teamNum);
				if ((team <= 0) || (team > 3))
				{
					PrintToChat(client, "\x04[%s]:\x03 Usage: sm_st <player> [team] (legal teams: t,ct,spec,1,2,3)", MODNAME);
					return Plugin_Handled;
				}
			}
			found = ProcessTargetString(searchFor, client ,targetsArr, sizeof(targetsArr), 0, target_name, sizeof(target_name), isML);
			if (found > 0) // Target is found!
			{
				new bool:flag = false;
				if (didLiveStarted)
				{
					didLiveStarted = false;
					flag = true;
				}
				for (new target = 0; target < found; target++)
				{
					if (GetClientTeam(targetsArr[target]) != team)
					{
						ChangeClientTeam(targetsArr[target], team); // Change the client team!
						PrintToChat(targetsArr[target], "\x04[%s]:\x03 Your team has been changed!", MODNAME);
					}
				}
				if (flag)
					didLiveStarted = true;
					
				PrintToChat(client,"\x04[%s]:\x03 %s team has been changed!", MODNAME, searchFor);
			}
			else 
				PrintToChat(client,"\x04[%s]:\x03Couldn't find %s in the server...", MODNAME, searchFor);
			
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action:Command_RestartTheGame(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (GetConVarInt(g_CvarEnableRRCommand) == 1)
		{
			// credit to advcommands.smx - TY ! :)
			new t = 1;
			if (args)
			{
				decl String:ax[16];
				GetCmdArg(1,ax,sizeof(ax));
				t = StringToInt(ax);
			}
			ServerCommand("mp_restartgame %d",t);
			
			return Plugin_Handled;
			// --------------------------------
		}
	}
	return Plugin_Continue;
}

public OnGameRestarted(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (StringToInt(newVal) > 0)
			RestartTheGame();
	}
}

RestartTheGame()
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		// If RR has been perfomed to rr the mix (Restart the mix : 0-0 in half1 or teamA-teamB for half2)
		// ------------------------------
		
		if (!hasMixStarted) // Mix is not running ...
			return;
	
/* ** Looks like trying to reduce memory usage, has been cost with bugs...	**

		if (!didLiveStarted) // Live is not running - there is no need to reset settings!
			return;
			
*/
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
		else
		{
			SetTeamScore(3, 0);
			SetTeamScore(2, 0);
			
			// Reset the scores.
			for (new i=0; i<=MaxClients; i++)
			{
				g_ScoresOfTheGame[i] = 0;
				g_DeathsOfTheGame[i] = 0;
			}
		}
		
	//	PrintToChatAll("\x04[%s]:\x03 The game has been restarted!", MODNAME);
	}
}

public Action:ShowScores(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (!IsFakeClient(client))
		{
			if (!hasMixStarted)
			{
				PrintToChat(client, "\x04[%s]:\x03 Mix is not running yet...", MODNAME);
				return Plugin_Handled;
			}
			
			decl String:teamAName[33], String:teamBName[33];
			GetConVarString(g_CvarCusomNameTeamCT, teamAName, sizeof(teamAName));
			GetConVarString(g_CvarCusomNameTeamT, teamBName, sizeof(teamBName));
			
			if (g_CurrentHalf == 1)
			{
				PrintToChat(client, "\x04[%s]:\x03 Round\x03 %d \x04- Half\x03 %d\x04 /\x03 2\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", MODNAME, g_CurrentRound, g_CurrentHalf, teamAName, g_nCTScoreH1, teamBName, g_nTScoreH1);
				
				if (!didLiveStarted)
					PrintToChat(client, "\x04[%s]:\x03 Not Live!", MODNAME);
			}
			else if (g_CurrentHalf == 2)
			{
				PrintToChat(client, "\x04[%s]:\x03 Round\x03 %d \x04- Half\x03 %d\x04 /\x03 2\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", MODNAME, g_CurrentRound, g_CurrentHalf, teamAName, g_nCTScore, teamBName, g_nTScore);

				if (GetConVarInt(g_CvarMr3Enabled) == 1)
				{
					if ((g_nCTScore == 15) && (g_nTScore == 14))
						PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s - \x04If %s wins, Mr3 will be loaded!", MODNAME, teamAName, teamBName);
					else if ((g_nCTScore == 14) && (g_nTScore == 15))
						PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s - \x04If %s wins, Mr3 will be loaded!", MODNAME, teamBName, teamAName);
					else
					{
						if (g_nCTScore == 15)
							PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", MODNAME, teamAName);
						if (g_nTScore == 15)
							PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", MODNAME, teamBName);
					}
				}
				else
				{
					if (g_nCTScore == 15)
						PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", MODNAME, teamAName);
					if (g_nTScore == 15)
						PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", MODNAME, teamBName);
				}
					
				if (!didLiveStarted)
					PrintToChat(client, "\x04[%s]:\x03 Not Live!", MODNAME);
			}
			else if (g_CurrentHalf > 2) // Mr3 ...
			{
				PrintToChat(client, "\x04[%s]:\x03 Round\x03 %d \x04- Half\x03 %d\x04 /\x03 4\x04 - %s\x03 %d,\x04 %s\x03 %d\x04.", MODNAME, g_CurrentRound, g_CurrentHalf, teamAName, g_nCTScore, teamBName, g_nTScore);

				if (g_nCTScore == 18)
					PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", MODNAME, teamAName);
				if (g_nTScore == 18)
					PrintToChatAll("\x04[%s]:\x03 LR \x04for\x03 %s", MODNAME, teamBName);
					
				if (!didLiveStarted)
					PrintToChat(client, "\x04[%s]:\x03 Not Live!", MODNAME);
			}
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_SetMixScore(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1 && (ENABLE_PLUGIN_CHECKING))
	{
		if(args < 3)
		{
			PrintToChat(client, "[Usage]: sm_setmixscore <half> <ct> <t>");
			return Plugin_Handled;
		}

		decl String:half[16], String:ct[16], String:t[16];
		GetCmdArg(1, half, sizeof(half));
		GetCmdArg(2, ct, sizeof(ct));
		GetCmdArg(3, t, sizeof(t));
		
		g_nCTScore = StringToInt(ct);
		g_nTScore = StringToInt(t);
		g_CurrentHalf = StringToInt(half);
		PrintToChat(client, "Scores has been set!");
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_KickCT(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		KickTeam(client, 3, GetConVarInt(g_CvarKickAdmins));
		PrintToChatAll("\x04[%s]:\x03 Counter-Terrorist team has been kicked!", MODNAME);
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_KickT(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		KickTeam(client, 2, GetConVarInt(g_CvarKickAdmins));
		PrintToChatAll("\x04[%s]:\x03 Terrorist team has been kicked!", MODNAME);
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

KickTeam(client, team, adminsImmunity)
{
	for (new i=1; i<= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && (client != i) && (GetClientTeam(i) == team)) // In game, not a bot, not the admin who perfrommed this command, and a player in this team.
		{
			if ((adminsImmunity == 1))
			{
				if (GetUserAdmin(i) == INVALID_ADMIN_ID)
					KickClient(client, "[%s]: You have been kicked by the admin!", MODNAME);
			}
			else
				KickClient(client, "[%s]: You have been kicked by the admin!", MODNAME);
		}
	}
}

public Action:Command_Maps(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (isMapListGenerated) // Is map list already been generated?
		{
			DisplayMenu(g_MapListMenu, client, 30);
			PrintToChat(client, "\x04[%s]:\x03 Choose a map to changelevel!", MODNAME);
		}
		else // The maplist hasn't been generated yet ... Lets create it now and infrom the admin.
		{
			CreateMapList();
			PrintToChat(client, "\x04[%s]:\x03 Map list is being created right now! please use\x01 sm_maps\x03 command agaon in a few seconds...", MODNAME);
		}

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

CreateMapList()
{
	if (!isMapListGenerated) // Map list will be generated now!
	{
		decl String:mapName[64];
		decl FileType:type;
		new nameLen;
		
		if (g_MapListMenu != INVALID_HANDLE)
			CloseHandle(g_MapListMenu);

		g_MapListMenu = CreateMenu(MapListMenuHandler);
		SetMenuTitle(g_MapListMenu, "%s: Map List", MODNAME);
		
		switch(GetConVarInt(g_CvarMapListFrom)) // Read from: 0 = Maps dir, 1 = mapcycle.txt
		{
			case 0:
			{
				new Handle:mapsDir = OpenDirectory("maps/");
				while (ReadDirEntry(mapsDir, mapName, sizeof(mapName), type))
				{
					if (type == FileType_File)
					{
						nameLen = strlen(mapName) - 4;
						if(StrContains(mapName,".bsp",false) == nameLen)
						{
							if (StrContains(mapName, "de_") != -1)
							{
								strcopy(mapName, (nameLen + 1), mapName);
								AddMenuItem(g_MapListMenu, mapName, mapName);
							}
						}
					}
				}
				CloseHandle(mapsDir);
			}
			case 1:
			{
				new Handle:mapsFile = OpenFile("mapcycle.txt","r");
				while(ReadFileLine(mapsFile, mapName, sizeof(mapName)))
				{
					if (StrContains(mapName, "de_") != -1)
						AddMenuItem(g_MapListMenu, mapName, mapName);
				}
				CloseHandle(mapsFile);
			}
		}
	
		SetMenuExitButton(g_MapListMenu, true);
		
		isMapListGenerated = true;
	}
}

public MapListMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		decl String:map[64];
		new bool:worked = GetMenuItem(menu, param2, map, sizeof(map));
		if (worked) // The map name has been found in the menu - Will change the map.
		{
			PrintToChatAll("\x04[%s]:\x03 Changing map to:\x01 %s", MODNAME, map);
			ServerCommand("changelevel %s", map);
		}
		else
			PrintToChat(param1, "\x04[%s]:\x03 Failed to change map to:\x01 %s", MODNAME, map); // Inform the admin that the map couldn't be changed.
	}
}

public Action:Command_DisableChat(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (args < 1)
		{
			ReplyToCommand(client, "[%s]: Usage: sm_disablechat <num> (0-Enable chat, 1-Disable chat, 2-Disable only when live)", MODNAME);
			return Plugin_Handled;
		}

		decl String:setTo[2];
		GetCmdArg(1, setTo, sizeof(setTo));
		new num = StringToInt(setTo);
		if ((num > 2) || (num < 0))
		{
			ReplyToCommand(client, "[%s]: Usage: sm_disablechat <num> (0-Enable chat, 1-Disable chat, 2-Disable only when live)", MODNAME);
			return Plugin_Handled;
		}
		
		SetConVarString(g_CvarDisableSayCommand, setTo);
		switch (num)
		{
			case 0:
				PrintToChatAll("\x04[%s]:\x03 Public chat is enabled!", MODNAME);
			case 1:
				PrintToChatAll("\x04[%s]:\x03 Public chat is disabled!", MODNAME);
			case 2:
				PrintToChatAll("\x04[%s]:\x03 Public chat is disabled when live is running!", MODNAME);
		}
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_SayChat(client, args)
{
	if (!IsChatTrigger())
	{
		if (g_GaggedPlayers[client])
			return Plugin_Handled;
			
		if ((GetConVarInt(g_CvarEnabled) == 1) && ((GetConVarInt(g_CvarDisableSayCommand) == 1) || ((GetConVarInt(g_CvarDisableSayCommand) == 2) && (hasMixStarted) && (didLiveStarted))))
			return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action:Command_MixHelp(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (g_HelpPanel != INVALID_HANDLE)
			DisplayMenu(g_HelpPanel, client, 180);
		else
		{
			CreateHelpPanel();
			PrintToChat(client, "\x04[%s]:\x03 Try again in a few seconds!", MODNAME);
		}
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

CreateHelpPanel()
{
	if (g_HelpPanel != INVALID_HANDLE)
		CloseHandle(g_HelpPanel);

	g_HelpPanel = CreateMenu(HelpMenuHandler);
	SetMenuTitle(g_HelpPanel, "%s - Help \n ---Created by iDragon\n", MODNAME);
	
	AddMenuItem(g_HelpPanel, "Admin commands:", "Admin commands:");	
	AddMenuItem(g_HelpPanel, "--------------", "---------------");
	AddMenuItem(g_HelpPanel, "sm_start - Starts a new mix", "sm_start - Starts a new mix");
	AddMenuItem(g_HelpPanel, "sm_pcw - Starts a new mix (saving scores!)", "sm_pcw - Starts a new mix");
	AddMenuItem(g_HelpPanel, "sm_stop - Stops the current mix", "sm_stop - Stops the current mix");
	AddMenuItem(g_HelpPanel, "sm_live - Starts the game (live ...).", "sm_live - Starts the game (live ...).");
	AddMenuItem(g_HelpPanel, "sm_nl - Pause the mix untill sm_live is used.", "sm_nl - Pause the mix untill sm_live is used.");
	AddMenuItem(g_HelpPanel, "sm_mr15 - Executes the mr15 (match) config.", "sm_mr15 - Executes the mr15 (match) config.");
	AddMenuItem(g_HelpPanel, "sm_prac - Executes the prac (warmup) config.", "sm_prac - Executes the prac (warmup) config.");
	AddMenuItem(g_HelpPanel, "sm_pw - Change the server password. usage: sm_pw <pass>", "sm_pw - Change the server password.");
	AddMenuItem(g_HelpPanel, "sm_st <player> [t/ct/spec/1/2/3] or sm_st", "sm_st - Swaps player or players team");
	AddMenuItem(g_HelpPanel, "sm_rpw - Set a random password to the server.", "sm_rpw - Set a random password to the server.");
	AddMenuItem(g_HelpPanel, "sm_rr <seconds>", "sm_rr - Restart the game");
	AddMenuItem(g_HelpPanel, "sm_kickct - Kick ct team.", "sm_kickct - Kick ct team.");
	AddMenuItem(g_HelpPanel, "sm_kickt -Kick t team.", "sm_kickt -Kick t team.");
	AddMenuItem(g_HelpPanel, "sm_maps - Show maps menu.", "sm_maps - Show maps menu.");
	AddMenuItem(g_HelpPanel, "sm_ko3 or sm_knifes - Starts knife round.", "sm_ko3 or sm_knifes - Starts knife round.");
	AddMenuItem(g_HelpPanel, "sm_spec <player>", "sm_spec - Move player to spectors team.");
	AddMenuItem(g_HelpPanel, "sm_mix - Open the mix menu.", "sm_mix - Open the mix menu.");
	AddMenuItem(g_HelpPanel, "sm_pause - Pause the mix (the current round was never played)", "sm_pause - Pause the mix (the current round was never played)");
	AddMenuItem(g_HelpPanel, "sm_disablechat: 0-Enable chat, 1-Disable chat, 2-Disable chat only when live is running.", "sm_disablechat - Change public chat settings.");
	AddMenuItem(g_HelpPanel, "sm_npw - Remove the server password.", "sm_npw - Remove the server password.");
	AddMenuItem(g_HelpPanel, "sm_record - Starts a record", "sm_record - Starts a record");
	AddMenuItem(g_HelpPanel, "sm_stoprecord - Stop the record (if running).", "sm_stoprecord - Stop the record (if running).");
	AddMenuItem(g_HelpPanel, "sm_random / sm_rnd - Random the teams.", "sm_random / sm_rnd - Randomizing the teams.");
	
	AddMenuItem(g_HelpPanel, "Player commands in next page...", "---------------------");
	AddMenuItem(g_HelpPanel, "Player commands in next page...", "---Player commands---");
	AddMenuItem(g_HelpPanel, "Player commands in next page...", "-----In next---------");
	AddMenuItem(g_HelpPanel, "Player commands in next page...", "-------Page----------");
	AddMenuItem(g_HelpPanel, "Player commands in next page...", "---------------------");
	AddMenuItem(g_HelpPanel, "Player commands:", "Player commands:");
	AddMenuItem(g_HelpPanel, "sm_score - Show the round number and team scores.", "sm_score - Show the round number and team scores.");
	AddMenuItem(g_HelpPanel, "sm_password or sm_pw - To see the server password.", "sm_password or sm_pw - To see the server password.");
	AddMenuItem(g_HelpPanel, "sm_ready or sm_rdy - Become ready.", "sm_ready or sm_rdy - Become ready.");
	AddMenuItem(g_HelpPanel, "sm_notready or sm_unready - Become not ready.", "sm_notready or sm_unready - Become not ready.");
	AddMenuItem(g_HelpPanel, "sm_teams - Only when auto-mix running! see teams.", "sm_teams - Only when auto-mix running! see teams.");
	AddMenuItem(g_HelpPanel, "sm_mixhelp - See all the plugin commands.", "sm_mixhelp - See all the plugin commands.");

	AddMenuItem(g_HelpPanel, "-----------------------", "-----------------------");
	AddMenuItem(g_HelpPanel, "--- Created by iDragon ---", "--- Created by iDragon ---");
	decl String:versio[32];
	Format(versio, sizeof(versio), "Mix-Plugin version: %s", PLUGIN_VERSION);
	AddMenuItem(g_HelpPanel, versio, versio);
	AddMenuItem(g_HelpPanel, "http://forums.alliedmods.net/showthread.php?p=1512637", "Download this plugin (click)");
	AddMenuItem(g_HelpPanel, "-----------------------", "-----------------------");
	SetMenuExitButton(g_HelpPanel, true);
}

public HelpMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_DrawItem)
	{
		return ITEMDRAW_DEFAULT;
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[128];
		GetMenuItem(menu, param2, info, sizeof(info));
		PrintToChat(param1, "\x04[%s]:\x03 %s", MODNAME, info);
	}
	return 0;
}

public Action:Command_Spec(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (args < 1)
		{
			ReplyToCommand(client, "[%s]: Usage: sm_spec <player>", MODNAME);
			return Plugin_Handled;
		}

		decl String:searchFor[64], String:target_name[64];
		new targetsArr[64], found = 0;
		new bool:isML;
		GetCmdArg(1,searchFor,sizeof(searchFor));
		
		found = ProcessTargetString(searchFor, client ,targetsArr, sizeof(targetsArr), 0, target_name, sizeof(target_name), isML);
		if (found > 0) // Target is found!
		{
			for (new target = 0; target < found; target++)
			{
				ChangeClientTeam(targetsArr[target], 1); // Spec the target!
				PrintToChat(targetsArr[target], "\x04[%s]:\x03 You have been moved to the spectors team!", MODNAME);
			}
			PrintToChat(client,"\x04[%s]:\x03 %s has been moved to Spectors team!", MODNAME, searchFor);
		}
		else 
			PrintToChat(client,"\x04[%s]:\x03Couldn't find %s in the server...", MODNAME, searchFor);
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_MixMenu(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (isMixMenuGenerated) // Is map list already been generated?
			DisplayMenu(g_MixMenu, client, 30);
		else // Mix menu hasn't been generated yet ...
		{
			CreateMixMenu();
			PrintToChat(client, "\x04[%s]:\x03 Mix Menu is being created right now! please use\x01 sm_mix\x03 command again in a few seconds...", MODNAME);
		}

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

CreateMixMenu()
{
	if (!isMixMenuGenerated) // Mix menu hasn't been generated yet ... Lets create it!
	{
		if (g_MixMenu != INVALID_HANDLE)
			CloseHandle(g_MixMenu);

		g_MixMenu = CreateMenu(MixMenuHandler);
		SetMenuTitle(g_MixMenu, "%s: ", MODNAME);

		AddMenuItem(g_MixMenu, "Start", "Start match");
		AddMenuItem(g_MixMenu, "Stop", "Stop the match");
		AddMenuItem(g_MixMenu, "Ko3", "Knife round (KO3 if enabled)");
		AddMenuItem(g_MixMenu, "Live", "Live (LO3 if enabled)");
		AddMenuItem(g_MixMenu, "NL", "Not live");
		AddMenuItem(g_MixMenu, "Cfgs", "CFGs menu");
		AddMenuItem(g_MixMenu, "Admin", "Admin menu");
	
		SetMenuExitButton(g_MixMenu, true);
		
		if (g_AdminMenu != INVALID_HANDLE)
			CloseHandle(g_AdminMenu);
		
		g_AdminMenu = CreateMenu(AdminMenuHandler);
		SetMenuTitle(g_AdminMenu, "%s - Admin menu", MODNAME);
		AddMenuItem(g_AdminMenu, "back", "-> Back to mix menu");
		AddMenuItem(g_AdminMenu, "map", "Change map");
		AddMenuItem(g_AdminMenu, "swap", "Swap player");
		AddMenuItem(g_AdminMenu, "kick", "Kick Player");
		AddMenuItem(g_AdminMenu, "spec", "Move all to spectators");
		AddMenuItem(g_AdminMenu, "rpw", "Set a random password to the server.");
		AddMenuItem(g_AdminMenu, "settings", "Change plugin settings");
		
		SetMenuExitButton(g_AdminMenu, true);
		
		isMixMenuGenerated = true;
	}
}

public MixMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_DrawItem)
	{
		return ITEMDRAW_DEFAULT;
	}
	else if (action == MenuAction_Select)
	{
		switch (param2)
		{
			/*
			0 = Start Match
			1 = Stop Match
			2 = Knife round (ko3)
			3 = Live (lo3)
			4 = Not live
			5 = Open cfg Menu
			6 = Open admin menu
			*/
			case 0:
				Command_Start(param1, 0);
			case 1:
				Command_Stop(param1, 0);
			case 2:
				Command_KO3(param1, 0);
			case 3:
				Command_Live(param1, 0);
			case 4:
				Command_NotLive(param1, 0);
			case 5:
			{
				new Handle:cfgMenu = CreateMenu(CfgMenuHandler);
				SetMenuTitle(cfgMenu, "%s - Cfg menu", MODNAME);
				AddMenuItem(cfgMenu, "back", "-> Back to mix menu");
				AddMenuItem(cfgMenu, "mr15", "Mr15 (match)");
				AddMenuItem(cfgMenu, "prac", "Prac (warmup)");
				AddMenuItem(cfgMenu, "mr3", "Mr3");
				SetMenuExitButton(cfgMenu, true);
				DisplayMenu(cfgMenu, param1, 30);
			}
			case 6:
				DisplayMenu(g_AdminMenu, param1, 30);
		}
	}
	return 0;
}

public AdminMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_DrawItem)
	{
		return ITEMDRAW_DEFAULT;
	}
	else if (action == MenuAction_Select)
	{
		/* 
		0 = Previous menu - Back to mix menu
		1 = Change map
		2 = Swap player
		3 = Kick player
		4 = Move all to spectors
		5 = Put random password in the server
		6 = Change cvar settings
		*/
		switch (param2) 
		{
			case 0:
				DisplayMenu(g_MixMenu, param1, 30);
			case 1:
				Command_Maps(param1, 0);
			case 2:
			{
				new Handle:swapMenu = CreateMenu(SwapMenuHandler);
				SetMenuTitle(swapMenu, "%s - Swap player", MODNAME);
				AddMenuItem(swapMenu, "back", "-> Back to admin menu");
				AddMenuItem(swapMenu, "swapTeams", "Swap teams");
				AddMenuItem(swapMenu, "swapPlayer", "Swap player");
				SetMenuExitButton(swapMenu, true);
				DisplayMenu(swapMenu, param1, 30);
			}
			case 3:
			{
				new Handle:kickMenu = CreateMenu(KickMenuHandler);
				SetMenuTitle(kickMenu, "%s - Kick", MODNAME);
				AddMenuItem(kickMenu, "back", "-> Back to admin menu");
				AddMenuItem(kickMenu, "kickCT", "Kick CT");
				AddMenuItem(kickMenu, "kickT", "Kick T");
				AddMenuItem(kickMenu, "kickSPEC", "Kick Spec");
				AddMenuItem(kickMenu, "kick", "Kick Player");
				SetMenuExitButton(kickMenu, true);
				DisplayMenu(kickMenu, param1, 30);
			}
			case 4:
			{
				for (new i=1; i< MaxClients; i++)
				{
					if (IsClientInGame(i) && (GetClientTeam(i) != 1))
						ChangeClientTeam(i, 1);
				}
				PrintToChatAll("\x04[%s]:\x03 All players are in spectors team!", MODNAME);
			}
			case 5:
				Command_GenerateRandomPassword(param1, 0);
			case 6:
			{
				new Handle:cvarMenu = CreateMenu(CvarMenuHandler);
				SetMenuTitle(cvarMenu, "%s - Cvar settings", MODNAME);
				AddMenuItem(cvarMenu, "back", "-> Back to admin menu");
				if (GetConVarInt(g_CvarEnabled) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_enable \"0\"", "Disable this plugin");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_enable \"1\"", "Enable this plugin");
				// ---
				if (GetConVarInt(g_CvarMr3Enabled) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_mr3_enable \"0\"", "Disable mr3 settings");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_mr3_enable \"1\"", "Enable mr3 settings");
				// ---
				if (GetConVarInt(g_CvarEnableKnifeRound) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_enable_knife_round \"0\"", "Disable knife round before live");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_enable_knife_round \"1\"", "Enable knife round before live");
				// ---
				if (GetConVarInt(g_CvarUseKo3Command) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_use_zb_ko3 \"0\"", "Use mp_restartgame instead of zb_ko3");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_use_zb_ko3 \"1\"", "Use zb_ko3 instead of mp_restartgame");
				if (GetConVarInt(g_CvarHalfAutoLiveStart) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_half_auto_live \"0\"", "Disable Automatically start live");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_half_auto_live \"1\"", "Enable Automatically start live");
				// ---
				if (GetConVarInt(g_CvarShowMoneyAndWeapons) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_showmoney \"0\"", "Don't Show money");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_showmoney \"1\"", "Show money");
				// ---
				if (GetConVarInt(g_CvarShowCashInPanel) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_show_cash_in_panel \"0\"", "Show money in chat");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_show_cash_in_panel \"1\"", "Show money in panel");
				// ---
				if (GetConVarInt(g_CvarShowScores) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_showscores \"0\"", "Show scores");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_showscores \"1\"", "Don't show scores");
				// ---
				if (GetConVarInt(g_CvarShowSwitchInPanel) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_show_swap_in_panel \"0\"", "Show auto-swap msg in chat");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_show_swap_in_panel \"1\"", "Show auto-swap msg in panel");
				// ---
				if (GetConVarInt(g_CvarEnableRRCommand) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_enable_rr_command \"0\"", "Disable sm_rr command");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_enable_rr_command \"1\"", "Enable sm_rr command");
				// ---
				if (GetConVarInt(g_CvarPlayTeamSwapedSound) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_enable_st_sound \"0\"", "Don't play swap team music");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_enable_st_sound \"1\"", "Play swap team music");
				// ---
				if (GetConVarInt(g_CvarUseZBMatchCommand) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_use_zb_lo3 \"0\"", "Use mp_restartgame instead of zb_lo3");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_use_zb_lo3 \"1\"", "Use zb_lo3 instead of mp_restartgame");
				// ---
				if (GetConVarInt(g_CvarKickAdmins) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_kick_admins \"0\"", "Don't kick admins with sm_kickTEAM");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_kick_admins \"1\"", "Kick admins with sm_kickTEAM");
				// ---
				if (GetConVarInt(g_CvarDisableSayCommand) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_disable_public_chat \"0\"", "Enable public chat");
				else if (GetConVarInt(g_CvarDisableSayCommand) == 2)
					AddMenuItem(cvarMenu, "sm_mixmod_disable_public_chat \"1\"", "Disable public chat");
				else if (GetConVarInt(g_CvarDisableSayCommand) == 0)
					AddMenuItem(cvarMenu, "sm_mixmod_disable_public_chat \"2\"", "Disable public chat only when live");
				// ---
				if (GetConVarInt(g_CvarInformWinnerInPanel) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_show_winner_in \"0\"", "Show winning team in chat");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_show_winner_in \"1\"", "Show winning team in menu");
				// ---
				if (GetConVarInt(g_CvarRpwShowPass) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_rpw_show_pass \"0\"", "Show random password only to admins");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_rpw_show_pass \"1\"", "Show random password to everyone");
				// ---
				if (GetConVarInt(g_CvarRemoveProps) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_remove_props \"0\"", "Don't remove props from the map");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_remove_props \"1\"", "Remove props from the map");
				// ---
				if (GetConVarInt(g_CvarAutoMixEnabled) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_auto_warmod_enable \"0\"", "Disable sm_ready system");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_auto_warmod_enable \"1\"", "Enable sm_ready system");
				// ---
				if (GetConVarInt(g_CvarAutoMixRandomize) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_auto_warmod_random \"0\"", "Don't random the teams in auto-war");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_auto_warmod_random \"1\"", "Random the teams in auto-war");
				// ---
				if (GetConVarInt(g_CvarEnableAutoSourceTVRecord) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_autorecord_enable \"0\"", "Disable SourceTv auto record when mix starts");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_autorecord_enable \"1\"", "Enable SourceTv auto record when mix starts");
				// ---
				if (GetConVarInt(g_CvarKnifeWinTeamVote) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_knife_round_win_vote \"0\"", "Disable winning team in knife - team choose vote");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_knife_round_win_vote \"1\"", "Enable winning team in knife - team choose vote");
				// ---
				if (GetConVarInt(g_CvarEnablePasswords) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_password_commands_enable \"0\"", "Disable password commands");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_password_commands_enable \"1\"", "Enable password commands");
				// ---
				if (GetConVarInt(g_CvarAllowManualSwitching) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_manual_switch_enable \"0\"", "Don't let players change their team when mix is running");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_manual_switch_enable \"1\"", "Allow players to change their team when mix is running");
				// ---
				if (GetConVarInt(g_CvarShowTkMessage) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_show_tk_damage \"0\"", "Don't show TK damage in chat");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_show_tk_damage \"1\"", "Show TK damage in chat");
				// ---
				if (GetConVarInt(g_CvarRemovePassWhenMixIsEnded) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_remove_password_on_mix_end \"0\"", "Don't remove the password on mix end");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_remove_password_on_mix_end \"1\"", "Remove the password on mix end");
				// ---
				if (GetConVarInt(g_CvarShowMVP) == 1)
					AddMenuItem(cvarMenu, "sm_mixmod_show_mvp \"0\"", "Don't show MVP stats.");
				else
					AddMenuItem(cvarMenu, "sm_mixmod_show_mvp \"1\"", "Show MVP stats.");
				
				SetMenuExitButton(cvarMenu, true);
				DisplayMenu(cvarMenu, param1, 30);
			}
		}
	}
	return 0;
}
// ----------------------------------------------------------------------------------
// ------------------------------- Admin Menu Options - Menu handlers ---------------
// ----------------------------------------------------------------------------------
public SwapMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_DrawItem)
	{
		return ITEMDRAW_DEFAULT;
	}
	else if (action == MenuAction_Select)
	{
		switch (param2)
		{
			/*
			0 = Back to admin menu
			1 = Swap teams
			2 = Swap player
			*/
			case 0:
				DisplayMenu(g_AdminMenu, param1, 30);
			case 1:
				Command_SwapTeams(param1, 0);
			case 2:
			{
				decl String:clientName[128], String:useridS[20];
				new Handle:swapPlayerMenu = CreateMenu(SwapPlayerMenuHandler);
				SetMenuTitle(swapPlayerMenu, "%s - Swap player", MODNAME);
				AddMenuItem(swapPlayerMenu, "back", "-> Back to admin menu");
				for (new i=1; i<= MaxClients; i++)
				{
					if (IsClientInGame(i) && (!IsFakeClient(i)) && (GetClientTeam(i) != 1))
					{
						GetClientName(i, clientName, sizeof(clientName));
						IntToString(GetClientUserId(i), useridS, sizeof(useridS));
						AddMenuItem(swapPlayerMenu, useridS, clientName);
					}
				}
				SetMenuExitButton(swapPlayerMenu, true);
				DisplayMenu(swapPlayerMenu, param1, 30);
			}
		}
	}
	if (action == MenuAction_End)
		CloseHandle(menu);
		
	return 0;
}

public SwapPlayerMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_DrawItem)
	{
		return ITEMDRAW_DEFAULT;
	}
	else if (action == MenuAction_Select)
	{
		if (param2 > 0) // Player was selcted ...
		{
			decl String:info[64];
			GetMenuItem(menu, param2, info, sizeof(info));
			new target = GetClientOfUserId(StringToInt(info));
			new team = GetClientTeam(target);
			if (team == 3)
				ChangeClientTeam(target, 2);
			else if (team == 2)
				ChangeClientTeam(target, 3);
			
			GetClientName(target, info, sizeof(info));
			PrintToChat(param1, "\x04[%s]:\x03 %s has been swapped!", MODNAME, info);
			PrintToChat(target, "\x04[%s]:\x03 You has been swapped!", MODNAME);
		}
		else if (param2 == 0) // Back to admin Menu
			DisplayMenu(g_AdminMenu, param1, 30);
	}
	if (action == MenuAction_End)
		CloseHandle(menu);
		
	return 0;
}

public KickMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_DrawItem)
	{
		return ITEMDRAW_DEFAULT;
	}
	else if (action == MenuAction_Select)
	{
		switch (param2)
		{
			/*
			0 = Back to admin menu
			1 = Kick ct
			2 = Kick t
			3 = Kick spec
			4 = Kick player
			*/
			case 0:
				DisplayMenu(g_AdminMenu, param1, 30);
			case 1:
				Command_KickCT(param1, 0);
			case 2:
				Command_KickT(param1, 0);
			case 3:
			{
				KickTeam(param1, 1, GetConVarInt(g_CvarKickAdmins));
				PrintToChatAll("\x04[%s]:\x03 Spectors team has been kicked!", MODNAME);
			}
			case 4:
			{
				decl String:clientName[128], String:useridS[20];
				new Handle:kickPlayerMenu = CreateMenu(KickPlayerMenuHandler);
				SetMenuTitle(kickPlayerMenu, "%s - Kick player", MODNAME);
				AddMenuItem(kickPlayerMenu, "back", "-> Back to admin menu");
				for (new i=1; i<= MaxClients; i++)
				{
					if (IsClientInGame(i) && (!IsFakeClient(i)))
					{
						GetClientName(i, clientName, sizeof(clientName));
						IntToString(GetClientUserId(i), useridS, sizeof(useridS));
						AddMenuItem(kickPlayerMenu, useridS, clientName);
					}
				}
			//	AddTargetsToMenu(kickPlayerMenu, 0, false, false);
				SetMenuExitButton(kickPlayerMenu, true);
				DisplayMenu(kickPlayerMenu, param1, 30);
			}
		}
	}
	if (action == MenuAction_End)
		CloseHandle(menu);
		
	return 0;
}

public KickPlayerMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_DrawItem)
	{
		return ITEMDRAW_DEFAULT;
	}
	else if (action == MenuAction_Select)
	{
		if (param2 > 0) // Player was selcted ...
		{
			decl String:info[64];
			GetMenuItem(menu, param2, info, sizeof(info));
			new target = GetClientOfUserId(StringToInt(info));
			KickClient(target, "[%s]: You have been kicked by the admin!", MODNAME);
			
			GetClientName(target, info, sizeof(info));
			PrintToChat(param1, "\x04[%s]:\x03 %s has been kicked!", MODNAME, info);
		}
		else if (param2 == 0) // Back to admin Menu
			DisplayMenu(g_AdminMenu, param1, 30);
	}
	if (action == MenuAction_End)
		CloseHandle(menu);
		
	return 0;
}

public CvarMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_DrawItem)
	{
		return ITEMDRAW_DEFAULT;
	}
	else if (action == MenuAction_Select)
	{
		if (param2 == 0) // Back to admin Menu
			DisplayMenu(g_AdminMenu, param1, 30);
		else if (param2 > 0)
		{
			decl String:info[64];
			GetMenuItem(menu, param2, info, sizeof(info));
			ServerCommand(info);
		}	
	}
	if (action == MenuAction_End)
		CloseHandle(menu);
		
	return 0;
}
// ----------------------------------------------------------------------
// ---------------------- End of admin options --------------------------
// ----------------------------------------------------------------------

public CfgMenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_DrawItem)
	{
		return ITEMDRAW_DEFAULT;
	}
	else if (action == MenuAction_Select)
	{
		/* 
		0 = Back to mix menu
		1 = Mr15
		2 = Prac
		3 = Mr3
		*/
		switch (param2) 
		{
			case 0:
				DisplayMenu(g_MixMenu, param1, 30);
			case 1:
				Command_Mr15(param1, 0);
			case 2:
				Command_Prac(param1, 0);
			case 3:
				Command_Mr3(param1, 0);
		}
	}
	if (action == MenuAction_End)
		CloseHandle(menu);
		
	return 0;
}

bool:IsValidMapToRemoveProps()
{
	if (g_IsMapValidToRemoveProps)
		return true;
		
	return false;
}

// Remove props
RemoveProps()
{
	if (!IsValidMapToRemoveProps())
		return;

	decl String:propClass[30]; // prop_physics / prop_physics_override / prop_dynamic / prop_static / prop_detail / prop_ragdoll / prop_physics_multiplayer / prop_dynamic_override
	new maxEntities = GetMaxEntities();
	for (new i=(MaxClients+1); i<maxEntities; i++) // Starting from maxClients+1 because we don't want to remove players entities ...
	{
		if (IsValidToBeRemoved(i))
		{
			GetEdictClassname(i, propClass, sizeof(propClass));
			if (StrContains(propClass, "prop_", false) == 0) // If the current class name starts with "prop_" it will be removed!
				RemoveEdict(i);
		}
	}
}

bool:IsValidToBeRemoved(ent)
{
	if (!IsValidEdict(ent) || !IsValidEntity(ent))
		return false;
	
	return true;
	
}

// ------------------------------------------------------------------------------------------------
// ------------------- Auto-War Code from here ----------------------------------------------------
// ------------------------------------------------------------------------------------------------

public Event_PlayerDisconnect(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_GaggedPlayers[GetClientOfUserId(GetEventInt(event, "userid"))] = false;
	g_MutedPlayers[GetClientOfUserId(GetEventInt(event, "userid"))] = false;
		
	if (hasMixStarted)
	{
		// Reset the exiting player score...
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		g_ScoresOfTheGame[client] = 0;
		g_DeathsOfTheGame[client] = 0;
	}
	
	if ((GetConVarInt(g_CvarAutoMixEnabled) == 1) && !g_IsItManual) // Auto-Mix is running...
	{
		new client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (IsFakeClient(client))
			return;
			
		if (g_ReadyPlayers[client])
		{
			g_ReadyPlayers[client] = false;
			g_ReadyPlayersData[client] = -1;
			g_ReadyCount--;
			
			/* Disabled for now ...
			decl String:nameFormat[160];
			Format(nameFormat, sizeof(nameFormat), "%s - NEED SUB!!!", g_HostName);
			SetConVarString(g_hHostName, nameFormat);
			g_AllowReady = true;
			Command_RemovePass(0, 0);
			PrintToChatAll("\x04[%s]:\x03 Sub is needed! password has been removed!");
			*/
		}
		
		decl String:reason[30];
		GetEventString(event, "reason", reason, sizeof(reason));
		if (StrContains(reason, "Disconnect by user") != -1)
		{
			new banTime = GetConVarInt(g_CvarAutoMixBan);
			if (banTime >= 0)
			{
				new String:auth[64];
				GetClientAuthString(client, auth, sizeof(auth));
				ServerCommand("sm_addban %d %s Left the mix", banTime, auth);
			}
		}
	}
}

// ---------------------------------------------------
// It's disabled because I don't sure what to do here... Ban the player that left the server? Remove password when sub is needed? and etc...
// -------------------------------------------------

/*public Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	if ((GetConVarInt(g_CvarAutoMixEnabled) == 0) || g_IsItManual)
	{
		return;
	}
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new old_team = GetEventInt(event, "oldteam");
	new new_team = GetEventInt(event, "team");
	
}*/

/* Disabled - Still beta... And I want to finish the other things before this.
public Action:Command_JoinTeam(client, args)
{
	new String:team[8];
	GetCmdArg(1, team, sizeof(team));
	if ((GetConVarInt(g_CvarAutoMixEnabled) == 1) && !g_IsItManual && g_ReadyPlayers[client] && (StringToInt(team) != g_ReadyPlayersData[client]))
	{
		PrintToChat(client,"\x04[%s]:\x03 You can't change your team when you are ready!", MODNAME);
		return Plugin_Handled;
	}
	
	decl String:hostname[160];
	GetConVarString(g_hHostName, hostname, sizeof(hostname));
	if (!g_ReadyPlayers[client] && (StrContains(hostname, "NEED SUB!!!") != -1)) // Sub has chosen his team!
	{
		if (StringToInt(team) > 1)
		{
			decl String:hostN[160];
			Format(hostN, sizeof(hostN), "%s", g_HostName);
			SetConVarString(g_hHostName, hostN); // Reset the hostname ...
			Command_GenerateRandomPassword(0, 0);
			
			g_ReadyPlayers[client] = true;
			
			new balance = AreTeamsBalanced();
			if (balance != 0)
			{
				if (balance == -1)
					ChangeClientTeam(client, 3);
				else if (balance == 1)
					ChangeClientTeam(client, 2);
				
				g_ReadyPlayersData[client] = GetClientTeam(client);
				return Plugin_Handled;
			}
			
			g_ReadyPlayersData[client] = StringToInt(team);
		}
	}
	
	return Plugin_Continue;
}*/

public Action:Command_JoinTeam(client, args)
{
	new String:team[8];
	GetCmdArg(1, team, sizeof(team));
	if ((hasMixStarted) && (GetConVarInt(g_CvarAllowManualSwitching) == 0) && (GetClientTeam(client) != 1)) // Mix is running and Manual switch is disabled! && He is not on spec team && And not going to switch to this team.
	{
		PrintToChat(client, "\x04[%s]:\x03 You can not change your team when mix is running!", MODNAME);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_ForceReady(client, args)
{
	for (new clients = 1; clients<=MaxClients; clients++)
	{
		if (!g_ReadyPlayers[clients]) // He is not ready ...
		{
			g_ReadyPlayers[clients] = true;
			g_ReadyCount++;
			
			if (g_ReadyCount == 10)
			{
				Command_GenerateRandomPassword(0, 0);
				g_IsItManual = false;
				g_AllowReady = false;
				StartAutoMix();
			}
		}
	}
	return Plugin_Handled;
}

public Action:Command_Ready(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (GetConVarInt(g_CvarAutoMixEnabled) == 0) // Auto-Mix is not running...
		{
			PrintToChat(client, "\x04[%s]:\x03 Auto-War is not running! This command is disabled.", MODNAME);
			return Plugin_Handled;
		}
		
		if (!g_AllowReady)
		{
			PrintToChat(client, "\x04[%s]:\x03 There are already 10 players ready!", MODNAME);
			return Plugin_Handled;
		}
		
		if (hasMixStarted)
		{
			if (GetPlayersInServerAndReady() >= 10)
			{
				PrintToChat(client, "\x04[%s]:\x03 Mix is running! This command is now disabled.", MODNAME);
				return Plugin_Handled;
			}
		}
		
		if (GetClientTeam(client) < 2) // He is not in ct / t team.
		{
			PrintToChat(client, "\x04[%s]:\x03 You must be in Terrorist or Counter-Terrorist team to use this command.", MODNAME);
			return Plugin_Handled;
		}
		
		if (!g_ReadyPlayers[client]) // He is not ready ...
		{
			g_ReadyPlayers[client] = true;
			g_ReadyCount++;
			
			if (g_ReadyCount == 10)
			{
				Command_GenerateRandomPassword(0, 0);
				g_IsItManual = false;
				g_AllowReady = false;
				StartAutoMix();
			}
		}
		
		PrintToChatAll("\x04[%s]:\x03 You are ready!", MODNAME);

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

StartAutoMix()
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (GetConVarInt(g_CvarAutoMixRandomize) == 1) // Random the team players and then start the mix!
		{
			new countA = 0, countB = 0, rnd = 0, bool:clients[MAXPLAYERS+1] = {false, ...};
			
			while (countA < 5 && (rnd != -1))
			{
				rnd = GetRandomClient(clients);
				if (!clients[rnd] && g_ReadyPlayers[rnd])
				{
					countA++;
					clients[rnd] = true;
					ChangeClientTeam(rnd, 3);
					g_ReadyPlayersData[rnd] = 3;
				}
			}
			
			rnd = GetRandomClient(clients);
			while (countB < 5 && (rnd != -1))
			{
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
			for (new i=1; i<=MaxClients; i++)
			{
				if (g_ReadyPlayers[i])
					g_ReadyPlayersData[i] = GetClientTeam(i);
			}
		}
		
		if (BalanceTeams()) // Check to see if teams are even with clients number.
			Command_ShowTeams(0, 0);
		
		Command_Start(0, 0);
	}
}

GetRandomClient(clients[])
{
	new clients2[MaxClients+1], count = 0;
	for (new i=0; i<MaxClients; i++)
	{
		if (!clients[i])
		{
			clients2[count] = i;
			count++;
		}
	}
	
	if (count == 0)
		return -1;
	else
		return clients2[GetRandomInt(0, (count-1))]; // Return random client.
}

GetPlayersInServerAndReady()
{
	new count = 0;
	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && g_ReadyPlayers[i])
			count++;
	}
	return count;
}

// return: 0-Balanced, -1 - teamA less, 1 - teamA more.
AreTeamsBalanced()
{
	new teamACount = 0, teamBCount = 0, team;
	for (new i=1; i<=MaxClients; i++)
	{
		if (g_ReadyPlayers[i])
		{
			team = GetClientTeam(i);
			if (team == 3)
				teamACount++;
			else if (team == 2)
				teamBCount++;
		}
	}
	if (teamACount > teamBCount)
		return 1;
	if (teamACount < teamBCount)
		return -1;

	return 0; // Balanced
}

bool:BalanceTeams()
{
	new balance = AreTeamsBalanced();
	if (((GetPlayersInServerAndReady() % 2) == 0) && (balance != 0))
	{
		new rnd;
		if (balance == -1) // There is more client in teamB ...
		{
			rnd = GetRandomClientFromReadyTeam(2);
			ChangeClientTeam(rnd, 3);
			g_ReadyPlayersData[rnd] = 3;
			
			if (IsFakeClient(rnd)) // If he is a bot, we need to let him choose a model!
				ClientCommand(rnd, "slot1");
		}
		else if (balance == 1) // More clients in teamA
		{
			rnd = GetRandomClientFromReadyTeam(3);
			ChangeClientTeam(rnd, 2);
			g_ReadyPlayersData[rnd] = 2;
			
			if (IsFakeClient(rnd)) // If he is a bot, we need to let him choose a model!
				ClientCommand(rnd, "slot1");
		}
		
		return BalanceTeams();
	}
	
	return true;
}

GetRandomClientFromReadyTeam(team)
{
	new clients[MaxClients+1], count = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (g_ReadyPlayersData[i] == team)
		{
			clients[count] = i;
			count++;
		}
	}
	if (count == 0)
		return -1;
	else
		return clients[GetRandomInt(0, count-1)];
}

public Action:Command_ShowTeams(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		
		if (GetConVarInt(g_CvarAutoMixEnabled) == 0) // Auto-Mix is not running...
		{
			if (!isRandomBeingUsed)
			{
				if (client != 0)
					PrintToChat(client, "\x04[%s]:\x03 Teams weren't randomized!", MODNAME);
				return Plugin_Handled;
			}
		}
		
		if (g_IsItManual || !hasMixStarted)
		{
			if (!hasMixStarted)
			{
				if (client != 0)
					PrintToChat(client, "\x04[%s]:\x03 This command is enabled only when mix is running");
				
				return Plugin_Handled;
			}
		}
		
		decl String:teamAName[32], String:teamBName[32], String:teamAPlayers[250], String:teamBPlayers[250];
		decl String:name[32];
		GetConVarString(g_CvarCusomNameTeamCT, teamAName, sizeof(teamAName));
		GetConVarString(g_CvarCusomNameTeamT, teamBName, sizeof(teamBName));
		Format(teamAPlayers, sizeof(teamAPlayers), "\x04%s:\x03 ", teamAName);
		Format(teamBPlayers, sizeof(teamBPlayers), "\x04%s:\x03 ", teamBName);
		
		if (client == 0)
			PrintToChatAll("\x04[%s]:\x03 Teams:", MODNAME);
		else
			PrintToChat(client, "\x04[%s]:\x03 Teams:", MODNAME);
			
		for (new i=1; i<=MaxClients; i++)
		{
			if (g_ReadyPlayers[i] && IsClientConnected(i))
			{
				GetClientName(i, name, sizeof(name));
				if (g_ReadyPlayersData[i] == 3) // team A
					Format(teamAPlayers, sizeof(teamAPlayers), "%s%s\x01, \x03", teamAPlayers, name);
				else if (g_ReadyPlayersData[i] == 2) // team B
					Format(teamBPlayers, sizeof(teamBPlayers), "%s%s\x01, \x03", teamBPlayers, name);
			}
		}
		if (client == 0)
		{
			PrintToChatAll(teamAPlayers);
			PrintToChatAll(teamBPlayers);
		}
		else
		{
			PrintToChat(client, teamAPlayers);
			PrintToChat(client, teamBPlayers);
		}
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_UnReady(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (GetConVarInt(g_CvarAutoMixEnabled) == 0) // Auto-Mix is not running...
		{
			PrintToChat(client, "\x04[%s]:\x03 Auto-War is not running! This command is now disabled.", MODNAME);
			return Plugin_Handled;
		}
		
		if (hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix is running! This command is now disabled.", MODNAME);
			return Plugin_Handled;
		}
		
		if (g_ReadyPlayers[client]) // He is ready ...
		{
			g_ReadyCount--;
			g_ReadyPlayers[client] = false;
		}
		
		PrintToChatAll("\x04[%s]:\x03 You are not ready!", MODNAME);

		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Command_ShowMvp(client, args)
{
	if (GetConVarInt(g_CvarEnabled) == 1)
	{
		if (!hasMixStarted)
		{
			PrintToChat(client, "\x04[%s]:\x03 Mix/Pcw is not running! This command is now disabled.", MODNAME);
			return Plugin_Handled;
		}
		
		if (GetConVarInt(g_CvarShowMVP) == 0)
		{
			PrintToChat(client, "\x04[%s]:\x03 MVP Stats is disabled! thsi command is now disabled.", MODNAME);
			return Plugin_Handled;
		}
		
		new max=0;
		new index=-1;
		for (new i=1; i<=MaxClients;i++)
		{
			if (IsClientConnected(i))
			{
				if (g_ScoresOfTheGame[i] >= max)
				{
					max = g_ScoresOfTheGame[i];
					index = i;
				}
			}
		}
		decl String:mvpName[33];
		GetClientName(index, mvpName, sizeof(mvpName));
		new kills = g_ScoresOfTheGame[index];
		if (kills <= 0)
		{
			PrintToChat(client, "\x04[%s]:\x03 MVP wasn't chosen yet. Please wait a few minutes.", MODNAME);
			return Plugin_Handled;
		}
		PrintToChat(client, "\x04[%s]:\x03 MVP:", MODNAME);
		PrintToChat(client, "------------------");
		PrintToChat(client, "\x03 - The \x01MVP:\x04 %s , \x03Killed:\x04 %d \x03Enemies!", mvpName, kills);
		
		if (index == client)
			return Plugin_Handled;
	
		decl String:clientName[33];
		GetClientName(client, clientName, sizeof(clientName));
		PrintToChat(client, "\x03 You killed:\x04 %d \x03 Enemies.", g_ScoresOfTheGame[client]);
		
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

UpdateReadyPanel()
{
	if (readyStatus != INVALID_HANDLE)
		CloseHandle(readyStatus);
	
	// Credit for GameTech warmod plugin - I didn't know what to write in the titles...
	readyStatus = CreatePanel();
	decl String:title[128], String:notReady[400], String:name[32];
	Format(title, sizeof(title), "%s - Ready system \n ---Created by iDragon", MODNAME);
	SetPanelTitle(readyStatus, title);
	DrawPanelText(readyStatus, "\n \n");
	DrawPanelItem(readyStatus, "Match will begin when 10 players are ready");
	DrawPanelText(readyStatus, "\n \n");
	DrawPanelItem(readyStatus, "Not ready: ");
	Format(notReady, sizeof(notReady), "");
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!g_ReadyPlayers[i] && IsClientConnected(i))
		{
			GetClientName(i, name, sizeof(name));
			Format(notReady, sizeof(notReady), "%s %s\n", notReady, name);
		}
	}
	DrawPanelText(readyStatus, notReady);
	DrawPanelText(readyStatus, "\n \n");
	DrawPanelItem(readyStatus, "Exit");
}

ShowReadyPanel(client)
{
	SendPanelToClient(readyStatus, client, Handler_DoNothing, 20);
}

bool:DisableBuyZone()
{
	new ent = -1, bool:disabled = false;
	while((ent = FindEntityByClassname(ent, "func_buyzone")) != -1)
	{
		AcceptEntityInput(ent, "Disable");
		disabled = true;
	}
	
	return disabled;
}

bool:EnableBuyZone()
{
	new ent = -1, bool:enabled = false;
	while((ent = FindEntityByClassname(ent, "func_buyzone")) != -1)
	{
		AcceptEntityInput(ent, "Enable");
		enabled = true;
	}
	
	return enabled;
}

public Action:SwapTimer(Handle:timer)
{
	didLiveStarted = false; // Disable it here, before changing teams.
	new team;
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client) && !IsFakeClient(client) && IsClientConnected(client))
		{
			team = GetClientTeam(client);
			
			if (team == 3)
				ChangeClientTeam(client, 2);
			else if (team == 2)
				ChangeClientTeam(client, 3);
		}
	}
	
	if ((GetConVarInt(g_CvarHalfAutoLiveStart) == 1) && g_IsItManual) // Admin need to write: !live to start...
		didLiveStarted = true;
}