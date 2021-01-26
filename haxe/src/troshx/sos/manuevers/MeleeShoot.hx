package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.core.ManueverSpec;
import troshx.sos.core.Manuever;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class MeleeShoot extends Manuever
{

	public function new() 
	{
		super("meleeShoot", "Melee Shoot");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._attackTypes(Manuever.ATTACK_TYPE_SHOOTING)._ranged();
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		//var weapon:Weapon = spec.activeItem;
		// todo: check weapon is loaded
		return true;
	}
}

/*
Melee Shoot [X+Variable]
Type and Tags: U Th ATTACK WEAPON
Requirements: Have a loaded or spanned bow, crossbow, or
firearm ready in the hand.
Maneuver: Attack at current combat reach, at Missile TN,
targeting opponent with X. Roll on the Thrusting Target
Zone for the hit location.
Success: Inflicts missile damage as a normal missile attack,
however hit location is determined by the Thrusting Target
Zones rather than the Missile Target Zones table.
Special: If a defense maneuver that requires a weapon is used
against Melee Shoot, the defender must pay an additional
activation cost equal to the range difference between the
characters. If successful, move to defender’s weapon reach.
If a character’s racial abilities allow them to parry missile
attacks, they may perform a defense maneuver that uses a
weapon, and not need to pay the additional activation cost.
When rolling an initiative test to determine attack order
while performing a Melee Shoot maneuver, you may roll 1
additional dice in the test.
If your weapon is readied in the hand, the variable activation cost is 0. If the weapon has just been drawn using
Quickdraw this move, the variable activation cost is 2.
While mounted, you suffer a -2 penalty to this maneuver.
*/