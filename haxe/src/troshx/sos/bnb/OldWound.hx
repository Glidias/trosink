package troshx.sos.bnb;
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
	
	@:ui({type:"HitLocationMultiSelector", body:char.body }) @:hitLocationMask public var hitLocations:Int  = 0;
	//public var hitLocations:Array<String> = [];
	
	
	var char:CharSheet;
	
	public function new(char:CharSheet) {
		super();
		this.char = char;
	}
	
	override public function getCost():Int {
		return super.getCost() * getQty();
	}
	
	override public function getQty():Int {
		var i = char.body.hitLocations.length;
		var qty:Int = 0;
		while (--i > -1) {
			if ( ((1 << i) & hitLocations) != 0 ) {
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

