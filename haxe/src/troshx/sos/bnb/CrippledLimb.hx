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
class CrippledLimb extends Bane
{

	public function new() 
	{
		super("Crippled Limb/Appendage", [8]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		multipleTimes = BoonBane.TIMES_VARYING;  // varies based on humanoid or body tructure, usually 4 total for each limb
	}
	
	override function getEmptyAssignInstance():BaneAssign {
		return new CrippledLimbAssign();
	}
}

class CrippledLimbAssign extends BaneAssign
{
	public static inline var LEFT_ARM:Int = (1 << 0);
	public static inline var RIGHT_ARM:Int = (1 << 1);
	public static inline var LEFT_LEG:Int = (1 << 2);
	public static inline var RIGHT_LEG:Int = (1 << 3);
	public static inline var BOTH_LEGS:Int = (LEFT_LEG | RIGHT_LEG);
	
	public var affectedLimb:Int = -1;
	
	override public function isValid():Bool {
		return affectedLimb >= 0;
	}
	
	public function new() {
		super();
		var m:SituationalCharModifier = new CrippedLimbMOBModifier(this);
		//m.next = ; // any extra modifiers into the linked list to set up
		situationalModifiers = [m];
	}
	
	
}

class CrippedLimbMOBModifier extends SituationalCharModifier {
	var current:CrippledLimbAssign;
	
	public function new(current:CrippledLimbAssign) {
		super(Modifier.CMP_MOB);
		this.current = current;
		
	}
	override public function getModifiedValue(char:CharSheet, rank:Int, qty:Int, value:Float):Float {
		if ( (current.affectedLimb & CrippledLimbAssign.BOTH_LEGS) != 0) {
			// house rule, both legs == 0.25  instead of .5 MOB penalty
			var multipler = current.affectedLimb == CrippledLimbAssign.BOTH_LEGS ? .25 : .5;
			var mob = char.MOB;
			return  mob * multipler < value ? mob * multipler : value;
		}
		return value;
	}
}

