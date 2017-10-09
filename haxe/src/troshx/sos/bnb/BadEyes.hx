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

	override function getEmptyAssignInstance(charSheet:CharSheet):BaneAssign {
		return  new BadEyesAssign();
	}
}

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
		super(Modifier.ATTR_PER);
	}
	override public function getModifiedValueAdd(char:CharSheet, base:Float, value:Float):Float {
		var rank:Int = current.rank;
		var equipedItems = char.inventory.equipedNonMeleeItems;
		var gotSpecs:Bool = false;
		for (i in 0...equipedItems.length) {
			var entry = equipedItems[i];
			if ( (entry.item.flags & (1<<Item.EYE_CORRECTIVE) )!=0 && Inventory.presumedActiveItem(entry) ) {
				gotSpecs = true;
				break;
			}
		}
		return 
		rank == 0 ? value - (gotSpecs ? 0 : 2) : 
		value - (gotSpecs ? 4 : 2);
	}
}