package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Boon;

/**
 * ...
 * @author Glidias
 */
class Language extends Boon
{
	
	public function new() 
	{
		super("Language", [1, 2, 3]);
		multipleTimes = BoonBane.TIMES_INFINITE;
	}
	
	override function getEmptyAssignInstance():BoonAssign {
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
	public var languages:Array<String> = [];
	
	public function new() {
		super();
		//EventModifierBinding.build(aHandler);
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