package troshx.sos.chargen;

import haxevx.vuex.core.IBuildListed;
import troshx.sos.bnb.Banes;
import troshx.sos.bnb.Boons;
import troshx.sos.chargen.CategoryPCP;
import troshx.sos.chargen.SkillPacket;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.BoonBane.BoonAssign;
import troshx.sos.core.Race;
import troshx.sos.core.Skill;
import troshx.sos.races.Races;
import troshx.util.LibUtil;


import troshx.sos.sheets.CharSheet;


/**
 * ...
 * @author Glidias
 */

class CharGenData implements IBuildListed
{
	
	public var char:CharSheet;
	
	
	static public inline var INT_MAX:Int = 2147483647;
	
	var showBnBs:Bool = true;
	public var shouldShowBnBs(get, never):Bool;
	function get_shouldShowBnBs():Bool 
	{
		return showBnBs ||  totalBnBScore<0;
	}
	

	
	public function new(charSheet:CharSheet=null) 
	{
		// Char sheet
		this.char = charSheet != null ? charSheet : new CharSheet();

		// Default race tier table
		raceTierTable = Races.getTiers();
		pcpForTiers = Races.PCP_FOR_TIERS.concat([]);
		
		if (charSheet == null) {
			this.char.race = raceTierTable[0][0];
		}
		// Categories
		this.categories = getNewCharGenCategories();
		this.categories[CATEGORY_BNB].pcp = 4;
		
		// ............
		
		// Boones and banes
		initBoons();
		
		// Skills
		initSkills();
		
	}
	
	function initBoons():Void {
		var boonList:Array<Boon> = Boons.getList();
		this.boonAssignList = [];
		this.baneAssignList = [];
		var bb:BoonBane;
		
		for (i in 0...boonList.length) {
			bb =  boonList[i];
			
			if (bb.costs != null) {
				var ba;
				this.boonAssignList.push(  ba = boonList[i].getAssign(0, this.char) );
				ba._costCached = bb.costs[0];
				ba._remainingCached = 999;
			}
		}
		var baneList:Array<Bane> = Banes.getList();
		for (i in 0...baneList.length) {
			bb = baneList[i];
			if (bb.costs != null) {
				var ba;
				this.baneAssignList.push(ba = baneList[i].getAssign(0, this.char) );
				ba._costCached = bb.costs[0];
			}
		}
	}
	
	function initSkills():Void {
		this.skillPackets = CharGenSkillPackets.getNewSkillPackets();
		this.skillLabelMappingBases = CharGenSkillPackets.getNewSkillLabelMappingBases();
		//this.
		
		skillsTable = SkillTable.getDefaultSkillTable();
		skillObjs = skillsTable.getSkillObjectsAsArray(true);
		specialisedSkills = skillsTable.getSpecialisationList();
		
		this.skillLabelMappings = getEmptyMappingsFromBase(skillLabelMappingBases);
		
		for (i in 0...skillPackets.length) {
			var p = skillPackets[i];
			for (s in Reflect.fields(p.values)) {
				if (LibUtil.field(this.skillLabelMappings, s)!=null) {
					p.history = [];
					break;
				}
			}
		}
		
		skillSubjectHash = {};
		
		for (f in Reflect.fields(skillValues)) {
			var arr = Skill.getSplitFromSpecialisation(f);
			if (arr != null) {
				var skill = arr[0];
				var special = arr[1];
				var skillToSpecial:Array<String>;
				var specialToSkill:Array<String>;
				if ( (skillToSpecial=LibUtil.field(skillSubjectHash, skill)) == null ) {
					LibUtil.setField(skillSubjectHash, skill, skillToSpecial=[]);
				}
				if ( (specialToSkill=LibUtil.field(skillSubjectHash, special)) == null ) {
					LibUtil.setField(skillSubjectHash, special, specialToSkill=[]);
				}
				skillToSpecial.push(special);
				specialToSkill.push(skill);
			}
		}
		
		startingSkillObjsCount = skillObjs.length;
	}
	
	
	// Non-reactive data can be intialized here.
	public function privateInit():Void {
		
		for (i in 0...skillPackets.length) {
			var s = skillPackets[i];
			s.fields = Reflect.fields(s.values);
			
		}
		
	
	}
	
	
	// CAMPAIGN POWER LEVEL
	public var campaignPowerLevels:Array<CampaignPowerLevel> = [
		new CampaignPowerLevel("Low (Grittiest)", 14, 5),
		new CampaignPowerLevel("Medium(Default)", 18, 6),
		new CampaignPowerLevel("High Fantasy", 22, 7),
		new CampaignPowerLevel("Epic Fantasy", 26, 8),
		new CampaignPowerLevel("Awesome Fantasy", 30, 10),
	];
	public var campaignPowLevelIndex:Int = 1;

