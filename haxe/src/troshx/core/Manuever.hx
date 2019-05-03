package troshx.core;
import haxe.Constraints.Function;
import troshx.components.FightState.ManueverDeclare;
import troshx.core.BodyChar;

/**
 * depcreated
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

	
	public var devTempDisabled:Bool;  // temporary dev flag to disable currently WIP manuvers.
	public var customDamageModiferMethod:Function;
	public var customRequirements:Array<Function>;
	
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
		evasive = 0;
		manueverType = MANUEVER_TYPE_MELEE;
	}
	
	public function isDefensiveOffHanded():Bool {  // not too sure about this logic
		return (attackTypes == DEFEND_TYPE_OFFHAND || offHanded); 
	}
	
	public static inline function isThrustingMotion(targetzone:Int, toBody:BodyChar):Bool {
		return targetzone >= toBody.thrustStartIndex;
	}
	
	
	public function _dmgType(val:Int):Manuever {
		damageType = val;
		return this;
	}
	
	/*
	public function _req(val:Int):Manuever {
		requirements = val;
		return this;
	}
	*/
	
	public function _offHanded(val:Bool):Manuever {
		offHanded = val;
		return this;
	}
	
	public function _evasive(val:Int):Manuever {
		evasive = val | EVASIVE_TRUE;
		return this;
	}
	
	public function _tn(val:Int):Manuever {
		defaultTN = val;
		return this;
	}
	public function _atkTypes(val:UInt):Manuever {
		attackTypes = val;
		return this;
	}
	public function _range(val:Int):Manuever {
		customRange = val;
		return this;
	}
	public function _rangeMin(val:Int):Manuever {
		customMinRange = val;
		return this;
	}
	
	public function _lev(val:Int):Manuever {
		requiredLevel = val;
		return this;
	}
	public function _spamPenalize(val:Int, spamIndividualOnly:Bool=false):Manuever {
		spamPenalty = val;
		this.spamIndividualOnly = spamIndividualOnly;
		return this;
		
	}
	public function _stanceModifier(val:Int):Manuever {
		stanceModifier = val;
		return this;
	}
	
	public function _regions(val:UInt):Manuever {
		regionMask  = val;
		return this;
	}
	
	// custom method(s) to filter the manuever
	public function _customRequire(requirements:Array<Function>=null):Manuever {
		customRequirements = requirements;
		
		if (requirements == null) devTempDisabled = true;  // not yet done...so
		
		return this;
	}
	

	public function _customPreResolve():Manuever {  // allows for pausing before resolution of maneuever for player to make decision
		devTempDisabled = true;
		return this;
	}
	
	
	public function _customPostResolve():Manuever {    // allows for pausing after resolution of maneuever for player to make decision
		devTempDisabled = true;
		return this;
	}

	
	// custom method(s) for resolving a given roll...to determine whether a hit occurs or not, the results of cp, and the intiaitive gain/lost as a result
	public function _customResolve():Manuever {  
		devTempDisabled = true;
		return this;
	}
	
	// custom modifer method to determine amount of raw damage level dealt
	public function _customDamage(method:Function=null):Manuever {
		customDamageModiferMethod = method;
		return this;
	}
	
	
	
	// custom modifer method to determine reflex amount
	public function _customReflex():Manuever {
		
		return this;
	}
	
	// custom modifer method to determine range amount of weapon
	public function _customRange():Manuever {
		
		return this;
	}
	
	
	// custom method to control splitting of maneuvers (for composite manuevers)
	public function _customSplit():Manuever {
		devTempDisabled = true;
		return this;
	}
	
	public function isTypeAttacking():Bool 
	{
		return type == TYPE_OFFENSIVE;
	}
	
	
	
}