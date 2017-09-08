package troshx.sos.sheets;
import haxevx.vuex.core.IBuildListed;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.BoonBane.BoonAssign;
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
class CharSheet implements IBuildListed
{
	
	public var name:String = "";
	public var race:String = "";
	public var sex:String = ""; 
	public var age:Int = -1;
	
	public var strength:Int= 0;
	public var agility:Int = 0;
	public var endurance:Int = 0;
	public var health:Int = 0;
	public var willpower:Int= 0;
	public var wit:Int = 0;
	public var intelligence:Int = 0;
	public var perception:Int = 0;
	

	public var ADR(get, never):Int;	// Adroitness
	public var MOB(get, never):Int;	// Mobility
	public var CAR(get, never):Int;	// Carry
	public var CHA(get, never):Int;	// Charisma
	public var TOU(get, never):Int;	// Toughness
	
	public var SDB(get, never):Int;	// Strength Damange Bonus
	
	public var GRIT(get, never):Int;
	public var baseGrit(get, never):Int;
	public var gritAccum:Int = 0;
	
	
	
	public var school:School = null;
	public var schoolLevel:Int = 0;
	public var profs:Int = 0;	// core profiecy mask
	public var profsCustom:Array<Profeciency> = null;  // gm-homebrews (if any)
	
	public var labelRace(get, never):String;
	public var labelSex(get, never):String;
	public var labelSchool(get, never):String;
	
	public var schoolCP(get, never):Int;
	public var meleeCP(get, never):Int;
	
	public var fatique:Int = 0;
	public var miscCPBonus:Int = 0;
	
	public var totalPain(get, never):Int;
	public var totalBloodLost(get, never):Int;
	
	public var money:Money = new Money();
	public var wealthAssets:Array<WealthAssetQty> = [];
	public var socialClass:String = "";
	
	public var skills:Array<SkillAssign> = [];
	public var boons:Array<BoonAssign> = [];
	public var banes:Array<BaneAssign> = [];
	public var talents:Array<Talent> = [];
	
	public var arcPointsAccum:Int = 0;
	var arcSpent:Int = 0;
	public var arcPointsAvailable(get, never):Int;
	
	//
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
			wounds.push(w);
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
	public var encumbranceLvl(get, never):Int;
	public var recoveryRate(get, never):Int;
	public var exhaustionRate(get, never):Int;
	public var skillPenalty(get, never):Int;
	public var mobWithMods(get, never):Int;
	
	
	public function new() 
	{
		
	}
	
	function get_totalPain():Int {
		var c:Int = 0;
		for (i in 0...wounds.length) {
			c += wounds[i].pain;
		}
		return c;
	}
	
	function get_totalBloodLost():Int {
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

