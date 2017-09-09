package troshx.sos.core;
import troshx.util.LibUtil;

/**
 * Represents a specific character body type with all relavant damage tables under it
 * @author Glidias
 */
class BodyChar
{
	public var name:String;
	
	// Typically melee target zones
	public var targetZones:Array<TargetZone>;
	public var thrustStartIndex:Int; // at what index point along the targetZones does it consider it as thrusting zones?
	
	// Missile-specific target hit locations
	public var missileHitLocations:Array<Int>;  // Random D10 roll index -> Hit Location
	
	// Damage tables of Hit Location Index -> Damage Level Index -> WoundDef
	//public var partsDamageCut:Array<Array<WoundDef>>;   
	//public var partsDamagePuncture:Array<Array<WoundDef>>;
	//public var partsDamageBludgeon:Array<Array<WoundDef>>;
	//public var partsDamageUnarmed:Array<Array<WoundDef>>;
	
	//public var fallingDamages:Array<FallingDamageDef>;  // Random D10 roll index -> FallingDamageDef
	//public var burnDamages:Array<WoundDef>;  //  Damage Level Index -> WoundDef
	//public var coldDamages:Array<WoundDef>;  //  Damage Level Index -> WoundDef
	
	
	public var hitLocationHash:Dynamic<Int> = null; // JS/Vue only the hash of hit location  from uids of given wounds for quick lookup of indices to hit Locations
	
	public var hitLocations:Array<HitLocation>; // list of indexed hit location name entries from highest to lowest for armor coverage/target-zone access
	
	function new() 	{
		
	}
	
	public inline function isThrusting(targetZone:Int):Bool {
		return targetZone >= thrustStartIndex;
	}
	

	// Imperative update call after making all necessary changes to this instance
	public function bake():Void { 
		var obj:Dynamic<Int> = {};
		for ( i in 0...hitLocations.length) {
			LibUtil.setField( obj, hitLocations[i].uid, i);
		}
		hitLocationHash = obj;
	}
	
	
	// The default singleton instance setup of standard Humanoid body type
	static var DEFAULT:BodyChar;
	public static function getInstance():BodyChar {
		return (DEFAULT != null ? DEFAULT : DEFAULT = getNewDefaultInstance());
	}
	
	public static function getNewDefaultInstance():BodyChar {
		var bodyChar:BodyChar = new BodyChar();
		bodyChar.name = "Humanoid";
		
		// this shoudl be factored into the IBodyHitZones macro
		bodyChar.targetZones = [];
		bodyChar.hitLocations = [];
		bodyChar.thrustStartIndex = Humanoid.thrustStartIndex;
		
		// todo; remaining damage tables for actual game.
		bodyChar.missileHitLocations = [];
		
		bodyChar.bake();
		return bodyChar;
	}
	
	public static function createBlankInstance():BodyChar {  // for homebrews blank forms
		var bodyChar:BodyChar = new BodyChar();
		bodyChar.name = "";
		bodyChar.targetZones = [];
		bodyChar.missileHitLocations = [];
		bodyChar.hitLocations = [];
		bodyChar.thrustStartIndex = 0;
		return bodyChar;
	}
	
	public static function createEmptyInstance():BodyChar { // for any instantations
		return new BodyChar();
	}
	
	
	// For Armor
	public function pushHitLocationNamesToStrArrByMask(arr:Array<String>, mask:Int):Void {
		for (i in 0...hitLocations.length) {
			if ( (mask & (1 << i)) != 0) {
				arr.push(hitLocations[i].name);
			}
		}
	}
	
	public function pushArmorCoverageLabelsTo(coverage:Dynamic<Int>, arr:Array<String>) 
	{
		for (f in Reflect.fields(hitLocationHash)) {
			
			var h:HitLocation = hitLocations[LibUtil.field(hitLocationHash, f)];
			var f = LibUtil.field(coverage, f);
			arr.push( h.name +  ((f & Armor.WEAK_SPOT) != 0 ? Armor.WEAK_SPOT_SYMBOL : "") + ((f & Armor.HALF) != 0 ? "*" : "") ); 
		}
	}

	
}

class Humanoid implements IBodyHitZones {
	
	// Melee Target zones
	