	public var campaignPowLevel(get, never):CampaignPowerLevel;
	inline function get_campaignPowLevel():CampaignPowerLevel 
	{
		return campaignPowerLevels[campaignPowLevelIndex];
	}
	
	// CATEGORIES
	public var categories:Array<CategoryPCP>;
	

	public static inline var CATEGORY_RACE:Int = 0;
	public static inline var CATEGORY_ATTRIBUTES:Int = 1;
	public static inline var CATEGORY_BNB:Int = 2;
	public static inline var CATEGORY_SKILLS:Int = 3;
	public static inline var CATEGORY_SOCIAL_WEALTH:Int = 4;
	public static inline var CATEGORY_PROFECIENCIES:Int = 5;
	
	static function getNewCharGenCategories():Array<CategoryPCP> {
		var arr:Array<CategoryPCP> = [];
		var a;
		arr[CATEGORY_RACE] = a = new CategoryPCP("Race"); a.slug = "gen-race";
		arr[CATEGORY_ATTRIBUTES] =a= new CategoryPCP("Attributes"); a.slug = "gen-attributes";
		arr[CATEGORY_BNB] = a=new CategoryPCP("Boons & Banes"); a.slug = "gen-bnb";
		arr[CATEGORY_SKILLS] = new CategoryPCP("Skills"); a.slug = "gen-skills";
		arr[CATEGORY_SOCIAL_WEALTH] = a=new CategoryPCP("Social class/Wealth");  a.slug = "gen-social-class";
		arr[CATEGORY_PROFECIENCIES] = a = new CategoryPCP("School/Profeciencies"); a.slug = "gen-schoolprofs";

		return arr;
	}
	public var categoryRace(get, never):CategoryPCP;
	inline function get_categoryRace():CategoryPCP 
	{
		return categories[CATEGORY_RACE];
	}
	public var categoryAttributes(get, never):CategoryPCP;
	inline function get_categoryAttributes():CategoryPCP 
	{
		return categories[CATEGORY_ATTRIBUTES];
	}
	
	public var categoriesRemainingAssignable(get, never):Int;
	function get_categoriesRemainingAssignable():Int {
		var accum:Int = 0;
		for (i in 0...categories.length) {
			accum += categories[i].pcp;
		}
		return campaignPowLevel.pcp - accum ;
	}
	
	public var isValidCategories(get, never):Bool;
	function get_isValidCategories():Bool {
		return categoriesRemainingAssignable >= 0;
	}
	
	
	
	
	public var warningCategories:WarningDef = { warn:false, remain:0};
	public function checkWarningCategories():Bool {
		var rm:Int = categoriesRemainingAssignable;
		if (rm > 0) {
			warningCategories.warn = true;
			warningCategories.remain = rm;
			return true;
		}
		else {
			return false;
		}
	}
	
	
	// RACE
	public var selectedTierIndex:Int = 0;
	public var raceTierTable:Array<Array<Race>>;
	
	var pcpForTiers:Array<Int>;
	
	public var isHuman(get, never):Bool;
	inline function get_isHuman():Bool {
		return selectedRaceName == "Human";
	}
	
	public var selectedRaceName(get, never):String;
	inline function get_selectedRaceName():String {
		return char.race != null ? char.race.name : "";
	}
	
	public inline function resetToHuman():Void {
		selectedTierIndex = 0;
		this.char.race = raceTierTable[0][0];
	}

	
	public inline function selectRaceAt(ti:Int, ri:Int):Void {
		selectedTierIndex = ti;
		char.race = raceTierTable[ti][ri];

		
	}
	
