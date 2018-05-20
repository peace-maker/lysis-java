package lysis.sourcepawn;

import lysis.lstructure.Tag;

public class OpcodeHelpers {
	public static SPOpcode ConditionToJump(SPOpcode spop, boolean onTrue) {
		switch (spop) {
		case sleq:
			return onTrue ? SPOpcode.jsleq : SPOpcode.jsgrtr;
		case sless:
			return onTrue ? SPOpcode.jsless : SPOpcode.jsgeq;
		case sgrtr:
			return onTrue ? SPOpcode.jsgrtr : SPOpcode.jsleq;
		case sgeq:
			return onTrue ? SPOpcode.jsgeq : SPOpcode.jsless;
		case eq:
			return onTrue ? SPOpcode.jeq : SPOpcode.jneq;
		case neq:
			return onTrue ? SPOpcode.jneq : SPOpcode.jeq;
		case not:
			return onTrue ? SPOpcode.jzer : SPOpcode.jnz;
		default:
			assert (false);
			break;
		}
		return spop;
	}

	public static boolean IsFunctionTag(Tag tag) {
		switch (tag.name()) {
		// Core
		case "Function":
			// clientprefs.inc
		case "CookieMenuHandler":
			// commandfilters.inc
		case "MultiTargetFilter":
			// console.inc
		case "SrvCmd":
		case "ConCmd":
		case "ConVarChanged":
		case "CommandListener":
		case "ConVarQueryFinished":
			// dbi.inc
		case "SQLTCallback":
			// events.inc
		case "EventHook":
			// functions.inc
		case "NativeCall":
			// logging.inc
		case "GameLogHook":
			// menus.inc
		case "MenuHandler":
		case "VoteHandler":
			// sdktools_entoutput.inc
		case "EntityOutput":
			// sdktools_sound.inc
		case "AmbientSHook":
		case "NormalSHook":
			// sdktools_tempents.inc
		case "TEHook":
			// sdktools_trace.inc
		case "TraceEntityFilter":
			// sorting.inc
		case "SortFunc1D":
		case "SortFunc2D":
		case "SortFuncADTArray":
			// textparse.inc
		case "SMC_ParseStart":
		case "SMC_ParseEnd":
		case "SMC_NewSection":
		case "SMC_KeyValue":
		case "SMC_EndSection":
		case "SMC_RawLine":
			// timers.inc
		case "Timer":
			// topmenus.inc
		case "TopMenuHandler":
			// usermessages.inc
		case "MsgHook":
		case "MsgPostHook":

			// Socket Extension
		case "SocketConnectCB":
		case "SocketIncomingCB":
		case "SocketReceiveCB":
		case "SocketSendqueueEmptyCB":
		case "SocketDisconnectCB":
		case "SocketErrorCB":
			// SDKHooks
		case "SDKHookCB":
			// SteamTools
		case "HTTPRequestComplete":
			// SendProxy
		case "SendProxyCallback":
		case "PropChangedCallback":
			// cURL
		case "CURL_OnComplete":
		case "CURL_OnSend":
		case "CURL_OnReceive":
		case "Openssl_Hash_Complete":
		case "CURL_Function_CB":
			// BZIP2
		case "BZ2Callback":
			// DHooks
		case "ListenCB":
		case "DHookRemovalCB":
		case "DHookCallback":
			// smlib
		case "EffectCallback":
		case "Entity_ChangeOverTimeCallback":
			// Sourceirc
		case "IRCCmd":
		case "IRCEvent":
			// tEasyFTP
		case "EasyFTP_FileUploaded":
			// Websockets
		case "WebsocketErrorCB":
		case "WebsocketCloseCB":
		case "WebsocketIncomingCB":
		case "WebsocketReceiveCB":
		case "WebsocketDisconnectCB":
		case "WebsocketReadyStateChangedCB":
			return true;
		}
		return false;
	}

	public static SPOpcode Invert(SPOpcode spop) {
		switch (spop) {
		case jsleq:
			return SPOpcode.jsgrtr;
		case jsless:
			return SPOpcode.jsgeq;
		case jsgrtr:
			return SPOpcode.jsleq;
		case jsgeq:
			return SPOpcode.jsless;
		case jeq:
			return SPOpcode.jneq;
		case jneq:
			return SPOpcode.jeq;
		case jnz:
			return SPOpcode.jzer;
		case jzer:
			return SPOpcode.jnz;
		case sleq:
			return SPOpcode.sgrtr;
		case sless:
			return SPOpcode.sgeq;
		case sgrtr:
			return SPOpcode.sleq;
		case sgeq:
			return SPOpcode.sless;
		case eq:
			return SPOpcode.neq;
		case neq:
			return SPOpcode.eq;
		default:
			assert (false);
			break;
		}
		return spop;
	}
}
