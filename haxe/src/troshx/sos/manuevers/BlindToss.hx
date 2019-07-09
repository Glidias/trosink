package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.core.ManueverSpec;
import troshx.sos.core.Manuever;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class BlindToss extends Manuever
{

	public function new() 
	{
		super("blindToss", "Blind Toss");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_STUFF)._tn(5)._costs(0, 0, true);
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		return node.targetLink.reach <= Weapon.REACH_EL;
	}
}

/*
Blind Toss [X+Variable]
Type and Tags: U ATTACK STUFF
Requirements: Have something to throw in-hand or within
quick and easy reach (hat, scarf, cloak, sand, dirt). Must be
at EL-reach or shorter.
Maneuver: Attack at TN 5, targeting opponent with X dice.
Ignores all reach modifiers.
Success: Opponent’s attack and defense TNs are increased by
1 per BS to a maximum of 10 until the end of the next phase.
Special: When rolling an initiative test to determine attack
order while making a Blind Toss, you may roll 3 additional
dice in the test.
This maneuver’s activation cost is equal to X+half the
opponent’s PER, +1 for each time you have used this
maneuver on that character before. This is not limited to
one fight—every single time you use Blind Toss on a character, your activation cost for it increases by 1 against that
character.
Blind Toss cannot be used as part of any Simultaneous
maneuver.
This maneuver may not be defended with a Parry; it can
only be defended with Block or Void maneuvers.
*/