	@:targetZone("Head", [], [], 0, "Downward swing") public static inline var SWING_DOWNWARD_HEAD = 0;
	@:targetZone("Head", [], [], 0, "Upward swing") public static inline var SWING_UPWARD_HEAD:Int = 1;
	@:targetZone("Neck", [], []) public static inline var SWING_NECK:Int = 2;
	@:targetZone("Torso", [], []) public static inline var SWING_TORSO:Int = 3;
	@:targetZone("Upper Arm", [], []) public static inline var SWING_UPPER_ARM:Int = 4;
	@:targetZone("Lower Arm", [], []) public static inline var SWING_LOWER_ARM:Int = 5;
	@:targetZone("Upper Leg", [], []) public static inline var SWING_UPPER_LEG:Int = 6;
	@:targetZone("Lower Leg", [], []) public static inline var SWING_LOWER_LEG:Int = 7;
	@:targetZone("Groin", [], []) public static inline var SWING_GROIN:Int = 8;
	
	public static inline var thrustStartIndex:Int = 9;
	
	@:targetZone("Head", [], []) public static inline var THRUST_HEAD:Int = 9;
	@:targetZone("Neck", [], []) public static inline var THRUST_NECK:Int = 10;
	@:targetZone("Chest", [], []) public static inline var THRUST_CHEST:Int = 11;
	@:targetZone("Belly", [], []) public static inline var THRUST_BELLY:Int = 12;
	@:targetZone("Upper Arm", [], []) public static inline var THRUST_UPPER_ARM:Int = 13;
	@:targetZone("Lower Arm", [], []) public static inline var THRUST_LOWER_ARM:Int = 14;
	@:targetZone("Groin", [], []) public static inline var THRUST_GROIN:Int = 15;
	@:targetZone("Upper Leg", [], []) public static inline var THRUST_UPPER_LEG:Int = 16;
	@:targetZone("Lower Leg", [], []) public static inline var THRUST_LOWER_LEG:Int = 17;
	
	// Hit locations
	
	@:hitLocation public static inline var UPPER_HEAD:Int = 0;
	@:hitLocation public static inline var FACE:Int = 1;
	@:hitLocation public static inline var LOWER_HEAD:Int = 2;
	@:hitLocation public static inline var NECK:Int = 3;
	@:hitLocation public static inline var SHOULDER:Int = 4;
	@:hitLocation public static inline var CHEST:Int = 5;
	@:hitLocation("","",true) public static inline var SIDE:Int = 6;
	@:hitLocation public static inline var BELLY:Int = 7;
	@:hitLocation public static inline var HIP:Int = 8;
	@:hitLocation public static inline var GROIN:Int = 9;
	@:hitLocation("","",true) public static inline var THIGH:Int = 10;
	@:hitLocation("","",true) public static inline var KNEE:Int = 11;
	@:hitLocation("","",true) public static inline var SHIN:Int = 12;
	@:hitLocation("","",true) public static inline var FOOT:Int = 13;
	
	@:hitLocation("","",true) public static inline var UPPER_ARM:Int = 14;
	@:hitLocation("","",true) public static inline var ELBOW:Int = 15;
	@:hitLocation("","",true) public static inline var FOREARM:Int = 16;
	@:hitLocation("","",true) public static inline var HAND:Int = 17;
	
	@:hitLocation public static inline var UPPER_BACK:Int = 18;
	@:hitLocation public static inline var LOWER_BACK:Int = 19;
	
	@:hitMask("Full Arm") public static inline var FULL_ARM:Int = (1 << SHOULDER) |  (1 << UPPER_ARM) | (1 << ELBOW) | (1 << FOREARM) | (1 << HAND);	
	@:hitMask("Full Leg") public static inline var FULL_LEG:Int = (1 << THIGH) | (1 << KNEE) | (1 << SHIN) | (1 << FOOT);
	@:hitMask("Full Torso") public static inline var FULL_TORSO:Int = (1 << CHEST) | (1 << SIDE) | (1 << HIP) | (1 << BELLY);

	@:hitMask("Lower Arm") public static inline var LOWER_ARM:Int = (1 << ELBOW) |  (1 << FOREARM) | (1 << HAND);
	@:hitMask("Lower Leg") public static inline var LOWER_LEG:Int =  (1 << KNEE) | (1 << SHIN) | (1 << FOOT);

	
	
	
	
}

typedef FallingDamageDef = {
	
}


typedef WoundDef = {
	public var stun:Int;
	public var pain:Int;
	public var BL:Int;
}
