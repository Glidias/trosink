package troshx.sos.events;

import troshx.sos.core.Armor;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.Skill;
import troshx.ds.ValueHolder;
import troshx.sos.core.Wound;
import troshx.sos.sheets.CharSheet;
import troshx.sos.core.Weapon;
/**
 * DRAFT:
 * A record of syncronous RPG events from which respective modifiers under Item Specials
 * Manuevers, and Boons/Banes can hook into them for buffing/debuffing or modifying existing
 * behaviour.
 * 
 * Events handler may then dispatch any other notifications whenever appropriate.
 * Usually, they shoudl not dispatch another event.
 * 
 * How to actually go about implementing this draft is still under consideration,
 * likely some form of event bus?
 * 
 * @author Glidias
 */
enum SOSEvent
{
	FATIQUE_GAIN(char:CharSheet, fatique:ValueHolder<Int>);
	
	MELEE_INITIATIVE_TEST(from:CharSheet, target:CharSheet);  // Bout/FightState to include in
	
	MISS_TARGET(from:CharSheet, target:CharSheet, ?ammo:Weapon);  // executed manuever, manuever's total successes tally 
	HIT_TARGET(from:CharSheet, target:CharSheet, ?ammo:Weapon);  // exectued manueer, manuever's total successes tally with calculaeted NetDamage
	HIT_TARGET_ARMOR(from:CharSheet, target:CharSheet, armor:Armor, ?ammo:Weapon);  // exectued manueer, manuever's total successes tally with calculaeted NetDamage
	DAMAGE_TARGET_RESOLVE(from:CharSheet, target:CharSheet, armor:Armor, ?ammo:Weapon);  // result damage after NetDamage being reduced by Armor and any other protections from target char
	
	WOUND_INFLICT(char:CharSheet, w:Wound);  // may modify wound and effectively nullify it before it gets processed
	
	MELEE_EXCHANGE_RESOLVE;
	MELEE_BOUT_RESOLVE;
	
	// a challenge that may involve 1 or more skills or/and attributes
	CHALLENGE_INIT(?attributes:Int, ?skills:Array<Skill>, challenge:Challenge);
	CHALLENGE_EXECUTE(char:CharSheet, ?attributes:Int, ?skills:Array<Skill>, challenge:Challenge);
	

	
}
