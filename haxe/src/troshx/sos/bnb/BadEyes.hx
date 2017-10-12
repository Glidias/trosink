package troshx.sos.bnb;

import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.Inventory;
import troshx.sos.core.Item;
import troshx.sos.core.Modifier;
import troshx.sos.core.Modifier.SituationalCharModifier;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class BadEyes extends Bane {
	public function new() {
		super("Bad Eyes", [4, 6]);
		channels = BoonBane.__GOOD_EYES__BAD_EYES;
		flags = BoonBane.CANNOT_BE_REMOVED;
	
	}

	/*	// Removed off atm. yagni. SItuationalModifier should be Event-based involving Sight checks only..
	override function getEmptyAssignInstance(charSheet:CharSheet):BaneAssign {
		return  new BadEyesAssign();
	}
	*/
}

/*
class BadEyesAssign extends BaneAssign {
	public function new() {
		super();
		var mod:BadEyesModifier = new BadEyesModifier(this);
		situationalModifiers = [
			mod,
			mod
		];
	}
	
}

class BadEyesModifier extends SituationalCharModifier {
	var current:BadEyesAssign;
	public function new(current:BadEyesAssign) {
		this.current = current;
		super(Modifier.ATTR_PER, "Bad Eyes");
	}
	
	override function get_name():String {
		return this.name + ( current.rank == 2 ? "(ii)" : " (i)");
	}
	
	override public function getModifiedValueAdd(char:CharSheet, base:Float, value:Float):Float {
		var rank:Int = current.rank;
		var equipedItems = char.inventory.equipedNonMeleeItems;
		var gotSpecs:Bool = false;
		for (i in 0...equipedItems.length) {
			var entry = equipedItems[i];
			if ( (entry.item.flags & Item.EYE_CORRECTIVE )!=0 && entry.unheld != Inventory.UNHELD_FORCE_DISABLED ) {
				gotSpecs = true;
				
				break;
			}
		}
		return 
		rank == 1 ? value - (gotSpecs ? 0 : 2) : 
		value - (gotSpecs ? 2 : 4);
	}
}
*/