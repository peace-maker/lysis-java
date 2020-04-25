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
