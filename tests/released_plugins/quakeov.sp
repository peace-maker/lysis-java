#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>

#define DMG_HEADSHOT (1 << 30)
#include emitsoundany.inc

new Handle:g_hQuakeov_enabled = INVALID_HANDLE;
new bool:g_bQuakeov_enabled;
new g_hPoints[MAXPLAYERS +1];
new Handle:g_hClientCookieOverlays = INVALID_HANDLE;
new g_bClientPrefOverlays[MAXPLAYERS+1];
new Handle:g_hClientCookieSounds = INVALID_HANDLE;
new g_bClientPrefSounds[MAXPLAYERS+1];

new String:SOUNDS_PACK[][] = {
"quake/standard/perfect.mp3",
"quake/standard/humiliation.mp3",
"quake/standard/headshot.mp3",
"quake/standard/humiliation.mp3",
"quake/standard/doublekill.mp3",
"quake/standard/triplekill.mp3",
"quake/standard/dominating.mp3",
"quake/standard/combowhore.mp3",
"quake/standard/rampage.mp3",
"quake/standard/killingspree.mp3",
"quake/standard/monsterkill.mp3",
"quake/standard/unstoppable.mp3",
"quake/standard/ultrakill.mp3",
"quake/standard/godlike.mp3",
"quake/standard/wickedsick.mp3",
"quake/standard/impressive.mp3",
"quake/standard/ludicrouskill.mp3",
"quake/standard/holyshit.mp3"};

#define PLUGIN_VERSION "1.0"
public Plugin:myinfo =
{
	name = "[CSGO] QuakeSounds Overlays edition",
	author = "TonyBaretta",
	description = "quakesounds overlays edition",
	version = PLUGIN_VERSION,
	url = "http://www.wantedgov.it"
}

