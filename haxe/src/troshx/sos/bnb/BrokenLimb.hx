package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.Inventory;
import troshx.sos.core.Item;
import troshx.sos.core.Modifier;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class BrokenLimb extends Bane
{
	

	public function new() 
	{
		super("Broken Limb", null);
		flags = BoonBane.CANNOT_BE_REMOVED;
		multipleTimes = BoonBane.TIMES_VARYING; 
	}
		
	override function getEmptyAssignInstance(charSheet:CharSheet):BaneAssign {
		var b = new BrokenLimbAssign(); // note: for now assume this is humanoid standard
		
		return b;
	}
}

class BrokenLimbAssign extends BaneAssign
{
	public static inline var LEFT_ARM:Int = (1 << 0);
	public static inline var RIGHT_ARM:Int = (1 << 1);
	public static inline var LEFT_LEG:Int = (1 << 2);
	public static inline var RIGHT_LEG:Int = (1 << 3);
	public static inline var BOTH_LEGS:Int = (LEFT_LEG | RIGHT_LEG);
	
	@:ui({type:"Bitmask", labels:["Left Arm", "Right Arm", "Left Leg", "Right Leg"] })  public var affectedLimbs:Int = 0;
	
	override public function isValid():Bool {
		
		return affectedLimbs > 0;
	}
	
	 override public function getCost(rank:Int):Int {
		return getQty() * super.getCost(rank);
	}
	
	override public function getQty():Int {
		var c:Int = 0;
		c += (affectedLimbs & LEFT_ARM) != 0 ? 1 : 0;
		c += (affectedLimbs & RIGHT_ARM) != 0 ? 1 : 0;
		c += (affectedLimbs & LEFT_LEG) != 0 ? 1 : 0;
		c += (affectedLimbs & RIGHT_LEG) != 0 ? 1 : 0;
		return c;
	}
	
	
	public function new() {
		super();
		var m:SituationalCharModifier = new BrokenLimbMOBModifier(this);
		//m.next = ; // any extra modifiers into the linked list to set up
		situationalModifiers = [m];
	}
}


class BrokenLimbMOBModifier extends SituationalCharModifier {
	var current:BrokenLimbAssign;
	
	public function new(current:BrokenLimbAssign) {
		super(Modifier.CMP_MOB);
		this.current = current;
		
	}
	override public function getModifiedValue(char:CharSheet, rank:Int, qty:Int, value:Float):Float {
		if ( (current.affectedLimbs & BrokenLimbAssign.BOTH_LEGS) != 0) {
			// house rule, both legs == 0.25  instead of .5 MOB penalty
				
			var equipedItems = char.inventory.equipedNonMeleeItems;
			var crutchesHeld:Int = 0;
			var affected:Int = 0;
			var leftHanded:Bool = char.leftHanded;
			affected |= (current.affectedLimbs & BrokenLimbAssign.LEFT_LEG) != 0 ? (char.leftHanded ? Inventory.HELD_MASTER : Inventory.HELD_OFF) : 0;
			affected |= (current.affectedLimbs & BrokenLimbAssign.RIGHT_LEG) != 0 ? (char.leftHanded ? Inventory.HELD_OFF : Inventory.HELD_MASTER) : 0;
			for (i in 0...equipedItems.length) {
				var entry = equipedItems[i];
				if ( (entry.item.flags & (1 << Item.CRUTCH) ) != 0 ) {
					crutchesHeld |= entry.held;
					break;
				}
			}
			
			if ( crutchesHeld == 0) { // no crutches held...can only crawl like a snail?
				return value < 1 ? value : 1;
			}
			else {  // has some crutches held...
				affected &= ~crutchesHeld; // heal some affected
				
				var mob = char.MOB;
				var multiplier = affected == 0 ? 0.25 : 0.125;  // if crutches didn't deal against all effected limbs fully, multiplier reduced 
				
				return mob * multiplier < value ? mob * multiplier : value;
			}
		}
		return value;
	}
}

