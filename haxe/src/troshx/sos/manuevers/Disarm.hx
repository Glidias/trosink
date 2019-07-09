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
class Disarm extends Manuever
{

	public function new() 
	{
		super("disarm", "Disarm (Weapon)");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._costs(1)._attackTypes(Manuever.ATTACK_TYPE_SWING)._targetZoneMode(Manuever.TARGET_ZONE_WEAPON)._superior();
		
	}
}
/*
Disarm (Weapon) [X+1]
Type and Tags: U S ATTACK WEAPON
Requirements: Using a weapon with a Swing TN. Opponent
is using a weapon.
Maneuver: Attack at weapon’s reach, at Swing TN, targeting
opponent’s weapon with X dice.
Success: Opponent suffers [BS] stun. Opponent must make an
AGI test at [BS] RS. If this test is failed, the targeted weapon
is removed from the opponent’s grasp, and either retained
by you, dropped at your feet, or thrown several yards away.
Special: If an opponent’s weapon is a 2H weapon, the opponent gains a +1 bonus to his AGI test.
Superior: When disarming an opponent with a 2H weapon,
they do not gain the normal +1 bonus to the AGI test.
Dusan has declared a Disarm with 8 dice, and Mirza has
declared a Parry with 7. Dusan scores 4 successes to Mirza’s
2. Mirza must now make an AGI test at 2 RS (2 BS). He has 5
AGI, but only rolls 1 success. He is disarmed, suffers 2 stun,
and his weapon lands some distance away. 
*/



class DisarmUnarmedAtk extends Manuever 
{

	public function new() 
	{
		super("disarmUnarmedAtk", "Disarmed (Unarmed, Attack)");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_UNARMED)._targetZoneMode(Manuever.TARGET_ZONE_WEAPON)._costs(1)._reach(Weapon.REACH_H)._tn(7)._superiorInit(function(m){m._tn(6); });
		
	}
}
/*
Disarm (Unarmed, Attack) [X+1]
Type and Tags: U S ATTACK UNARMED
Requirements: Have a hand available and ready to strike.
Maneuver: Attack at H-reach, at TN 7, targeting opponent’s
weapon with X dice.
Success: Opponent must make an AGI test with [BS] RS. If
this test is failed, the targeted weapon is removed from
the opponent’s grasp, and either retained by you, dropped
at your feet, or thrown several yards away.
Special: If an opponent’s weapon is a 2H weapon, the opponent gains a +1 bonus to his AGI test.
Superior: This maneuver is performed at -1 TN
*/

class DisarmUnarmedDef extends Manuever 
{

	public function new() 
	{
		super("disarmUnarmedDef", "Disarmed (Unarmed, Defend)");
		_types(Manuever.TYPE_DEFENSIVE)._requisite(Manuever.REQ_UNARMED)._tags(Manuever.TAG_PARRY)._costs(1)._reach(Weapon.REACH_H)._tn(8)._superiorInit(function(m){m._tn(7); });
	}
}
/*
Disarm (Unarmed, Defense) [X+1]
Type and Tags: U S DEFENSE UNARMED PARRY
Requirements: Have a hand available and ready to parry.
Maneuver: Defense at H-reach, at TN 8, targeting opponent’s
weapon.
Success: Opponent must make an AGI test with [BS] RS. If
this test is failed, the targeted weapon is removed from
the opponent’s grasp, and either retained by you, dropped
at your feet, or thrown several yards away.
Special: If an opponent’s weapon is a 2H weapon, the opponent gains a +1 bonus to his AGI test.
Superior: This maneuver is done at -1 TN
*/