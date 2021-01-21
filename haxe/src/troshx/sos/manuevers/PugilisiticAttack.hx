package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.core.ManueverSpec;
import troshx.sos.core.BodyChar.Humanoid;
import troshx.sos.core.DamageType;
import troshx.sos.core.Manuever;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;

/**
 * 
 * @author Glidias
 */

 class PugilisiticAttack extends Manuever {
	public function new(id:String, name:String) 
	{
		super(id, name);
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_UNARMED);
	}
 }
 
 
 // Swing only
 
 class HookPunch extends PugilisiticAttack {
	public function new() 
	{
		super("hookPunch", "Hook Punch");
		_reach(Weapon.REACH_HA)._tn(6)._attackTypes(Manuever.ATTACK_TYPE_SWING)._damage(DamageType.UNARMED, 1)._superiorInit(function(m){m._damage(DamageType.UNARMED, 2, 2); });
	}
 }
 /*
 Hook Punch [X]
Type and Tags: U S Sw ATTACK UNARMED
Requirements: Have a hand available and ready to strike. This
can be done while holding a weapon, at the GM’s discretion.
Maneuver: Attack at HA-reach, at TN 6, targeting opponent
with X dice. Roll on the Swinging Target Zone for the hit
location.
Success: Inflicts unarmed damage equal to [SDB-1+BS] to hit
location. Half the damage done is inflicted back on your
hand. If you strike a hard surface (metal armor, the upper
head, a shield) you receive full damage back on your hand.
Failure: If defended with a Parry maneuver, suffer a Swing or
Thrust (opponent’s choice, GM adjudicates) to punching arm
with dice equal to half the defense maneuver’s successes
from parrying weapon or shield.
Special: If hand is armored in metal, or has brass knuckles/
knuckledusters, add +2 to damage, and suffer no damage
back on the hand. If you have Superior Hook Punch, you
inflict +1 additional stun as well.
If aiming a Hook Punch below the waist, the activation
cost for the maneuver increases by 1.
Superior: Your punches now inflict an additional +1 damage,
and inflict 2 stun.
*/
 
 // Thrust only
 
class StraightPunch extends PugilisiticAttack {
	public function new() 
	{
		super("straightPunch", "Straight Punch");
		_reach(Weapon.REACH_H)._tn(6)._attackTypes(Manuever.ATTACK_TYPE_THRUST)._damage(DamageType.UNARMED, 2)._superiorInit(function(m){m._damage(DamageType.UNARMED, 3, 1); });
	}
 }
 /* Straight Punch [X]
Type and Tags: U S Th ATTACK UNARMED
Requirements: Have a hand available and ready to punch.
This can be done while holding a weapon, at the GM’s
discretion.
Maneuver: Attack at H-reach, at TN 6, targeting opponent
with X dice. Roll on the Thrusting Target Zone for the hit
location.
Success: Inflicts unarmed damage equal to [SDB-2+BS] to hit
location. Half the damage done is inflicted back on your
hand. If you strike a hard surface (metal armor, the upper
head, a shield) you receive full damage back on your hand.
Failure: If defended with a Parry maneuver, suffer a Swing or
Thrust (opponent’s choice, GM adjudicates) to punching arm
with dice equal to half the defense maneuver’s successes
from parrying weapon.
Special: If hand is armored in metal, or has brass knuckles/
knuckledusters, add +2 to damage, and suffer no damage
back on your hand. If you have Superior Straight Punch, you
inflict +1 additional stun as well.
When rolling an initiative test to determine attack order
while making a Straight Punch, you may roll 1 additional
dice in the test.
If aiming a Straight Punch below the belly, the activation
cost for the maneuver increases by 1.
Superior: Your punches now inflict an additional +1 damage,
and inflict +1 stun.
*/

 
 class Knee extends PugilisiticAttack {
	public function new() 
	{
		super("knee", "Knee");
		_reach(Weapon.REACH_HA)._tn(7)._attackTypes(Manuever.ATTACK_TYPE_THRUST)._damage(DamageType.UNARMED, 1)._superiorInit(function(m){m._damage(DamageType.UNARMED, 3); });
	}
 }
  /*
 Knee [X]
Type and Tags: U S Th ATTACK UNARMED
Requirements: Have a leg available and ready to knee.
Maneuver: Attack at HA-reach, at TN 7, targeting opponent
with X dice. Roll on the Thrusting Target Zone for the hit
location.
Success: Inflicts unarmed damage equal to [SDB+1+BS] to hit
location.
Failure: If defended with a Parry maneuver, suffer a Swing or
Thrust (opponent’s choice, GM adjudicates) to kneeing leg
with dice equal to half the defense maneuver’s successes
from parrying weapon or shield.
Special: If aiming a Knee above the waist, the activation cost
increases by 2.
If wearing metal knee armor, add +1 to damage.
Superior: Your Knees now inflict an additional +2 damage.
*/
 
 
class HeadButt extends PugilisiticAttack {
	public function new() 
	{
		super("headbutt", "Headbutt");
		_reach(Weapon.REACH_HA)._tn(6)._attackTypes(Manuever.ATTACK_TYPE_THRUST)._targetZoneMode(Manuever.specificTargetZoneModeMask((1 << Humanoid.THRUST_HEAD) | (1 << Humanoid.THRUST_CHEST)))._damage(DamageType.UNARMED, 1)._costs(1);
	}
 }
 /*Headbutt [X+1]
Type and Tags: U Th ATTACK UNARMED
Requirements: None. No hands required!
Maneuver: Attack at HA-reach, at TN 6, targeting opponent
with X dice. Maneuver must be aimed at either the face or
chest Thrusting Target Zones.
Success: Inflicts unarmed damage equal to [SDB-1+BS] to hit
location. Target suffers [BS] stun. Half of the damage done
is inflicted back on your upper head. You suffer [half BS]
stun.
Failure: If defended with a Parry maneuver, suffer a Swing or
Thrust (opponent’s choice, GM adjudicates) to upper head
with dice equal to half the defense maneuver’s successes
from the parrying weapon. If defended with a Block
maneuver, suffer a Shield Bash to the upper head with dice
equal to half the defense maneuver’s successes from the
shield used.
Special: If the head is protected with a helmet (chain coifs
do not count) the head receives no damage or stun back
upon it from this attack, and the Headbutt instead inflicts
[SDB+0+BS] damage.
*/
 

 
// Both swing/thrust
 
