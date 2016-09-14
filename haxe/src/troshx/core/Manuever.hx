package troshx.core;
import troshx.core.BodyChar;

/**
 * ...
 * @author Glidias
 */
 
@:expose
class Manuever
{
	
	public var id:String;
	public var name:String;
	public var cost:Int;
	
	
	public var attackTypes:UInt;
	public var damageType:Int;
	public var defaultTN:Int;
	public var customRange:Int;
	public var customMinRange:Int;
	public var requiredLevel:Int;
	public var spamPenalty:Int;
	public var spamIndividualOnly:Bool;
	public var regionMask:UInt;
	public var offHanded:Bool;
	public var stanceModifier:Int;
	public var evasive:Bool;

	
	//public var devTempDisabled:Bool;  // temporary dev flag to disable currently WIP manuvers.
	//public var customDamageModiferMethod:Function;
	//public var customRequirements:Array;
	
	public var usingHands:Int;
	public static inline var MANUEVER_HAND_NONE:Int = 0;
	public static inline var MANUEVER_HAND_MASTER:Int = 1; 
	public static inline var MANUEVER_HAND_SECONDARY:Int = 2;
	public static inline var MANUEVER_HAND_BOTH:Int = 3;  // a union mask of 1|2
	
	public var manueverType:Int;
	public static inline var MANUEVER_TYPE_MELEE:Int = 0;
	public static inline var MANUEVER_TYPE_RANGED:Int = 1;

	public static inline var DAMAGE_TYPE_NONE:Int = 0;
	public static inline var DAMAGE_TYPE_CUTTING:Int =1;
	public static inline var DAMAGE_TYPE_PUNCTURING:Int = 2;  // used to denote "true" thrusting weapons
	public static inline var DAMAGE_TYPE_BLUDGEONING:Int = 3;
	
	public static inline var ATTACK_TYPE_STRIKE:UInt = 1;
	public static inline var ATTACK_TYPE_THRUST:UInt = 2;
	
	public static inline var DEFEND_TYPE_OFFHAND:UInt = 1;
	public static inline var DEFEND_TYPE_MASTERHAND:UInt = 2;
	
	public var type:Int = 0;
	public static inline var TYPE_NONE:Int = 0;
	public static inline var TYPE_DEFENSIVE:Int = 1;
	public static inline var TYPE_OFFENSIVE:Int = 2;

	public function new(id:String, name:String,  cost:Int = 0) {
		this.id = id;
		this.name = name;
		this.cost = cost;
		
		//requirements = 0;
		usingHands = 0;
		defaultTN = 0;
		customRange = 0;
		customMinRange = 0;
		stanceModifier = 2;
		attackTypes = ATTACK_TYPE_STRIKE | ATTACK_TYPE_THRUST;
		damageType = 0;
		requiredLevel = 0;
		spamPenalty = 0;
		spamIndividualOnly = false;
		regionMask = 0;
		offHanded = false;
		evasive = false;
		manueverType = MANUEVER_TYPE_MELEE;
	}
	
	public static inline function isThrustingMotion(targetzone:Int, toBody:BodyChar):Bool {
		return targetzone >= toBody.thrustStartIndex;
	}
	
	
	
}