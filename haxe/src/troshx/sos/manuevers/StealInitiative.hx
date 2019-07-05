package troshx.sos.manuevers;
import troshx.components.FightState;
import troshx.components.FightState.ManueverDeclare;
import troshx.sos.core.Manuever;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class StealInitiative extends Manuever
{

	public function new() 
	{
		super("stealInitiative", "Steal Initiative");
		types = Manuever.TYPE_INITIATIVE;
		tags = Manuever.TAG_INSTANT;
		costVaries = true;
	}
	
	override public function resolve(sheet:CharSheet, state:FightState, declare:ManueverDeclare):Void {
		
	}
	
	override public function getCost(sheet:CharSheet, fightState:FightState, inputs:Array<Int>):Int {
		// return opponent perception
		return 0;
	}
	
	
	
}