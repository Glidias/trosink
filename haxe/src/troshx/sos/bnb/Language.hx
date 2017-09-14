package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.sheets.CharSheet;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class Language extends Boon
{
	
	public static inline var COST_SINGLE:Int = 1;
	public static inline var COST_2:Int = 2;
	public static inline var COST_3:Int = 3;
	public function new() 
	{
		super("Language", [COST_SINGLE, COST_2, COST_3]);
		
		// Language is special, can learn multiple times of level 1 at character creation only, 
		// but never at levels 2 and 3 and never during gameplay (on all levels)
		customCostInnerSlashes = "|/";
		multipleTimes = BoonBane.TIMES_VARYING;
		
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BoonAssign {
		return new LanguageAssign(charSheet);
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
	
	var char:CharSheet;
	
	@:ui({ minLength:1, label:"Starting Languages #1", maxLength:getMaxLength(Language.COST_SINGLE, startingLanguages.length)  })
	public var startingLanguages:Array<String> = [""];
	
	@:ui({  label:"2nd Language #2", maxLength:(rank == 2 ? 1 : 0) })
	public var secondLanguage:Array<String> = [];
	
	@:ui({  label:"Starting Polyglot Languages #3", maxLength:(rank >= 3 ? char.INT + 2 : 0)  })
	public var polyglotLanguages:Array<String> = [];
	
	@:ui({maxLength:ingame ? null : 0 }) public var ingameLanguages:Array<String> = [];
	@:ui({type:"textarea"}) public var notes:String = "";
	
	
	
	public function new(char:CharSheet) {
		super();
		this.char = char;
		
		// example
		//EventModifierBinding.build(aHandler);
	}
	
	override public function getQty():Int {
		return startingLanguages.length;
	}
	

	inline function getRankCost(rank:Int):Int {
		return rank > 1 ? rank == 3 ? Language.COST_3 : Language.COST_2 :  Language.COST_SINGLE;
	}
	
	override public function getCost(rank:Int):Int {
		return Language.COST_SINGLE*(startingLanguages.length > 1 ? startingLanguages.length - 1 : 0) + getRankCost(rank);
	}
	
	
	
	// example instance based modifier example under BoonAssign/BaneAssign class
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