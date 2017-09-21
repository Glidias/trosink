package troshx.sos.core;
import troshx.util.LibUtil;

/**

 * For Skills, i decided to adopt a primarily non-object oriented approach to managing a hash of skills.
 * 
 * There is primarily no dedicated Skill instance class to be used. 
 * 
 * Skills simply exist under a SkillTable.
 * A "skill" is identified by it's String hash id under the SkillTable which is simply it's title, and links to vairous attributes
 * that may be used under that given skill (or a skill level). So, it's more like a stringly-typed lookup table for any sort of skill.
 * 
 * There can be countless "skills" a game character may have, whether "official" or not, and each
 * character may unofficially contain his own SkillTable using a different "universe" set of rules.
 * 
 * Each character than contains his own set of skill assignments, also using another SkillTable class instance to store 
 * his own set of skills to match against his skill level.
 * 
 * There's a default SoS SkillTable bundled in here.
 * 
 * Stringly typed skills can be pretty dangerous. It might be best in the future to also include a hardcoded SkillName lookup table of strings 
 * to avoid typos.
 * 
 * @author Glidias
 */
class Skill 
{
	// Ingamae, charSheet to generate switch case table to perform Attribute lookup with ATR()....
	@:attrib("Strength") public static inline var STR:Int = (1<< 0);
	@:attrib("Agility") public static inline var AGI:Int = (1<< 1);
	@:attrib("Endurance") public static inline var END:Int  = (1<< 2);
	@:attrib("Health") public static inline var HLT:Int  = (1<< 3);
	@:attrib("Willpower") public static inline var WIP:Int  = (1<<4);
	@:attrib("Wit") public static inline var WIT:Int =  (1<< 5);
	@:attrib("Intelligence") public static inline var INT:Int  = (1<< 6);
	@:attrib("Perception") public static inline var PER:Int  = (1 << 7);
	@:attrib("Charisma") public static inline var CHA:Int  = (1 << 8); 
	
	public static inline var TRAINED:Int = 1;
	public static inline var TEACHER:Int = 4;
	public static inline var MASTERY:Int = 10;
	
	public static inline function isVarious(n:Int):Bool {
		return (n & (n - 1)) != 0;
	}
	
	public static inline var CHARS_SPECIAL_OPEN:String = " (";
	public static inline var CHARS_SPECIAL_CLOSE:String = ")";
	
	public static inline function specialisationName(base:String, special:String):String {
		return base + CHARS_SPECIAL_OPEN + special + CHARS_SPECIAL_CLOSE;
	}
	
	/**
	 * This approach only checks for opening set of characters, might yield false positives to find given base of specialisation name
	 * but is useful for quick naive checks
	 * @param	name
	 * @return
	 */
	public static inline function getBaseFromSpecialisationNaive(name:String):String {
		var index:Int = name.indexOf(CHARS_SPECIAL_OPEN);
		return index > 0 ? name.substring(0, index) : null;
	}
	
	/**
	 * This approach  checks for opening and ending set of characters to find given base of specialisation name
	 * @param	name
	 * @return
	 */
	public static function getBaseFromSpecialisation(name:String):String {
		var index:Int = name.indexOf(CHARS_SPECIAL_OPEN);
		var len:Int = CHARS_SPECIAL_OPEN.length + CHARS_SPECIAL_CLOSE.length;
		return index > 0 && name.length > len &&  name.substr(name.length - CHARS_SPECIAL_CLOSE.length) == CHARS_SPECIAL_CLOSE ? name.substring(0,index) : null;
	}
	
	/**
	 * This approach checks for opening and ending set of characters to find given base and special tag of specialisation name
	 * @param	name
	 * @return
	 */
	public static function getSplitFromSpecialisation(name:String):Array<String> {
		var index:Int = name.indexOf(CHARS_SPECIAL_OPEN);
		var len:Int = CHARS_SPECIAL_OPEN.length + CHARS_SPECIAL_CLOSE.length;
		return index > 0 && name.length > len &&  name.substr(name.length - CHARS_SPECIAL_CLOSE.length) == CHARS_SPECIAL_CLOSE ? [name.substring(0,index), name.substring(index+CHARS_SPECIAL_OPEN.length, name.length - CHARS_SPECIAL_CLOSE.length) ] : null;
	}
	
	/*		// dupplicate yagni
	public static function getSubjectFromSpecialisation(name:String):Array<String> {
		var index:Int = name.indexOf(CHARS_SPECIAL_OPEN);
		var len:Int = CHARS_SPECIAL_OPEN.length + CHARS_SPECIAL_CLOSE.length;
		return index > 0 && name.length > len &&  name.substr(name.length - CHARS_SPECIAL_CLOSE.length) == CHARS_SPECIAL_CLOSE ? name.substring(index+CHARS_SPECIAL_OPEN.length, name.length - CHARS_SPECIAL_CLOSE.length) : null;
	}
	*/
}




