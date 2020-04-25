#include <sourcemod>

public OnPluginStart()
{
    new client;
    if (!IsClientInGame(client) || GetClientTeam(client) != 1) return;
    if (!IsClientInGame(client) || GetClientTeam(client) == 1) return;
    if (GetClientTeam(client) != 1) return;
}