public OnMapStart() {
	decl String:file[256];
	BuildPath(Path_SM, file, 255, "configs/quakeov.ini");
	new Handle:fileh = OpenFile(file, "r");
	if (fileh != INVALID_HANDLE)
	{
		decl String:buffer[256];
		decl String:buffer_full[PLATFORM_MAX_PATH];

		while(ReadFileLine(fileh, buffer, sizeof(buffer)))
		{
			TrimString(buffer);
			if ( (StrContains(buffer, "//") == -1) && (!StrEqual(buffer, "")) )
			{
				PrintToServer("Reading overlay_downloads line :: %s", buffer);
				Format(buffer_full, sizeof(buffer_full), "%s", buffer);
				if (FileExists(buffer_full))
				{
					PrintToServer("Precaching %s", buffer);
					PrecacheDecal(buffer, true);
					AddFileToDownloadsTable(buffer_full);
				}
			}
		}
	}
	for(new i = 0;i<sizeof(SOUNDS_PACK);i++){
		PrecacheSoundAny(SOUNDS_PACK[i]);
	}
}
public OnPluginStart() {
	CreateConVar("quakesoundov", PLUGIN_VERSION, "[CSGO] Hs Impact Effect", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	HookEvent("player_death", PlayerDeath); //When player suicide
	g_hQuakeov_enabled = CreateConVar("qsov_enabled", "1", "enable quake sounds plugin");
	g_bQuakeov_enabled = GetConVarBool(g_hQuakeov_enabled);
	g_hClientCookieOverlays = RegClientCookie("QS Overlays", "set overlays on / off ", CookieAccess_Private);
	g_hClientCookieSounds = RegClientCookie("QS Overlays sounds", "set sounds on/off", CookieAccess_Private);
	SetCookieMenuItem(QSPrefSelected,0,"QS Prefs");
}
public OnClientPutInServer(client) {
	LoadClientCookiesFor(client);
	CreateTimer(25.0, WelcomeVersion, client);
}
public void OnClientDisconnect(client)
{
	g_hPoints[client] = 0;
}
public LoadClientCookiesFor(client)
{
	new String:buffer[5]
	GetClientCookie(client,g_hClientCookieOverlays,buffer,5)
	if(!StrEqual(buffer,""))
	{
		g_bClientPrefOverlays[client] = StringToInt(buffer)
	}
	if(StrEqual(buffer,"")){
		g_bClientPrefOverlays[client] = 1;
	}
	GetClientCookie(client,g_hClientCookieSounds,buffer,5)
	if(!StrEqual(buffer,""))
	{
		g_bClientPrefSounds[client] = StringToInt(buffer)
	}
	if(StrEqual(buffer,"")){
		g_bClientPrefSounds[client] = 1;
	}
}
public PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	g_bQuakeov_enabled = GetConVarBool(g_hQuakeov_enabled);	
	new userId = GetEventInt(event, "userid"); 
	new attackerId = GetEventInt(event, "attacker");
	new attacker = GetClientOfUserId(attackerId);
	new victim = GetClientOfUserId(userId); 
	if(IsValidClient(victim) && (g_bQuakeov_enabled)){
		new String:weapon[32];
		GetEventString(event, "weapon",weapon, sizeof(weapon));
		if(StrEqual(weapon,"hegrenade")){
			if(IsValidClient(attacker)){
				if(g_bClientPrefSounds[attacker]){
					EmitSoundToClientAny(attacker, "quake/standard/perfect.mp3");
				}
				if(g_bClientPrefOverlays[attacker]){
					SetClientOverlay(attacker, "event_overlay/overlay2/perfect");
				}
				CreateTimer(2.0, DeleteOverlay, attacker);
			}		
		}
		if(strncmp(weapon, "knife", 5) == 0){
			if(IsValidClient(attacker)){
				if(g_bClientPrefSounds[attacker]){
					EmitSoundToClientAny(attacker, "quake/standard/humiliation.mp3");
				}
				if(g_bClientPrefOverlays[attacker]){
					SetClientOverlay(attacker, "event_overlay/overlay2/humiliation");
				}
				CreateTimer(2.0, DeleteOverlay, attacker);
			}		
		}
		if (GetEventBool(event, "headshot") && IsValidClient(victim)){
			if(IsValidClient(attacker)){
				if(g_bClientPrefSounds[attacker]){
					EmitSoundToClientAny(attacker, "quake/standard/headshot.mp3");
				}
				if(g_bClientPrefOverlays[attacker]){
					SetClientOverlay(attacker, "event_overlay/overlay2/hs");
				}
				CreateTimer(2.0, DeleteOverlay, attacker);
			}
		}
		g_hPoints[victim] = 0;
		if(IsValidClient(attacker)){
			g_hPoints[attacker] += 1;
			CheckPoints(attacker);
			//PrintToConsole(attacker, " %d",g_hPoints[attacker]);
			CreateTimer(2.0, DeleteOverlay, attacker);
		}
		if (attacker == victim){
			if(IsValidClient(victim)){
				if(g_bClientPrefSounds[attacker]){
					EmitSoundToClientAny(victim, "quake/standard/humiliation.mp3");
				}
				if(g_bClientPrefOverlays[attacker]){
					SetClientOverlay(victim, "event_overlay/overlay2/suicide");
				}
				CreateTimer(2.0, DeleteOverlay, victim);
				g_hPoints[victim] = 0;
				g_hPoints[attacker] = 0;
			}
		}
	}
}
public Action:DeleteOverlay(Handle:timer, any:iClient)
{
	if (IsValidClient(iClient)){
		SetClientOverlay(iClient, "");
	}
	return Plugin_Handled;
}

