package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Favor extends Boon {
	
	public static inline var COST_1:Int = 1;
	public static inline var COST_2:Int = 3;
	
	public function new() {
		super("Favor", [COST_1, COST_2]);
		clampRank = true;
		multipleTimes = BoonBane.TIMES_VARYING;
		
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BoonAssign {
		return new FavorAssign();
	}
}


class FavorAssign extends BoonAssign { 
	
	@:ui({minLength:0, maxLength:getMaxLength(Favor.COST_1, clampLength(simpleFavors.length)) }) public var simpleFavors:Array<String> = [""];
	@:ui({minLength:0, maxLength:getMaxLength(Favor.COST_2, greaterFavors.length) }) public var greaterFavors:Array<String> = [];
	@:ui({type:"textarea"}) public var notes:String = "";
	
	public function new() {
		super();
	}
	override public function isValid():Bool {
		return getQty() >= 1;
	}
	
	override public function getQty():Int {
		return simpleFavors.length + greaterFavors.length;
	}
	
	override public function getCost(rank:Int):Int {
		return Favor.COST_1 * simpleFavors.length + Favor.COST_2 * greaterFavors.length;
	}
}