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
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._attackTypes(Manuever.ATTACK_TYPE_SWING)._targetZoneMode(Manuever.TARGET_ZONE_WEAPON)._superior();
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