class SkillTable
{
	public var skillHash:Dynamic<Int>;
	public var requiresTrained:Dynamic<Bool>;
	public var requiresSpecialisation:Dynamic<Bool>;
	
	function new() {
		
	}
	
	public static function getNewEmptySkillTable( withRules:SkillTable=null):SkillTable {
		var s:SkillTable = new SkillTable();
		s.skillHash = {};
	
		if (withRules!=null) {
			s.matchRulesWith(withRules);
		}
		else {
			s.requiresTrained = {};
			s.requiresSpecialisation = {};
		}
	
		return s;
	}
	
	static var DEFAULT:SkillTable;
	public static function getDefaultSkillTable():SkillTable {
		return DEFAULT != null ? DEFAULT : (DEFAULT = getNewDefaultSkillTable());
	}
	public static function getNewDefaultSkillTable():SkillTable {
		var s:SkillTable = new SkillTable();
		s.skillHash = {
			"Athletics": Skill.STR | Skill.AGI | Skill.END,
			"Chymistry": Skill.INT,
			"Climbing": Skill.END,
			"Cooking": Skill.INT,
			"Crafting": Skill.INT,
			"Drill": Skill.WIP,
			"Engineering": Skill.INT,
			"Etiquette": Skill.WIT,
			"Gather Information": Skill.CHA,
			"Hunting": Skill.PER,
			"Intimidation": Skill.CHA,
			"Knowledge": Skill.INT,
			"Navigation": Skill.PER,
			"Observation": Skill.PER,
			"Oration": Skill.CHA,
			"Performance": Skill.CHA,
			"Persuasion": Skill.CHA,
			"Profession": Skill.WIP,
			"Research": Skill.INT,
			"Riding": Skill.AGI,
			"Sailing": Skill.WIT,
			"Stealth": Skill.AGI,
			"Strategy": Skill.INT,
			"Subterfuge": Skill.CHA,
			"Surgery": Skill.INT,
			"Swimming": Skill.END,
			"Tactics": Skill.INT,
			"Thievery": Skill.AGI,
		};
		s.requiresTrained = {
			"Crafting": true,
			"Engineering": true,
			"History": true,
			"Navigation": true,
			"Swimming": true,
			"Tactics": true,
			"Strategy": true,
			"Etiquette": true
		};
		s.requiresSpecialisation = {
			"Profession": true,
			"Knowledge": true,
			"Crafting": true,
			"Performance": true
		};
		return s;
	}
	
	public function getSpecialisationList():Array<String> {
		var arr:Array<String> = [];
		for (f in Reflect.fields(requiresSpecialisation)) {
			arr.push( f );
		}
		return arr;
	}
	
	public function getSkillObjectsAsArray(sortAlphabetically:Bool=true):Array<SkillObj> {
		var arr:Array<SkillObj> = [];
		
		for (p in Reflect.fields(skillHash)) {
			arr.push( {
				name:p,
				attribs:LibUtil.field(skillHash, p)
			});
		}
		
		if (sortAlphabetically) {
			arr.sort( sortArrayMethod);
		}
		
		return arr;
	}
	
	public static function sortArrayMethod(a:SkillObj, b:SkillObj):Int
	{
		var aStr = a.name.toLowerCase();
		var bStr= b.name.toLowerCase();
		if (aStr < bStr) return -1;
		if (aStr > bStr) return 1;
		return 0;
	} 
	
	public inline function matchRulesWith(other:SkillTable):Void {
		requiresTrained = other.requiresTrained;
		requiresSpecialisation = other.requiresSpecialisation;
	}
	
	inline public function requiresSpecification(name:String):Bool {
		return LibUtil.field(requiresSpecialisation, name);
	}
	
	public function clearAllSkills(flushed:Bool):Void {
		if (flushed) {
			skillHash = {};
		}
		else {
			for (p in Reflect.fields(skillHash)) {
				Reflect.deleteField(skillHash, p);
			}
		}
	}

	
	inline public function canAttemptUntrained(name:String):Bool {
		return !LibUtil.field(requiresTrained, name);
	}
	
	inline public function getSkillValue(name:String):Int {
		return LibUtil.field(skillHash, name);
	}
	inline public function hasSkill(name:String):Bool {
		return Reflect.hasField(skillHash, name);
	}
	public inline function setSkill(name:String, attribs:Int):Void {
		LibUtil.setField(skillHash, name, attribs); 
	}
	public function addSpecialisationTo(skillName:String, special:String, specialAttribs:Int=0):String {
		if (hasSkill(skillName)) {
			throw "No skill found for:" + skillName;
		}
		var key:String;
		setSkill(key = Skill.specialisationName(skillName, special), specialAttribs != 0 ? specialAttribs : getSkillValue(skillName) );
		return key;
	}
	
	public inline function removeSkill(name:String):Bool {
		return Reflect.deleteField(skillHash, name);
	}
	
}

typedef SkillObj = {
	var name:String;
	var attribs:Int;
}