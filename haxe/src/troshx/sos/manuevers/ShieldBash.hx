package troshx.sos.manuevers;
import troshx.core.ManueverSpec;
import troshx.sos.core.Manuever;
import troshx.sos.core.Shield;
import troshx.sos.core.Weapon;
import troshx.util.LibUtil;

/**
 * ...
 * @author ...
 */
class ShieldBash extends Manuever
{

	public function new() 
	{
		super("shieldBash", "Shield Bash");
		//_damage(DamageType.BLUDGEONING, 0)
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_SHIELD)._reach(Weapon.REACH_H)._attackTypes(Manuever.ATTACK_TYPE_THRUST)._superior();
	}
	
	var _bash:ShieldBash;
	override public function getSecondary():Manuever {
		return _bash != null ? _bash : (_bash = new ShieldBash());
	}
	/*
	override public function getTN(spec:ManueverSpec):Int {
		var shield:Shield = LibUtil.as(spec.activeItem, Shield);
		if (shield == null) return -1;
		return shield.bashTN;
	}
	*/
	
	
}

/*
Shield Bash [X]
Type and Tags: U S Th ATTACK SHIELD BASH
Requirements: Using a shield.
Maneuver: Attack at H-reach, at Shield Bash TN, targeting
opponent with X dice. Roll on the Thrusting Target Zone
for the hit location.
Success: Inflicts bludgeoning damage equal to [SDB+shield
bash damage+BS] to hit location.
Special: Weapon defense maneuvers made against a Shield
Bash are made at +1 TN.
Shield Bash cannot be used as part of any Simultaneous
maneuver.
Superior: Opponent must make a [BS] RS stability check or
be rendered prone.
*/