package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.components.Bout.FightNode;
import troshx.core.ManueverSpec;
import troshx.sos.core.DamageType;
import troshx.sos.core.Manuever;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;

/**
 * Regular void at -1TN but with fatiue rules
 * @author Glidias
 */
class HastyVoid extends Manuever
{

	public function new() 
	{
		super("hastyVoid", "Hasty Void");
		_types(Manuever.TYPE_DEFENSIVE)._tags(Manuever.TAG_VOID)._tn(7)._bs(2);
	}
}

/*
Void [X+EP]
Type and Tags: U DEFENSE VOID
Requirements: None.
Maneuver: Defense at TN 8, with X dice.
Success: Opponent’s attack is negated. You do not take initiative with this maneuver without 2 or more BS.
Special: You may declare Void any number of times per move,
if there are multiple incoming attacks to defend against.
Fatigue Rules: You may choose to gain [2+EP] fatigue points
when performing this maneuver (multiply this as you
would normal fatigue speed!). If you do, the TN of the
maneuver is reduced by 1, to a base of 7. 
*/