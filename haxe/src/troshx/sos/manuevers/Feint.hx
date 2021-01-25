package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.components.Bout.FightNode;
import troshx.core.ManueverSpec;
import troshx.sos.core.Manuever;
import troshx.sos.core.MeleeSpecial;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Feint extends Manuever
{

	public function new() 
	{
		super("feint", "Feint");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._attackTypes(Manuever.ATTACK_TYPE_BOTH)._costs(2, Manuever.DEFER_COST)._superior();
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var weapon:Weapon = spec.activeItem;
		var fluidThrusts:Bool = (weapon.meleeFlags & MeleeSpecial.FLUID_THRUSTS) != 0;
		if (spec.activeEnemyBody.isThrusting(spec.activeEnemyZone) && !fluidThrusts) {
			return false;
		}
		return true;
	}
}	
/*
Feint [2+Variable]
Type and Tags: U S ATTACK WEAPON
Requirements: Using a weapon with a Swing or Thrust TN.
Activate after having declared a Swing or Thrust maneuver,
and after any other attack or defense maneuvers have been
declared, but before any are resolved. You may only activate
this maneuver from a Thrust if the weapon being used has
the Fluid Thrusts quality.
Maneuver: When activated, change either the type of the
attack (to a Swing or Thrust maneuver), or the target zone
of the attack (face to chest, upper arm to lower leg, and so
on). You may elect to change both the type of maneuver
and the target zone. You may pay 2 CP to add 1 CP to this
attack, as many times as you can afford.
Superior: You may pay 1 CP to add 1 CP to this attack, as many
times as you can afford.
*/