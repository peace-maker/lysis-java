#pragma semicolon 1

#include <sourcemod>


// Colors
#define GREEN 0x04
#define DEFAULTCOLOR 0x01
#define KM_VERSION "2.0.0"

// Define author information
public Plugin:myinfo = 
{
	name = "KnifeMug",
	author = "FlyingMongoose, sslice",
	description = "Knife Mugging",
	version = KM_VERSION,
	url = "http://www.steamfriends.com/"
};

// Define global variables
new g_MoneyOffset;

new Handle:cvarEnable;
new Handle:cvarMugCash;
new Handle:cvarMugPercent;

new bool:g_isHooked;

// Gets the user's money
GetPlayerCash(entity)
{
	return GetEntData(entity, g_MoneyOffset);
}

SetPlayerCash(entity, amount)
{
	SetEntData(entity, g_MoneyOffset, amount, 4, true);
}

public OnPluginStart(){
	LoadTranslations("knifemug.phrases");
	g_MoneyOffset = FindSendPropOffs("CCSPlayer", "m_iAccount");
	if (g_MoneyOffset == -1)
	{
		g_isHooked = false;
		PrintToServer("* FATAL ERROR: Failed to get offset for CCSPlayer::m_iAccount");
		SetFailState("[KnifeMug] * FATAL ERROR: Failed to get offset CCSPlayer::m_iAccount");
	}else{
		CreateConVar("km_version", KM_VERSION, _, FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_SPONLY);
		cvarEnable = CreateConVar("km_enable","1","Enables/Disables KnifeMug as well as sets the type of mugging\n0 = Off\n1 = Hard Cash\n2 = Percentage on Kill\n3 = Percentage on Damage",FCVAR_PLUGIN,true,0.0,true,3.0);
		cvarMugCash = CreateConVar("km_mugcash","2500","Sets the amount of money taken in a mugging based on a hard value",FCVAR_PLUGIN,true,0.0,true,16000.0);
		cvarMugPercent = CreateConVar("km_mugpercent","0.33","Sets the amount of money taken in a mugging based on percent",FCVAR_PLUGIN,true,0.0,true,1.0);
		
		AutoExecConfig(true,"knifemug","sourcemod");
		
		CreateTimer(3.0, OnPluginStart_Delayed);
	}
}

public Action:OnPluginStart_Delayed(Handle:timer){
	if(GetConVarInt(cvarEnable) > 0 && GetConVarInt(cvarEnable) <= 3){
		g_isHooked = true;
		HookEvent("player_death",ev_PlayerDeath);
		HookEvent("player_hurt",ev_PlayerHurt);
		
		HookConVarChange(cvarEnable,KnifeMugCvarChange);
		
		LogMessage("[KnifeMug] - Loaded");
	}
}

public KnifeMugCvarChange(Handle:convar, const String:oldValue[], const String:newValue[]){
	if(GetConVarInt(cvarEnable) <= 0){
		if(g_isHooked){
			g_isHooked = false;
			UnhookEvent("player_death",ev_PlayerDeath);
			UnhookEvent("player_hurt",ev_PlayerHurt);
		}
	}else if(!g_isHooked){
		g_isHooked = true;
		HookEvent("player_death",ev_PlayerDeath);
		HookEvent("player_hurt",ev_PlayerHurt);
	}
}

