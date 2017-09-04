package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class BodyChar
{
	public var targetZones:Array<TargetZone>;
	public var thrustStartIndex:Int;
	
	// damage table of different array levels for different body parts by Hit Location uid
	//public var partsDamageCut:Dynamic<WoundDef>;  
	//public var partsDamagePuncture:Dynamic<WoundDef>;
	//public var partsDamageBludgeon:Dynamic<WoundDef>;
	
	public var hitLocationsHash:Dynamic<HitLocation>; // the hash of hit location  from uids of given wounds
	public var hitLocations:Array<HitLocation>; // list of hit locations from highest to lowest for armor coverage/target-zone access

	public function new() 	{
		
	}
	
}

