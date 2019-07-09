package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.components.Bout.FightNode;
import troshx.core.ManueverSpec;
import troshx.sos.core.DamageType;
import troshx.sos.core.Manuever;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Riposte extends Manuever
{

	public function new() 
	{
		super("riposte", "Riposte");
		_types(Manuever.TYPE_DEFENSIVE)._requisite(Manuever.REQ_WEAPON)._tags(Manuever.TAG_PARRY | Manuever.TAG_ADVANCED)._costs(2)._superior();
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var weapon:Weapon = spec.activeItem;
		return weapon.atnS > 0;
	}
	
}

/*
Riposte [X+2]
Type and Tags: A S DEFENSE WEAPON PARRY
Requirement: Using a weapon with a Defense TN and a Swing
TN.
Maneuver: Defense at Defense TN, with X dice. If you are
using this maneuver without initiative, declare it against
an opponent’s attack.
Success: Opponent’s attack is negated. Note down the total
successes the attack achieved. You may follow through
Riposte next move by declaring a swinging or thrusting
maneuver against the opponent whose attack was negated
by this maneuver. If you do so, your attack gains bonus dice
equal to the opponent’s successes.
Special: You may only declare this maneuver once per weapon
per move.
Superior: When you succeed with a Riposte, the weapon
riposted cannot be used to perform any weapon maneuvers
in the next move.
*/