package troshx.sos.bnb;
import troshx.sos.core.BodyChar.Humanoid;
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
class SeveredLimb extends Bane
{

	public function new() 
	{
		super("Severed Limb/Appendage", [10,15,18]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		multipleTimes = BoonBane.TIMES_VARYING; // based on body structure, usually 2 for each side
		// which side affected?
		// Level on which side...
		
		// thus, need left rank, right rank...
	}
	
	override function getEmptyAssignInstance():BaneAssign {
		var b =  new SeveredLimbAssign();
		return b;
	}
}

class SeveredLimbAssign extends BaneAssign
{
	public var severedAreasLeft:Int = 0;
	public var severedAreasRight:Int = 0;
	@:level1 public static inline var HAND:Int = Humanoid.HAND; 
	@:level2 public static inline var LOWER_ARM:Int = Humanoid.LOWER_ARM; 
	@:level3 public static inline var FULL_ARM:Int = Humanoid.FULL_ARM; 
	
	@:level1 public static inline var FOOT:Int = Humanoid.FOOT; 
	@:level2 public static inline var LOWER_LEG:Int = Humanoid.LOWER_LEG; 
	@:level3 public static inline var FULL_LEG:Int = Humanoid.FULL_LEG; 
	
	public static inline var LEVEL_1_AREAS:Int = HAND | FOOT;
	public static inline var LEVEL_2_AREAS:Int = LOWER_ARM | LOWER_LEG;
	public static inline var LEVEL_3_AREAS:Int = FULL_ARM | FULL_LEG;
	
	override public function isValid():Bool {
		
		return rank == 3 ? (severedAreasLeft == FULL_LEG || severedAreasLeft == FULL_ARM || severedAreasRight == FULL_LEG || severedAreasRight == FULL_ARM) :
		rank == 2 ?  (severedAreasLeft == LOWER_ARM || severedAreasLeft == LOWER_LEG || severedAreasRight == LOWER_ARM || severedAreasRight == LOWER_LEG) : 
		(severedAreasLeft == HAND || severedAreasLeft == FOOT || severedAreasRight == HAND || severedAreasRight == FOOT);
	}
	
	public function new() {
		super();
	}
	
	
}
