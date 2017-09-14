package troshx.sos.bnb;
import troshx.sos.bnb.LastingPain.LastingPainAssign;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class LastingPain extends Bane
{
	public static inline var COST_MINOR:Int = 4;
	public static inline var COST_MAJOR:Int = 8;

	public function new() 
	{
		super("Lasting Pain", [COST_MINOR, COST_MAJOR]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		multipleTimes = BoonBane.TIMES_VARYING;
		clampRank = true;
	}
	override function getEmptyAssignInstance(charSheet:CharSheet):BaneAssign {
		return new LastingPainAssign(charSheet);
	}
}

class LastingPainAssign extends BaneAssign {
	var char:CharSheet;
	
	@:ui({type:"HitLocationMultiSelector", body:char.body }) @:hitLocationMask  public var hitLocationsMinor:Int = 0;
	@:ui({type:"HitLocationMultiSelector", body:char.body }) @:hitLocationMask  public var hitLocationsMajor:Int = 0;
	//public var hitLocationId:String = "";
	
	
	public function new(char:CharSheet) {
		super();
		this.char = char;
	}
	
	override public function getCost(rank:Int):Int {
		return minorCount() * LastingPain.COST_MINOR +  majorCount() * LastingPain.COST_MAJOR;
	}
	
	function minorCount():Int {
		var i = char.body.hitLocations.length;
	
		var qty:Int = 0;
		while (--i > -1) {
			if ( ((1 << i) & hitLocationsMinor) != 0 ) {
				qty++;
			}
		}
		return qty;
		
	}
	
	function majorCount():Int {
		var i = char.body.hitLocations.length;
		var qty:Int = 0;
		while (--i > -1) {
			if ( ((1 << i) & hitLocationsMajor) != 0 ) {
				qty++;
			}
		}
		return qty;
	}
	
	override public function getQty():Int {
	
		return minorCount() + majorCount();
	}
	
	override public function isValid():Bool {
		return hitLocationsMajor != 0 || hitLocationsMinor !=0; // hitLocationId != null && hitLocationId != "";
	}
}


