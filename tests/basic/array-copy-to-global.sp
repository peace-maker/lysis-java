#pragma semicolon 1;

#include <sourcemod>

new String:g_str[64];
new String:g_str2[64];
new String:g_mstr[2][64];
new String:g_mstr2[2][64];

public OnPluginStart()
{
    decl String:str[64], String:str2[64];
    static String:str3[64];
    str = "test";
    g_str = str;
    str2 = str;
    str3 = str;
    g_str2 = g_str;
    str3 = g_str;
    g_str2 = str3;
    g_mstr[1] = g_mstr2[0];
}