	public inline function settleRaceTier():Void {
		categories[CATEGORY_RACE].pcp = pcpForTiers[selectedTierIndex];
	}
	public var promptSettleRaceTier(get, never):Bool;
	function get_promptSettleRaceTier():Bool {
		return categories[CATEGORY_RACE].pcp != pcpForTiers[selectedTierIndex];
	}
	
	public var raceTier(get, never):Int;
	function get_raceTier():Int {
		return getRaceTierFromPCP(categoryRace.pcp);
	}
	public function getRaceTierFromPCP(pcp:Int):Int {
		// TODO: lookup table
		var b:Int = 0;
		for ( i in 0...pcpForTiers.length) {
			if (pcpForTiers[i] > pcp) break;
			b = i;
		}
		return b + 1;
	}
	
	// ATTRIBUTES
	static public inline var ATTRIBUTE_START_MAX:Int = 8; 
	static public inline var MORTAL_MAX:Int = 12;
	
	static var PCP_COLUMN_ATTRIBUTES:Array<Int> = [22,23,24,27,31,35,40,45,50,56];
	
	var boonAssignList:Array<BoonAssign>;
	var baneAssignList:Array<BaneAssign>;

	
	public var totalAttributePointsSpent(get, never):Int;
	function get_totalAttributePointsSpent():Int {
		var sum:Int = 0;
		sum+=GetAttributeTotalCostOfLevel(char.strength);
		sum+=GetAttributeTotalCostOfLevel(char.agility);
		sum+=GetAttributeTotalCostOfLevel(char.endurance);
		sum+=GetAttributeTotalCostOfLevel(char.health);
		sum+=GetAttributeTotalCostOfLevel(char.willpower);
		sum+=GetAttributeTotalCostOfLevel(char.wit);
		sum+=GetAttributeTotalCostOfLevel(char.intelligence);
		sum+=GetAttributeTotalCostOfLevel(char.perception);
		return sum;
	}
	
	public var remainingAttributePoints(get, never):Int;
	
	public var availableAttributePoints(get, never):Int;
	function get_availableAttributePoints():Int {
		return PCP_COLUMN_ATTRIBUTES[categoryAttributes.pcp-1];
	}
	

	
	function get_remainingAttributePoints():Int {
		return availableAttributePoints- totalAttributePointsSpent;
	}
	
	
	// todo: check these methods with table
	public static inline function GetAttributeTotalCostOfLevel(level:Int):Int {
		return level < 11 ? level - 1 :  9  + (level - 10) * 2; 
	}
	
	public static inline function MaxAttributeLevelUpsFrom(level:Int, remainingAttribPoints:Int):Int {
		var upTo:Int = level + remainingAttribPoints;
		return remainingAttribPoints - ( upTo > 10 ? upTo-10 : 0);
	}
	
	public function canBuyMoreAttributeLevels():Bool {
		var rm:Int = remainingAttributePoints;
		if (MaxAttributeLevelUpsFrom(char.strength, rm )>0) return true;
		if (MaxAttributeLevelUpsFrom(char.agility, rm )>0) return true;
		if (MaxAttributeLevelUpsFrom(char.endurance, rm )>0) return true;
		if (MaxAttributeLevelUpsFrom(char.health, rm )>0) return true;
		if (MaxAttributeLevelUpsFrom(char.willpower, rm )>0) return true;
		if (MaxAttributeLevelUpsFrom(char.wit, rm )>0) return true;
		if (MaxAttributeLevelUpsFrom(char.intelligence, rm )>0) return true;
		if (MaxAttributeLevelUpsFrom(char.perception,rm )>0) return true;
		return false;
	}
	
	public var warningAttributes:WarningDef = { warn:false, remain:0};
	public function checkWarningAttributes():Bool {
		var rm:Int = remainingAttributePoints;
		if (rm  > 0 && canBuyMoreAttributeLevels()) {
			warningAttributes.warn = true;
			warningAttributes.remain = rm;
			return true;
			
		}
		else {
			return false;
		}
	}
	
	
	// BOONS & BANES
	
