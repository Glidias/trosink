package troshx.sos.manuevers;
import troshx.core.ManueverSpec;
import troshx.sos.core.Manuever;

/**
 * ...
 * @author Glidias
 */
class ShieldFeint extends Manuever
{

	public function new() 
	{
		super("shieldFeint", "Shield Feint");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON | Manuever.REQ_SHIELD)._costs(1, Manuever.DEFER_COST);
	}
	
	override public function getTN(spec:ManueverSpec):Int {
		return super.getTN(spec); // if >=0, return bashTN instead?
	}
	
}

/*
Shield Feint [1]
Type and Tags: U ATTACK SHIELD
Requirements: Using a shield. Attacking with a weapon.
Maneuver: Spend activation cost to change declared attack
from current one to a Bash maneuver, aimed at the same
or a new location, using the same dice. Pay CP for reach
costs, if necessary. You may activate this maneuver after
an opponent has declared a defense maneuver against your
other attack
*/