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
		
		var mod:BadEyesModifier = new BadEyesModifier();
		situationalModifiers = [
			mod,
			mod
		];
	}
}

class BadEyesModifier extends SituationalCharModifier {
	public function new() {
		super(Modifier.ATTR_PER);
	}
	override public function getModifiedValue(char:CharSheet, rank:Int, qty:Int, value:Float):Float {
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