	//public var allBaneAssignments():Int
	/*
	
		Remember to register/un-register any modifiers assosiated with each boon/bane adding/removal from CharSheet.

		_____


		*/

		public function restoreAnyBnBWithMask(msk:Int):Void {
		var arr = baneAssignList;
		var arr2 = boonAssignList;
		for (i in 0...arr.length) {  // banes first
			var a = arr[i];
			if ( a._canceled && (a.bane.channels & msk)!=0 ) {
				a._canceled = false;
				return;
			}
		}
		for (i in 0...arr2.length) {
			var a = arr2[i];
			if ( a._canceled &&  (a.boon.channels & msk)!=0 ) {
				a._canceled = false;
				return;
			}
		}
	}
	
	// Duplicate
	public function checkBaneAgainstOthers(baneAssign:troshx.sos.core.BoonBane.BaneAssign):Void {
		var arr = baneAssignList;
		var arr2 = boonAssignList;
		baneAssign._canceled = false;
		if (baneAssign.bane.channels == 0) return;
		
		var msk:Int = baneAssign.bane.channels;
		for (i in 0...arr.length) {
			var a = arr[i];
			if ( a != baneAssign && (a.bane.channels & msk)!=0 ) {
				a._canceled = true;
			}
		}
		for (i in 0...arr2.length) {
			var a = arr2[i];
			if (  (a.boon.channels & msk)!=0 ) {
				a._canceled = true;
			}
		}
	}
	

	
	// dupliacte semi
	public function checkBoonAgainstOthers(boonAssign:troshx.sos.core.BoonBane.BoonAssign):Void {
		var arr = baneAssignList;
		var arr2 = boonAssignList;
		boonAssign._canceled = false;
		if (boonAssign.boon.channels == 0) return;
		
		var msk:Int = boonAssign.boon.channels;
			for (i in 0...arr.length) {
			var a = arr[i];
			if (   (a.bane.channels & msk)!=0 ) {
				a._canceled = true;
			}
		}
		for (i in 0...arr2.length) {
			var a = arr2[i];
			if ( a != boonAssign && (a.boon.channels & msk)!=0 ) {
				a._canceled = true;
			}
		}
		
	}
		
	public static inline function getBnBFromPCP(pcp:Int):Int {
		return -BaneAssign.MAX_BANE_EARNABLE + (pcp*5-5);
	}
	
	public function uncancel(bba:troshx.sos.core.BoonBane.BoonBaneAssign, isBane:Bool):Void {
		bba._canceled = false;
		if (isBane) {
		
			checkBaneAgainstOthers(cast bba);
		}
		else {
			
			checkBoonAgainstOthers(cast bba);
		}
	}
		
	public function addBB(bba:troshx.sos.core.BoonBane.BoonBaneAssign, isBane:Bool):Void {
		//trace("ADDING:" + bba + " , " + isBane);
		if (isBane) {
			char.addBane(cast bba);
			checkBaneAgainstOthers(cast bba);
		}
		else {
			char.addBoon(cast bba);
			checkBoonAgainstOthers(cast bba);
		}
		
	}
	public function removeBB(bba:troshx.sos.core.BoonBane.BoonBaneAssign, isBane:Bool):Void {
		//trace("REMOVING:" + bba + " , " + isBane);
		if (isBane) {
			var b:BaneAssign = cast bba;
			char.removeBane(b);
			if (b.bane.channels!=0 ) restoreAnyBnBWithMask(b.bane.channels);
			
		}
		else {
			var b:BoonAssign = cast bba;
			char.removeBoon(b);
			if (b.boon.channels !=0) restoreAnyBnBWithMask(b.boon.channels);
		}
	}
	
	
	var categoryBnB(get, never):CategoryPCP;
		function get_categoryBnB():CategoryPCP 
	{
		return categories[CATEGORY_BNB];
	}
	
	public var totalBaneExpenditure(get, never):Int;
	public function get_totalBaneExpenditure():Int {
		var arr = char.banesArray;
		var total = 0;
		var i:Int = arr.length;
		while (--i > -1) {
			var b = arr[i];
			total += !b._canceled ? b._costCached : 0;
		}
		return total;
	}
	
