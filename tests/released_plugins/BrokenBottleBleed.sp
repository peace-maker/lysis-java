#include <sourcemod>
#include <tf2_stocks>
#include <sdkhooks>
#define PLUGIN_VERSION "1.0.3"

new Handle:BleedChance;
new Handle:BleedTime;

public Plugin:myinfo = {
	name             = "[TF2] Broken Bottle Bleed",
	author         = "DarthNinja",
	description     = "Broken Demo Bottles have a chance to inflict bleed.",
	version         = PLUGIN_VERSION,
	url             = "DarthNinja.com"
};

public OnPluginStart( )
{
	CreateConVar("sm_bbb_version", PLUGIN_VERSION, "TF2 Player Stats", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	BleedChance = CreateConVar("sm_bbb_chance", "1.00", "Chance to inflict bleed, 1.00 = 100%, 0.50 = 50%, etc", FCVAR_PLUGIN);
	BleedTime = CreateConVar("sm_bbb_time", "5.0", "Seconds to inflict bleed for", FCVAR_PLUGIN);

	RegAdminCmd("sm_break", BottleBreak, ADMFLAG_SLAY, "Breaks your Bottle");

	//Lateload support
	for (new i=1; i<=MaxClients; i++)
	{
		if (IsClientInGame(i))
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
	}

	LoadTranslations("common.phrases");
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public OnClientDisconnect(client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if (damagetype == 4 || victim < 0 || victim > MaxClients || attacker < 0 || attacker > MaxClients)
		return Plugin_Continue;	//Bleed Damage

	new Float:iBleedChance = GetConVarFloat(BleedChance);
	new Float:iRoll = GetRandomFloat();
	if (iBleedChance >= iRoll)
	{
		new iWeapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon"); //Bottle should still be active if it was just used
		new iItemID = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");
		if (iItemID != 1 && iItemID != 191)
			return Plugin_Continue;	//Not a bottle

		new bBroken = GetEntProp(iWeapon, Prop_Send, "m_bBroken");
		if (bBroken != 1)
			return Plugin_Continue;	//Bottle isnt broken

		if (victim == attacker)
			return Plugin_Continue; //This should be impossible unless a plugin is dealing damage

		if (victim > 0 && victim < MaxClients && IsClientInGame(victim))
		{
			TF2_MakeBleed(victim, attacker, GetConVarFloat(BleedTime));
		}
	}
	return Plugin_Continue;
}

public Action:BottleBreak(client, args)
{
	if (!IsClientInGame(client))
	{
		ReplyToCommand(client, "You must be ingame!");
		return Plugin_Handled;
	}

	//	1	= Bottle
	//	191	= Upgradeable Bottle

	//new iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	new iWeapon = GetPlayerWeaponSlot(client, 2);
	new iItemID = GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex");

	if (iItemID != 1 && iItemID != 191)
	{
		ReplyToCommand(client, "You do not have a bottle to break!");
		return Plugin_Handled;
	}

	ReplyToCommand(client, "Your bottle has been broken!");
	SetEntProp(iWeapon, Prop_Send, "m_bBroken", 1)
	return Plugin_Handled;
}