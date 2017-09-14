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
	public static inline var COST_3:Int = 18;
	public static inline var COST_2:Int = 15;
	public static inline var COST_1:Int = 10;
	
	public function new() 
	{
		super("Severed Limb/Appendage", [COST_1, COST_2, COST_3]);  
		clampRank = true;
		flags = BoonBane.CANNOT_BE_REMOVED;
		multipleTimes = BoonBane.TIMES_VARYING; // based on body structure, usually 2 for each side
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BaneAssign {
		var b =  new SeveredLimbAssign();  // assumption made for humanoid for this sort of assignment
		return b;
	}
}

class SeveredLimbAssign extends BaneAssign
{
	@:ui({type:"SingleSelection", label:"Left Side Upper Limb", labels:["None", "Left Hand", "Left Lower Arm", "Left Full Arm"], values:[0, HAND, LOWER_ARM, FULL_ARM] }) public var severedArmLeft:Int = 0;
	@:ui({type:"SingleSelection", label:"Right Side Upper Limb", labels:["None", "Right Hand", "Right Lower Arm", "Right Full Arm"], values:[0, HAND, LOWER_ARM, FULL_ARM] }) public var severedArmRight:Int = 0;
	
	@:ui({type:"SingleSelection", label:"Left Side Lower Limb", labels:["None", "Left Foot", "Left Lower Leg", "Left Full Leg"], values:[0, FOOT, LOWER_LEG, FULL_LEG] }) public var severedLegLeft:Int = 0;
	@:ui({type:"SingleSelection",  label:"Right Side Lower Limb", labels:["None", "Right Foot", "Right Lower Leg", "Right Full Leg"],  values:[0, FOOT, LOWER_LEG, FULL_LEG] }) public var severedLegRight:Int = 0;
	
	@:computed public var severedAreasLeft(get, never):Int;
	public function get_severedAreasLeft():Int {
		return (severedArmLeft | severedLegLeft);
	}
	@:computed public var severedAreasRight(get, never):Int;
	public function get_severedAreasRight():Int {
		return (severedArmRight | severedLegRight);
	}
	
	
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
		
		var a =  (severedAreasLeft & (LEVEL_1_AREAS | LEVEL_2_AREAS | LEVEL_3_AREAS)) != 0;
		var b = (severedAreasRight & (LEVEL_1_AREAS | LEVEL_2_AREAS | LEVEL_3_AREAS)) != 0;
		return a || b;
	}
	
	override public function getCost(rank:Int):Int {
		var c:Int = 0;
		c += severedArmLeft == FULL_ARM ? SeveredLimb.COST_3 : severedArmLeft == LOWER_ARM ? SeveredLimb.COST_2 : severedArmLeft != 0 ? SeveredLimb.COST_1 : 0;
		c +=  severedArmRight == FULL_ARM ? SeveredLimb.COST_3 : severedArmRight == LOWER_ARM ? SeveredLimb.COST_2 : severedArmRight != 0 ? SeveredLimb.COST_1 : 0;
		
		c += severedLegLeft== FULL_LEG ? SeveredLimb.COST_3 : severedLegLeft == LOWER_LEG ? SeveredLimb.COST_2 : severedLegLeft != 0 ? SeveredLimb.COST_1 : 0;
		c += severedLegRight == FULL_LEG ? SeveredLimb.COST_3 :severedLegRight == LOWER_LEG ? SeveredLimb.COST_2 : severedLegRight != 0 ? SeveredLimb.COST_1 : 0;
		
		return c;
	}
	
	public function new() {
		super();
	}
	

	
	
}
