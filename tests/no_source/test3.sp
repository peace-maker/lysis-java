#pragma semicolon 0

#define PLUGIN_AUTHOR "KK"
#define PLUGIN_VERSION "0.00"

public Plugin:myinfo = 
{
	name = "", 
	author = PLUGIN_AUTHOR, 
	description = "", 
	version = PLUGIN_VERSION, 
	url = ""
};
#include <sourcemod>
#include <socket>

public OnGameFrame()
{
	static k;
	if(k!= 0) k ++;
	else k --;
}