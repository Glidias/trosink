package troshx.sos.core;

/**
 * Target zones cannot work in isolation but must work in relation to a BodyCHar
 * @author Glidias
 */
class TargetZone 
{
	public var name:String;  // the name of the zone
	public var parts:Array<Int>;  // the parts, according to ids
	public var partWeights:Array<Float>;  // distribution of parts for probability
	public var weightsTotal:Float = 0;
	public var description:String = "";
	
	public static function create(name:String, partWeights:Array<Float>, parts:Array<Int>, weightsTotal:Float=0, description:String=""):TargetZone {
		var zb:TargetZone = new TargetZone();
		zb.name = name;
		zb.parts = parts;
		zb.partWeights = partWeights;
		zb.description = description;
		
		zb.weightsTotal = weightsTotal;
		if (weightsTotal == 0) {
			zb.recalcWeightsTotal();
		}
		return zb;
	}

	
	public function recalcWeightsTotal():Void
	{
		var accum:Float = 0;
		var i:Int = partWeights.length;
		while ( --i > -1) {
			accum += partWeights[i];
		}
		weightsTotal = accum;
	}
	
	
	public function getBodyPart(floatRatio:Float):Int {
		floatRatio *= weightsTotal;
	
		var accum:Float = 0;
		var result:Int = 0;
		for (i in 0...partWeights.length)  {
			if ( floatRatio < accum ) {
				break;
			}
			accum += partWeights[i];
			result = i;
		}	
		return parts[result];
	}
	

	public function new() 
	{
		
	}
	

}