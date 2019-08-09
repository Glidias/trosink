package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.components.FightState;
import troshx.components.FightState.ManueverDeclare;
import troshx.core.ManueverSpec;
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
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		return !Manuever.hasInitiative(node, node.targetLink);
	}
	
	override public function resolve(bout:Bout<CharSheet>, node:FightNode<CharSheet>, declare:ManueverDeclare):Void {
		
	}
	
	override public function getCost(bout:Bout<CharSheet>, node:FightNode<CharSheet>, inputs:Array<Int>):Int {
		// return opponent perception
		return 0;
	}
	
	
	
}