package troshx.sos.bnb;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.Money;

/**
 * ...
 * @author Glidias
 */
class Debt extends Bane {
	public static var CASH_MULTIPLIERS(default, never):Array<Float> = [1, 1.5, 2 ];
	public function new() {
		super("Debt", [2, 4, 8]);
		
	}
	
	override function getEmptyAssignInstance():DebtAssign {
		return new DebtAssign();
	}
}

class DebtAssign extends BaneAssign {
	
	public var currentOwed:Money;
	public var settled:Bool = false;
	
	public function new() {
		super();
	}
	
}



