package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.components.Bout.FightNode;
import troshx.core.ManueverSpec;
import troshx.sos.core.DamageType;
import troshx.sos.core.Manuever;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;

/**
 *
 * @author Glidias
 */
class Flee extends Manuever
{

	public function new() 
	{
		super("flee", "Flee");
		_types(Manuever.TYPE_DEFENSIVE)._tags(Manuever.TAG_VOID)._tn(5);
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var noAttacksNow:Bool = node.fight.attackManuevers.length == 0;
		var firstRound:Bool = bout.roundCount <= 1;
		var orientDef:Bool = node.fight.orientation == Manuever.ORIENTATION_DEFENSIVE;
		return !node.fight.lastAttacking && noAttacksNow && (!firstRound || orientDef);
	}
	
	override public function getMaxInvest(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Int {
		return node.charSheet.MOB;
	}
}

/*
Flee [X+EP]
Type and Tags: U DEFENSE VOID
Requirements: Have not declared an attack in either this or
the previous move. If it is the first round of the bout, must
have chosen defensive orientation.
Maneuver: Defense at TN 5, with X dice. You may not declare
more dice on this maneuver than your current MOB.
Success: Opponent’s attack is negated. You leave the bout.
Special: If it is the first round, and you have just declared
orientation, you cannot use this maneuver unless you
declared defensive.
You may declare Flee any number of times, if there are
multiple incoming attacks to defend against. All of your
defense maneuvers must succeed for you to leave the bout.
Fatigue Rules: Performing this maneuver causes you to
immediately gain 3 points of fatigue (multiply this as you
would normal fatigue speed!), which is applied immediately after the roll.
*/