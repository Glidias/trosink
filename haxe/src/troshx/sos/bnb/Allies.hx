package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Allies extends Boon {
	public function new() {
		super("Allies", [1, 5, 10]);
		clampRank = true;
		

		multipleTimes = BoonBane.TIMES_VARYING;
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BoonAssign {
		return new AlliesAssign();
	}
}

class AlliesAssign extends BoonAssign {  // todo: combination of ranks
	
	@:ui({minLength:1}) public var list:Array<String> = [""];
	@:ui({type:"textarea"}) public var notes:String;
	
	public function new() {
		super();
	}
	
	override public function getQty():Int {
		return list.length;
	}
	
	override public function getCost(rank:Int):Int {
		return boon.costs[0] * list.length;
	}
}