package troshx.sos.sheets;
import haxevx.vuex.core.IBuildListed;
import troshx.ds.HashedArray;
import troshx.sos.core.BoonBane.BoonBaneAssign;
import troshx.sos.core.Modifier;
import troshx.sos.core.Modifier.StaticModifier;
import troshx.sos.core.Race;
import troshx.sos.core.SocialClass;
import troshx.sos.sheets.CharSheet.WealthAssetAssign;
import troshx.sos.sheets.EncumbranceTable.EncumbranceRow;
import troshx.sos.sheets.FatiqueTable;
import troshx.util.LibUtil;


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
	public var nickname:String = "";
	public var faction:String = "";
	public var notes:String = "";
	public var title:String = "";
	public var uid(get, never):String;
	function get_uid():String {
		return (title != "" ? title+ " ": "") + name + (nickname != "" ? ' "$nickname"' : "") + (faction != "" ? " of "+faction : "");
	}
	
	
	public var race(default, set):Race = null;
	function set_race(r:Race):Race {
		var oldR = this.race;
		if ( oldR != r) {
			//r.staticModifiers;
			if (oldR != null ) {
				removeStaticModifier(oldR.staticModifiers);
				removeSituationalModifier(oldR.situationalModifiers);
			}
			if (r != null ) {
				addStaticModifier(r.staticModifiers);
				addSituationalModifier(r.situationalModifiers);
			}
			this.race = r;
		}
		return r;
	}
	
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
	
	
	// new in v2
	public static inline var VERSION:Int = 2;
	public var version:Int = VERSION;
	public var healthLoss:Int = 0;
	public var prone:Bool = false;
	public function postSerialization():Void {
		postSerialize_2();
		
		body = BodyChar.getInstance();  // enforce global human body instance for now.
		
		inventory.postSerialization();
	}
	@:postSerialize function postSerialize_2():Bool {	// warning: ingame ONLY!
		if (version == null || version < 2) version = 2
		else return false;
		if (!ingame) ingame = true;  // a bug in prev chargen that needs to be monkey patched
			
		if (healthLoss == null) healthLoss = 0;
		if (prone == null) prone = false;
		
		return true;
	}
	
	
	
	public var STR(get, never):Int;	// strength
	function get_STR():Int { return clampIntZero(getModifiedValue(Modifier.ATTR_STR, strength));  } 
	public var AGI(get, never):Int;	// agility
	function get_AGI():Int { return clampIntZero(getModifiedValue(Modifier.ATTR_AGI, agility));  } 
	public var END(get, never):Int;	// endurance
	function get_END():Int { return clampIntZero(getModifiedValue(Modifier.ATTR_END, endurance));  } 
	public var HLT(get, never):Int;	// health
	function get_HLT():Int { return Math.floor(getModifiedValue(Modifier.ATTR_HLT, health)) - healthLoss;  } 
	public var WIP(get, never):Int;	// willpower
	function get_WIP():Int { return clampIntZero(getModifiedValue(Modifier.ATTR_WIL, willpower));  } 
	public var WIT(get, never):Int;	// wit
	function get_WIT():Int { return clampIntZero(getModifiedValue(Modifier.ATTR_WIT, wit));  } 
	public var INT(get, never):Int;	// intelligence
	function get_INT():Int { return clampIntZero(getModifiedValue(Modifier.ATTR_INT, intelligence));  } 
	public var PER(get, never):Int;	// perception
	function get_PER():Int { return clampIntZero(getModifiedValue(Modifier.ATTR_PER, perception));  } 

	public var adr(get, never):Int;	// Adroitness
	public var mob(get, never):Int;	// Mobility
	public var car(get, never):Int;	// Carry
	public var cha(get, never):Int;	// Charisma
	public var tou(get, never):Int;	// Toughness
	
	public var ADR(get, never):Int;	// Adroitness (with mods)
	public var MOB(get, never):Int;	// Mobility  (with mods)
	public var CAR(get, never):Int;	// Carry  (with mods)
	public var CHA(get, never):Int;	// Charisma  (with mods)
	public var TOU(get, never):Int;	// Toughness  (with mods)
	
	public var SDB(get, never):Int;	// Strength Damange Bonus
	
	public var GRIT(get, never):Int;
	public var baseGrit(get, never):Int;
	public var gritAccum:Int = 0;
	
	public var school(default,set):School = null;
	function set_school(r:School):School {
		var oldR = this.school;
		if ( oldR != r) {
			if (oldR != null ) {
				removeStaticModifier(oldR.staticModifiers);
				removeSituationalModifier(oldR.situationalModifiers);
			}
			if (r != null ) {
				addStaticModifier(r.staticModifiers);
				addSituationalModifier(r.situationalModifiers);
			}
			this.school = r;
		}
		return r;
	}
	public var schoolBonuses(default,set):SchoolBonuses = null;
	function set_schoolBonuses(r:SchoolBonuses):SchoolBonuses {
		var oldR = this.schoolBonuses;
		if ( oldR != r) {
			if (oldR != null ) {
				removeSituationalModifier(oldR.situationalModifiers);
			}
			if (r != null ) {
				addSituationalModifier(r.situationalModifiers);
			}
			this.schoolBonuses = r;
		}
		return r;
	}
	
	
	public var schoolLevel:Int = 0;
	public var profsMelee:Int = 0;	// core melee profiecy mask
	public var profsRanged:Int = 0;	// core ranged profiecy mask
	public var profsCustom:Array<Profeciency> = null;  // gm-homebrews (if any) // consider: divide to melee and ranged?
	
	public var superiorManueverNotes:Array<String> = [];
	public var masteryManueverNotes:Array<String> = [];
	public var talentNotes:Array<String> = [];
	
	
	public var labelRace(get, never):String;
	public var labelGender(get, never):String;
	public var labelSchool(get, never):String;
	public var labelSocialClass(get, never):String;
	
	public var schoolCP(get, never):Int;
	public var baseCP(get, never):Int;
	public var CP(get, never):Int;
	public var meleeCP(get, never):Int;
	
	public var fatique:Int = 0;
	
	public var totalPain(get, never):Int;
	public var totalBloodLost(get, never):Int;
	
	public var ingame:Bool = false; // when no longer in character generation mode
	
	public var staticModifierTable:Array<Array<StaticModifier>> = Modifier.getStaticModifierSlots();
	public var situationalModifierTable:Array<Array<SituationalCharModifier>> = Modifier.getSituationalModifierSlots();
	
	public var money:Money = new Money(); 
	
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
			uid:wealthAssetAssignCount,
			worth: worth
		}
		wealthAssetAssignCount++;
		return w;
	}
	
	
	public static inline var LIQUIDATE_ASSET_BASE:Int = 6;  // assumed in GP
	function get_assetLiquidateTotal():Int {
		return getTotalLiquidity(wealthAssets);
	}
	
	public static function getTotalLiquidity(wealthAssets:Array<WealthAssetAssign>, customLen:Int=0):Int {
		var i:Int = customLen!=0 ? customLen : wealthAssets.length;
		var c:Int = 0;
		while (--i > -1) {
			var w = wealthAssets[i];
			c += w.liquidate ? w.worth*LIQUIDATE_ASSET_BASE : 0;
		}
		return c;
	}
	
	public var skills:SkillTable = SkillTable.getNewEmptySkillTable(SkillTable.getDefaultSkillTable());
	public var talents:Array<Talent> = [];
	
	
	public var direPast:Bool = false;  // whether character had a dire past triggered on him during character creation
	public var boons(default, never) :HashedArray<BoonAssign>= new HashedArray<BoonAssign>();
	public var banes(default, never):HashedArray<BaneAssign> =  new HashedArray<BaneAssign>();
	public var boonsArray(get, never):Array<BoonAssign>;
	inline function get_boonsArray():Array<BoonAssign> {
		return boons.list;
	}
	public inline function addBoon(assign:BoonAssign):Void {
		boons.add(assign);
	}
	
	public inline function removeBoon(assign:BoonAssign):Void {
		boons.delete(assign);
	}
	
	
	public var banesArray(get, never):Array<BaneAssign>;
	inline function get_banesArray():Array<BaneAssign> {
		return banes.list;
	}
	public inline function addBane(assign:BaneAssign):Void {
		banes.add(assign);
		
	}
	public inline function removeBane(assign:BaneAssign):Void {
		banes.delete(assign);
		//baneRankUpdated(assign, newRank,  assign.rank);
	}
	public function mayRemoveBane(assign:BaneAssign):Void {
		if (banes.contains(assign)) {
			removeBane(assign);
		}
	}
	
	public function boonRankUpdated(assign:BoonAssign, newRank:Int, oldRank:Int):Void {
		if (oldRank > 0) {
			if (assign.boon.staticModifiers!=null && assign.boon.staticModifiers.length >=oldRank)  removeStaticModifier(assign.boon.staticModifiers[oldRank-1]);
			if (assign.boon.situationalModifiers!=null && assign.boon.situationalModifiers.length >=oldRank) removeSituationalModifier(assign.boon.situationalModifiers[oldRank-1]);
			if (assign.situationalModifiers!=null && assign.situationalModifiers.length >=oldRank) removeSituationalModifier(assign.situationalModifiers[oldRank-1]);
		}
		if (newRank > 0) {
			if (assign.boon.staticModifiers!=null && assign.boon.staticModifiers.length >=newRank) addStaticModifier(assign.boon.staticModifiers[newRank-1]);
			if (assign.boon.situationalModifiers!=null && assign.boon.situationalModifiers.length >=newRank) addSituationalModifier(assign.boon.situationalModifiers[newRank-1]);
			if (assign.situationalModifiers!=null && assign.situationalModifiers.length >=newRank) addSituationalModifier(assign.situationalModifiers[newRank - 1]);
		}
	}

	public function baneRankUpdated(assign:BaneAssign, newRank:Int, oldRank:Int):Void {
		if (oldRank > 0) {
			if (assign.bane.staticModifiers!=null && assign.bane.staticModifiers.length >=oldRank)  removeStaticModifier(assign.bane.staticModifiers[oldRank-1]);
			if (assign.bane.situationalModifiers!=null && assign.bane.situationalModifiers.length >=oldRank) removeSituationalModifier(assign.bane.situationalModifiers[oldRank-1]);
			if (assign.situationalModifiers!=null && assign.situationalModifiers.length >=oldRank) removeSituationalModifier(assign.situationalModifiers[oldRank-1]);
		}
		if (newRank > 0) {
			if (assign.bane.staticModifiers!=null && assign.bane.staticModifiers.length >=newRank) addStaticModifier(assign.bane.staticModifiers[newRank-1]);
			if (assign.bane.situationalModifiers!=null && assign.bane.situationalModifiers.length >=newRank) addSituationalModifier(assign.bane.situationalModifiers[newRank-1]);
			if (assign.situationalModifiers!=null && assign.situationalModifiers.length >=newRank) addSituationalModifier(assign.situationalModifiers[newRank - 1]);
		}
	}
	
	public function boonRankCanceledChange(assign:BoonAssign, newCanceled:Bool, oldCanceled:Bool):Void {  // specific to char gen only..
		boonRankUpdated(assign, newCanceled ? 0 : assign.rank, oldCanceled ? 0 : assign.rank);
	}
	public function baneRankCanceledChange(assign:BaneAssign, newCanceled:Bool, oldCanceled:Bool):Void {  // specific to char gen only..
		baneRankUpdated(assign, newCanceled ? 0 : assign.rank, oldCanceled ? 0 : assign.rank);
	}
	
	public function boonAssignReplaced(newAssign:BoonAssign, oldAssign:BoonAssign):Void { // specific to char gen only..
		if (oldAssign.boon.staticModifiers!=null && oldAssign.boon.staticModifiers.length >=oldAssign.rank) removeStaticModifier(oldAssign.boon.staticModifiers[oldAssign.rank-1]);
		if (oldAssign.boon.situationalModifiers!=null && oldAssign.boon.situationalModifiers.length >=oldAssign.rank) removeSituationalModifier(oldAssign.boon.situationalModifiers[oldAssign.rank-1]);
		if (oldAssign.situationalModifiers !=null && oldAssign.situationalModifiers.length >=oldAssign.rank) removeSituationalModifier(oldAssign.situationalModifiers[oldAssign.rank-1]);
		
		if (newAssign.boon.staticModifiers!=null && newAssign.boon.staticModifiers.length >=newAssign.rank) addStaticModifier(newAssign.boon.staticModifiers[newAssign.rank-1]);
		if (newAssign.boon.situationalModifiers!=null && newAssign.boon.situationalModifiers.length >=newAssign.rank) addSituationalModifier(newAssign.boon.situationalModifiers[newAssign.rank-1]);
		if (newAssign.situationalModifiers!=null && newAssign.situationalModifiers.length >=newAssign.rank) addSituationalModifier(newAssign.situationalModifiers[newAssign.rank-1]);
	}
	
	public inline function removeStaticModifier(modifier:StaticModifier):Void {
		if (modifier != null) {
			var t =  staticModifierTable[modifier.index];
			var s = t.splice(t.indexOf(modifier), 1);
	
			var m = modifier.next;
			while ( m != null) {
				t =  staticModifierTable[m.index];
				s = t.splice(t.indexOf(m), 1);
				m = m.next;
			}
		}
	}
	
	public inline function removeSituationalModifier(modifier:SituationalCharModifier):Void {
		if (modifier != null) {
			var t =  situationalModifierTable[modifier.index];
			var s = t.splice(t.indexOf(modifier), 1);
	
			var m = modifier.next;
			while ( m != null) {
				t =  situationalModifierTable[m.index];
				s = t.splice(t.indexOf(m), 1);
				m = m.next;
			}
		}
	}
	
	public inline function addStaticModifier(modifier:StaticModifier):Void {
		if (modifier != null) {
			var t =  staticModifierTable[modifier.index];
			t.push(modifier);
	
			var m = modifier.next;
			while ( m != null) {
				t =  staticModifierTable[m.index];
				t.push(m);
				m = m.next;
			}
		}
	}
	
	public inline function addSituationalModifier(modifier:SituationalCharModifier):Void {
		if (modifier != null) {
			var t =  situationalModifierTable[modifier.index];
			t.push(modifier);
	
			var m = modifier.next;
			while ( m != null) {
				t =  situationalModifierTable[m.index];
				t.push(m);
				m = m.next;
			}
		}
	}
	
	public function getModifiedValue(modifierIndex:Int, base:Float):Float {
		var staticList = staticModifierTable[modifierIndex];
		var val:Float = base;
		for (i in 0...staticList.length) {
			var s = staticList[i];
			val = s.getModifiedValueMultiply(val);
		}
		for (i in 0...staticList.length) {
			var s = staticList[i];
			val = s.getModifiedValueAdd(val);
		}
		
		
		var situationalList = situationalModifierTable[modifierIndex];
		for (i in 0...situationalList.length) {
			var s = situationalList[i];
			val = s.getModifiedValueMultiply(this, base, val);
		}
		for (i in 0...situationalList.length) {
			var s = situationalList[i];
			val = s.getModifiedValueAdd(this, base, val);
		}
		
		return val;
	}
	
	public var arcPointsAccum:Int = 0;
	public var arcSpent:Int = 0;
	public var arcPointsAvailable(get, never):Int;
	
	//
	public var arcSaga:String = "";
	public var arcEpic:String = "";
	public var arcBelief:String = "";
	public var arcGlory:String = "";
	public var arcFlaw:String = "";
	
	public var inventory:Inventory = new Inventory();
	public var totalWeight(get, never):Float;
	inline function get_totalWeight():Float { return  inventory.calculateTotalWeight(); } 
	
	public var body:BodyChar = BodyChar.getInstance();
	var wounds:Array<Wound> = [];
	var woundHash:Dynamic<Wound> = {}; 
	
	public static function dynSetField(obj:Dynamic, prop:String, val:Dynamic):Void {
		LibUtil.setField(obj, prop, val);
	}
	
	public function applyWound(w:Wound):Void {
		var uid:String = w.getUID(body);
		if (!Reflect.hasField(woundHash, uid)) {
			dynSetField(woundHash, uid, w);
			wounds.push(w); 
			
			
		}
		else { 
			var fw:Wound = LibUtil.field(woundHash, uid);
			fw.updateAgainst(w);
		
		}
		
	}
	
	public function hasWound(w:Wound):Bool {
		var uid:String = w.getUID(body);
		return Reflect.hasField(woundHash, uid);
	}
	
	public inline function getWound(w:Wound):Wound {
		return LibUtil.field(woundHash, w.getUID(body));
	}
	
	public function removeWound(w:Wound):Void {
		var uid:String = w.getUID(body);
		if (Reflect.hasField(woundHash, uid)) {
			dynDelField(woundHash, uid);
		}
		else { 
			trace("Warning: No wound found to be removed for uid:" + w.getUID(body));
		}
		
		var index:Int = wounds.indexOf(w);
		if (index >= 0) {
			wounds.splice(index, 1);
		}
		else {
			trace("Warning: No wound found to be removed for array index:" + index);
		}		
	}
	
	public static function dynDelField(woundHash:Dynamic<Wound>, uid:String):Void
	{
		Reflect.deleteField(woundHash, uid);
	}
	
		

	
	public var encumbranceLvl(get, never):Int;
	public var recoveryRate(get, never):Float;
	public var exhaustionRate(get, never):Float;
	public var skillPenalty(get, never):Int;


	public var startingGrit(get, never):Int;
	
	public function new() 
	{
		
	}
	
	public function wealthAssetsWorth():Int
	{
		var i:Int = wealthAssets.length;
		var c:Int = 0;
		while (--i > -1) {
			c += wealthAssets[i].worth;
		}
		return c;
	}
	
	public var pain(get, never):Int;
	function get_pain():Int {
		var r:Int =  this.totalPain - GRIT;
		return r < 0 ? 0 : r;
	}
	
	function get_totalPain():Int {
		var c:Int = 0;
		var gotInfinite:Bool = false;
		for (i in 0...wounds.length) {
			var w = wounds[i];
			c += w.isTreated() ? Math.floor(w.pain*.5) : w.pain;
			
			if ( w.pain < 0) {
				gotInfinite = true;
			}
		}
		return gotInfinite ? 999999999 : c;
	}
	
	function get_totalBloodLost():Int {
		var c:Int = 0;
		for (i in 0...wounds.length) {
			var w = wounds[i];
			c += w.gotBloodLost() ? w.BL : 0;
		}
		return c;
	}
	
	inline function get_adr():Int 
	{
		return Std.int( (agility + wit) / 2);
	}
	
	inline function get_mob():Int 
	{
		return Std.int( (strength + agility + endurance) / 2 ) ;
	}
	
	inline function get_car():Int 
	{
		return strength + endurance;
	}
	
	inline function get_cha():Int 
	{
		return Std.int( (willpower + wit + perception) / 2 );
	}
	inline function get_tou():Int 
	{
		return 4;
	}
	
	inline function get_ADR():Int 
	{
		return clampIntZero(getModifiedValue(Modifier.CMP_ADR, adr));
	}
	
	inline function get_MOB():Int 
	{	
		var row = encumbranceLvlRow;
		return row.mobMult* clampIntZero((getModifiedValue(Modifier.CMP_MOB, mob)) + row.mob + fatiqueMobPenalty);
	}
	
	inline function get_CAR():Int 
	{
		return clampIntZero(getModifiedValue(Modifier.CMP_CAR, clampIntZero(getModifiedValue(Modifier.CAR_END, car)) ));
	}
	
	inline function get_CHA():Int 
	{
		return clampIntZero(getModifiedValue(Modifier.CMP_CHA, cha));
	}
	
	inline function get_startingGrit():Int 
	{
		return clampIntZero(getModifiedValue(Modifier.STARTING_GRIT, baseGrit));
	}
	inline function get_GRIT():Int 
	{
		return Std.int(startingGrit + gritAccum);
	}
	
	inline function get_baseGrit():Int 
	{
		return Std.int(willpower / 2);
	}
	
	
	
	
	
	public function clampIntZero(val:Float):Int {
		var r = Std.int(val);
		return r < 0 ? 0 : r;
	}
	
	public function hasStaticModifier(mod:StaticModifier):Bool
	{
		return staticModifierTable[mod.index].indexOf(mod) >= 0;
	}
	public function hasSituationalCharModifier(mod:SituationalCharModifier):Bool
	{
		return situationalModifierTable[mod.index].indexOf(mod) >= 0;
	}
	
	inline function get_TOU():Int 
	{
		return clampIntZero(getModifiedValue(Modifier.CMP_TOU, tou));
	}
	
	inline function get_SDB():Int 
	{
		return Std.int(STR / 2);
	}
	
	inline function get_labelRace():String 
	{
		return race != null ? race.name : "Unspecified";
	}

	
	inline function get_labelSchool():String 
	{
		return school != null ? school.name : "";
	}
	
	inline function get_labelSocialClass():String 
	{
		return socialClass != null ? socialClass.name : "";
	}
	
	
	inline function get_baseCP():Int {
		return schoolCP + ADR;
	}
	
	inline function get_CP():Int {
		var row = encumbranceLvlRow;
		return row.cpMult * clampIntZero( (getModifiedValue(Modifier.CP, baseCP)) * (prone ? 0.5 : 1) + row.cp + fatiqueCPPenalty );
	}
	
	inline function get_meleeCP():Int 
	{
		return CP - pain;
	}
	
	inline function get_schoolCP():Int 
	{
		return schoolLevel >= 1 ? schoolLevel + 4 : 0;
	}
	
	function get_arcPointsAvailable():Int 
	{
		var r =  arcPointsAccum - arcSpent;
		return r >= 0 ? r : 0;
	}
	
	
	function get_skillPenalty():Int 
	{
		return encumbranceLvlRow.skill + fatiqueSkillPenalty;
	}
	
	function get_recoveryRate():Float 
	{
		return clampIntZero(encumbranceLvlRow.recovery); 
	}
	
	
	public var encumbranceLvlRow(get, never):EncumbranceRow;
	function get_encumbranceLvlRow():EncumbranceRow 
	{
		var tabler =  EncumbranceTable.getTable();
		return tabler[encumbranceLvl>=tabler.length ? tabler.length - 1 : encumbranceLvl < 0 ? 0 : encumbranceLvl];
	}
	
	
	inline function get_encumbranceLvl():Int 
	{
		return Math.floor(totalWeight/CAR);
	}
	
	public var encumberedBeyond(get, never):Bool;
	inline function get_encumberedBeyond():Bool 
	{
		return encumbranceLvl >= 5;
	}
	

	function get_exhaustionRate():Float 
	{
		return encumbranceLvlRow.exhaustion;
	}
	
	public var fatiqueLevel(get, never):Int;
	function get_fatiqueLevel():Int 
	{
		var hlt:Int = HLT;
		hlt = hlt < 0 ? 0 : hlt;
		return FatiqueTable.getFatiqueLevel(fatique, hlt);
	}
	
	public var fatiqueSkillPenalty(get, never):Int;
	inline function get_fatiqueSkillPenalty():Int 
	{
		return FatiqueTable.getTable()[fatiqueLevel].skill;
	}
	
	public var fatiqueMobPenalty(get, never):Int;
	inline function get_fatiqueMobPenalty():Int 
	{
		return FatiqueTable.getTable()[fatiqueLevel].mob;
	}
	
	public var fatiqueCPPenalty(get, never):Int;
	inline function get_fatiqueCPPenalty():Int 
	{
		return FatiqueTable.getTable()[fatiqueLevel].cp;
	}
	

	
}

typedef WealthAssetAssign = {
	name:String,
	liquidate:Bool,
	uid:Int,
	worth:Int  // 1 to 3
}

typedef SkillAssign = {
	skill:Skill,
	rank:Int
}

