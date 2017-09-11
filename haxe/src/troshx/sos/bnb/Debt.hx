package troshx.sos.bnb;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.Money;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Debt extends Bane {
	public static var CASH_MULTIPLIERS(default, never):Array<Float> = [1, 1.5, 2 ];
	public function new() {
		super("Debt", [2, 4, 8]);
		
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):DebtAssign {
		return new DebtAssign();
	}
}

class DebtAssign extends BaneAssign {
	
	@:ui public var currentOwed:Money = new Money(); // currently, this is manual entry??
	
	public function new() {
		super();
	}
	
}



