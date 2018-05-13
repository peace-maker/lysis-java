#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>

#define TID_RESTORE_ORIGIN 457547

new Float:_pg_ftmp
#define _Vec3ToAngles(%1,%2) _pg_ftmp = floatsqroot(%1[0]*%1[0] + %1[1]*%1[1]);\
    %2[1] = floatacos(%1[0]/_pg_ftmp, 1)*(1-2*_:(%1[1]<0));\
    %2[0] =-floatatan(%1[2]/_pg_ftmp, 1);\
    %2[2] = 0.0
    
#define _Vec3AddScalar(%1,%2) %1[0]+=%2;%1[1]+=%2;%1[2]+=%2
#define _Vec3MultScalar(%1,%2) %1[0]*=%2;%1[1]*=%2;%1[2]*=%2
#define _Vec3Set(%1,%2) %1[0]=%2[0];%1[1]=%2[1];%1[2]=%2[2]
#define _Vec3Add(%1,%2) %1[0]+=%2[0];%1[1]+=%2[1];%1[2]+=%2[2]    

#define _Set(%1,%2) %1|=1<<%2
#define _UnSet(%1,%2) %1&=~(1<<%2)
#define _Is(%1,%2) (%1&1<<%2)
new _human
new _alive

#define _IsPlayer(%1) (1<=%1<=g_max_players)


new g_max_players
new g_msg_saytext
new Float:g_t_origin[3]
new Float:g_b_origin[3]
new bool:g_valid_origin
new bool:g_ml


public plugin_init(){
    register_plugin("Replace Disconnected T", "1.5", "Sylwester")
    RegisterHam(Ham_Use, "func_button", "button_pushed", 1)
    RegisterHam(Ham_Spawn, "player", "Player_Spawn", 1)
    RegisterHam(Ham_Killed, "player", "Player_Killed", 1)
    g_max_players = get_maxplayers()
    g_msg_saytext = get_user_msgid("SayText")
    
    new path[128]
    get_datadir(path, 127)
    add(path, 127, "/lang/replace_disconnected_t.txt")
    if(file_exists(path)){
        register_dictionary("replace_disconnected_t.txt")
        g_ml = true
    }
}


public button_pushed(ent, idcaller, idactivator, use_type, Float:value){
    if(!_IsPlayer(idcaller) || !_Is(_alive, idcaller) || !pev_valid(ent) || cs_get_user_team(idcaller) != CS_TEAM_T)
        return
    new Float:ftmp[3]
    pev(ent, pev_mins, g_b_origin)
    pev(ent, pev_maxs, ftmp)

    _Vec3Add(g_b_origin, ftmp)
    _Vec3MultScalar(g_b_origin, 0.5) 

    pev(idcaller, pev_origin, g_t_origin)
    if(pev(idcaller, pev_flags) & FL_DUCKING)
        g_t_origin[2] += 19
    g_valid_origin = true
}


public Player_Killed(id){
    _UnSet(_alive, id)
}


public Player_Spawn(id){
    if(!is_user_alive(id))
        return
    _Set(_alive, id)
    if(cs_get_user_team(id) != CS_TEAM_T)
        return
    g_valid_origin = false
}


public client_putinserver(id){
    if(is_user_bot(id) || is_user_hltv(id)) 
        return
    _Set(_human, id)
}


public announce_t_change(newid, oldid){
    new msg[160], otname[32], ntname[32]
    get_user_name(oldid, otname, 31)
    get_user_name(newid, ntname, 31)
    if(!g_ml){
        formatex(msg, 159, "^3[ DeathRun ] ^4%s^1 has left the game. ^4%s^1 is now the terrorist.", otname, ntname)
        message_begin(MSG_ALL, g_msg_saytext, _, 0)
        write_byte(oldid)
        write_string(msg)
        message_end()    
        return
    }
    for(new i=1; i<=g_max_players; i++){
        if(!_Is(_human, i))
            continue
        formatex(msg, 159, "%L", i, "ANN_REPL_T", otname, ntname)         
        message_begin(MSG_ONE, g_msg_saytext, _, i)
        write_byte(oldid)
        write_string(msg)
        message_end()
    }
}


public client_disconnect(id){  
    _UnSet(_human, id)
    _UnSet(_alive, id)
    new players[32], pnum
    for(new i=1; i<=g_max_players; i++){
        if(!_Is(_human, i))
            continue
        if(cs_get_user_team(i) == CS_TEAM_T)
            return
        players[pnum++] = i
    }
    if(pnum<=0)
        return
    new new_terr = players[random(pnum)]
    cs_set_user_team(new_terr, CS_TEAM_T)

    announce_t_change(new_terr, id)

    if(!g_valid_origin){
        ExecuteHamB(Ham_CS_RoundRespawn, new_terr)
        return
    }
    ExecuteHamB(Ham_CS_RoundRespawn, new_terr)
    g_valid_origin = true
    new param[2]
    param[0] = new_terr
    param[1] = 10 //max teleport attempts
    restore_origin(param)
}


public restore_origin(param[]) {
    if(!g_valid_origin || --param[1]<0 || !_Is(_alive, param[0]))
        return
    new tr, Float:ftmp[3]
    _Vec3Set(ftmp, g_t_origin)
    
    //find vacant location
    for(new i=0; i<100; i++){      
        engfunc(EngFunc_TraceHull, ftmp, ftmp, 0, HULL_HUMAN, 0, tr)
        if(get_tr2(tr, TR_StartSolid) || get_tr2(tr, TR_AllSolid)){
            _Vec3AddScalar(ftmp, random_float(-10.0, 10.0))
            continue
        }   
        //check if new location is on the correct side of the wall
        engfunc(EngFunc_TraceLine, g_t_origin, ftmp, DONT_IGNORE_MONSTERS, 0, tr)
        new Float:fraction
        get_tr2(tr, TR_flFraction, fraction)
        if(fraction != 1.0){
            break
        }
        _Vec3Set(g_t_origin, ftmp)     
        
        set_pev(param[0], pev_origin, g_t_origin) //move player to vacant location
       
        //calculate angles
        _Vec3Set(ftmp, -g_t_origin)        
        _Vec3Add(ftmp, g_b_origin)
        _Vec3ToAngles(ftmp, ftmp)
        
        //aim at button
        set_pev(param[0], pev_angles, ftmp)
        set_pev(param[0], pev_fixangle, 1)
        return
    }
    set_task(0.1, "restore_origin", TID_RESTORE_ORIGIN+param[0], param, 2)
}
