package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.core.ManueverSpec;
import troshx.sos.core.Manuever;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class TotalBlock extends Manuever
{

	public function new() 
	{
		super("totalBlock", "Total Block");
		_types(Manuever.TYPE_DEFENSIVE)._requisite(Manuever.REQ_SHIELD)._tags(Manuever.TAG_BLOCK)._costs(0, Manuever.NO_INVEST);
	}
	
	override public function getCost(bout:Bout<CharSheet>, node:FightNode<CharSheet>, inputs:Array<Int>):Int {
		return Math.floor(node.charSheet.CP * 0.5);
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var firstMove:Bool = !bout.secondTempo;
		var firstRound:Bool = bout.roundCount <= 1;
		var orientDef:Bool = node.fight.orientation == Manuever.ORIENTATION_DEFENSIVE;
		var noAttacksNow:Bool = node.fight.attackManuevers.length == 0;
		var noDefsNow:Bool = node.fight.defensiveManevers.length == 0;
		var atLeast1CP:Bool = Math.floor(node.charSheet.CP * 0.5) >= 1;
		return noAttacksNow && noDefsNow && firstMove && (!firstRound || orientDef) && atLeast1CP;
	}
	
}

/*
Total Block [Half Maximum CP]
Type and Tags: U DEFENSE SHIELD BLOCK
Requirements: Using a shield. Only usable in first move of
a bout. If it is the first move and bout immediately after
orientation declaration, you must have declared defensive
Maneuver: Opponent’s attack resolves as normal. If the
attack causes damage (to the body only, not a weapon or
shield) add shield AV to defense of the area struck, regardless of shield position. Lower shield durability by opponent’s successes.
Special: This Block cannot be used in conjunction with any
Simultaneous maneuver. If you declare Total Block you
cannot declare any attack during this move for any reason.
*/