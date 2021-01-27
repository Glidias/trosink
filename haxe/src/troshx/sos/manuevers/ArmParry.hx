package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.components.Bout.FightNode;
import troshx.core.ManueverSpec;
import troshx.sos.core.BodyChar.Humanoid;
import troshx.sos.core.DamageType;
import troshx.sos.core.Manuever;
import troshx.sos.core.Shield;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class ArmParry extends Manuever
{

	public function new() 
	{
		super("armParry", "Arm Parry");
		_types(Manuever.TYPE_DEFENSIVE)._requisite(Manuever.REQ_UNARMED)._tags(Manuever.TAG_PARRY)._tn(7)._superiorInit(function(m){m._tn(6);});
	}
	
	override public function getTN(spec:ManueverSpec):Int {
		var tn:Int = super.getTN(spec);
		if (tn < 0) return tn;
		var usingLeftLimb:Bool = spec.usingLeftLimb;
		if ( spec.replyTo != null &&  // always getTN refresh needed upon resolved if manuever is floated
			((spec.replyTo.targetZone == Humanoid.SWING_UPPER_ARM || spec.replyTo.targetZone == Humanoid.SWING_LOWER_ARM || spec.replyTo.targetZone == Humanoid.THRUST_LOWER_ARM || spec.replyTo.targetZone == Humanoid.THRUST_UPPER_ARM) 
			&& spec.replyTo.targetZonePreferLeft == usingLeftLimb)
		) {
			tn++;
		}
		return tn;
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var shield:Shield = LibUtil.as(spec.activeItem, Shield);
		return shield == null;
	}
	
}

/*
Arm Parry [X]
Type and Tags: U S DEFENSE UNARMED PARRY
Requirement: Have an arm that extends (at least) to the
forearm (prosthetics can be used for this) available to
parry. This arm cannot be holding or wearing a shield.
Maneuver: Defense at TN 7, with X dice. If you are using
this maneuver without initiative, declare it against
an opponents attack.
Success: Opponent’s attack is negated. If opponent’s attack
was a swinging or thrusting maneuver, it inflicts a Swing or
Thrust to parrying limb with 0 BS. Total damage is reduced
by Arm Parry BS.
Failure: Opponent’s attack resolves with damage reduced by
successes. If opponent’s attack was a swinging or thrusting
maneuver, it inflicts a Swing or Thrust to the lower arm
target zone of the parrying limb with 0 BS in addition to
the opponent’s attack.
Special: If Arm Parry is used against an attack targeting the
limb used for Arm Parry, the Arm Parry TN increases to 8.
Superior: Arm Parry now resolves at -1 TN.
*/