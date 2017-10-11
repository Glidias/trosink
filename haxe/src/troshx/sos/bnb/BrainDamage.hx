package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class BrainDamage extends Bane {
	public function new() {
		super("Brain Damage", [4,8]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		multipleTimes = BoonBane.TIMES_VARYING;	
		this.clampRank = true;
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BaneAssign {
		return  new BrainDamageAssign(charSheet);
	}
}

class BrainDamageAssign extends BaneAssign {
	var char:CharSheet;
	
	@:ui({label:"Trigger Brain Damage (4)", type:"ButtonCounter", callback:callbackUITrigger, preventDefault:true }) var count1:Int = 0;
	@:ui({label:"Trigger Brain Damage (8)", type:"ButtonCounter", callback:callbackUITrigger, preventDefault:true }) var count2:Int = 0;

	
	public function new(char:CharSheet) {
		super();
		this.char = char;
	}
	
	function callbackUITrigger(obj:Dynamic, prop:String):Void {
		execute(prop == "count1" ? 0 : 1);
	}
	
	public function execute(indexRank:Int):Void {
		if (indexRank == 0) {
			count1++;
		}
		else {
			count2++;
		}
		
	}
	
	override function getCost(rank:Int):Int {
		return count1 * 4 + count2 * 8;
	}
	
	
	
}


