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
class PushCut extends Manuever
{

	public function new() 
	{
		super("pushCut", "Push Cut");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._attackTypes(Manuever.ATTACK_TYPE_THRUST)._costs(1)._superior();
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var weapon:Weapon = spec.activeItem; 
		return weapon.atnS > 0 && weapon.damageTypeS == DamageType.CUTTING; // && weapon.atnT > 0 // not needed due to built-in this.getRequisiteTN() 
	}
}
/*
 * Push Cut [X+1]
Type and Tags: U S Th ATTACK WEAPON
Requirements: Using a weapon with both a Thrust TN, and a
Swing TN that inflicts cutting damage.
Maneuver: Attack at weapon’s reach, at Thrust TN, targeting
opponent with X dice. Roll on the Thrusting Target Zone
for the hit location.
Success: Inflicts cutting damage equal to [SDB+weapon swing
damage-1+BS] to hit location.
Special: When rolling an initiative test to determine attack
order while making a Push Cut, you may roll 1 additional
dice in the test.
This attack does not apply AP Swing, AP Thrust, Crushing,
or Shock effects. However, it does apply Draw damage.
Superior: When performing a Push Cut, reduce the number of
BS needed to trigger Draw by 1.
*/