	public var maxBanePointsEarnable(get, never):Int;
	public inline function get_maxBanePointsEarnable():Int {
		return BnBpoints < 0 ? BaneAssign.MAX_BANE_EARNABLE - BnBpoints : BaneAssign.MAX_BANE_EARNABLE;
	}
	
	public var totalBanePointsEarned(get, never):Int;
	public function get_totalBanePointsEarned():Int {
		var a = totalBaneExpenditure;
		var b = maxBanePointsEarnable;
		return a > b ? b : a;
	}
	
	public var totalBanePointsSpent(get, never):Int;
	public function get_totalBanePointsSpent():Int {
		return  totalBaneExpenditure - totalBanePointsEarned;
	}
	
	public var totalBoonExpenditure(get, never):Int;
	public function get_totalBoonExpenditure():Int {
		var arr = char.boonsArray;
		var total = 0;
		var i:Int = arr.length;
		while (--i > -1) {
			var b = arr[i];
			total += !b._canceled ? b._costCached : 0;
		}
		return total;
	}
	
	public var boonsArray(get, never):Array<troshx.sos.core.BoonBane.BoonAssign>;
	inline function get_boonsArray():Array<BoonAssign> {
		return char.boonsArray;
	}
	public var banesArray(get, never):Array<troshx.sos.core.BoonBane.BaneAssign>;
	inline function get_banesArray():Array<BaneAssign> {
		return char.banesArray;
	}
	
	public var BnBpoints(get, never):Int;
	function get_BnBpoints():Int {
	
		return getBnBFromPCP( categoryBnB.pcp);
	}
	
	
	public var totalBnBScore(get, never):Int;
	function get_totalBnBScore():Int {
		return BnBpoints + totalBanePointsEarned - totalBanePointsSpent - totalBoonExpenditure;
	}
	
	public var maxBoonsSpendable(get, never):Int;
	function get_maxBoonsSpendable():Int {
		return BnBpoints + maxBanePointsEarnable;
		
	}
	public var maxBoonsSpendableLeft(get, never):Int;
	function get_maxBoonsSpendableLeft():Int {
		return  maxBoonsSpendable - totalBoonExpenditure;
		
	}
	
	
	public var maxBanesSpendable(get, never):Int;
	function get_maxBanesSpendable():Int {
		return  maxBanePointsEarnable + (BnBpoints < 0 ? 0 : BnBpoints);
		
	}
	public var maxBanesSpendableLeft(get, never):Int;
	function get_maxBanesSpendableLeft():Int {
		return  maxBanesSpendable - totalBaneExpenditure;
		
	}
	
	
	// SKILLS

	var skillPackets:Array<SkillPacket>;
	
	var skillLabelMappingBases:Dynamic;
	var skillLabelMappings:Dynamic<String>;
	
	var skillValues:Dynamic<Int>;
	var skillPacketValues:Dynamic<Int>;
	var skillsTable:SkillTable;
	var skillObjs:Array<SkillObj>;
	var startingSkillObjsCount:Int;
	var skillSubjects:Array<String>;
	var skillSubjectsInitial:Dynamic<Bool>;
	var specialisedSkills:Array<String>;
	var packetChoosy:Bool = false;
	
	var skillSubjectHash:Dynamic<Array<String>>;
	
	
	static inline var MAX_PACKET_SKILL_LEVEL:Int = 5;
	
	public static function dynSetField<T>(of:Dynamic<T>, field:String, value:T):Void {
		#if js
		untyped of[field] = value;
		#else
		Reflect.setField(of, field, value);
		#end
	}
	
