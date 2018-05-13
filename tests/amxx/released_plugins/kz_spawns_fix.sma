#include <amxmodx>
#include <orpheu>
#include <fakemeta>

#pragma semicolon true


new Array:gSpawnPoints;

public plugin_init()
{
    register_plugin("KreedZ: Spawns Fix", "1.0.0", "KliPPy");

    RequestFrame("@FrameRequest_FixSpawnPoints");
    OrpheuRegisterHook(OrpheuGetFunction("EntSelectSpawnPoint"), "@CBasePlayer_EntSelectSpawnPoint", OrpheuHookPre);
}

static @FrameRequest_FixSpawnPoints()
{
    gSpawnPoints = GetCTSpawnPoints();
    if(ArraySize(gSpawnPoints) == 0)
    {
        set_fail_state("No info_player_start entities.");
        return;
    }

    RemoveTSpawnPoints();
    
    set_gamerules_int("CHalfLifeMultiplay", "m_iSpawnPointCount_Terrorist", 0);
    set_gamerules_int("CHalfLifeMultiplay", "m_iSpawnPointCount_CT", 32);
}

static OrpheuHookReturn:@CBasePlayer_EntSelectSpawnPoint(this)
{
    OrpheuSetReturn(ArrayGetCell(gSpawnPoints, random(ArraySize(gSpawnPoints))));

    return OrpheuSupercede;
}

static Array:GetCTSpawnPoints()
{
    new const Array:spawnPoints = ArrayCreate(1);
    new ent = MaxClients;
    while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "info_player_start")) > 0)
    {
        ArrayPushCell(spawnPoints, ent);
    }

    return spawnPoints;
}

static RemoveTSpawnPoints()
{
    new ent = MaxClients;
    while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "info_player_deathmatch")) > 0)
    {
        set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_KILLME);
    }
}
