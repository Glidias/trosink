package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Favor extends Boon {
	
	public function new() {
		super("Favor", [1, 3]);
		clampRank = true;
		multipleTimes = BoonBane.TIMES_VARYING;
		
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BoonAssign {
		return new FavorAssign();
	}
}


class FavorAssign extends BoonAssign { // todo: combination of ranks
	
	@:ui({minLength:1}) public var list:Array<String> = [""];
	@:ui({type:"textarea"}) public var notes:String = "";
	
	public function new() {
		super();
	}
	
	override public function getQty():Int {
		return list.length;
	}
	
	override public function getCost():Int {
		return boon.costs[0] * list.length;
	}
}