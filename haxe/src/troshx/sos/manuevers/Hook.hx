package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.components.Bout.FightNode;
import troshx.core.ManueverSpec;
import troshx.sos.core.DamageType;
import troshx.sos.core.Manuever;
import troshx.sos.core.MeleeSpecial;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Hook extends Manuever
{

	public function new() 
	{
		super("hook", "Hook");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._attackTypes(Manuever.ATTACK_TYPE_BOTH)._targetZoneMode(Manuever.TARGET_ZONE_SHIELD | Manuever.TARGET_ZONE_OPPONENT)._costs(1)._superior();
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var weapon:Weapon = spec.activeItem;
		return (weapon.meleeFlags & MeleeSpecial.HOOK)!=0;
	}
}
/*
Hook [X+1]
Type and Tags: U S Sw Th ATTACK WEAPON
	Requirements: Use a weapon with the Hook quality.
	Maneuver: Attack at weapon’s reach, at weapon Swing TN or
	Thrust TN, targeting opponent’s shield or opponent with
	X dice.
	Success: If targeting opponent, opponent suffers [BS] stun,
	and must make a [BS] RS stability test or be rendered prone.
	If targeting shield, opponent cannot use his shield in the
	following move, and must make an AGI roll at [BS] RS or
	lose the shield altogether as it is dragged away.
	Special: You cannot use Hook against a mounted opponent
	unless the weapon being used is of L-reach or longer.
	Superior: If you successfully use Hook, and your opponent
	fails their check, your next attack maneuver against this
	opponent inflicts +2 damage.
*/