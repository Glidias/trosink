package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.components.Bout.FightNode;
import troshx.core.ManueverSpec;
import troshx.sos.core.DamageType;
import troshx.sos.core.Manuever;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class ShieldBind extends Manuever
{

	public function new() 
	{
		super("shieldBind", "Shield Bind");
		_types(Manuever.TYPE_DEFENSIVE)._requisite(Manuever.REQ_SHIELD)._tags(Manuever.TAG_BLOCK | Manuever.TAG_ADVANCED)._costs(1)._superior();
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var weapon:Weapon = LibUtil.as(spec.activeEnemyItem, Weapon);
		if (weapon == null) return false;
		return weapon.isMelee() && weapon.range >= Weapon.REACH_M;
	}
	
}

/*
Shield Bind [X+1]
Type and Tags: A S DEFENSE SHIELD BLOCK
Requirements: Using a shield, and opponent is attacking
with weapon of M-reach or longer.
Maneuver: Defense at Block TN, with X dice.
Success: Opponent’s attack is negated. Attacking
weapon cannot be used as part of any
weapon maneuvers in the next move.
You cannot Block with your shield
next move.
Superior: When you successfully Shield Bind, you may
advance a number of reach
steps towards your opponent up to BS
*/