
#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_stocks>

#define PLUGIN	"Helmet Hit Sound"
#define AUTHOR	"tmen13"
#define VERSION	"1.0"

#define OFFSET_ARMORTYPE 112
#define fm_get_user_armor_type(%1) get_pdata_int(%1, OFFSET_ARMORTYPE)

new MAX_PLAYERS;

new const SOUND[] = "misc/helmet.wav";

public plugin_cfg()
{
	MAX_PLAYERS = get_maxplayers();
}
public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	RegisterHam(Ham_TakeDamage, "player", "playerTakeDamage");
}
public plugin_precache()
{
	precache_sound(SOUND)
}
public playerTakeDamage(victim, inflictor, attacker, Float:fDamage, bitDamage) 
{
	if( (1 <= victim <= MAX_PLAYERS) && (1 <= attacker <= MAX_PLAYERS) && is_user_connected(victim))
	{
		new gun,hitZone
		get_user_attacker(victim,gun,hitZone)
				
		if( (fm_get_user_armor_type(victim) & 2) && (hitZone == HIT_HEAD))
		{
			new Float:origin[3];
			pev(victim,pev_origin,origin);
			
			EF_EmitAmbientSound(0,origin,SOUND, 1.0, ATTN_NORM, 0 , PITCH_NORM);
		}
	}
}