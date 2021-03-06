package troshx.sos.core;
import troshx.core.IBodyChar;
import troshx.sos.core.Armor.AV3;
import troshx.util.LibUtil;

/**
 * Represents a specific character body type with all relavant damage tables under it
 * @author Glidias
 */
class BodyChar implements IBodyChar
{
	public var name(default,null):String;
	
	// Typically melee target zones
	public var targetZones(default,null):Array<TargetZone>;
	public var thrustStartIndex(default, null):Int; // at what index point along the targetZones does it consider it as thrusting zones?
	public var rearStartIndex(default, null):Int; //  at what index point along the hitLocations does it consider it as rear zones?
	
	// Missile-specific target hit locations
	public var missileHitLocations(default,null):Array<Int>;  // Random D10 roll index -> Hit Location
	
	// Damage tables of Hit Location Index -> Damage Level Index -> WoundDef
	//public var partsDamageCut:Array<Array<WoundDef>>;   
	//public var partsDamagePuncture:Array<Array<WoundDef>>;
	//public var partsDamageBludgeon:Array<Array<WoundDef>>;
	//public var partsDamageUnarmed:Array<Array<WoundDef>>;
	
	//public var fallingDamages:Array<FallingDamageDef>;  // Random D10 roll index -> FallingDamageDef
	//public var burnDamages:Array<WoundDef>;  //  Damage Level Index -> WoundDef
	//public var coldDamages:Array<WoundDef>;  //  Damage Level Index -> WoundDef
	
	
	public var hitLocationHash(default,null):Dynamic<Int> = null; // JS/Vue only the hash of hit location  from uids of given wounds for quick lookup of indices to hit Locations
	
	public var hitLocations(default,null):Array<HitLocation>; // list of indexed hit location name entries from highest to lowest for armor coverage/target-zone access
	
	// to be baked from thrustStartIndex
	public var swingMask(default,null):Int;
	public var thrustMask(default, null):Int;
	
	public function getNewHitLocationsFrontSlice():Array<HitLocation> {
		return hitLocations.slice(0, rearStartIndex);
	}
	
	public inline function isSwingingAll(mask:Int):Bool {
		return (mask & swingMask) == swingMask;
	}
	public inline function isThrustingAll(mask:Int):Bool {
		return (mask & thrustMask) == thrustMask;
	}
	
	public inline function isSwingingOnly(mask:Int):Bool {
		return mask == swingMask;
	}
	public inline function isThrustingOnly(mask:Int):Bool {
		return mask == thrustMask;
	}
	
	function new() 	{
		
	}
	
