package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Language extends Boon
{
	
	public static inline var COST_SINGLE:Int = 1;
	public function new() 
	{
		super("Language", [COST_SINGLE, 2, 3]);
		
		// Language is special, can learn multiple times of level 1 at character creation only, 
		// but never at levels 2 and 3 and never during gameplay (on all levels)
		customCostInnerSlashes = "|/";
		multipleTimes = BoonBane.TIMES_VARYING;
		
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BoonAssign {
		return new LanguageAssign();
	}
	
	/*  //  modifier example under Boon/Bane class
	 * 
	 private function aHandler(event:SOSEvent, bus:SOSEventBus):Int {
		switch( event) {
			case SOSEvent...(_,_):
				
				
				
			default: return 0;
		}
		
		return 0;
	}
	*/
	
}

class LanguageAssign extends BoonAssign {
	@:ui({ label:"Beginning Languages #1", maxLength:Std.int((_remainingCached +  startingLanguages.length * Language.COST_SINGLE) / Language.COST_SINGLE)  })
	public var startingLanguages:Array<String> = [""];
	@:ui({maxLength:ingame ? null : 0 }) public var ingameLanguages:Array<String> = [];
	@:ui({type:"textarea"}) public var notes:String = "";
	
	
	
	public function new() {
		super();
		// TODO: proper...
		
		//EventModifierBinding.build(aHandler);
	}
	
	override public function getQty():Int {
		return startingLanguages.length;
	}
	
	inline function getLevelCost(rank:Int):Int {
		return (rank > 1 ? boon.costs[rank - 1] : 0);
	}
	
	override public function getCost(rank:Int):Int {
		return Language.COST_SINGLE * startingLanguages.length + getLevelCost(rank);
	}
	// instance based modifier example under BoonAssign/BaneAssign class
	/*
	private function aHandler(event:SOSEvent, bus:SOSEventBus):Int {
		switch( event) {
			case SOSEvent....(_,_):
				
			default: return 0;
		}
		
		return 0;
	}
	*/
	

}