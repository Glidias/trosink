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
	
	public function new() 
	{
		super("Language", [1, 2, 3]);
		
		// Language is special, can learn multiple times of level 1 at character creation only, 
		// but never at levels 2 and 3 and never during gameplay (on all levels)
		
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
	@:ui public var languages:Array<String> = [""];
	@:ui("textarea") public var notes:String = "";
	
	public function new() {
		super();
		// TODO: proper...
		
		//EventModifierBinding.build(aHandler);
	}
	
	override public function getQty():Int {
		return languages.length;
	}
	
	override public function getCost():Int {
		return boon.costs[0] * languages.length;
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