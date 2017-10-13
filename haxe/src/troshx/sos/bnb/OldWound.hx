package troshx.sos.bnb;
import troshx.sos.bnb.OldWound.OldWoundAssign;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.HitLocation;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class OldWound extends Bane
{

	public function new() 
	{
		super("Old Wound", [1]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		multipleTimes = BoonBane.TIMES_VARYING;  // varies based on body
	}
	
	override function getEmptyAssignInstance(sheet:CharSheet):OldWoundAssign {
		return new OldWoundAssign(sheet);
	}
	
}

class OldWoundAssign extends BaneAssign {
	
	@:ui({type:"HitLocationMultiSelector", body:char.body, validateOptionFunc:isValidUILocation}) public var hitLocations:Int  = 0;
	//public var hitLocations:Array<String> = [];
	
	
	var char:CharSheet;
	
	public function new(char:CharSheet) {
		super();
		this.char = char;
	}
	
	override public function getCost(rank:Int):Int {
		return super.getCost(rank) * getQty();
	}
	
	function isValidUILocation(i:Int):Bool {
		return ( (1<< i) & permaMask)==0;
	}
	
	public var permaMask:Int = 0;
	
	public function inflictRandom():OldWoundAssign {  // done for char gen only
		var i = char.body.hitLocations.length;
		var selectArr:Array<Int> = [];
		while (--i > -1) {
			if ( ((1 << i) & hitLocations) == 0 ) {
				selectArr.push( (1 << i) );
			}
		}
		if (selectArr.length > 0) {
			i = selectArr[ Std.int(Math.random() * selectArr.length) ];
			hitLocations |= i;
			permaMask |= i;
		}
		return this;
	}
	
	public function mergeWith(other:OldWoundAssign):Void {
		hitLocations |= other.hitLocations;
		discount = super.getCost(rank) * countMask(permaMask);
	}
	
	override public function getQty():Int {
		return countMask(hitLocations);
	}
	
	inline function countMask(msk:Int):Int {
		var i = char.body.hitLocations.length;
		var qty:Int = 0;
		while (--i > -1) {
			if ( ((1 << i) & msk) != 0 ) {
				qty++;
			}
		}
		return qty;
	}
	
	override public function isValid():Bool {
		return hitLocations != 0;
		//return hitLocations.length > 0;
	}
}

