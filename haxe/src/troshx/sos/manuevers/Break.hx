package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.sos.core.Manuever;

/**
 * ...
 * @author Glidias
 */
class Break extends Manuever
{

	public function new() 
	{
		super("break", "Break");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._attackTypes(Manuever.ATTACK_TYPE_SWING)._targetZoneMode(Manuever.TARGET_ZONE_WEAPON)._costs(2)._superior();
	}
	
}

/*
Break [X+2]
Type and Tags: U S ATTACK WEAPON
Requirements: Using a weapon with a Swing TN. Opponent
is using a weapon.
Maneuver: Attack at weapon’s reach, at Swing TN, targeting
opponent’s weapon with X dice.
Success: Opponent’s weapon sustains damage equal to
[SDB+weapon swing damage+half BS]. If the amount of
damage dealt is equal to or exceeds the damage threshold
for the targeted weapon (thresholds listed below), it breaks,
and becomes useless, except as a potential improvised
weapon. This is all-or-nothing: either the weapon breaks,
or there is no effect. At the GM’s discretion, a spear or
polearm may effectively become a quarterstaff after being
broken, and a wood-hafted blunt weapon may become a
truncheon, and so on.
Special: This maneuver ignores reach modifiers. The user does
not move to their weapon’s reach on a successful attack, but
may if the opponent’s weapon is broken.
Superior: Break inflicts +2 additional damage.
Weapon Damage Threshold
Wood-hafted blunt weapon 10
Spear or polearm 10
Langetted/reinforced spear or polearm 12
Dagger or knife 12
Sword with the Light Blade quality 15
Metal-hafted blunt weapon 15
Sword 20
*/