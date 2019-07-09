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
class CleavingBlow extends Manuever
{

	public function new() 
	{
		super("cleavingBlow", "Cleaving Blow");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._attackTypes(Manuever.ATTACK_TYPE_SWING)._tags(Manuever.TAG_CROSS_FIGHTING)._costs(2, Manuever.DEFER_COST);
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var weapon:Weapon = spec.activeItem;
		var multipleOpp:Bool = bout.countLinkedOpponents(node) > 1;
		return weapon.reach >= Weapon.REACH_L && multipleOpp;
	}
	
}

/*
Cleaving Blow [2]
Type and Tags: U ATTACK WEAPON CROSS-FIGHTING
Requirements: Using a weapon of L-reach or greater
with a Swing TN, facing multiple opponents in combat
simultaneously.
Maneuver: At any time that a Swing is successful and the
requirements are met, you may pay the Cleaving Blow
activation cost to immediately (in the same move) declare
and resolve a Swing maneuver against new target with a
number of dice equal to the BS of the previous attack. If the
new target is at the same reach as the previous target, you
do not need to pay reach costs. If the target is at a different
reach, you must pay the difference between the previous
target and the new target’s reach.
You may add additional dice to this maneuver at a 2:1
ratio (2 CP spent for 1 CP added). You may continue doing
this until you are out of CP, and potential targets
*/