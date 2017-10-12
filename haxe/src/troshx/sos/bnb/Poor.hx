package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.Modifier;
import troshx.sos.core.Modifier.StaticModifier;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Poor extends Bane {
	public function new() {
		super("Poor", [4, 6, 8]);
		flags = BoonBane.CHARACTER_CREATION_ONLY;
		channels = BoonBane.__RICH__POOR;
		var h = StaticModifier.create(Modifier.STARTING_WEALTH, "Poor (i)",  0, .5);
		h.next = StaticModifier.create(Modifier.STARTING_MONEY, "Poor (i)", 0, .5);
		
		var h2 =  StaticModifier.create(Modifier.STARTING_WEALTH, "Poor (ii)" , 0, .25);
		h2.next = StaticModifier.create(Modifier.STARTING_MONEY, "Poor (ii)", 0, .25);
		staticModifiers = [
			h,
			h2,
			StaticModifier.create(Modifier.STARTING_MONEY, "Poor (iii)", 0, 0)
		];
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BaneAssign {
		return new PoorAssign(charSheet);
	}
}

class PoorAssign extends BaneAssign {
	var char:CharSheet;
	
	
	public function new(char:CharSheet) {
		super();
		this.char = char;
		
	}
	
	override public function getCost(rank:Int):Int {
		var wealthIndexNumRequired:Int = this.rank == 3 ?  4 : this.rank == 2 ? 3 : 2;
		var wealthIndexNum:Int = this.char.socialClass.wealthIndex + 1;
		var result = (wealthIndexNum < wealthIndexNumRequired ? wealthIndexNum/wealthIndexNumRequired : 1)* (rank > 0 ? this.bane.costs[rank-1] : 0 );
		return Math.floor(result ) ;
	}
}