public ev_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast){
	decl String:weaponName[100];
	decl String:victimName[100];
	decl String:killerName[100];
	
	GetEventString(event,"weapon",weaponName,100);
	// if the weapon used in death was a knife it continues
	if(StrEqual(weaponName, "knife")){
		new MugType = GetConVarInt(cvarEnable);
		// if damage mugging is not on then it continues
		if(MugType == 2){
			new Float:mugPercent = GetConVarFloat(cvarMugPercent);
			new userid = GetEventInt(event, "userid");
			new userid2 = GetEventInt(event, "attacker");
			
			new victim = GetClientOfUserId(userid);
			new killer = GetClientOfUserId(userid2);
		
			if(victim != 0 && killer != 0){
				new victimTeam = GetClientTeam(victim);
				new killerTeam = GetClientTeam(killer);
				// if the players teams are not the same set cash accordingly
				if(killerTeam!=victimTeam){
					GetClientName(victim,victimName,100);
					GetClientName(killer,killerName,100);
					
					new victimCash = GetPlayerCash(victim);
					new killerCash = GetPlayerCash(killer);
					
					new percentVictimCash = RoundFloat(float(victimCash) - float(victimCash) * mugPercent);
					new percentKillerCash = RoundFloat(float(killerCash) + float(victimCash) * mugPercent);
					
					new percentCashTaken = RoundFloat(float(victimCash) * mugPercent);
					
					SetPlayerCash(victim,percentVictimCash);
					PrintToConsole(victim,"[KnifeMug] %T","Mugged You For",LANG_SERVER,killerName,percentCashTaken);
					PrintToChat(victim,"%c[KnifeMug]%c %T",GREEN,DEFAULTCOLOR,"Mugged You For",LANG_SERVER,killerName,percentCashTaken);
					// if the end result will be greater than 16000 then force a maximum of 16000
					if(percentKillerCash > 16000){
						SetPlayerCash(killer,16000);
					}else{
						SetPlayerCash(killer,percentKillerCash);
					}
					PrintToConsole(killer,"[KnifeMug] %T","You Have Mugged",LANG_SERVER,victimName,percentCashTaken);
					PrintToChat(killer,"%c[KnifeMug]%c %T",GREEN,DEFAULTCOLOR,"You Have Mugged",LANG_SERVER,victimName,percentCashTaken);
				}
			}
		}
		if(MugType == 1){
			new mugCash = GetConVarInt(cvarMugCash);
			new userid = GetEventInt(event, "userid");
			new userid2 = GetEventInt(event, "attacker");
			
			new victim = GetClientOfUserId(userid);
			new killer = GetClientOfUserId(userid2);
			if(victim != 0 && killer != 0){
				// if the cvar for mugcash is within it's boundaries execute following code
				if(mugCash > 0 || mugCash < 16000){
					new victimTeam = GetClientTeam(victim);
					new killerTeam = GetClientTeam(killer);
					// if the killer and victim team is not the same execute the following
					if(killerTeam!=victimTeam){
						GetClientName(victim,victimName,100);
						GetClientName(killer,killerName,100);
						
						new victimCash = GetPlayerCash(victim);
						new killerCash = GetPlayerCash(killer);
						
						// if the victim's cash is less than the cash that is being mugged then give the killer however
						// much money the victim has and set the victim's money to 0
						if(victimCash < mugCash){
							SetPlayerCash(victim,0);
							PrintToConsole(victim,"[KnifeMug] %T","Mugged You For",LANG_SERVER,killerName,victimCash);
							PrintToChat(victim,"%c[KnifeMug]%c %T",GREEN,DEFAULTCOLOR,"Mugged You For",LANG_SERVER,killerName,victimCash);
							// if the end result will be greater than 16000 then force a maximum of 16000
							if(killerCash + victimCash > 16000){
								SetPlayerCash(killer,16000);
							}else{
								SetPlayerCash(killer,killerCash + victimCash);
							}
							PrintToConsole(killer,"[KnifeMug] %T","You Have Mugged",LANG_SERVER,victimName,victimCash);
							PrintToChat(killer,"%c[KnifeMug]%c %T",GREEN,DEFAULTCOLOR,"You Have Mugged",LANG_SERVER,victimName,victimCash);
						}else{
							// if the victims cash is not less than the cash set for mugging then do the following
							GetClientName(victim,victimName,100);
							GetClientName(killer,killerName,100);
							
							new newVictimCash = victimCash - mugCash;
							new newKillerCash = killerCash + mugCash;
							
							SetPlayerCash(victim, newVictimCash);
							PrintToConsole(victim,"[KnifeMug] %T","Mugged You For",LANG_SERVER,killerName,mugCash);
							PrintToChat(victim,"%c[KnifeMug%c %T",GREEN,DEFAULTCOLOR,"Mugged You For",LANG_SERVER,killerName,mugCash);
							// if the end result will be greater than 16000 then force a maximum of 16000
							if(newKillerCash > 16000){
								SetPlayerCash(killer,16000);
							}else{
								SetPlayerCash(killer, newKillerCash);
							}
							PrintToConsole(killer,"[KnifeMug] %T","You Have Mugged",LANG_SERVER,victimName,mugCash);
							PrintToChat(killer,"%c[KnifeMug]%c %T",GREEN,DEFAULTCOLOR,"You Have Mugged",LANG_SERVER,victimName,mugCash);
						}
					}
				}
			}
		}
	}
}

