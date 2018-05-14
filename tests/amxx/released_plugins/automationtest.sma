#include <amxmodx>
#include <hamsandwich>

 #define PLUGIN    "Automaton"
#define AUTHOR    "Albernaz o Carniceiro Demoniaco"
#define VERSION    "1.0"

new HamHook:HamHookSpawn

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)                
    state unregistered;
}

public enableHam() <unregistered> state (HamHookSpawn = RegisterHam(Ham_Spawn,"player","playerSpawn") ) enabled;
public enableHam() <disabled> state (EnableHamForward(HamHookSpawn)) enabled;
public disableHam() <enabled> state (!DisableHamForward(HamHookSpawn)) disabled;
public enableHam() <> {}
public disableHam() <>{}

public playerSpawn(id)
{
    
}  