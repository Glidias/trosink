package troshx.core;

/**
 * ...
 * @author 
 */
typedef Wound = {
	@:optional var BL:Int;
	@:optional var KD:Int;
	@:optional var lev:Int;
	@:optional  var d:Int;
	@:optional  var ko:Int;
	var shock:Int;
	var shockWP:Int;
	var pain:Int;
	var painWP:Int;
}

typedef WoundLocation = {
	var id:String;
	var cut:Array<Wound>;
	var puncture:Array<Wound>;
	var bludgeon:Array<Wound>;
}




@:expose
class BodyChar
{
	public static var D_DESTROY_PART:Int = 1;
	public static var D_DEATH:Int = 2;

	public static function getEmptyBodyPartTypeDef():Wound {
		return {
			BL:0,
			KD:null,
			lev:0,
			d:0,
			ko:null,
			shock:0,
			shockWP:0,
			pain:0,
			painWP:0
		}
	}
	public static function getEmptyWoundLocation(id:String):WoundLocation {
		return {
			id:id,
			cut:[],
			puncture:[],
			bludgeon:[]
		}
	}
	
	public static function getCleanArrayOfWound(dirtyArr:Array<Wound>):Array<Wound> {
		var cleanArr:Array<Wound> = [];
		for (i in 0...dirtyArr.length) {
			cleanArr[i] = getBodyPartOf(dirtyArr[i]);
		}
		return cleanArr;
	}
	public static function getBodyPartOf(obj:Dynamic):Wound {
		var theBodyPart = getEmptyBodyPartTypeDef();
		for (f in  Reflect.fields(theBodyPart)) {
			if (Reflect.hasField(obj, f)) Reflect.setField( theBodyPart, f, Reflect.field(obj, f) );
		}
		return theBodyPart;
	}
	
	public function getAllWoundLocations():Array<WoundLocation> {
		var arr:Array<WoundLocation> = [];
		var partsMap:Map<String,Bool> = new Map();
		for (f in  Reflect.fields(partsCut)) {
			partsMap.set(f, true);
		}
		for (f in  Reflect.fields(partsBludgeon)) {
			partsMap.set(f, true);
		
		}
		for (f in  Reflect.fields(partsPuncture)) {
			partsMap.set(f, true);
			
		}
		for (f in  partsMap.keys()) {
			var woundLocation:WoundLocation = getEmptyWoundLocation(f);
			if (Reflect.hasField(partsCut, f)) woundLocation.cut = getCleanArrayOfWound(Reflect.field(partsCut, f));
			if (Reflect.hasField(partsPuncture, f))  woundLocation.puncture = getCleanArrayOfWound(Reflect.field(partsPuncture, f));
			if (Reflect.hasField(partsBludgeon, f))  woundLocation.bludgeon = getCleanArrayOfWound(Reflect.field(partsBludgeon, f));
			arr.push(woundLocation);
		}
		
		return arr;
	}
	


	//public function getViewModel():Array>
	


	public var zones:Array<ZoneBody>;   // zones for bladed attacks
	public var zonesB:Array<ZoneBody>;  // zones for blunt attacks
	public var thrustStartIndex:Int; // at what index attack zones become thrusting/spiking motions.
	public var centerOfMass:Array<Int>;  // the zone indices that indicate the center of mass of the given body for cutting
	public var centerOfMassT:Array<Int>;  // the zone indices that indicate the center of mass of the given body for thrusting
	
	// damage table for different body parts
	public var partsCut:Dynamic<Array<Wound>>;  
	public var partsPuncture:Dynamic<Array<Wound>>;
	public var partsBludgeon:Dynamic<Array<Wound>>;
	
	public static inline var WOUND_TYPE_CUT:Int = 1;
	public static inline var WOUND_TYPE_PIERCE:Int = 2;
	public static inline var WOUND_TYPE_BLUNT_TRAUMA:Int = 4;
	
	public static inline var WOUND_D_DESTROY:Int = 1;
	public static inline var WOUND_D_DEATH:Int = 2;
	
	public function new() 
	{
		zones = new Array<ZoneBody>();  // cutting and thrusting(puncturing) damage to body
		zones[0] = null;
		zonesB = new Array<ZoneBody>();  // bludgeonoing and spiking damage to body
		zones[1] = null;
	}
	
	public function getTargetZoneCost(index:Int):Int {
		return 0;
	}
	
}