public ev_PlayerHurt(Handle:event, const String:name[], bool:dontBroadcast){
	decl String:dmgWeaponName[100];
	decl String:dmgVictimName[100];
	decl String:dmgKillerName[100];
	
	new MugType = GetConVarInt(cvarEnable);
	// checks to see if the damage mugging a.k.a. active mugging is enabled
	if(MugType == 3){
		GetEventString(event,"weapon",dmgWeaponName,100);
		// checks to see if the weapon in use is a knife
		if(StrEqual(dmgWeaponName,"knife")){
			new userid = GetEventInt(event,"userid");
			new userid2 = GetEventInt(event,"attacker");
			
			new victim = GetClientOfUserId(userid);
			new killer = GetClientOfUserId(userid2);
			if(victim != 0 && killer != 0){
				new dmgVictimTeam = GetClientTeam(victim);
				new dmgKillerTeam = GetClientTeam(killer);
				// checks to see if the victim and killer are not on the same team
				if(dmgVictimTeam != dmgKillerTeam){
					GetClientName(victim,dmgVictimName,100);
					GetClientName(killer,dmgKillerName,100);
				
					new dmgVictimCash = GetPlayerCash(victim);
					new dmgKillerCash = GetPlayerCash(killer);
					
					new dmgDone = GetEventInt(event,"dmg_health");
					// checks the damage done and assigns money to player(s) accordingly
					// if the damage is greater than or equal to 100 then gives 50% of the victim's money to the attacker
					if(dmgDone >= 100){
						new dmgPercentVictimCash = RoundFloat(float(dmgVictimCash) - float(dmgVictimCash) * 0.50);
						new dmgPercentKillerCash = RoundFloat(float(dmgKillerCash) + float(dmgVictimCash) * 0.50);
						
						new dmgPercentCashTaken = RoundFloat(float(dmgVictimCash) * 0.50);
						
						SetPlayerCash(victim,dmgPercentVictimCash);
						PrintToConsole(victim,"[KnifeMug] %T","Mugged You For",LANG_SERVER,dmgKillerName,dmgPercentCashTaken);
						PrintToChat(victim,"%c[KnifeMug]%c %T",GREEN,DEFAULTCOLOR,"Mugged You For",LANG_SERVER,dmgKillerName,dmgPercentCashTaken);
						// if the end result will be greater than 16000 then force a maximum of 16000
						if(dmgPercentKillerCash > 16000){
							SetPlayerCash(killer,16000);
						}else{
							SetPlayerCash(killer,dmgPercentKillerCash);
						}
						PrintToConsole(killer,"[KnifeMug] %T","You Have Mugged",LANG_SERVER,dmgVictimName,dmgPercentCashTaken);
						PrintToChat(killer,"%c[KnifeMug]%c %T",GREEN,DEFAULTCOLOR,"You Have Mugged",LANG_SERVER,dmgVictimName,dmgPercentCashTaken);
					}
					// if the damage is from 21 to 99 the attacker gets 33% of the victims money
					if(dmgDone > 20 && dmgDone < 100){
						new dmgPercentVictimCash = RoundFloat(float(dmgVictimCash) - float(dmgVictimCash) * 0.33);
						new dmgPercentKillerCash = RoundFloat(float(dmgKillerCash) + float(dmgVictimCash) * 0.33);
						
						new dmgPercentCashTaken = RoundFloat(float(dmgVictimCash) * 0.33);
						
						SetPlayerCash(victim,dmgPercentVictimCash);
						PrintToConsole(victim,"[KnifeMug] %T","Mugged You For",LANG_SERVER,dmgKillerName,dmgPercentCashTaken);
						PrintToChat(victim,"%c[KnifeMug]%c %T",GREEN,DEFAULTCOLOR,"Mugged You For",LANG_SERVER,dmgKillerName,dmgPercentCashTaken);
						// if the end result will be greater than 16000 then force a maximum of 16000
						if(dmgPercentKillerCash > 16000){
							SetPlayerCash(killer,16000);
						}else{
							SetPlayerCash(killer,dmgPercentKillerCash);
						}
						PrintToConsole(killer,"[KnifeMug] %T","You Have Mugged",LANG_SERVER,dmgVictimName,dmgPercentCashTaken);
						PrintToChat(killer,"%c[KnifeMug]%c %T",GREEN,DEFAULTCOLOR,"You Have Mugged",LANG_SERVER,dmgVictimName,dmgPercentCashTaken);
					}
					// if the damage done is from 1 to 20 then the attacker gets 25% of the killer's money
					if(dmgDone > 1 && dmgDone <= 20){
						new dmgPercentVictimCash = RoundFloat(float(dmgVictimCash) - float(dmgVictimCash) * 0.25);
						new dmgPercentKillerCash = RoundFloat(float(dmgKillerCash) + float(dmgVictimCash) * 0.25);
						
						new dmgPercentCashTaken = RoundFloat(float(dmgVictimCash) * 0.25);
						
						SetPlayerCash(victim,dmgPercentVictimCash);
						PrintToConsole(victim,"[KnifeMug] %T","Mugged You For",LANG_SERVER,dmgKillerName,dmgPercentCashTaken);
						PrintToChat(victim,"%c[KnifeMug]%c %T",GREEN,DEFAULTCOLOR,"Mugged You For",LANG_SERVER,dmgKillerName,dmgPercentCashTaken);
						// if the end result will be greater than 16000 then force a maximum of 16000
						if(dmgPercentKillerCash > 16000){
							SetPlayerCash(killer,16000);
						}else{
							SetPlayerCash(killer,dmgPercentKillerCash);
						}
						PrintToConsole(killer,"[KnifeMug] %T","You Have Mugged",LANG_SERVER,dmgVictimName,dmgPercentCashTaken);
						PrintToChat(killer,"%c[KnifeMug]%c %T",GREEN,DEFAULTCOLOR,"You Have Mugged",LANG_SERVER,dmgVictimName,dmgPercentCashTaken);
					}
				}
			}
		}
	}
}