	public function getNewEmptyAvs():Dynamic<AV3> {
		var ch = hitLocations;
		var dyn:Dynamic<AV3> = {};
		//trace("Hit dummy set up...");
		for (i in 0...ch.length) {
			var h = ch[i];
			LibUtil.setField(dyn, h.id, { avp:0, avc:0, avb:0 }); 
		}
		return dyn;
	}
	public function getNewEmptyAvsWithVis():Dynamic<AV3> {
		var ch = hitLocations;
		var dyn:Dynamic<AV3> = {};
		//trace("Hit dummy set up...");
		for (i in 0...ch.length) {
			var h = ch[i];
			LibUtil.setField(dyn, h.id, { avp:0, avc:0, avb:0, vis:0, visArmor:null }); 
		}
		return dyn;
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
		
		thrustMask = 0;
		for ( i in thrustStartIndex...targetZones.length) {
			thrustMask |= (1 << i);
		}
		
		swingMask = 0;
		for ( i in 0...thrustStartIndex) {
			swingMask |= (1 << i);
		}
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
		bodyChar.targetZones = Humanoid.getNewTargetZones();
		bodyChar.hitLocations = Humanoid.getNewHitLocations();
		bodyChar.thrustStartIndex = Humanoid.thrustStartIndex;
		bodyChar.rearStartIndex = Humanoid.rearStartIndex;
		
		bodyChar.missileHitLocations = [-1, Humanoid.THRUST_HEAD, Humanoid.THRUST_CHEST,Humanoid.THRUST_CHEST, Humanoid.THRUST_BELLY, Humanoid.THRUST_GROIN, Humanoid.THRUST_UPPER_ARM, Humanoid.THRUST_LOWER_ARM, Humanoid.THRUST_UPPER_LEG, Humanoid.THRUST_LOWER_LEG ];
		
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
	
	public function getTargetZoneHitAreaMasks():Array<Int> {
		var masks:Array<Int> = [];
		for (i in 0...targetZones.length) {
			var t = targetZones[i];
			masks.push( t.getHitAreaMask() );
		}
		return masks;
	}

	public function getDescLabelTargetZone(zoneIndex:Int, thrustLabel:String="Thrust to", swingLabel:String = "Swing to", descOverwites:Array<String>=null):String {
		var isThrusting:Bool  = zoneIndex >= thrustStartIndex;
		var t = targetZones[zoneIndex];
		var defaultDesc = (isThrusting ? thrustLabel : swingLabel);
		return (t.description != ""  ? descOverwites != null && zoneIndex < descOverwites.length && descOverwites[zoneIndex] != null ? descOverwites[zoneIndex] : t.description + " to" : defaultDesc ) + " " +t.name;
	}
	
	
	public function getDescLabelsTargetZoneMask(mask:Int):Array<String> {
		var arr:Array<String> = [];
		for (i in 0...targetZones.length) {
			if ( ((1 << i) & mask) != 0 ) arr.push( getDescLabelTargetZone(i) );
		}
		return arr;
	}
	
	
	public function getTitleLabelsTargetZoneMask(mask:Int):Array<String> {
		var arr:Array<String> = [];
		for (i in 0...targetZones.length) {
			var t =  targetZones[i];
			if ( ((1 << i) & mask) != 0 ) arr.push( t.name + (t.description != "" ? " ("+t.description+")" : "" ) );
		}
		return arr;
	}
	
	public function describeTargetZones(mask:Int):String {
		var str:String = "";
		var swinging:Int = mask & swingMask;
		var thrusting:Int = mask & thrustMask;
		if (swinging == swingMask && thrusting == thrustMask) {
			return "all swinging and thrusting attacks";
		}
		if (swinging != 0) {
			if (swinging == swingMask) {
				str += "all Swinging attacks";
			}
			else {
				str += "Swinging attacks to the "+getTitleLabelsTargetZoneMask(swinging).join(", ");
			}
		}
		if (thrusting != 0) {
			if (swinging != 0) {
				str += " and ";
			}
			if (thrusting == thrustMask) {
				str += "all Thrusting attacks";
			}
			else {
				str += "Thrusting attacks to the "+getTitleLabelsTargetZoneMask(thrusting).join(", ");
			}
		}
		
		return str;
	}
	
	public function getLabelsHitLocationMask(mask:Int):Array<String> {
		var arr:Array<String> = [];
		for (i in 0...hitLocations.length) {
			if ( ((1 << i) & mask) != 0 ) arr.push( hitLocations[i].name );
		}
		return arr;
	}
	
	// For Armor (may refactor this to armor class)
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
	
	public function getHitLocationLabelFromId(id:String):String
	{
		var i:Int = LibUtil.field(hitLocationHash, id);
		if (i != null) {
			return hitLocations[i].name;
		}
		return null;
	}
	
	public function getHitLocationById(id:String):HitLocation
	{
		var i:Int = LibUtil.field(hitLocationHash, id);
		if (i != null) {
			return hitLocations[i];
		}
		return null;
	}
	
	public function gotSideWithId(locationId:String):Bool
	{
		var hitLoc:HitLocation =  getHitLocationById(locationId);
		return hitLoc != null && hitLoc.twoSided;
	}

	
}



// Defaults

class Humanoid implements IBodyHitZones {
	
	// Melee Target zones
	
	@:targetZone("Head", [3,2,2,3], [SHOULDER, LOWER_HEAD, FACE, UPPER_HEAD], 0, "Downward Swing") public static inline var SWING_DOWNWARD_HEAD = 0;
	@:targetZone("Head", [3,2,3,2], [CHEST, NECK, LOWER_HEAD, FACE], 0, "Upward Swing") public static inline var SWING_UPWARD_HEAD:Int = 1;
	@:targetZone("Neck", [3,3,2,2], [SHOULDER, NECK, LOWER_HEAD, FACE]) public static inline var SWING_NECK:Int = 2;
	@:targetZone("Torso", [3,4,3], [BELLY, SIDE, CHEST]) public static inline var SWING_TORSO:Int = 3;
	@:targetZone("Upper Arm", [3,4,3], [ELBOW, UPPER_ARM, SHOULDER]) public static inline var SWING_UPPER_ARM:Int = 4;
	@:targetZone("Lower Arm", [3,4,3], [HAND, FOREARM, ELBOW]) public static inline var SWING_LOWER_ARM:Int = 5;
	@:targetZone("Upper Leg", [3,4,3], [KNEE, THIGH, HIP]) public static inline var SWING_UPPER_LEG:Int = 6;
	@:targetZone("Lower Leg", [3,4,3], [FOOT, SHIN, KNEE]) public static inline var SWING_LOWER_LEG:Int = 7;
	@:targetZone("Groin", [3,4,3], [THIGH, GROIN, BELLY]) public static inline var SWING_GROIN:Int = 8;
	
