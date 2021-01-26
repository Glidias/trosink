package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.core.ManueverSpec;
import troshx.sos.core.Manuever;
import troshx.sos.core.MeleeSpecial;
import troshx.sos.core.Shield;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class ShieldFeint extends Manuever
{


	public function new() 
	{
		super("shieldFeint", "Shield Feint");
		//_types(Manuever.TYPE_OFFENSIVE)._reach(Weapon.REACH_H)._attackTypes(Manuever.ATTACK_TYPE_THRUST)._superior();
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON | Manuever.REQ_SHIELD)._costs(1, Manuever.DEFER_COST);
	}
	
	override public function getTN(spec:ManueverSpec):Int {
		return super.getTN(spec); // if >=0, return bashTN instead?
		//return 0;
	}
	
	var _bash:ShieldBash;
	override public function getSecondary():Manuever {
		return _bash != null ? _bash : (_bash = new ShieldBash());
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var shield:Shield = LibUtil.as(spec.activeItem, Shield); //  node.charSheet.inventory.findHeldShield();
		if (shield == null) return false;
		///*
		var weapon:Weapon = node.charSheet.inventory.getMasterWeapon();
		if (weapon == null) node.charSheet.inventory.getOffhandWeapon();
		var fluidThrusts:Bool = (weapon.meleeFlags & MeleeSpecial.FLUID_THRUSTS) != 0;
		if (!spec.activeEnemyBody.isThrusting(spec.activeEnemyZone) && fluidThrusts) {
			return false;
		}
		return true;
		//*/
	
		/*
		var weapon:Weapon = spec.activeItem;

		var fluidThrusts:Bool = (weapon.meleeFlags & MeleeSpecial.FLUID_THRUSTS) != 0;
		if (!spec.activeEnemyBody.isThrusting(spec.activeEnemyZone) && fluidThrusts) {
			return false;
		}
		
		return true;
		*/
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