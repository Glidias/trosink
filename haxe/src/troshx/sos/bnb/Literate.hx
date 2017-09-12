package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Literate extends Boon
{
	
	public function new() 
	{
		super("Literate", [1]);
		multipleTimes = BoonBane.TIMES_VARYING;
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BoonAssign {
		return new LiterateAssign();
	}
	
}

class LiterateAssign extends BoonAssign {
	@:ui({label:"Known scripts", minLength:1}) public var scripts:Array<String> = [""];
	@:ui({type:"textarea"}) public var notes:String = "";
	
	public function new() {
		super();
	}
	
	override public function getQty():Int {
		return scripts.length;
	}
	
	override public function getCost():Int {
		return boon.costs[0] * scripts.length;
	}

}