stock bool:IsValidClient(iClient) {
	if (iClient <= 0) return false;
	if (iClient > MaxClients) return false;
	if (!IsClientConnected(iClient)) return false;
	return IsClientInGame(iClient);
}
SetClientOverlay(client, String:strOverlay[])
{
	if (IsValidClient(client)){
		new iFlags = GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT);
		SetCommandFlags("r_screenoverlay", iFlags);	
		ClientCommand(client, "r_screenoverlay \"%s\"", strOverlay);
		return true;
	}
	return false;
}
CheckPoints(client)
{
	if (IsValidClient(client)){
		if(g_hPoints[client] == 2){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/doublekill.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/dk");
			}
		}
		if(g_hPoints[client] == 3){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/triplekill.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/tk");
			}
		}
		if(g_hPoints[client] == 4){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/dominating.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/domination");
			}
		}
		if(g_hPoints[client] == 5){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/combowhore.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/cw");
			}
		}
		if(g_hPoints[client] == 6){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/rampage.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/rampage");
			}
		}
		if(g_hPoints[client] == 8){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/killingspree.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/ks");
			}
		}
		if(g_hPoints[client] == 10){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/monsterkill.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/monsterkill");
			}
		}
		if(g_hPoints[client] == 14){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/unstoppable.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/unstop");
			}
		}
		if(g_hPoints[client] == 16){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/ultrakill.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/ultrakill");
			}
		}
		if(g_hPoints[client] == 18){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/godlike.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/godlike");
			}
		}
		if(g_hPoints[client] == 20){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/wickedsick.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/wicked");
			}
		}
		if(g_hPoints[client] == 22){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/impressive.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/impressive");
			}
		}
		if(g_hPoints[client] == 24){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/ludicrouskill.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/lk");
			}
		}
		if(g_hPoints[client] == 26){
			if(g_bClientPrefSounds[client]){
				EmitSoundToClientAny(client, "quake/standard/holyshit.mp3");
			}
			if(g_bClientPrefOverlays[client]){
				SetClientOverlay(client, "event_overlay/overlay2/holyshit");
			}
		}
	}
}

public Action:CMD_ShowQSPrefsMenu(client,args)
{
	ShowQSMenu(client)
	return Plugin_Handled
}

// Make the menu or nothing will show
public ShowQSMenu(client)
{
	new Handle:menu = CreateMenu(MenuHandlerQS)
	SetMenuTitle(menu, "Quake Sounds OV Edition");
	AddMenuItem(menu, "g_bClientPrefOverlays[client] == 1", "Enable/Disable Overlays");
	AddMenuItem(menu, "g_bClientPrefSounds[client] == 1", "Enable/Disable Sounds");
	SetMenuExitButton(menu,true)
	DisplayMenu(menu,client,20)
}

// Check what's been selected in the menu
public MenuHandlerQS(Handle:menu,MenuAction:action,param1,param2)
{
	if(action == MenuAction_Select)	
	{
		if(param2 == 0)
		{
			if(g_bClientPrefOverlays[param1] == 0)
			{
				g_bClientPrefOverlays[param1] = 1;
				PrintToChat(param1,"overlays Enabled");
			}
			else
			{
				g_bClientPrefOverlays[param1] = 0;
				PrintToChat(param1,"overlays Disabled");
			}
		}
		if(param2 == 1){
			if(g_bClientPrefSounds[param1] == 0)
			{
				g_bClientPrefSounds[param1] = 1;
				PrintToChat(param1,"Quake Sounds Enabled");
			}			
			else
			{
				g_bClientPrefSounds[param1] = 0;
				PrintToChat(param1,"Quake Sounds Disabled");
			}
		}
		new String:buffer[5]
		IntToString(g_bClientPrefSounds[param1],buffer,5)
		SetClientCookie(param1,g_hClientCookieOverlays,buffer)
		IntToString(g_bClientPrefOverlays[param1],buffer,5)
		SetClientCookie(param1,g_hClientCookieSounds,buffer)
		CMD_ShowQSPrefsMenu(param1,0)
	} 
	else if(action == MenuAction_End)
	{
		CloseHandle(menu)
	}
}
public QSPrefSelected(client,CookieMenuAction:action,any:info,String:buffer[],maxlen)
{
	if(action == CookieMenuAction_SelectOption)
	{
		ShowQSMenu(client)
	}
}
public Action:WelcomeVersion(Handle:timer, any:client){
	if(!IsValidClient(client)) return Plugin_Handled;
	PrintToChat(client, "\x02 QuakeSounds Overlays Edition \x06 %s \x01by \x05 -GoV-TonyBaretta", PLUGIN_VERSION);
	PrintToChat(client, "\x02 type \x05 !settings \x01 for enable/disable QuakeSounds options ");
	return Plugin_Handled;
}