package troshx.sos.sheets;
import haxevx.vuex.core.IBuildListed;
import troshx.ds.HashedArray;
import troshx.sos.core.Race;
import troshx.sos.core.SocialClass;
import troshx.sos.sheets.CharSheet.WealthAssetAssign;

import troshx.sos.core.BodyChar;

import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.BoonBane.BoonAssign;
import troshx.sos.core.Inventory;
import troshx.sos.core.Profeciency;
import troshx.sos.core.Money;
import troshx.sos.core.School;
import troshx.sos.core.Skill;
import troshx.sos.core.Talent;
import troshx.sos.core.Wound;

//import troshx.ds.HashedArray;

/**
 * ...
 * @author Glidias
 */
class CharSheet implements IBuildListed
{
	
	
	public var name:String = "";
	public var race:Race = null;
	
	public var gender:Int = 0; 
	@:gender("Male") public static inline var GENDER_MALE:Int = 0;
	@:gender("Female") public static inline var GENDER_FEMALE:Int = 1;
	inline function get_labelGender():String 
	{
		return gender == GENDER_MALE ? "Male" : "Female";
	}
	
	public var leftHanded:Bool = false;
	
	public var age:Int = -1;
	
	
	public var strength:Int= 1;
	public var agility:Int = 1;
	public var endurance:Int = 1;
	public var health:Int = 1;
	public var willpower:Int= 1;
	public var wit:Int = 1;
	public var intelligence:Int = 1;
	public var perception:Int = 1;
	
	
	public var STR(get, never):Int;	// strength
	inline function get_STR():Int { return strength;  } 
	public var AGI(get, never):Int;	// agility
	inline function get_AGI():Int { return agility;  } 
	public var END(get, never):Int;	// endurance
	inline function get_END():Int { return endurance;  } 
	public var HLT(get, never):Int;	// health
	inline function get_HLT():Int { return health;  } 
	public var WIP(get, never):Int;	// willpower
	inline function get_WIP():Int { return willpower;  } 
	public var WIT(get, never):Int;	// wit
	inline function get_WIT():Int { return wit;  } 
	public var INT(get, never):Int;	// intelligence
	inline function get_INT():Int { return intelligence;  } 
	public var PER(get, never):Int;	// perception
	inline function get_PER():Int { return perception;  } 

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
	public var labelGender(get, never):String;
	public var labelSchool(get, never):String;
	
	public var schoolCP(get, never):Int;
	public var meleeCP(get, never):Int;
	
	public var fatique:Int = 0;
	public var miscCPBonus:Int = 0;
	
	public var totalPain(get, never):Int;
	public var totalBloodLost(get, never):Int;
	
	public var money:Money = new Money();  // note: this field is for ingame use only
	
	public var socialClass:SocialClass = new SocialClass("", new Money(), 0);  // this field's inner Money() is for char generation 
	public var wealthAssets:Array<WealthAssetAssign> = [];
	public var assetWorth(get, never):Int;
	function get_assetWorth():Int {
		var i:Int = wealthAssets.length;
		var c:Int = 0;
		while (--i > -1) {
			c += wealthAssets[i].worth;
		}
		return c;
	}
	
	public function getAssetsWithWorth(worth:Int):Array<WealthAssetAssign> {
		var arr:Array<WealthAssetAssign> = [];
		for (i in 0...wealthAssets.length) {
			var w = wealthAssets[i];
			if (w.worth == worth) {
				arr.push(w);
			}
		}
		return arr;
	}
	
	var wealthAssetAssignCount:Int = 0; 
	public function getEmptyWealthAssetAssign(worth:Int):WealthAssetAssign {
		var w:WealthAssetAssign = {
			name: "",
			liquidate:false,
			uidCount:wealthAssetAssignCount,
			worth: worth
		}
		wealthAssetAssignCount++;
		return w;
	}
	
	
	public static inline var LIQUIDATE_ASSET_BASE:Int = 6;  // assumed in GP
	function get_assetLiquidateTotal():Int {
		var i:Int = wealthAssets.length;
		var c:Int = 0;
		while (--i > -1) {
			var w = wealthAssets[i];
			c += w.liquidate ? w.worth*LIQUIDATE_ASSET_BASE : 0;
		}
		return c;
	}
	
	public var skills:Array<SkillAssign> = [];
	public var talents:Array<Talent> = [];
	
	
	
	var boons:HashedArray<BoonAssign> = new HashedArray<BoonAssign>();
	var banes:HashedArray<BaneAssign> =  new HashedArray<BaneAssign>();
	public var boonsArray(get, never):Array<BoonAssign>;
	inline function get_boonsArray():Array<BoonAssign> {
		return boons.list;
	}
	public function addBoon(assign:BoonAssign):Void {
		boons.add(assign);
	}
	public function removeBoon(assign:BoonAssign):Void {
		boons.delete(assign);
	}
	
	public var banesArray(get, never):Array<BaneAssign>;
	inline function get_banesArray():Array<BaneAssign> {
		return banes.list;
	}
	public function addBane(assign:BaneAssign):Void {
		banes.add(assign);
	}
	public function removeBane(assign:BaneAssign):Void {
		banes.delete(assign);
	}
	
	
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
	
	
	public var body:BodyChar = BodyChar.getInstance();
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
		return race != null ? race.name : "Unspecified";
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

typedef WealthAssetAssign = {
	name:String,
	liquidate:Bool,
	uidCount:Int,
	worth:Int  // 1 to 3
}

typedef SkillAssign = {
	skill:Skill,
	rank:Int
}