	public static inline var thrustStartIndex:Int = 9;
	
	@:targetZone("Head", [3,4,3], [NECK, FACE, UPPER_HEAD]) public static inline var THRUST_HEAD:Int = 9;
	@:targetZone("Neck", [3,4,3], [CHEST, NECK, FACE]) public static inline var THRUST_NECK:Int = 10;
	@:targetZone("Chest", [3,4,2,1], [BELLY, CHEST, SHOULDER, NECK]) public static inline var THRUST_CHEST:Int = 11;
	@:targetZone("Belly", [1,1,5,3], [GROIN, HIP, SIDE, BELLY]) public static inline var THRUST_BELLY:Int = 12;
	@:targetZone("Upper Arm", [3,4,3], [ELBOW, UPPER_ARM, SHOULDER]) public static inline var THRUST_UPPER_ARM:Int = 13;
	@:targetZone("Lower Arm", [3,4,3], [HAND, FOREARM, ELBOW]) public static inline var THRUST_LOWER_ARM:Int = 14;
	@:targetZone("Groin", [3,4,3], [THIGH, GROIN, BELLY]) public static inline var THRUST_GROIN:Int = 15;
	@:targetZone("Upper Leg", [3,4,3], [KNEE, THIGH, HIP]) public static inline var THRUST_UPPER_LEG:Int = 16;
	@:targetZone("Lower Leg", [3,4,3], [FOOT, SHIN, KNEE]) public static inline var THRUST_LOWER_LEG:Int = 17;
	
	// Hit locations
	
	@:hitLocation public static inline var UPPER_HEAD:Int = 0;
	@:hitLocation public static inline var FACE:Int = 1;
	@:hitLocation public static inline var LOWER_HEAD:Int = 2;
	@:hitLocation public static inline var NECK:Int = 3;
	@:hitLocation("","",true) public static inline var SHOULDER:Int = 4;
	@:hitLocation public static inline var CHEST:Int = 5;
	@:hitLocation("","",true) public static inline var SIDE:Int = 6;
	@:hitLocation public static inline var BELLY:Int = 7;
	@:hitLocation("","",true) public static inline var HIP:Int = 8;
	@:hitLocation public static inline var GROIN:Int = 9;
	@:hitLocation("","",true) public static inline var THIGH:Int = 10;
	@:hitLocation("","",true) public static inline var KNEE:Int = 11;
	@:hitLocation("","",true) public static inline var SHIN:Int = 12;
	@:hitLocation("","",true) public static inline var FOOT:Int = 13;
	
	@:hitLocation("","",true) public static inline var UPPER_ARM:Int = 14;
	@:hitLocation("","",true) public static inline var ELBOW:Int = 15;
	@:hitLocation("","",true) public static inline var FOREARM:Int = 16;
	@:hitLocation("","",true) public static inline var HAND:Int = 17;
	
	public static inline var rearStartIndex:Int = 18;
	@:hitLocation public static inline var UPPER_BACK:Int = 18;
	@:hitLocation public static inline var LOWER_BACK:Int = 19;
	
	@:hitMask("Full Head") public static inline var FULL_HEAD:Int = (1 << UPPER_HEAD) | (1 << FACE) | (1 << LOWER_HEAD);
	@:hitMask("Full Torso") public static inline var FULL_TORSO:Int = (1 << CHEST) | (1 << SIDE) | (1 << HIP) | (1 << BELLY); //  | (1 << UPPER_BACK) | (1 << LOWER_BACK)
	
	@:hitMask("Full Leg") public static inline var FULL_LEG:Int = (1 << THIGH) | (1 << KNEE) | (1 << SHIN) | (1 << FOOT);
	@:hitMask("Full Arm") public static inline var FULL_ARM:Int = (1 << SHOULDER) |  (1 << UPPER_ARM) | (1 << ELBOW) | (1 << FOREARM) | (1 << HAND);
	@:hitMask("Front Only") public static inline var FRONT_ONLY:Int = (1 << FACE);
}

typedef FallingDamageDef = {
	
}


typedef WoundDef = {
	public var stun:Int;
	public var pain:Int;
	public var BL:Int;
}
