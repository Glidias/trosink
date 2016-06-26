package troshx;

/**
 * ...
 * @author 
 */
class ZoneBody
{

	public var name:String;  // the name of the zone
	public var parts:Array<Dynamic>;  // the parts, according to ids
	public var partWeights:Array<Float>;  // distribution of parts for probability
	public var weightsTotal:Float = 0;
	
	public static function create(name:String, partWeights:Array<Float>, parts:Array<Dynamic>, weightsTotal:Float=0):ZoneBody {
		var zb:ZoneBody = new ZoneBody();
		zb.name = name;
		zb.parts = parts;
		zb.partWeights = partWeights;
		
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
	
	
	public function getBodyPart(floatRatio:Float):String {
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