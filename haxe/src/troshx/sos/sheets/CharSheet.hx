package troshx.sos.sheets;
import haxe.ds.StringMap;
import troshx.sos.core.Inventory;
import troshx.sos.core.Profeciency;
import troshx.sos.core.Money;
import troshx.sos.core.School;
import troshx.sos.core.Skill;
import troshx.sos.core.Talent;
import troshx.sos.core.Wound;

/**
 * ...
 * @author Glidias
 */
class CharSheet 
{
	
	public var name:String = "";
	public var race:String = "";
	public var socialClass:String = "";
	public var sex:String = ""; 
	public var age:Int = -1;
	
	public var strength:Int= 4;
	public var agility:Int = 4;
	public var endurance:Int = 4;
	public var health:Int = 4;
	public var willpower:Int= 4;
	public var wit:Int = 4;
	public var intelligence:Int = 4;
	public var perception:Int = 4;
	
	public var ADR(get, null):Int;	// Adroitness
	public var MOB(get, null):Int;	// Mobility
	public var CAR(get, null):Int;	// Carry
	public var CHA(get, null):Int;	// Charisma
	public var TOU(get, null):Int;	// Toughness
	
	public var SDB(get, null):Int;	// Strength Damange Bonus
	
	public var GRIT(get, null):Int;
	public var baseGrit(get, null):Int;
	public var gritAccum:Int = 0;
	
	public var school:School = null;
	public var schoolLevel:Int = 0;
	public var schoolProfeciencies:Array<Profeciency> = [];
	
	public var labelRace(get, null):String;
	public var labelSex(get, null):String;
	public var labelSchool(get, null):String;
	
	public var schoolCP(get, null):Int;
	public var meleeCP(get, null):Int;
	
	public var fatique:Int = 0;
	public var miscCPBonus:Int = 0;
	
	public var totalPain(get, null):Int;
	public var totalBloodLost(get, null):Int;
	
	public var money:Money = new Money();
	public var wealthAssets:Array<WealthAssetQty> = [];
	public var skills:Array<SkillAssign> = [];
	public var talents:Array<Talent> = [];
	
	public var arcPointsAccum:Int = 0;
	var arcSpent:Int = 0;
	public var arcPointsAvailable(get, null):Int;
	
	public var arcSaga:String = "";
	public var arcEpic:String = "";
	public var arcBelief:String = "";
	public var arcGlory:String = "";
	public var arcFlaw:String = "";
	
	public var inventory:Inventory = new Inventory();
	

	var wounds:Array<Wound> = [];
	var woundHash:Dynamic<Wound> = {}; 
	public function applyWound(w:Wound):Void {
		var uid:String = w.uid;
		if (!Reflect.hasField(woundHash, uid)) {
			Reflect.setField(woundHash, uid, w);
		}
		else { 
			var fw:Wound = Reflect.field(woundHash, uid);
			fw.updateAgainst(w);
		}
	}
	
	public function removeWound(w:Wound):Void {
		var uid:String = w.uid;
		if (Reflect.hasField(woundHash, uid)) {
			Reflect.deleteField(woundHash, uid);
		}
		else { 
			trace("Warning: No wound found to be removed for uid:" + w.uid);
		}
		
		var index:Int = wounds.indexOf(w);
		if (index >= 0) {
			wounds.splice(index, 1);
		}
		else {
			trace("Warning: No wound found to be removed for array index:" + index);
		}		
	}
	
		
	// todo:
	public var encumbranceLvl(get, null):Int;
	public var recoveryRate(get, null):Int;
	public var exhaustionRate(get, null):Int;
	public var skillPenalty(get, null):Int;
	public var mobWithMods(get, null):Int;
	
	
	public function new() 
	{
		
	}
	
	public function get_totalPain():Int {
		var c:Int = 0;
		for (i in 0...wounds.length) {
			c += wounds[i].pain;
		}
		return c;
	}
	
	public function get_totalBloodLost():Int {
		var c:Int = 0;
		for (i in 0...wounds.length) {
			c += wounds[i].BL;
		}
		return c;
	}
	
	
	inline function get_ADR():Int 
	{
		return Std.int( (agility + wit) / 2);
	}
	
	inline function get_MOB():Int 
	{
		return Std.int( (strength + agility + endurance) / 2 ) ;
	}
	
	inline function get_CAR():Int 
	{
		return strength + endurance;
	}
	
	inline function get_CHA():Int 
	{
		return Std.int( (willpower + wit + perception) / 2 );
	}
	
	inline function get_GRIT():Int 
	{
		return baseGrit + gritAccum;
	}
	
	inline function get_baseGrit():Int 
	{
		return Std.int(willpower / 2);
	}
	
	inline function get_TOU():Int 
	{
		return 4;
	}
	
	inline function get_SDB():Int 
	{
		return Std.int(strength / 2);
	}
	
	inline function get_labelRace():String 
	{
		return race;
	}
	
	inline function get_labelSex():String 
	{
		return sex;
	}
	
	inline function get_labelSchool():String 
	{
		return school != null ? school.name : "";
	}
	
	inline function get_meleeCP():Int 
	{
		return schoolCP + ADR + miscCPBonus - totalPain;
	}
	
	inline function get_schoolCP():Int 
	{
		return schoolLevel >= 1 ? schoolLevel + 4 : 0;
	}
	
	
	function get_skillPenalty():Int 
	{
		return 0;
	}
	
	function get_recoveryRate():Int 
	{
		return 0;
	}
	
	function get_encumbranceLvl():Int 
	{
		return 0;
	}
	
	function get_exhaustionRate():Int 
	{
		return 0;
	}
	
	function get_mobWithMods():Int 
	{
		return MOB;
	}
	
	function get_arcPointsAvailable():Int 
	{
		return arcPointsAccum - arcSpent;
	}
	
}

typedef WealthAssetQty = {
	name:String,
	quantity:String
}

typedef SkillAssign = {
	skill:Skill,
	rank:Int
}