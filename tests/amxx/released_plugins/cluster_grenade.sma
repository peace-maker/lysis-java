#include < amxmodx >
#include < amxmisc >
#include < engine >
#include < fun >

#define TE_EXPLOSION 3
#define TE_WORLDDECAL 116

#define CLUSTERS 5

#define MAX_CLUSTER_DAMAGE 20
#define CLUSTER_DAMAGE_RADIUS 300

#define MIN_FLY_DISTANCE 200
#define MAX_FLY_DISTANCE 400

#define UPWARD_ARC 200

#define SCORCH 47

new explosion1, explosion2, grenade[32], last
new bool:enabled = true
new bool:catchdeath = false

public death_msg() {
	if ( catchdeath ) {
		catchdeath = false
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public grenade_throw() {

	if ( get_msg_args() < 2 ) return PLUGIN_HANDLED_MAIN

	if ( get_msg_arg_int( 1 ) == 12 && get_msg_arg_int( 2 ) == 0 )
		add_grenade_owner( last )

	return PLUGIN_CONTINUE
}

public fire_in_the_hole( id, dest, ent ) {
	if ( get_msg_args() != 5 ) return PLUGIN_CONTINUE

	new temp[17]
	get_msg_arg_string( 5, temp, 17 )

	if ( equali( temp, "#Fire_in_the_hole" ) ) {
		new name[32]
		entity_get_string( ent, EV_SZ_netname, name, 32 )

		last = find_player( "a", name )
	}

	return PLUGIN_CONTINUE
}

public pfn_touch( ptr, ptd ) { 

	//Gets the indentifying strings of each entity
	new identify[15], compare[15], Float:origin[3]
	if ( ptr == 0 ) identify = "world"
	else entity_get_string( ptr, EV_SZ_classname, identify, 15 )
	if ( ptd == 0 ) compare = "world"
	else if ( is_valid_ent( ptd ) ) entity_get_string( ptd, EV_SZ_classname, compare, 15 )

	//Ensures that the grenade cluster argument is always the 'ptr'
	if ( ptr == 0 || equali( compare, "grenade_cluster" ) ) return PLUGIN_HANDLED

	//Checks to see if it is a grenade cluster hitting another object. If it is it explodes and deals damage
	if ( equali( identify, "grenade_cluster" ) ) {
		entity_get_vector( ptr, EV_VEC_origin, origin )

		//Deals radius damage to the spot of collision
		new player[32], players, location[3], origin2[3], distance, Float:multiplier, owner
		origin2[0] = floatround( origin[0] )
		origin2[1] = floatround( origin[1] )
		origin2[2] = floatround( origin[2] )

		owner = entity_get_edict( ptr, EV_ENT_owner )

		get_players( player, players, "a" )
		for ( new i = 0; i < players; i++ ) {
			get_user_origin( player[i], location )
			distance = get_distance( origin2, location )
			if ( distance < CLUSTER_DAMAGE_RADIUS ) {
				multiplier = floatdiv( float( CLUSTER_DAMAGE_RADIUS - distance ), float( CLUSTER_DAMAGE_RADIUS ) )
				deal_grenade_damage( player[i], owner, floatmul( multiplier, float( MAX_CLUSTER_DAMAGE ) ) )
			}
		}

		//Paints the explosion
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY ) 
		write_byte( TE_EXPLOSION ) 
		write_coord( floatround( origin[0] ) ) 
		write_coord( floatround( origin[1] ) ) 
		write_coord( floatround( origin[2] ) ) 
		write_short( explosion1 ) 
		write_byte( 50 ) 
		write_byte( 15 ) 
		write_byte( 0 )
		message_end() 

		message_begin( MSG_BROADCAST, SVC_TEMPENTITY ) 
		write_byte( TE_EXPLOSION ) 
		write_coord( floatround( origin[0] ) ) 
		write_coord( floatround( origin[1] ) ) 
		write_coord( floatround( origin[2] ) ) 
		write_short( explosion2 ) 
		write_byte( 50 ) 
		write_byte( 15 ) 
		write_byte( 0 )
		message_end() 

		//If the grenade hit the ground or a wall then this draws a land scar
		if ( ptd == 0 ) {
			message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
			write_byte( TE_WORLDDECAL )
			write_coord( floatround( origin[0] ) ) 
			write_coord( floatround( origin[1] ) ) 
			write_coord( floatround( origin[2] ) ) 
			write_byte( SCORCH )
			message_end()
		}

		remove_entity( ptr ) //Removes the grenade cluster so that it does not enter an infinite loop

		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public grenade_explosion() {
	if (get_msg_arg_int( 1 ) == 3 && get_msg_arg_int ( 6 ) == 25 && get_msg_arg_int ( 7 ) == 30 && enabled) {
		new pos[3]
		pos[0] = floatround( get_msg_arg_float( 2 ) )
		pos[1] = floatround( get_msg_arg_float( 3 ) )
		pos[2] = floatround( get_msg_arg_float( 4 ) )

		new cluster, Float:vAngle[3], Float:angles[3], Float:velocity[3], Rvelocity[3], Float:distance, Float:actualDistance, Float:multiplier

		new Float:origin[3] 
		origin[0] = float( pos[0] )
		origin[1] = float( pos[1] )
		origin[2] = float( pos[2] )

		new Float:minBox[3] = { -1.0, ... }
		new Float:maxBox[3] = { 1.0, ... }
		
		//This will launch the above specified number of clusters
		for (new i = 0; i < CLUSTERS; i++) {
			//Create a random direction for the cluster to fly
			velocity[0] = random_float( float( MIN_FLY_DISTANCE ), float( MAX_FLY_DISTANCE ) )
			if ( random_num( 0, 1 ) == 1 ) velocity[0] = floatmul( velocity[0], -1.0 )
			velocity[1] = random_float( float( MIN_FLY_DISTANCE ), float( MAX_FLY_DISTANCE ) )
			if ( random_num( 0, 1 ) == 1 ) velocity[1] = floatmul( velocity[1], -1.0 )
			velocity[2] = float( UPWARD_ARC )

			Rvelocity[0] = pos[0] + floatround( velocity[0] )
			Rvelocity[1] = pos[1] + floatround( velocity[1] )
			Rvelocity[2] = pos[2] + floatround( velocity[2] )

			//Create the distance the cluster will fly
			distance = random_float( float( MIN_FLY_DISTANCE ), float( MAX_FLY_DISTANCE ) )
			actualDistance = float( get_distance( pos, Rvelocity ) )
			multiplier = floatdiv( distance, actualDistance )
			

			velocity[0] = floatmul( velocity[0], multiplier )
			velocity[1] = floatmul( velocity[1], multiplier )
			velocity[2] = floatmul( velocity[2], multiplier )

			//Create the angles for the facing of the cluster. PS: I have no idea how to do the angle thing really. This is a blind attempt.
			vector_to_angle( velocity, angles )
			vector_to_angle( velocity, vAngle )

			//Create the entity of the cluster
			cluster = create_entity( "info_target" )

			//Set the identifying string of the cluster's entity
			entity_set_string( cluster, EV_SZ_classname, "grenade_cluster") 

			//Set the model for the cluster's entity
			entity_set_model( cluster, "models/grenade.mdl" ) 	

			//Set the bounds for the cluster's entity	
			entity_set_vector( cluster, EV_VEC_mins, minBox)
			entity_set_vector( cluster, EV_VEC_maxs, maxBox)

			//Set the origin for the cluster's entity (NOTE: The clusters will spawn in the same spot, but they will be set to ignore eachother
			entity_set_origin( cluster, origin )

			//Set the angles of the cluster's entity	
			entity_set_vector( cluster, EV_VEC_angles, angles )
			entity_set_vector( cluster, EV_VEC_v_angle, vAngle )

			//Set the behavior specific variables for the cluster's entity
			entity_set_int( cluster, EV_INT_movetype, 6 ) //Has gravity and registers collisions
			entity_set_int( cluster, EV_INT_solid, 1 ) //Collisions do not block

			//Record who the owner of this nade is
			entity_set_edict( cluster, EV_ENT_owner, get_grenade_owner() )

			//Make the cluster fly!
			entity_set_vector( cluster, EV_VEC_velocity, velocity ) 
		}
	}

	return PLUGIN_CONTINUE
}

public enable_cluster_grenade( id ) {
	new argument[1], number

	read_argv( 1, argument, 1 )
	number = str_to_num( argument )

	if ( number == 0 ) {
		enabled = false
	}
	if ( number == 1 ) {
		enabled =true
	}

	return PLUGIN_HANDLED
}

public plugin_init() {
	register_plugin( "Cluster Grenades", "1.0beta", "doomy" )

	register_concmd( "amx_cluster_grenade_enable", "enable_cluster_grenade", ADMIN_KICK, "Enable or disable cluster grenades (1 = enable, 0 = false)" )

	register_message( 23, "grenade_explosion" )
	register_message( 77, "fire_in_the_hole" )
	register_message( 83, "death_msg" )
	register_message( 99,"grenade_throw" )

	return PLUGIN_CONTINUE	
}

public plugin_precachce() {
	precache_sound( "sound/weapons/explode3.wav" )
	explosion1 = precache_model( "sprites/zerogxplode.spr" )
	explosion2 = precache_model( "sprites/explode1.spr" )
}

//MISCELLANEOUS FUNCTIONS

deal_grenade_damage( attacked, attacker, Float:damage ) {
	//DeathMsg 85 -1 BYTE : killer index BYTE : victim index STRING : weapon 
	if ( get_user_health( attacked ) - floatround( damage ) <= 0 ) {
		//Stops the default death message from being displayed
		catchdeath = true
		user_kill( attacked )
		
		//Displays who killed who
		message_begin( 2, 83 )
		write_byte( attacker )
		write_byte( attacked )
		write_byte( 0 ) //No idea what this does
		write_string( "grenade" )
		message_end()

		//Adds a frag to the killer
		set_user_frags( attacker, get_user_frags( attacker ) + 1 )
	}
	else
		set_user_health( attacked, get_user_health( attacked ) - floatround( damage ) )
}

add_grenade_owner( owner ) {
	for ( new i = 0; i < 32; i++ ) {
		if ( grenade[i] == 0 ) {
			grenade[i] = owner
			return
		}
	}
}

stock get_grenade_owner() {
	new which = grenade[0]
	for ( new i = 1; i < 32; i++ ) {
		grenade[i - 1] = grenade[i]
	}
	grenade[31] = 0

	return which
}