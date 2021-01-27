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
class WeaponThrow extends Manuever
{

	public function new() 
	{
		super("weaponThrow", "Weapon Throw");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._attackTypes(Manuever.ATTACK_TYPE_THROWING)._costs(1)._ranged();
	}
	
}

/*
Weapon Throw [X+1]
Type and Tags: U Th ATTACK WEAPON
Requirements: Using a throwing weapon, or a melee weapon
that can be thrown. Current range must be at least as long
as the weapon’s reach.
Maneuver: Attack at current combat reach, at Missile TN,
targeting opponent with X dice. Roll on the Thrusting
Target Zone for the hit location. Weapon is thrown.
Success: Inflicts [SDB+weapon missile damage+BS] to hit
location. Weapon may be embedded in target.
Failure: In addition to having no effect, weapon has likely
flown past the target or is stuck in a shield.
Special: These attacks can be defended with Parry maneuvers
at +2 activation cost, or with Block and Void as normal.
When rolling an initiative test to determine attack order
while making a Weapon Throw, you may roll 1 additional
dice in the test.
Special [End Him Rightly]: At an additional +1 CP cost, if
using a sword or other weapon with a detachable pommel
or other component, you may unscrew it and fling it at your
opponent. This counts as a metal weight, as detailed in the
throwing weapons section of Chapter 13: Missile Weapons.
Doing this increases the Defense TN of the weapon by 1,
however, as it becomes unbalanced. Pommel Strike, obviously, may not be used with this weapon.
*/