	public static function dynDeleteField<T>(of:Dynamic<T>, field:String):Void {
		Reflect.deleteField(of, field);
	}
	
	
	public function addSkill(skill:String, special:String):Void {
		var skillToSpecial:Array<String>;
		var specialToSkill:Array<String>;
		if ( (skillToSpecial=LibUtil.field(skillSubjectHash, skill)) == null ) {
			dynSetField(skillSubjectHash, skill, skillToSpecial=[]);
		}
		if ( (specialToSkill=LibUtil.field(skillSubjectHash, special)) == null ) {
			dynSetField(skillSubjectHash, special, specialToSkill=[]);
		}
		skillToSpecial.push(special);
		specialToSkill.push(skill);
		
		var name = Skill.specialisationName(skill, special);
		dynSetField(skillValues, name, 0);
		dynSetField(skillPacketValues, name, 0);
		
		skillObjs.push({
			name: name,
			attribs:0	// for this case (or for now), this isn't needed
		});
	}
	
	
	public function deleteSkillInput(index:Int):Void {
		var obj = skillObjs[index];
		var spl = Skill.getSplitFromSpecialisation(obj.name);
		var skill = spl[0];
		var special = spl[1];
		
		
		var skillToSpecial:Array<String> = LibUtil.field(skillSubjectHash, skill);
		var specialToSkill:Array<String>  = LibUtil.field(skillSubjectHash, special);
		skillToSpecial.splice( skillToSpecial.indexOf(special), 1 );
		specialToSkill.splice( skillToSpecial.indexOf(skill), 1 );
		dynDeleteField(skillValues, obj.name);
		dynDeleteField(skillPacketValues, obj.name);
		
		skillObjs.splice(index, 1);
	}
	
	
	
	public function onSkillPacketChange(index:Int, vector:Int, clickedPlus:Bool):Void {
		var packet = skillPackets[index];
		
		if (packet.history == null) {
			for (i in 0...packet.fields.length) {
				var f = packet.fields[i];
				LibUtil.setField(skillPacketValues, f, LibUtil.field(skillPacketValues, f) + LibUtil.field(packet.values, f) * vector);
			}
		}
		else { // todo: history scrolling case
			for (i in 0...packet.fields.length) {
				var f = packet.fields[i];
				var l = getSkillLabel(f);
				LibUtil.setField(skillPacketValues, l, LibUtil.field(skillPacketValues, l) + LibUtil.field(packet.values, f) * vector);
			}
		}
		
		if (vector > 0  ) {  // items added, invalidate stateful history current levels
			if (packet.history == null || clickedPlus) truncateSkillPacketHistory();
		}
	}
	
	public function onSkillIndividualChange(vector:Int):Void {
		if (vector > 0) {  
			truncateSkillPacketHistory();
		}
	}
	
	 // naive approach..just clear future history instead of evaluating future per-history item instance max qty caps.
	function truncateSkillPacketHistory():Void {
		for ( i in 0...skillPackets.length) {
			var s = skillPackets[i];
			if (s.history != null) {
				if (s.history.length != s.qty) {
					LibUtil.setArrayLength(s.history, s.qty);
				}
			}
		}
	}
	/*  // not used atm
	public function tallySkillsFromPackets():Void {
		for (f in Reflect.fields(skillValues)) {
			
			LibUtil.setField(skillPacketValues, f, 0);
		}
		for (i in 0...skillPackets.length) {
			var packet = skillPackets[i];
			for (i in 0...packet.fields.length) {
				var f = packet.fields[i];
				LibUtil.setField(skillPacketValues, f, LibUtil.field(skillValues, f) + LibUtil.field(packet.values, f) );
				
			}	
		}
	}
	*/
	
	public function finaliseSkillsFromPackets():Void {
		// to do this when finailising char sheet
		
	}
	public inline function clampSkillValue(value:Int):Int {
		return value >= MAX_PACKET_SKILL_LEVEL ? MAX_PACKET_SKILL_LEVEL : value;
	}

	public inline function isSkillLabelBinded(s:String):Bool {
		return  CharGenSkillPackets.isSkillLabelBinded(s);
	}
	public function getSkillLabel(s:String):String {
		return CharGenSkillPackets.getSkillLabel(s, skillLabelMappingBases, skillLabelMappings);
	}

	
	public var SkillPoints(get, never):Int;
	function get_SkillPoints():Int {
		return (categories[CATEGORY_SKILLS].pcp-1) * 3;	
	}
	
	public var individualSkillsSpent(get, never):Int;
	function get_individualSkillsSpent():Int {
		var c:Int = 0;
		for (f in Reflect.fields(skillValues)) {
			c += LibUtil.field(skillValues, f);  // how to seperate out skillpackets
		}
		
		return c;
	}
	
