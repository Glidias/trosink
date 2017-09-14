package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Allies extends Boon {
	public static inline var COST_1:Int = 1;
	public static inline var COST_2:Int = 5;
	public static inline var COST_3:Int = 10;
	
	public function new() {
		super("Allies", [COST_1, COST_2, COST_3]);
		clampRank = true;
		
		multipleTimes = BoonBane.TIMES_VARYING;
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BoonAssign {
		return new AlliesAssign();
	}
}

class AlliesAssign extends BoonAssign {  // todo: combination of ranks
	
	@:ui({minLength:0, maxLength:getMaxLength(Allies.COST_1, clampLength(minorPowerList.length))}) public var minorPowerList:Array<String> = [""];
	@:ui({minLength:0, maxLength:getMaxLength(Allies.COST_2, moderatePowerList.length)}) public var moderatePowerList:Array<String> = [];
	@:ui({minLength:0, maxLength:getMaxLength(Allies.COST_3, majorPowerList.length)}) public var majorPowerList:Array<String> = [];
	@:ui({type:"textarea"}) public var notes:String;
	
	public function new() {
		super();
	}
	
	override public function getQty():Int {
		return minorPowerList.length + moderatePowerList.length + majorPowerList.length;
	}
	
	
	
	 function getMaxLengthCost(costBase:Int, length:Int):Int {
		//var a = getMaxLength(costBase);
		var b = length * costBase;
		return b;// a < b ? a : b;
	}
	
	override public function getCost(rank:Int):Int {
		return getMaxLengthCost(Allies.COST_1,minorPowerList.length) + getMaxLengthCost(Allies.COST_2,moderatePowerList.length) + getMaxLengthCost(Allies.COST_3, majorPowerList.length);
	}
}