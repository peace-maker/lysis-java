
   /* - - - - - - - - - - -

        AMX Mod X script.

          | Author  : Arkshine
          | Plugin  : Server Cvars Unlocker
          | Version : v1.0.1

        (!) Support : http://forums.alliedmods.net/showthread.php?t=120866

        This plugin is free software; you can redistribute it and/or modify it
        under the terms of the GNU General Public License as published by the
        Free Software Foundation; either version 2 of the License, or (at
        your option) any later version.

        This plugin is distributed in the hope that it will be useful, but
        WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
        General Public License for more details.

        You should have received a copy of the GNU General Public License
        along with this plugin; if not, write to the Free Software Foundation,
        Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

        ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~

        Description :
        - - - - - - -
            In CS there are some server cvars which are "locked", meaning there are
            a minimum and a maximum which can not be crossed.

            This plugin unlocks them by removing the hardcoded limitation.

            As side note there is still a limitation, the data type of the variable
            where is stored the value, used in some CS functions. But no fear, the
            type is a signed long which means the max value can be up to 2147483583.
            It's an high value which should be fairly enough.

            Basically, the minimum for all the following cvars is 0, and the maximum 2147483583.
            ( except mp_limitteams set to 31 )

            Multiplay cvars :

                mp_buytime*
                mp_c4timer*
                mp_freezetime*
                mp_limitteams
                mp_roundtime*
                mp_startmoney**

            Servers cvars :

                sv_accelerate
                sv_friction
                sv_stopspeed
                sv_restart
                sv_restartround

            *  The timer on the HUD can't show above 546 minutes. Higher value and you will see 00:00.
            ** The money on the HUD can't show above $999999.


        Requirement :
        - - - - - - -
            * CS 1.6 / CZ.
            * AMX Mod X 1.8.x or higher.
            * Orpheu 2.3 and higher.
            * Steam server.


        Command :
        - - - - -
            * scu_toggle <0|1> // Toggle the plugin state. Enable/disable properly the forward and memory patch.


        Changelog :
        - - - - - -
            v1.0.1 : [ 20 mar 2010 ]

                fixed : sv_accelerate/sv_friction/sv_stopspeed were resetted to their original value after using sv_restart[round].
                fixed : The signature in the ReadMultiplayCvars file was incorrect + another typo. (linux)

            v1.0.0 : [ 9 mar 2010 ]

                Initial release.

    - - - - - - - - - - - */


    #include <amxmodx>
    #include <amxmisc>
    #include <orpheu>
    #include <orpheu_memory>
    #include <orpheu_stocks>


    /* PLUGIN INFORMATIONS */

        new const pluginName   [] = "Server Cvars Unlocker";
        new const pluginVersion[] = "1.0.1";
        new const pluginAuhtor [] = "Arkshine";


    /* ORPHEU HOOK HANDLE */

        new OrpheuHook:handleHookReadMultiplayCvars;
        new OrpheuHook:handleHookCVarSetFloat;


    /* CONSTANTS */

        enum /* plugin state */
        {
            DISABLED = 0,
            ENABLED
        };


    /*  VARIABLES */

        new currentPluginState;


    public plugin_precache ()
    {
        register_plugin( pluginName, pluginVersion, pluginAuhtor );
        register_cvar( "server_cvars_unlocker", pluginVersion, FCVAR_SERVER | FCVAR_SPONLY );

        register_concmd( "scu_toggle", "ConsoleCommand_TogglePlugin", ADMIN_RCON, "<0|1> - Toggle plugin state" );

        /*
            | At map start, the value for these cvars are not the same as the original we know setted after.
            | Since these cvars are not written generally in server.cfg with the default value because
            | locked and thus not used, I prefer to prevent future questions about weird movements in game.
            | And I'm really lazy to make another signature just for that.
        */
        set_cvar_num( "sv_accelerate", 5 );
        set_cvar_num( "sv_stopspeed" , 75 );

        /*
            | Plugin is enabled by default.
        */
        state disabled;
        TogglePluginState( .stateWanted = ENABLED );
    }


    /**
     *  Command to toggle the plugin state,
     *  then to enable/disable properly the forwards used.
     *
     *  @param player       The player's index who use the command.
     *  @param level        The command access flags.
     *  @param cid          The command index.
     */
    public ConsoleCommand_TogglePlugin ( const player, const level, const cid )
    {
        if ( cmd_access( player, level, cid, 2 ) )
        {
            new newPluginState[ 2 ];
            read_argv( 1, newPluginState, charsmax( newPluginState ) );

            TogglePluginState( player, clamp( str_to_num( newPluginState ), DISABLED, ENABLED ) );
        }

        return PLUGIN_HANDLED;
    }


    /**
     *  Toggle the plugin state.
     *
     *  @param player         The player's index.
     *  @param stateWanted    The new state wanted.
     */
    TogglePluginState ( const player = 0, const stateWanted )
    {
        ( currentPluginState == stateWanted ) ?

            console_print( player, "^n[%s] %s", pluginName, stateWanted ? "Plugin already enabled!" : "Plugin already disabled!^n" ) :
            console_print( player, "^n[%s] %s", pluginName, stateWanted ? "Plugin is now enabled!"  : "Plugin is now disabled!^n"  );

        switch ( currentPluginState = stateWanted )
        {
            case DISABLED : DisablePlugin();
            case ENABLED  : EnablePlugin();
        }
    }


    /**
     *  Disable properly the plugin on map end.
     *
     *  The reason to do that is when you patch something into the memory
     *  it will be kept until hlds is shutdown to free the memory.
     *  If someone does a config by map the patch will be kept even if the plugin
     *  is unloaded, even after using restart command. So to avoid future complaints,
     *  we unpatch all at map end.
     */
    public plugin_end()
    {
        TogglePluginState( .stateWanted = DISABLED );
    }


    /**
     *  The plugin was disabled. A user has enabled the plugin with the command.
     *  Enable properly all the forwards and patch the memory.
     */
    public EnablePlugin () <> {}
    public EnablePlugin () <disabled>
    {
        /*
            | mp_c4timer, mp_freezetime, mp_roundtime, mp_limitteams
        */
        handleHookReadMultiplayCvars = OrpheuRegisterHook( OrpheuGetFunction( "ReadMultiplayCvars" ), "ReadMultiplayCvars", OrpheuHookPre );

        /*
            | sv_accelerate, sv_friction, sv_stopspeed
        */
        handleHookCVarSetFloat = OrpheuRegisterHook( OrpheuGetEngineFunction( "pfnCVarSetFloat", "CVarSetFloat" ), "CVarSetFloat", OrpheuHookPre );

        /*
            | mp_buytime, mp_starmoney
            | sv_accelerate, sv_friction, sv_stopspeed, sv_restart, sv_restartround
        */
        TogglePatchMemory();

        /*
            | Plugin is now enabled.
        */
        state enabled;
    }


    /**
     *  The plugin was enabled. A user has disabled the plugin with the command.
     *  Disable properly all the forwards and patch the memory.
     */
    public DisablePlugin () <> {}
    public DisablePlugin () <enabled>
    {
        /*
            | mp_c4timer, mp_freezetime, mp_roundtime, mp_limitteams
        */
        OrpheuUnregisterHook( handleHookReadMultiplayCvars );

        /*
            | sv_accelerate, sv_friction, sv_stopspeed
        */
        OrpheuUnregisterHook( handleHookCVarSetFloat );

        /*
            | mp_buytime, mp_starmoney
            | sv_accelerate, sv_friction, sv_stopspeed, sv_restart, sv_restartround
        */
        TogglePatchMemory();

        /*
            | Plugin is now disabled.
        */
        state disabled;
    }


    /**
     *  Read the multiplay cvars.
     *  ( mp_c4timer, mp_freezetime, mp_roundtime and mp_limitteams )
     *
     *  This function is called from CHalfLifeMultiplay::CHalfLifeMultiplay() (called at map start)
     *  and from CHalfLifeMultiplay::RestartRound().
     *
     *  This function basically checks for each cvars, the minimum/maximum and set the cvar/var if needed.
     *  At the start I've used the method like I do for the other cvars where I alter directly the value
     *  in the check/set. The problem was the data type of the check is a signed byte. It means you can
     *  not put a value higher than 127, which a pain when the set (cvar/var) is a signed long where you
     *  can go up to 2,147,483,647.
     *
     *  So, as alternative solution, we simply redo the function and blocking the original call then we
     *  change directly the value of the vars which are used in another functions. This way we can set
     *  a number > 127.
     */
    public OrpheuHookReturn:ReadMultiplayCvars ( const handleGameRules )
    {
        server_print( "^n[%s] Reading/setting multiplay cvars...^n", pluginName );

        new const cvarsName[][] =
        {
            "mp_roundtime",
            "mp_c4timer",
            "mp_freezetime",
            "mp_limitteams"
        };

        static cvarsHandle[ sizeof cvarsName ];
        static bool:cvarsHandleRetrieved;

        if ( !cvarsHandleRetrieved )
        {
            for ( new i = 0; i < sizeof cvarsName; i++ )
            {
                cvarsHandle[ i ] = get_cvar_pointer( cvarsName[ i ] );
            }

            cvarsHandleRetrieved = true;
        }

        const null          = 0;
        const maxSignedLong = 2147483583;
        const maxPlayers    = 32;

        enum CvarLimit { minimum, maximum, Float:seconds };

        new const entriesIdentifiers[ sizeof cvarsName ][] =
        {
            "roundTime@g_pGameRules" ,
            "c4Timer@g_pGameRules"   ,
            "freezeTime@g_pGameRules",
            "limitTeams@g_pGameRules"
        };

        new const any:entriesNewValues[ sizeof cvarsName ][ CvarLimit ] =
        {
            { null, maxSignedLong , 60.0 },
            { null, maxSignedLong , 1.0  },
            { null, maxSignedLong , 1.0  },
            { null, maxPlayers - 1, 1.0  }
        }

        for ( new cvar, bool:shouldSetCvar, value; cvar < sizeof cvarsName; cvar++ )
        {
            value = ClampOOB
            (
                floatround( get_pcvar_float( cvarsHandle[ cvar ] ) * entriesNewValues[ cvar ][ seconds ] ),
                entriesNewValues[ cvar ][ minimum ],
                entriesNewValues[ cvar ][ maximum ],
                shouldSetCvar
            );

            if ( shouldSetCvar )
            {
                set_pcvar_float( cvarsHandle[ cvar ], value / entriesNewValues[ cvar ][ seconds ] );
            }

            OrpheuMemorySetAtAddress( handleGameRules, entriesIdentifiers[ cvar ], 1, value );
            server_print( "^t[OK] %s %.1f", cvarsName[ cvar ], value / entriesNewValues[ cvar ][ seconds ] );
        }

        server_print( "^n^t* All multiplay cvars set properly.^n" );
        return OrpheuSupercede;
    }


    /**
     *  A value is going to be set into a server cvar.
     *
     *  Used to block the reset done when sv_restart[round] is triggered for the server cvars :
     *  sv_accelerate, sv_friction and sv_stopspeed.
     *  I've failed to create directly a memory patch in CHalfLifeMultiplay::Think(), so
     *  I hook directly the engine function CVarSetFloat() as alternative method.
     */
    public OrpheuHookReturn:CVarSetFloat ( const varName[], Float:value )
    {
        new const cvarsServerName[][] =
        {
            "sv_accelerate",
            "sv_friction",
            "sv_stopspeed"
        };

        static bool:cvarsHandleRetrieved;
        static Trie:handleTrieServerCvars;

        if ( !cvarsHandleRetrieved )
        {
            handleTrieServerCvars = TrieCreate();

            for ( new i = 0; i < sizeof cvarsServerName; i++ )
            {
                TrieSetCell( handleTrieServerCvars, cvarsServerName[ i ], true );
            }

            cvarsHandleRetrieved = true;
        }

        return TrieKeyExists( handleTrieServerCvars, varName ) ? OrpheuSupercede : OrpheuIgnored;
    }


    /**
     *  Alter the original memory.
     *
     *  Multiplay cvars ( mp_buytime, mp_startmoney ) :
     *
     *      We replace directly original values by new ones. Check, set vars and set cvars.
     *      We can do this way because data type is not a problem and there are severals
     *      functions to edit.
     *
     *  Server cvars ( sv_accelerate, sv_fricton and sv_stopspeed ) :
     *
     *      Another method. We nop totally all the intructions. We have to do that since the
     *      original check is to see only if the current cvar value is still equal to the default
     *      value. Brutal way but the most efficient.
     */
    TogglePatchMemory ()
    {

      /* MULTIPLAY CVARS */

        if ( currentPluginState == ENABLED )
        {
            server_print( "[%s] Applying multiplay cvars memory patches...^n", pluginName );
        }

        /*
            |  MP_BUYTIME :
            |  Amount of buy time in minutes for each round.
            |
            |  Minimum : (orig.) 0.25 -> (new) 0.0
         */

        const null = 0;
        const minOrigBuyTime = 15;

        PatchMe
        (
            "minBuyTime@CBasePlayer::CanPlayerBuy()#Check"  , minOrigBuyTime, null,
            "minBuyTime@CBasePlayer::CanPlayerBuy()#Set"    , minOrigBuyTime, null,
            "minBuyTime@CBasePlayer::CanPlayerBuy()#SetCvar", minOrigBuyTime / 60.0, float( null )
        );


        /*
            |  MP_STARTMONEY :
            |  Amount of money players start with.
            |
            |  Minimum : (orig.) 800   -> (new) 0
            |  Maximum : (orig.) 16000 -> (new) 2147483583
        */

        const minOrigStartMoney = 800;
        const maxOrigStartMoney = 16000;
        const maxSignedLong     = 2147483583;

        PatchMe
        (
            "minStartMoney@CheckStartMoney()#SetCvar"             , float( minOrigStartMoney ), float( null ),
            "maxStartMoney@CheckStartMoney()#SetCvar"             , float( maxOrigStartMoney ), float( maxSignedLong ),
            "minStartMoney@ClientPutInServer()#SetCvar"           , float( minOrigStartMoney ), float( null ),
            "maxStartMoney@ClientPutInServer()#SetCvar"           , float( maxOrigStartMoney ), float( maxSignedLong ),
            "minStartMoney@HandleMenu_ChooseTeam()#SetCvar"       , float( minOrigStartMoney ), float( null ),
            "maxStartMoney@HandleMenu_ChooseTeam()#SetCvar"       , float( maxOrigStartMoney ), float( maxSignedLong ),
            "minStartMoney@CheckStartMoney()#Check"               , minOrigStartMoney, null,
            "maxStartMoney@CheckStartMoney()#Check"               , maxOrigStartMoney, maxSignedLong,
            "minStartMoney@ClientPutInServer()#Check"             , minOrigStartMoney, null,
            "maxStartMoney@ClientPutInServer()#Check"             , maxOrigStartMoney, maxSignedLong,
            "maxStartMoney@HandleMenu_ChooseTeam()#Check"         , minOrigStartMoney, null,
            "maxStartMoney@HandleMenu_ChooseTeam()#Check"         , maxOrigStartMoney, maxSignedLong,
            "maxStartMoney@CBasePlayer::AddAccount()#Check"       , maxOrigStartMoney, maxSignedLong,
            "maxStartMoney@CBasePlayer::AddAccount()#Set"         , maxOrigStartMoney, maxSignedLong,
            "maxStartMoney@CBasePlayer::JoiningThink()#Check"     , maxOrigStartMoney, maxSignedLong,
            "maxStartMoney@CBasePlayer::JoiningThink()#Set"       , maxOrigStartMoney, maxSignedLong,
            "maxStartMoney@CBasePlayer::Reset()#Check"            , maxOrigStartMoney, maxSignedLong,
            "maxStartMoney@CBasePlayer::Reset()#Set"              , maxOrigStartMoney, maxSignedLong,
            "maxStartMoney@CHalfLifeTraining::PlayerThink()#Check", maxOrigStartMoney, maxSignedLong,
            "maxStartMoney@CHalfLifeTraining::PlayerThink()#Set"  , maxOrigStartMoney, maxSignedLong
        );


      /* SERVER CVARS */

        if ( currentPluginState == ENABLED )
        {
            server_print( "[%s] Applying server cvars memory patches...^n", pluginName );
        }

        /*
            | SV_ACCELERATE :
            | Sets the acceleration speed.
            |
            | Minimum : (orig.) 5.0 -> (new) 0.0
            | Maximum : (orig.) 5.0 -> (new) 2147483583.0


            | SV_FRICTION :
            | It controls the ground friction.
            |
            | Minimum : (orig.) 4.0 -> (new) 0.0
            | Maximum : (orig.) 4.0 -> (new) 2147483583.0


            | SV_STOPSPEED :
            | It sets the minimum stopping speed when on ground.
            |
            | Minimum : (orig.) 75.0 -> (new) 0.0
            | Maximum : (orig.) 75.0 -> (new) 2147483583.0


            | SV_RESTART / SV_RESTARTROUND :
            | Sets the amount of seconds before the server restarts the game.
            | This will reset all frags, scores, weapons and money to default.
            |
            | Maximum : (orig.) 60.0 -> (new) 2147483583.0
        */

        new bool:isLinuxServer = bool:is_linux_server();

        NopMe
        (
            /* amountBytesToNop */ ( isLinuxServer ) ? 202 : 115,
            /* startIdentifier  */ "serverCvars1@CHalfLifeMultiplay::Think()#StartChecks",
            /* dummyIdentifier  */ "serverCvars@CHalfLifeMultiplay::Think()#Dummy",

            /* amountBytesToNop */ ( isLinuxServer ) ? 10 : 14,
            /* startIdentifier  */ "serverCvar2@CHalfLifeMultiplay::Think()#StartCheck",
            /* dummyIdentifier  */ "serverCvars@CHalfLifeMultiplay::Think()#Dummy"
        );

    }


    /**
     *  Do the patch into the memory.
     *  The purpose is to replace an orginal value by a new.
     *
     *      - Retrieve the elements passed
     *      - Replace the old value by the new in the memory
     *
     *  @param ...      The memory identifier to know the data type and where to patch,
     *                  The original value used to revert the change if plugin is disabled,
     *                  The new value to replace if plugin is enabled.
     */
    PatchMe ( any:... )
    {
        enum Patch
        {
            memoryIdentifier[ 64 ],
            any:valueOriginal,
            any:valueToReplace
        };

        new data[ Patch ];
        new rowCount = numargs() / 3;
        new offsetsPatched;

        for ( new i = 0, c, j, row; i < rowCount; i++ )
        {
            /*
                | Retrieve the elements passed into the function.
            */
            row = i * 3;
            while ( ( c = getarg( row, j ) ) )  { data[ memoryIdentifier ][ j++ ] = c; }

            data[ memoryIdentifier ][ j++ ] = '^0';
            data[ valueOriginal  ] = getarg( row + 1 );
            data[ valueToReplace ] = getarg( row + 2 );

            /*
                | Time to apply the patch.
            */
            if ( currentPluginState == ENABLED )
            {
                if ( OrpheuMemorySet( data[ memoryIdentifier ], 1, data[ valueToReplace ] ) )
                {
                    server_print( "^t[OK] %s", data[ memoryIdentifier ] );
                    offsetsPatched++;
                }
                else
                {
                    server_print( "^t[NOT FOUND] %s", data[ memoryIdentifier ] );
                }
            }
            else
            {
                OrpheuMemorySet( data[ memoryIdentifier ], 1, data[ valueOriginal ] );
            }

            j = 0;
        }

        if ( currentPluginState == ENABLED )
        {
            server_print( "^n^t* Total Patches : %d/%d^n", offsetsPatched, rowCount );
        }
    }


    /**
     *  Do the patch into the memory.
     *  The purpose is to nop few bytes. Nop = 0x90 = does nothing.
     *
     *      - Retrieve the elements passed
     *      - Retrieve the start address to nop
     *      - Backup the current bytes before patch
     *      - Apply the patch by nopping all the instructions
     *
     *  @param ...      The amount of bytes to nop,
     *                  The start identifier to know where to start,
     *                  The dummy identifier to know the data type.
     */
    NopMe ( ... )
    {
        enum Patch
        {
            amountBytesToNop,
            startIdentifier[ 64 ],
            dummyIdentifier[ 64 ]
        };

        new data[ Patch ];
        new rowCount = numargs() / 3;

        static Array:handleArrayIndex;
        new Array:handleArrayBytesToPatch;
        new Array:handleArrayBackupBytes;

        if ( handleArrayIndex == Invalid_Array )
        {
            FillDynamicArray( handleArrayIndex = ArrayCreate(), rowCount, Invalid_Array );
        }

        for ( new i = 0, c, j, k, row, startAddress, currentAddress; i < rowCount; i++ )
        {
            /*
                | Retrieve the elements passed into the function.
            */
            row = i * 3;
            data[ amountBytesToNop ] = getarg( row );

            while ( ( c = getarg( row + 1, j ) ) )  { data[ startIdentifier ][ j++ ] = c; }

            data[ startIdentifier ][ j++ ] = '^0';
            j = 0;

            while ( ( c = getarg( row + 2, j ) ) )  { data[ dummyIdentifier ][ j++ ] = c; }

            data[ dummyIdentifier ][ j++ ] = '^0';
            j = 0;

            /*
                | We fill the dynamic with 0x90 value to nop the memory.
            */
            FillDynamicArray( handleArrayBytesToPatch = ArrayCreate(), data[ amountBytesToNop ], 0x90 );

            /*
                | We retrieve the start address from the start identifer.
                | So, we will nop x bytes from this address.
            */
            OrpheuMemoryGet( data[ startIdentifier ], startAddress );
            currentAddress = startAddress;

            /*
                | We backup the original content so to restore the original state if plugin is disabled.
                | Dynamic array is used so to destroy easily the array if plugin is disabled.
            */
            if ( ( handleArrayBackupBytes = Array:ArrayGetCell( handleArrayIndex, i ) ) == Invalid_Array )
            {
                ArraySetCell( handleArrayIndex, i, handleArrayBackupBytes = ArrayCreate() );

                for ( k = 0; k < data[ amountBytesToNop ]; k++ )
                {
                    ArrayPushCell( handleArrayBackupBytes, OrpheuMemoryGetAtAddress( currentAddress, data[ dummyIdentifier ], currentAddress ) );
                    currentAddress++;
                }
            }

            currentAddress = startAddress;

            /*
                | Plugin is going to be disabled.
                | We copy the backup to restore the previous memory state.
            */
            if ( currentPluginState == DISABLED )
            {
                for ( k = 0; k < data[ amountBytesToNop ]; k++ )
                {
                    ArraySetCell( handleArrayBytesToPatch, k, ArrayGetCell( handleArrayBackupBytes, k ) );
                }
            }

            /*
                | Time to apply the patch.
            */
            for ( k = 0; k < data[ amountBytesToNop ]; k++ )
            {
                OrpheuMemorySetAtAddress( currentAddress, data[ dummyIdentifier ], 1, ArrayGetCell( handleArrayBytesToPatch, k ), currentAddress );
                currentAddress++;
            }

            if ( currentPluginState == ENABLED )
            {
                server_print( "^t* %d bytes were nopped successful.", data[ amountBytesToNop ] );
                ArrayDestroy( handleArrayBytesToPatch );
            }
        }

        if ( currentPluginState == DISABLED )
        {
            ArrayDestroyAll( handleArrayIndex );
        }
    }


    /**
     *  Destroy the main/subs dynamic arrays.
     *
     *  @param handleArray      The main dynamic array handle.
     */
    stock ArrayDestroyAll ( &Array:handleArray )
    {
        new size = ArraySize( handleArray );
        new Array:handleSubArray;

        for ( new i = 0; i < size; i++ )
        {
            handleSubArray = Array:ArrayGetCell( handleArray, i );
            ArrayDestroy( handleSubArray );
        }

        ArrayDestroy( handleArray );
    }


    /**
     *  Fill a dynamic array with a specified value.
     *
     *  @param handleArray      The dynamic array handle to modify.
     *  @param size             The number of entries we want to push.
     *  @param value            Thee value to be stored.
     */
    stock FillDynamicArray ( const Array:handleArray, const size, const any:value )
    {
        for ( new i = 0; i < size; i++ )
        {
            ArrayPushCell( handleArray, value );
        }
    }


    /**
     *  Check if a value is in the limit provided.
     *  The same then clamp(), except we add a var to know if value was
     *  out of the limit.
     *
     *  @param value        The value which needs to be check.
     *  @param minimum      The minimum value to not go below.
     *  @param maximum      The maximum value to not go over.
     *  @param wasOOB       To know if the value was out of bound.
     *  @return             The clamped value.
     */
    stock ClampOOB ( value, const minimum, const maximum, &bool:wasOOB )
    {
        wasOOB = false;

        if ( value < minimum )
        {
            value  = minimum;
            wasOOB = true;
        }
        else if ( value > maximum )
        {
            value  = maximum;
            wasOOB = true;
        }

        return value;
    }
