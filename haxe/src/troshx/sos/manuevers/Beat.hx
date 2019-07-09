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
class Beat extends Manuever
{

	public function new() 
	{
		super("beat", "Beat");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._attackTypes(Manuever.ATTACK_TYPE_SWING)._targetZoneMode(Manuever.TARGET_ZONE_WEAPON | Manuever.TARGET_ZONE_SHIELD)._superior();
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var tempo:Bool = !bout.secondTempo;
		var round:Bool = isSuperior ? true : bout.roundCount < 2;
		return tempo && round;
	}
	
}

/*
Beat [X]
Type and Tags: U S ATTACK WEAPON
Requirements: Using weapon with a Swing TN. It must be the
first bout and move after orientation declaration, and you
must have declared aggressive.
Maneuver: Attack at weapon’s Swing TN, targeting opponent’s
weapon or shield with X dice. Halve all reach costs for this
maneuver. For initiative tests involving this maneuver, do
not add reach advantage to the roll.
Success: Opponent suffers [BS] stun. Target cannot use
targeted weapon or shield to perform any maneuver until
the refresh. Shields are knocked out of their shield position
until the refresh. This attack does not change the reach
of combat.
Superior: If you have initiative, you may now declare this
maneuver in the first move of any bout. You still need to
have declared aggressive to use Beat in the first move after
orientation, but this does not apply in later bouts.
*/

class ShieldBeat extends Manuever
{

	public function new() 
	{
		super("shieldBeat", "Shield Beat");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_SHIELD)._attackTypes(0)._targetZoneMode(Manuever.TARGET_ZONE_WEAPON | Manuever.TARGET_ZONE_SHIELD)._reach(Weapon.REACH_S)._costs(2);
	}
	
}
/*
Shield Beat [X+2]
Type and Tags: U ATTACK SHIELD BASH
Requirements: Using a shield.
Maneuver: Attack at S-reach, at Shield Bash TN, targeting
opponent’s weapon or shield.
Success (Weapon): Target weapon cannot be used as part
of any maneuvers in the next move. You cannot perform
maneuvers with your shield in the next move. This does
not change the reach of combat.
Success (Shield): Target shield does not grant AV for this or
the next move, and cannot be used to Block for the next
move. Your shield is knocked out of its shield position next
move. This does not change the reach of combat.
*/