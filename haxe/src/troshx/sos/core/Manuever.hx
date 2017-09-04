package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Manuever 
{
	
	public var id:String
	public var name:String;
	public var cost:Int;
	public var defaultTN:Int;
		
	public var type:Int = 0;
	public static inline var TYPE_NONE:Int = 0;
	public static inline var TYPE_DEFENSIVE:Int = 1;
	public static inline var TYPE_OFFENSIVE:Int = 2;
	public static inline var TYPE_BOTH:Int = 4;
	
	public var attackTypes:Int;
	public static inline var ATTACK_TYPE_SWING:Int = 1;
	public static inline var ATTACK_TYPE_THRUST:Int = 2;
	
	public var usingHands:Int;
	public static inline var MANUEVER_HAND_NONE:Int = 0;
	public static inline var MANUEVER_HAND_MASTER:Int = 1; 
	public static inline var MANUEVER_HAND_SECONDARY:Int = 2;
	public static inline var MANUEVER_HAND_BOTH:Int = 3;  // a union mask of 1|2
	
	public var requiredLevel:Int;
	//public var spamPenalty:Int;
	//public var spamIndividualOnly:Bool;
	public var customRange:Int;
	public var customMinRange:Int;
	public var regionMask:Int;
	public var offHanded:Bool;
	
	public var manueverType:Int;
	public static inline var MANUEVER_TYPE_MELEE:Int = 0;
	public static inline var MANUEVER_TYPE_RANGED:Int = 1;
	
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