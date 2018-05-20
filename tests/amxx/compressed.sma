#pragma compress 1
#include <amxmodx>

public plugin_init() 
{
	register_plugin( "Compressed output" , "1.0" , "Someone" )
}

public client_putinserver( id )
{
	console_print( id , "Hi %d" , id )
}
