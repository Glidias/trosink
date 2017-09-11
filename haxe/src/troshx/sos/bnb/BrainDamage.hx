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
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BaneAssign {
		return  new BrainDamageAssign();
	}
}

class BrainDamageAssign extends BaneAssign {
	public function new() {
		super();
	}
	
	override public function onInited(char:CharSheet):Void {
		//  TODO: after char sheet creation when finalising character..
	}
	
	override public function onFurtherAdded(char:CharSheet):Void {
		//  in-game logic once needed
	}
}


