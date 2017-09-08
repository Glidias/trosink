package troshx.sos.events;
import troshx.sos.core.Armor;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.BoonBane.BoonAssign;
import troshx.sos.core.Skill;
import troshx.sos.core.Wound;
import troshx.sos.sheets.CharSheet;

/**
 * Draft:
 * Notifications can be dispatched from event handlers or anywhere else in the code. 
 * 
 * Sound effects and other visual ux aspects may play in response to these notifications.
 * 
 * Unlike events, all notifications  by default are  USUALLY pre-stacked beforehand, and only dispatch after all event handlers  along the chain are resolved.  This depends on the nature of the SOSNotification itself
 * and is handled by the SOSEventBus accordingly.
 * 
 * This behaviour may be foregoed for instant SOS notification call, if needed.
 * 
 * @author Glidias
 */
enum SOSNotification
{
	// these triggers should be id-masked to avoid duplicates/repeats
	BOON_TRIGGERED(boon:BoonAssign); 
	BANE_TRIGGERED(bane:BaneAssign);
	
	BANE_REMOVED(bane:BaneAssign);
	BANE_ADDED(bane:BaneAssign);
	
	BOON_REMOVED(boon:BoonAssign);
	BOON_ADDED(boon:BoonAssign);
		
	HIT_TARGET_RESOLVED(from:CharSheet, target:CharSheet);  // full results tally to include it. Also, after all damage is resolved on target.
	MELEE_EXCHANGE_RESOLVED;   // to include bout parameter and all tallied results for all combatants
	MELEE_ROUND_RESOLVED;  // to include bout parameter and all tallied results  for all combatants

	CHALLENGE_RESOLVED(?attributes:Int, ?skills:Array<Skill>, challenge:Challenge);
	
	///*
	//SKIRMISH_PHASE_ACTION_TURN_RESOLVED;
	//SKIRMISH_PHASE_MOVEMENT_TURN_RESOLVED;
	SKIRMISH_PHASE_RESOLVED;
	SKIRMISH_ROUND_RESOLVED; 
	//*/
}