	public var maxSkillPacketsAllowed(get, never):Int;
	function get_maxSkillPacketsAllowed():Int {
		return Math.floor( (totalSkillPointsProvided - individualSkillsSpent) / 3);
	}
	
	public var maxIndividualSkillsSpendable(get, never):Int;
	function get_maxIndividualSkillsSpendable():Int {
		return totalSkillPointsProvided - skillPacketsBought * 3;
	}
	
	public var individualSkillsRemaining (get, never):Int;
	function get_individualSkillsRemaining ():Int {
		return maxIndividualSkillsSpendable - individualSkillsSpent;
	}
	
	
	public var totalSkillPointsProvided(get, never):Int;
	function get_totalSkillPointsProvided():Int {
		
		return SkillPoints + char.intelligence * 2;
	}
	
	public var skillPacketsRemaining(get, never):Int;
	function get_skillPacketsRemaining():Int {
	
		return maxSkillPacketsAllowed - skillPacketsBought;
	}
	
	public var skillPacketsBought(get, never):Int; 
	function get_skillPacketsBought():Int {
		var c:Int = 0;
		var i = skillPackets.length;
		while (--i > -1) {
			c += skillPackets[i].qty;
		}
		return c;
	}
	
	public var totalSkillPointsLeft(get, never):Int;
	function get_totalSkillPointsLeft():Int {
		return totalSkillPointsProvided - individualSkillsSpent - skillPacketsBought*3;
	}
	
	
	function getEmptyMappingsFromBase(base:Dynamic):Dynamic<String>
	{
		var map:Dynamic<String> = {};
		var count:Int = 1;
		for (p in Reflect.fields(base)) {
			var dyn = LibUtil.field(base, p);
			if (Std.is(dyn, Array)) {
				LibUtil.setField(map, p, LibUtil.as(dyn, Array)[0]); 
			}
			else {
				LibUtil.setField(map, p, "");
			}
			
		}
		
		var arrAdded:Array<SkillObj> = [];
		
		this.skillValues = {};
		this.skillPacketValues = {};
		for (i in 0...skillPackets.length) {
			var s = skillPackets[i];
			for ( f in Reflect.fields(s.values)) {
				LibUtil.setField(this.skillValues, f, 0);
				LibUtil.setField(this.skillPacketValues, f, 0);
				if ( !CharGenSkillPackets.isSkillLabelBinded(f) && !skillsTable.hasSkill(f)) {
					arrAdded.push({ name:f, attribs:0});
				}
			}
		}
		
		for (f in Reflect.fields(skillsTable.skillHash)) {
			if ( !skillsTable.requiresSpecification(f) ) {
				LibUtil.setField(this.skillValues, f, 0);
				LibUtil.setField(this.skillPacketValues, f, 0);
			}
		}
		arrAdded.sort(SkillTable.sortArrayMethod);
		skillObjs = skillObjs.concat(arrAdded);
		
		skillSubjects = CharGenSkillPackets.getExistingSubjects();
		var reflectedExisting:Dynamic<Bool> = {};
		for ( i in 0...skillSubjects.length) {
			LibUtil.setField(reflectedExisting, skillSubjects[i], true);
		}
		skillSubjectsInitial = reflectedExisting;
	
		
		return map;
	}
	
	//static var PCP_COLUMN_SKILLS:Array<Int> = [6,9,12,15,18,21,24,27,30,33];

	
	// SOCIAL CLASS/WEALTH
	// to lookup wealth table of different social classes
	
	
	// SCHOOL/PROFECIENCIES
	//static var PCP_COLUMN_PROFS:Array<Int> = [0,3,6,9,12,15,18,21,24,27];
	public var ProfPoints(get, never):Int;
	inline function get_ProfPoints():Int {
		return (categories[CATEGORY_PROFECIENCIES].pcp-1) * 3;	
	}
	
	

	// TODO final: validate all char generation categories
	
	public function isValidAll(showWarnings:Bool=false):Bool { 
		return true;
	}
	
	
	
	
}

typedef WarningDef = {
	var warn:Bool;
	var remain:Int;
}


