#pragma semicolon 1

#include <sourcemod>
#undef REQUIRE_PLUGIN
#include <sdktools>

public Plugin:myinfo =
{
	name = "Zstuck",
	author = "SoZika",
	description = "Unlock other players, if the antistick of ZR fails",
	version = "0.4",
	url = "http://insanitybrasil.info"
};

// Variaveis Globais

new g_CollisionOffset;
new intervalo[MAXPLAYERS + 1];

// CVARS

new Handle:gCvarEnabled;
new bool:gEnabled;
new Handle:gCvarInterval;
new Float:gInterval;
new Handle:gCvarNoBlock;
new bool:gNoBlock;
new Handle:gCvarSlap;
new bool:gSlap;

public OnPluginStart() {

	/**** CVARS ***/

	gCvarEnabled = CreateConVar("zr_zstuck_enabled", "1", "Enable Plugin");
	gEnabled = GetConVarBool(gCvarEnabled);
	HookConVarChange(gCvarEnabled, CvarChanged);

	gCvarInterval = CreateConVar("zr_zstuck_interval", "3", "Interval to use zstuck");
	gInterval = GetConVarFloat(gCvarInterval);
	HookConVarChange(gCvarInterval, CvarChanged);

	gCvarNoBlock = CreateConVar("zr_zstuck_noblock", "1", "Give noblock");
	gNoBlock = GetConVarBool(gCvarNoBlock);
	HookConVarChange(gCvarNoBlock, CvarChanged);

	gCvarSlap = CreateConVar("zr_zstuck_slap", "1", "Give slap");
	gSlap = GetConVarBool(gCvarSlap);
	HookConVarChange(gCvarSlap, CvarChanged);

	g_CollisionOffset = FindSendPropOffs("CBaseEntity", "m_CollisionGroup"); // NoBlock
	
	/** COMMANDS (chat) **/

	RegConsoleCmd("say", ChamarStuck);

	/** CONFIG **/
	AutoExecConfig(true, "zombiereloaded/zstuck");
}

// Cvar changer

public CvarChanged(Handle:cvar, const String:oldValue[], const String:newValue[]) {
	if(cvar == gCvarEnabled)
	{
		gEnabled = GetConVarBool(gCvarEnabled);
	}
	if(cvar == gCvarInterval)
	{
		gInterval = GetConVarFloat(gCvarInterval);
	}
	if(cvar == gCvarNoBlock)
	{
		gNoBlock = GetConVarBool(gCvarNoBlock);
	}
	if(cvar == gCvarSlap)
	{
		gSlap = GetConVarBool(gCvarSlap);
	}
}

// NoBlock

public setNoblock(id){
	SetEntData(id, g_CollisionOffset, 2, 4, true);
}

// Tirar intervalo de uso do zStuck

public Action:tirarIntervalo(Handle:timer,any:id){
	intervalo[id] = INVALID_HANDLE;
}

// Tirar noblock

public Action:desblock(Handle:timer,any:id)
{
	SetEntData(GetClientOfUserId(id), g_CollisionOffset, 5, 4, true);
} 

// Funcao de Zstuck

public Action:zstuck(id){
	if(intervalo[id] == INVALID_HANDLE)
	{
		if(gNoBlock)
		{
			setNoblock(id);
			CreateTimer(0.3, desblock, GetClientOfUserId(id));
		}
		if(gSlap) 
		{
			SlapPlayer(id, 0, false);
		}

		intervalo[id] = 1;
		CreateTimer(gInterval, tirarIntervalo, id);
	}
}

// Chamar o zStuck

public Action:ChamarStuck( id, args )
{
	decl String:Said[ 128 ];
	GetCmdArgString( Said, sizeof( Said ) - 1 );
	StripQuotes( Said );
	TrimString( Said );
	
	if( StrEqual( Said, "!zstuck"))
	{
		if(gEnabled == 1) 
		{
			zstuck(id);
		}
	}
}