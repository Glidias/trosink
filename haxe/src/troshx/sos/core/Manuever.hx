package troshx.sos.core;
import troshx.sos.events.SOSEvent;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Manuever 
{
	
	public var id:String;
	public var name:String;
	public var tn:Int = 7;
	public function _tn(val:Int):Int {
		tn = val;
		return this;
	}
	
	public var cost:Int = 0;
	public var costFunc:CharSheet->Array<Int>->Bool;
	public var costFuncInputs:Int = 0;
	public function _costs(cost:Int, costFunc:CharSheet->Array<Int>->Bool=null, costFuncInputs:Int=0):Manuever {
		this.cost = cost;
		this.costFunc = costFunc;
		this.costFuncInputs = costFuncInputs;
		return this;
	}
	
	public var types:Int = 0;
	public static inline var TYPE_NONE:Int = 0;
	public static inline var TYPE_DEFENSIVE:Int = 1;
	public static inline var TYPE_OFFENSIVE:Int = 2;
	public static inline var TYPE_BOTH:Int = (TYPE_DEFENSIVE | TYPE_OFFENSIVE);
	public static inline var TYPE_MOVEMENT:Int = 4;
	public static inline var TYPE_TRANSFORMATION:Int = 8;
	public static inline var TYPE_INITIATIVE:Int = 16;
	public static inline var TYPE_PASSING:Int = 32;
	public function _attackTypes(val:Int):Manuever {
		attackTypes = val;
		return this;
	}
	
	public var attackTypes:Int = 0;
	public static inline var ATTACK_TYPE_SWING:Int = 1;
	public static inline var ATTACK_TYPE_THRUST:Int = 2;
	public static inline var ATTACK_TYPE_BOTH:Int = (ATTACK_TYPE_SWING | ATTACK_TYPE_THRUST);
	public function _attackTypes(val:Int):Manuever {
		attackTypes = val;
		return this;
	}
	
	public var requisites:Int = 0;
	public static inline var REQ_WEAPON:Int = 1;
	public static inline var REQ_SHIELD:Int = 2;
	public static inline var REQ_UNARMED:Int = 4;
	public static inline var REQ_STUFF:Int = 8;
	public var requisiteFunc:CharSheet->Int->Bool;
	public function _requisite(val:Int, func:CharSheet->Int->Bool = null):Manuever {
		requisites = val;
		requisiteFunc = func;
		return this;
	}
	
	public var superiorManuever:CharSheet->SOSEvent->Manuever;
	
	public var shooting:Bool = false;
	public var advanced:Bool = false;
	
	public var tags:Int = 0;
	public static inline var TAG_CROSS_FIGHTING:Int = (1 << 0);
	public static inline var TAG_GRAPPLE:Int = (1 << 1);
	public static inline var TAG_CLINCHING:Int = (1 << 2);
	public static inline var TAG_PUSH:Int = (1 << 3);
	public static inline var TAG_GRAB:Int = (1 << 4);
	
	public static inline var TAG_BASH:Int = (1 << 5);
	public static inline var TAG_PARRY:Int = (1 << 6);
	public static inline var TAG_VOID:Int = (1 << 7);
	public static inline var TAG_BLOCK:Int = (1 << 8);
	public function _tags(val:Int):Manuever {
		tags = val;
		return this;
	}
	
	public var usingHands:Int = 0;
	public static inline var HANDS_NONE:Int = 0;
	public static inline var HANDS_MASTER:Int = 1; 
	public static inline var HANDS_SECONDARY:Int = 2;
	public static inline var HANDS_BOTH:Int = 3;  // a union mask of 1|2
	public function _usingHands(val:Int):Manuever {
		usingHands = val;
		return this;
	}
	
	//public var requiredLevel:Int;
	//public var spamPenalty:Int;
	//public var spamIndividualOnly:Bool;
	//public var customRange:Int;
	//public var customMinRange:Int;
	//public var regionMask:Int;
	//public var offHanded:Bool;
	
	//public var manueverType:Int;
	//public static inline var MANUEVER_TYPE_MELEE:Int = 0;
	//public static inline var MANUEVER_TYPE_RANGED:Int = 1;
	
	/*
	public var evasive:Int;
	public static inline var EVASIVE_TRUE:Int = 1;
	public static inline var EVASIVE_NO_INITAITIVE:Int = 2;
	public static inline var EVASIVE_NO_INITAITIVE_TARGET:Int = 4;
	public static inline var EVASIVE_UNTARGET_FROM_ENEMY:Int = 8;
	public static inline var EVASIVE_UNTARGET:Int = 16;
	public static inline var EVASIVE_NO_INITAITIVE_MUTUAL:Int = (EVASIVE_NO_INITAITIVE|EVASIVE_NO_INITAITIVE_TARGET);
	public static inline var EVASIVE_UNTARGET_MUTUAL:Int = (EVASIVE_UNTARGET | EVASIVE_UNTARGET_FROM_ENEMY);
	public function gotResolveEvasive():Bool {
		return (evasive & ~EVASIVE_TRUE) != 0;
	}
	*/
	
	/*
	public var damageType:Int;
	public static inline var DAMAGE_TYPE_NONE:Int = 0;
	public static inline var DAMAGE_TYPE_CUTTING:Int =1;
	public static inline var DAMAGE_TYPE_PUNCTURING:Int = 2;  // used to denote "true" thrusting weapons
	public static inline var DAMAGE_TYPE_BLUDGEONING:Int = 3;
	*/

	

	public function new() 
	{
		
	}
	
}