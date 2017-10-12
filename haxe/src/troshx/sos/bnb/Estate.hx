package troshx.sos.bnb;
import troshx.sos.bnb.Estate.EstateAssign;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Estate extends Boon {
	
	public static inline var WEALTH_PER_QTY:Int = 2;
	public static inline var COST_PER_ESTATE:Int = 10;
	
	public function new() {
		super("Estate", [COST_PER_ESTATE]);
		flags = BoonBane.CHARACTER_CREATION_ONLY;
		multipleTimes = BoonBane.TIMES_VARYING;
	}
	override function getEmptyAssignInstance(charSheet:CharSheet):BoonAssign {
	
		return new EstateAssign(charSheet);
	}
	
}


class EstateAssign extends BoonAssign {
	
	@:ui({label:"Estates", defaultValue:getEmptyWealthAssign, fixedWorth:true, disableLiquidity:!char.ingame, minLength:1,  maxLength: getMaxLength(Estate.COST_PER_ESTATE, estates.length)  }) public var estates:Array<WealthAssetAssign> = [getEmptyWealthAssign()];
	@:ui({type:"textarea"}) public var notes:String = "";
	
	static var COUNT:Int = 0;
	var char:CharSheet;

	
	static function getEmptyWealthAssign():WealthAssetAssign {
		return {
			name:"",
			liquidate:false,
			uid:COUNT++,
			worth:2
		};
	}
	
	override public function getQty():Int {
		return estates.length;
	}
	
	override public function getCost(rank:Int):Int {
		return estates.length * Estate.COST_PER_ESTATE;
	}
	
	public function new(char:CharSheet) {
		super();
		this.char = char;
		
	}
	

}