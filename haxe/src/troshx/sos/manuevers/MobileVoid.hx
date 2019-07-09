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
class MobileVoid extends Manuever
{

	public function new() 
	{
		super("mobileVoid", "Mobile Void");
		_types(Manuever.TYPE_DEFENSIVE)._tags(Manuever.TAG_VOID)._tn(8)._bs(1);
	}
}

/*
Mobile Void [X+EP]
Type and Tags: U DEFENSE VOID
Requirements: None.
Maneuver: Defense at TN 8, with X dice.
Success: Opponent’s attack is negated. You may close or
retreat up to [BS] reach steps. You do not take initiative
with this maneuver without 1 or more BS.
Failure: You must make a [1+enemy BS] RS stability check or
be rendered prone.
Special: You may declare this maneuver any number of times
per move, if there are multiple incoming attacks to defend
against.
If you increase the reach between you and an opponent to LL-reach, still have BS left, and no additional
enemies are targeting you who are closer than LL-reach or
outflanking you, you may choose to leave the bout.
Fatigue Rules: You may choose to gain [2+EP] fatigue points
when performing this maneuver (multiply this as you
would normal fatigue speed!). If you do, the TN of the
maneuver is reduced by 1, to a base of 7. 
*/