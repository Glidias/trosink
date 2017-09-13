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
	

	public function new() 
	{
		super("Lasting Pain", [4, 8]);
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
	
	@:ui({type:"HitLocationMultiSelector", body:char.body }) @:hitLocationMask  public var hitLocations:Int;
	//public var hitLocationId:String = "";
	
	
	public function new(char:CharSheet) {
		super();
		this.char = char;
	}
	
	override public function getCost(rank:Int):Int {
		return super.getCost(rank) * getQty();
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
		return hitLocations != 0; // hitLocationId != null && hitLocationId != "";
	}
}


