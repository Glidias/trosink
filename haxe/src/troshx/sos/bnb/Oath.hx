package troshx.sos.bnb;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Oath extends Bane {
	public function new() {
		super("Oath", [2]);
	}
	override function getEmptyAssignInstance(charSheet:CharSheet):OathAssign {
		return new OathAssign();
	}
}

class OathAssign extends BaneAssign {
	
	@:ui({min:2, max:10}) public var cost:Int = 2;
	@:ui({type:"textarea"}) public var notes:String = "";
	
	public function new() {
		super();
	}
	
	override public function getCost():Int {
		return cost;
	}
}