class Elbow extends PugilisiticAttack {
	public function new() 
	{
		super("elbow", "Elbow");
		_reach(Weapon.REACH_HA)._tn(7)._attackTypes(Manuever.ATTACK_TYPE_SWING | Manuever.ATTACK_TYPE_THRUST)._damage(DamageType.UNARMED, 0)._superiorInit(function(m){m._damage(DamageType.UNARMED, 2); });
		
	}
 }
 /* Elbow [X]
Type and Tags: U S Sw Th ATTACK UNARMED
Requirements: Have an arm available and ready to strike.
This can be performed while holding a weapon, at the GM’s
discretion.
Maneuver: Attack at HA-reach, at TN 7, targeting opponent
with X dice. Use the Swinging Target Zones or Thrusting
Target Zones for the hit location, as appropriate.
Success: Inflicts unarmed damage equal to [SDB+0+BS] to hit
location.
Failure: If defended with a Parry maneuver, suffer a Swing or
Thrust (opponent’s choice, GM adjudicates) to elbowing arm
with dice equal to half the defense maneuvers successes
from the parrying weapon.
Special: If elbow is armored in metal, add +1 to damage.
If aiming an elbow below the waist, the activation cost
for this maneuver increases by 1.
Superior: Your elbows now inflict an additional +2 damage.
*/
  
class Kick extends PugilisiticAttack {
	public function new() 
	{
		super("kick", "Kick");
		_reach(Weapon.REACH_S)._tn(7)._attackTypes(Manuever.ATTACK_TYPE_SWING | Manuever.ATTACK_TYPE_THRUST)._damage(DamageType.UNARMED, 0)._superiorInit(function(m){m._damage(DamageType.UNARMED, 2); });
	}
 }
 /*
 Kick [X]
Type and Tags: U S Sw Th ATTACK UNARMED
Requirements: Have a leg available and ready to kick.
Maneuver: Attack at S-reach, at TN 7, targeting opponent
with X dice. Roll on the Swinging Target Zone or Thrusting
Target Zone for the hit location, as appropriate.
Success: Inflicts unarmed damage equal to [SDB+0+BS] to hit
location. Target must make a stability check at BS or be
rendered prone.
Failure: If defended with a Parry maneuver, suffer a Swing or
Thrust (opponent’s choice, GM adjudicates) to kicking leg
with dice equal to half the defense maneuver’s successes
from parrying weapon or shield.
Special: Kicks are normally aimed at the belly, legs or groin.
If aimed higher on standing targets, there is an additional
activation cost of 1.
If making a thrusting Kick against a prone target, add
+2 damage.
If wearing sabatons or steel boots, add +1 to damage.
Superior: Your Kicks now inflict an additional +2 damage.
*/

 // Swing/thrust specific
 class Trip extends PugilisiticAttack {
	public function new() 
	{
		super("trip", "Trip");
		_reach(Weapon.REACH_HA)._tn(8)._attackTypes(Manuever.ATTACK_TYPE_SWING | Manuever.ATTACK_TYPE_THRUST)._targetZoneMode(Manuever.specificTargetZoneModeMask((1 << Humanoid.SWING_UPPER_LEG) | (1 << Humanoid.SWING_LOWER_LEG)))._superior();
	}
 }
 /* Trip [X]
 Type and Tags: U S ATTACK UNARMED
Requirement: Have the means to trip an opponent.
Maneuver: Attack at HA-reach, at TN 8, targeting opponent’s
legs.
Success: Opponent must make a stability check at [2+BS] RS
or be rendered prone.
Special: This maneuver may not be defended with a Block or
Parry; it can only be defended with a Void maneuver.
Superior: If your opponent fails the stability check, you automatically disarm them as per Disarm (Unarmed, Attack).
*/
 
 
class OneTwoPunch extends PugilisiticAttack {
	public function new() {
		super("oneTwoPunch", "One-Two Punch");
		//_types(0).
		_costs(2, Manuever.DEFER_COST);
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		// todo: left handed might be using a differnet master hand item?
		var otherHandItem = spec.usingLeftLimb ? node.charSheet.inventory.findMasterHandItem() : node.charSheet.inventory.findOffHandItem();
		return otherHandItem == null;
	}
}
 /*
 One-Two Punch [X+2]
Type and Tags: A ATTACK UNARMED
Requirements: Have two hands available and ready to strike.
This can be done while holding weapons, at GM’s discretion.
Maneuver: Activate this maneuver after resolving a Hook
Punch or Straight Punch, Pay 2 CP, and immediately declare
a second maneuver of the same type to the same target
zone with X. X cannot be more than the dice devoted to the
original maneuver. This new Punch resolves in the same
move, at the same initiative, as the first Punch. The target’s
defense to the original Punch (if any) is used against this
second Punch without rolling, at the same successes as the
original. The target may declare a Quick Defense to add dice
to the original defense, but if this is done, all dice must be
re-rolled at the new TN for Quick Defense.
Special: You may declare another One-Two Punch after
resolving one, however, you must pay the costs again.
*/