package troshx.sos.bnb;

import haxe.ds.StringMap;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.BoonBane;
import troshx.sos.core.Modifier.EventModifierBinding;
import troshx.sos.events.SOSEvent;


/**
 * Draft example in comments for static/situational customisation of Boons/Bane
 * @author Glidias
 */
class Rich extends Boon
{

	public function new() 
	{
		super("Rich", [1, 3, 5]);
		channels = BoonBane.__RICH__POOR;
		flags = BoonBane.CHARACTER_CREATION_ONLY;
	}
	
	/*
	override function getEmptyAssignInstance():BoonAssign {
		var richAssign:RichAssign = new RichAssign();
		// apply custom class properties to custom RichAssign;
		
		return richAssign;
	}
	*/
	
	
	/*  //  modifier example under Boon/Bane class
	 * 
	 private function aHandler(event:SOSEvent, bus:SOSEventBus):Int {
		switch( event) {
			case SOSEvent.FATIQUE_GAIN(_,_):
				
				
				
			default: return 0;
		}
		
		return 0;
	}
	*/

}

/*
class RichAssign extends BoonAssign {

	// custom fields declared here for specific boon/bane assignment

	public function new() {
		super();
		//EventModifierBinding.build(aHandler);
	}

	// instance based modifier example under BoonAssign/BaneAssign class
	/*
	private function aHandler(event:SOSEvent, bus:SOSEventBus):Int {
		switch( event) {
			case SOSEvent.FATIQUE_GAIN(_,_):
				
				
				
			default: return 0;
		}
		
		return 0;
	}
	*/

