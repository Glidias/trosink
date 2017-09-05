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
	//public var coldDamages:Array<coldDamage>;  //  Damage Level Index -> WoundDef
	
	
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
		
		bodyChar.targetZones = [];
		//bodyChar.thrustStartIndex =
		
		bodyChar.hitLocations = [];
		
		bodyChar.missileHitLocations = [];
		
		bodyChar.bake();
		return bodyChar;
	}
	
	public static function createEmptyInstance():BodyChar {
		var bodyChar:BodyChar = new BodyChar();
		bodyChar.name = "";
		bodyChar.targetZones = [];
		bodyChar.missileHitLocations = [];
		bodyChar.hitLocations = [];
		bodyChar.thrustStartIndex = 0;
		return bodyChar;
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

class Humanoid {
	
}

typedef FallingDamageDef = {
	
}


typedef WoundDef = {
	public var stun:Int;
	public var pain:Int;
	public var BL:Int;
}
