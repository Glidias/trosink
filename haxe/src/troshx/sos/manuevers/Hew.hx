package troshx.sos.manuevers;
import troshx.sos.core.Manuever;

/**
 * ...
 * @author Glidias
 */
class Hew extends Manuever
{

	public function new() 
	{
		super("hew", "Hew");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._attackTypes(Manuever.ATTACK_TYPE_SWING)._targetZoneMode(Manuever.TARGET_ZONE_SHIELD)._costs(1)._superior();
	}
	
}

/*
Hew [X+1]
Type and Tags: U S Sw ATTACK WEAPON
Requirements: Using a weapon with a Swing TN.
Maneuver: Attack at weapon’s reach, at weapon Swing TN,
targeting opponent’s shield with X dice.
Success: Opponent suffers [BS] stun. Opponent’s shield
sustains damage equal to [SDB+weapon swing damage+BS]
against its durability. If the damage equals or exceeds its
durability, the shield is destroyed and any excess damage
is applied to the opponent’s shield-arm (roll on the lower
arm Swinging Target Zone for exact hit location). Each time
a shield sustains a Hew attempt that does not destroy it, its
durability is permanently reduced by 2.
Special: Blocking maneuvers made to defend against this
maneuver are made at +1 TN.
Superior: If this Hew fails to destroy a shield it hits, it instead
reduces that shield’s durability by the damage inflicted,
with a minimum of 2.
*/