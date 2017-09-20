package troshx.sos.chargen;
import haxe.ds.StringMap;
import troshx.sos.core.Skill;
import troshx.util.LibUtil;

/**
 * Just to store default setup of Character generation's skill packets
 * @author Glidias
 */
class CharGenSkillPackets 
{

	public static function getNewSkillPackets():Array<SkillPacket> {
		return [
			{
				name: "Academic", qty: 0,
				values: {
					"~academic1":1,
					"~academic2":1,
					"Research":1,
					"~academicLast":1,
				},
			},
			{
				name:"Athlete", qty:0,
				values: {
					"Athletics":2,
					"Climbing": 1,
					"Swimming": 1
				},
			},
			{
				name:"Farmer", qty:0,
				values: strMapValues([
					Skill.specialisationName("Profession", "Farmer") => 2,
					Skill.specialisationName("Crafting", "Wood") => 1,
					"Cooking" => 1
				]),
			},
			{
				name:"Tradesman", qty:0,
				values: strMapValues([
					Skill.specialisationName("Profession", "Trade") => 2,
					Skill.specialisationName("Crafting", "Trade") => 1,
					"Persuasion" => 1
				]),
			},
			{
				name:"Merchant", qty:0,
				values: strMapValues([
					Skill.specialisationName("Knowledge", "Finance") => 2,
					"Etiquette" => 1,
					"Persuasion" => 1
				]),
			},
			{
				name:"Thief", qty:0,
				values: {
					"Stealth":1,
					"Thievery":2,
					"Observation": 1
				},
			},
			{
				name:"Criminal", qty:0,
				values: strMapValues([
					"Gather Information" => 1,
					"Intimidation" => 1,
					"Observation" => 1,
					Skill.specialisationName("Knowledge", "Criminal") => 1,
				]),
			},
			{
				name:"Hunter", qty:0,
				values: {
					"~hunter1":1,
					"Navigation": 1,
					"Hunting": 2,
				},
			},
			{
				name:"Guard", qty:0,
				values: strMapValues([
					"Intimidation" => 1,
					Skill.specialisationName("Knowledge", "Criminal") => 1,
					"Observation" => 2,
				]),
			},
			{
				name:"Soldier", qty:0,
				values: {
					"~soldier1":1,
					"Tactics": 1,
					"Drill": 2,
				},
			},
			{
				name:"Surgeon", qty:0,
				values: strMapValues([
					"Surgery" => 2,
					"Chymistry" => 1,
					Skill.specialisationName("Profession", "Doctor") => 1,
				]),
			},
			{
				name:"Officer", qty:0,
				values: {
					"Drill":1,
					"Tactics": 1,
					"Navigation": 1,
					"Strategy": 1,
				},
			},
			{
				name:"Sailor", qty:0,
				values: strMapValues([
					"Sailing" => 2,
					Skill.specialisationName("Profession", "Sailing") => 1,
					"Navigation" => 1,
				]),
			},
			{
				name:"Scout", qty:0,
				values: {
					"~scout1":1,
					"Stealth": 1,
					"Navigation": 1,
					"Observation": 1
				},
			},
			{
				name:"Politician", qty:0,
				values: strMapValues([
					"Etiquette" => 1,
					Skill.specialisationName("Knowledge", "Politics") => 1,
					"Oration" => 1,
					"Persuasion" => 1,
				]),
			},
			{
				name:"Nobleman", qty:0,
				values: strMapValues([
					Skill.specialisationName("Knowledge", "Nobility") => 1,
					"Etiquette" => 1,
					Skill.specialisationName("Knowledge", "Politics") => 1,
					"Persuasion" => 1,
				]),
			},
			{
				name:"Domestic", qty:0,
				values: strMapValues([
					"Cooking" => 2,
					Skill.specialisationName("Crafting", "Homestead") => 2,
				]),
			}
		];
	}
	

	public static function getExistingSubjects():Array<String> {
		return [	// hardcoded 
			"Farmer",
			"Trade",
			"Finance",
			"Wood",
			"Homestead",
			"Criminal",
			"Nobility",
			"Politics",
			"Sailing",
			"Doctor"
		];
	}
	
	
	public static function getNewSkillLabelMappingBases():Dynamic {
		return {
		"~academic1":"Knowledge",
		"~academic2":"Knowledge",
		"~academicLast":["Engineering", Skill.specialisationName("Knowledge", "Politics"), "Chymistry" ],
		"~soldier1": ["Athletics", "Ride"],
		"~scout1": ["Athletics", "Ride"],
		"~hunter1": ["Stealth", "Ride"]
		};
	}
	
	public static function strMapValues(str:StringMap<Int>):Dynamic<Int> {
		var dyn:Dynamic<Int> = {};
		for (p in str.keys()) {
			LibUtil.setField( dyn, p, str.get(p) );
		}
		return dyn;
	}
	
		
	public inline static function isSkillLabelBinded(s:String):Bool {
		return s.charAt(0) == "~";
	}
	
	/**
	 * 
	 * @param	s	The string id if needs to be binded to something else
	 * @param	skillLabelMappingBases	Schema
	 * @param 	skillLabelMappings The string values to resolve to schema
	 * @return
	 */
	public  static function getSkillLabel(s:String, skillLabelMappingBases:Dynamic, skillLabelMappings:Dynamic<String>):String {
		return isSkillLabelBinded(s) ? Std.is(LibUtil.field(skillLabelMappingBases,s), String) ? LibUtil.field(skillLabelMappingBases,s) + Skill.CHARS_SPECIAL_OPEN+ LibUtil.field(skillLabelMappings, s)+Skill.CHARS_SPECIAL_CLOSE :  LibUtil.field(skillLabelMappings, s) : s;
	}
	
	
}