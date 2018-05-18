#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.0.0.3"

#define MAX_PLAYERS 64


// globals
new gObj[MAXPLAYERS+1];         // how many tripmines player has this spawn
new Float:gThrow[MAXPLAYERS+1]; // throw charge state 
new Handle:gTimer;       
new String:gSound[256];

// convars
new Handle:cvSpeed = INVALID_HANDLE;
new Handle:cvDistance = INVALID_HANDLE; 
new Handle:cvTeamRestrict = INVALID_HANDLE;
new Handle:cvSound = INVALID_HANDLE;
new Handle:cvGround = INVALID_HANDLE;
new Handle:cvThrowTime = INVALID_HANDLE;
new Handle:cvThrowSpeed = INVALID_HANDLE;
new Handle:cvMaxDistance = INVALID_HANDLE;
new Handle:cvSteal = INVALID_HANDLE;
new Handle:cvDropOnJump = INVALID_HANDLE;


public Plugin:myinfo = {
	name = "Grabber:SM",
	author = "L. Duke",
	description = "grabber (gravgun)",
	version = PLUGIN_VERSION,
	url = "http://www.lduke.com/"
};


public OnPluginStart() 
{
	// events
	HookEvent("player_death", PlayerDeath);
	HookEvent("player_spawn",PlayerSpawn);
	
	// convars
	CreateConVar("sm_grabber_version", PLUGIN_VERSION, "Grabber:SM Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	cvSpeed = CreateConVar("sm_grabber_speed", "10.0");
	cvDistance = CreateConVar("sm_grabber_distance", "64.0");
	cvTeamRestrict = CreateConVar("sm_grabber_team_restrict", "0", "team restriction (0=all use, 2 or 3 to restrict that team");
	cvSound = CreateConVar("sm_grabber_sound", "weapons/physcannon/hold_loop.wav", "sound to play, change takes effect on map change");
	cvGround = CreateConVar("sm_grabber_groundmode", "0", "ground mode (soccer) 0=off 1=on");
	cvThrowTime = CreateConVar("sm_grabber_throwtime", "2.0", "time to charge up to full throw speed");
	cvThrowSpeed = CreateConVar("sm_grabber_throwspeed", "1000.0", "speed at which an object is thrown");
	cvMaxDistance = CreateConVar("sm_grabber_maxdistance", "512.0", "maximum distance from which you can grab an object");
	cvSteal = CreateConVar("sm_grabber_steal", "1", "can objects be 'stolen' from other players (0=no 1=yes)");
	cvDropOnJump = CreateConVar("sm_grabber_droponjump", "1", "drop objects when jumping (prevents player from flying around level on large objects) (0=no 1=yes)");
	
	// commands
	RegConsoleCmd("+grab", Command_Grab);
	RegConsoleCmd("-grab", Command_UnGrab2);
	RegConsoleCmd("+throw", Command_Throw);
	RegConsoleCmd("-throw", Command_UnThrow);
}

public OnEventShutdown(){
	UnhookEvent("player_death", PlayerDeath);
	UnhookEvent("player_spawn",PlayerSpawn);
}

public OnMapStart()
{ 
	// reset object list
	new i;
	for (i=0; i<=MAX_PLAYERS; i++)
	{
		gObj[i]=-1;
		gThrow[i]=0.0;
	}
	
	// start timer
	gTimer = CreateTimer(0.1, UpdateObjects, INVALID_HANDLE, TIMER_REPEAT);
	
	// precache sounds
	GetConVarString(cvSound, gSound, sizeof(gSound));
	PrecacheSound(gSound, true);
}

public OnMapEnd()
{
	CloseHandle(gTimer);
}

// When a new client is put in the server we reset their status
public OnClientPutInServer(client){
	if(client && !IsFakeClient(client))
	{
		gThrow[client]=0.0;
		gObj[client] = -1;
	}
}

public OnClientDisconnect(client)
{
	if (gObj[client]>0)
		Command_UnGrab(client, 0);
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client;
	client = GetClientOfUserId(GetEventInt(event, "userid"));
	// reset object held
	gThrow[client]=0.0;
	gObj[client] = -1;
	StopSound(client, SNDCHAN_AUTO, gSound);
	return Plugin_Continue;
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast){
	new client;
	client = GetClientOfUserId(GetEventInt(event, "userid"));
	// reset object held
	gThrow[client]=0.0;
	gObj[client] = -1;
	StopSound(client, SNDCHAN_AUTO, gSound);
	return Plugin_Continue;
}

public Action:Command_Grab(client, args)
{  
	
	// if an object is being held, go to UnGrab
	if (gObj[client]>0)
		return Command_UnGrab(client, args);
	
	// make sure client is not spectating
	if (!IsPlayerAlive(client))
		return Plugin_Handled;
	
	// check team restrictions
	new restrict = GetConVarInt(cvTeamRestrict);
	if (restrict>0)
	{
		if (restrict==GetClientTeam(client))
		{
			return Plugin_Handled;
		}
	}
	
	// find entity
	new ent = TraceToEntity(client);
	if (ent==-1)
		return Plugin_Handled;
	
	// only grab physics entities
	new String:edictname[128];
	GetEdictClassname(ent, edictname, 128);
	if (strncmp("prop_", edictname, 5, false)==0)
	{
		// check if another player is holding it
		new j;
		for (j=1; j<=MAX_PLAYERS; j++)
		{
			if (gObj[j]==ent)
			{
				if (GetConVarInt(cvSteal)==1)
				{
					// steal from other player
					Command_UnGrab(j, args);
				}
				else
				{
					// already being held - stealing not allowed
					return Plugin_Handled;
				}
			}
		}
		
		// grab entity
		gObj[client] = ent;
		gThrow[client] = 0.0;
		if (GetConVarInt(cvGround)!=1)
		{
			EmitSoundToAll(gSound, client);   // no sound in ground mode
		}
	}
	
	return Plugin_Handled;
}

public Action:Command_UnGrab(client, args)
{  
	// make sure client is not spectating
	if (!IsPlayerAlive(client))
		return Plugin_Handled;
	
	if (GetConVarInt(cvGround)!=1)
	{
		StopSound(client, SNDCHAN_AUTO, gSound);  // no sound in ground mode
	}
	
	if (gThrow[client]>0.0)
		PrintHintText(client, "");
	
	gThrow[client] = 0.0;
	gObj[client] = -1;
	
	return Plugin_Handled;
}

public Action:Command_Throw(client, args)
{
	// make sure client is not spectating
	if (!IsPlayerAlive(client))
		return Plugin_Handled;
	// has an object?
	if (gObj[client]<1)
		return Plugin_Handled;
	
	// start throw timer
	gThrow[client] = GetEngineTime();
	
	return Plugin_Handled;
}

public Action:Command_UnGrab2(client, args)
{
	// changed so Commmand_Ungrab is called from Command_Grab if an object is already held
	// so we need to handle -grab with this function
	return Plugin_Handled;
}

public Action:Command_UnThrow(client, args)
{
	// make sure client is not spectating
	if (!IsPlayerAlive(client))
		return Plugin_Handled;
	// has an object?
	if (gObj[client]<1)
		return Plugin_Handled;
	
	
	// throw object
	new Float:throwtime = GetConVarFloat(cvThrowTime);
	new Float:throwspeed = GetConVarFloat(cvThrowSpeed);
	new Float:time = GetEngineTime();
	new Float:percent;
	
	time=time-gThrow[client];
	if (time>throwtime)
	{
		percent = 1.0;
	}
	else
	{
		percent = time/throwtime;
	}
	throwspeed*=percent;
	
	new Float:start[3];
	GetClientEyePosition(client, start);
	new Float:angle[3];
	new Float:speed[3];
	GetClientEyeAngles(client, angle);
	GetAngleVectors(angle, speed, NULL_VECTOR, NULL_VECTOR);
	speed[0]*=throwspeed; speed[1]*=throwspeed; speed[2]*=throwspeed;
	
	TeleportEntity(gObj[client], NULL_VECTOR, NULL_VECTOR, speed);
	
	// cleanup
	Command_UnGrab(client, args);
	PrintHintText(client, "");  
	
	return Plugin_Handled;
}


public Action:UpdateObjects(Handle:timer)

{
	new Float:vecDir[3], Float:vecPos[3], Float:vecVel[3];      // vectors
	new Float:viewang[3];                                       // angles
	new i;
	new Float:speed = GetConVarFloat(cvSpeed);
	new Float:distance = GetConVarFloat(cvDistance);
	new groundmode = GetConVarInt(cvGround);
	new Float:throwtime = GetConVarFloat(cvThrowTime);
	new Float:time = GetEngineTime();
	new bool:DropInJump = false;
	for (i=0; i<=MAX_PLAYERS; i++)
	{
		if (gObj[i]>0)
		{
			if (GetConVarBool(cvDropOnJump))
			{
				DropInJump = GetClientButtons(i) & IN_JUMP ? true : false;
			}
			if (IsValidEdict(gObj[i]) && IsValidEntity(gObj[i]) && !DropInJump )
			{
				// get client info
				GetClientEyeAngles(i, viewang);
				GetAngleVectors(viewang, vecDir, NULL_VECTOR, NULL_VECTOR);
				if (groundmode==1)
				{
					GetClientAbsOrigin(i, vecPos);
				}
				else
				{
					GetClientEyePosition(i, vecPos);
				}
				
				// update object 
				vecPos[0]+=vecDir[0]*distance;
				vecPos[1]+=vecDir[1]*distance;
				if (groundmode!=1)
				{
					vecPos[2]+=vecDir[2]*distance;    // don't change up/down in ground mode
				}
				
				GetEntPropVector(gObj[i], Prop_Send, "m_vecOrigin", vecDir);
				
				SubtractVectors(vecPos, vecDir, vecVel);
				
				ScaleVector(vecVel, speed);
				if (groundmode==1)
				{
					vecVel[2]=0.0;
				}
				TeleportEntity(gObj[i], NULL_VECTOR, NULL_VECTOR, vecVel);
				
				// update throw time
				if (gThrow[i]>0.0)
				{
					ShowBar(i, time-gThrow[i], throwtime);
				}
				
			}
			else
			{
				gObj[i]=-1;
			}
			
		}
	}
	
	return Plugin_Continue;
}















public TraceToEntity(client)
{
	new Float:vecClientEyePos[3], Float:vecClientEyeAng[3];
	GetClientEyePosition(client, vecClientEyePos); // Get the position of the player's eyes
	GetClientEyeAngles(client, vecClientEyeAng); // Get the angle the player is looking    
	
	//Check for colliding entities
	TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelf, client);
	
	if (TR_DidHit(INVALID_HANDLE))
	{
		new TRIndex = TR_GetEntityIndex(INVALID_HANDLE);
		
		// check max distance
		new Float:pos[3];
		GetEntPropVector(TRIndex, Prop_Send, "m_vecOrigin", pos);
		if (GetVectorDistance(vecClientEyePos, pos)>GetConVarFloat(cvMaxDistance))
		{
			return -1;
		}
		else
		{
			return TRIndex;
		}
	}
	
	return -1;
}

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	if(entity == data) // Check if the TraceRay hit the itself.
	{
		return false; // Don't let the entity be hit
	}
	return true; // It didn't hit itself
}


// show a progres bar via hint text
ShowBar(client, Float:curTime, Float:totTime)
{
	new i;
	new String:output[128];
	
	if (curTime>totTime)
	{
		Format(output, sizeof(output), "[XXXXXXXXXXXXXXXXXXXX]");
	}
	else
	{
		new Float:fl = 1.0;
		output[0]='[';
		for (i=1;i<21;i++)
		{
			if (fl/20.0 > curTime/totTime)
			{
				output[i]='-';
			}
			else
			{
				output[i]='X';
			}
			fl+=1.0;
		}
		output[21]=']';
		output[22]='\0';
	}
	
	PrintHintText(client, output);
}


