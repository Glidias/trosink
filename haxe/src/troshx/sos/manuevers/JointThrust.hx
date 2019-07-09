package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.components.Bout.FightNode;
import troshx.core.ManueverSpec;
import troshx.sos.core.DamageType;
import troshx.sos.core.Manuever;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class JointThrust extends Manuever
{

	public function new() 
	{
		super("jointThrust", "Joint Thrust");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._attackTypes(Manuever.ATTACK_TYPE_THRUST)._costs(0, 0, true);	
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var weapon:Weapon = spec.activeItem;
		return weapon.damageTypeT == DamageType.PIERCING;
	}
	
}
/*
 Type and Tags: U ATTACK WEAPON
Requirements: Using a weapon with a thrust value that
inflicts piercing damage.
Maneuver: Attack at weapon’s reach, at Thrust TN+1, targeting
chosen hit location of target with X dice.
Success: Your weapon inflicts piercing damage equal to
[SDB+weapon thrust damage+half BS] to chosen hit location. Do not roll on the Thrusting Target Zones.
The damage from this attack is not reduced by AV from
any armor that has a Weak Spot for the hit location that was
targeted. All other AV protecting that area applies.
Special: When rolling an initiative test to determine attack
order while making a Joint Thrust, you may roll 1 additional
dice in the test.
You may only target a hit location in a target zone that
you would be able to attack normally; for example, you 

cannot attack a mounted opponent’s face with a dagger.
This maneuver’s variable activation cost is equal to [2] +1
for every reach step beyond M for the weapon being used.
This attack does not benefit from AP Thrust [X] unless
there is Hard Armor on the hit location aside from that
which is being ignored by this maneuver (such as mail
worn beneath the plate), in which case it does benefit from
AP Thrust [X] and other modifiers.
This maneuver gets -1 TN for each of these that apply:
 The weapon has the Thin Blade quality;
 The weapon is a spear or polearm held in two hands; or
 This maneuver is performed in a grapple.
*/