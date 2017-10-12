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
	
	@:ui({type:"HitLocationMultiSelector", body:char.body,  validateOptionFunc:isValidUILocation }) @:hitLocationMask  public var hitLocationsMinor:Int = 0;
	@:ui({type:"HitLocationMultiSelector", body:char.body,  validateOptionFunc:isValidUILocation2}) @:hitLocationMask  public var hitLocationsMajor:Int = 0;
	//public var hitLocationId:String = "";
	
	
	public function new(char:CharSheet) {
		super();
		this.char = char;
	}
	
	public var permaMask:Int = 0;
	public var permaMask2:Int = 0;
	
	function isValidUILocation(i:Int):Bool {
		return (i & permaMask)!=0;
	}
	
	function isValidUILocation2(i:Int):Bool {
		return (i & permaMask2)!=0;
	}
	
	override public function getCost(rank:Int):Int {
		return minorCount() * LastingPain.COST_MINOR +  majorCount() * LastingPain.COST_MAJOR;
	}
	
	public function inflictRandomMinor():LastingPainAssign {
		var i = char.body.hitLocations.length;
		var selectArr:Array<Int> = [];
		while (--i > -1) {
			if ( ((1 << i) & hitLocationsMinor) == 0 ) {
				selectArr.push( (1 << i) );
			}
		}
		if (selectArr.length > 0) {
			i = selectArr[ Std.int(Math.random() * selectArr.length) ];
			hitLocationsMinor |= i;
			permaMask |= i;
		}
		return this;
	}
	
	public function inflictRandomMajor():LastingPainAssign {
		var i = char.body.hitLocations.length;
		var selectArr:Array<Int> = [];
		while (--i > -1) {
			if ( ((1 << i) & hitLocationsMajor) == 0 ) {
				selectArr.push( (1 << i) );
			}
		}
		if (selectArr.length > 0) {
			i = selectArr[ Std.int(Math.random() * selectArr.length) ];
			hitLocationsMajor |= i;
			permaMask2 |= i;
		}
		return this;
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


