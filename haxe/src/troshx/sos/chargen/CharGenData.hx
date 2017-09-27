package troshx.sos.chargen;

import haxe.ds.StringMap;
import haxevx.vuex.core.IBuildListed;
import troshx.sos.bnb.Banes;
import troshx.sos.bnb.Boons;
import troshx.sos.chargen.CategoryPCP;
import troshx.sos.chargen.SkillPacket;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.BoonBane.BoonAssign;
import troshx.sos.core.Money;
import troshx.sos.core.Profeciency;
import troshx.sos.core.Race;
import troshx.sos.core.School;
import troshx.sos.core.Skill;
import troshx.sos.core.SocialClass;
import troshx.sos.races.Races;
import troshx.sos.schools.Schools;
import troshx.util.LibUtil;


import troshx.sos.sheets.CharSheet;


/**
 * View model for Character generation 
 * All formulas based off gist: https://gist.github.com/Glidias/9cbd8bd8114649207b79c252873fd207
 * 
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
		this.categories[CATEGORY_PROFECIENCIES].pcp = 6; // for testing
		
		// ............
		
		// Boones and banes
		initBoons();
		
		// Skills
		initSkills();
		
		// Social class
		initSocialClasses();
		
		initSocialClassesBenefits();
		
		// Schools and profs
		initSchools();
		
	}
	
	function initSchools():Void {
		
		schoolLevelCosts = School.getLevels();
		var accum:Int;
		
		accum =  schoolLevelCosts[0];
		for (i in 1...schoolLevelCosts.length) {
			accum +=  schoolLevelCosts[i];
			schoolLevelCosts[i] = accum;
		}
		
		talentsAvailable = School.getTalentAdds();
		
		accum =  talentsAvailable[0];
		for (i in 1...talentsAvailable.length) {
			accum +=  talentsAvailable[i];
			talentsAvailable[i] = accum;
		}
		
		superiorsAvailable = School.getSuperiorAdds();
		
		accum =  superiorsAvailable[0];
		for (i in 1...superiorsAvailable.length) {
			accum +=  superiorsAvailable[i];
			superiorsAvailable[i] = accum;
		}
		
		schoolAssignList = [];
		var schoolList = Schools.getList();
		for (i in 0...schoolList.length) {
			var s = schoolList[i];
			schoolAssignList.push({
				school:s,
				bonuses:s.getSchoolBonuses(char)
			});
		}
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
		
		skillsTable = SkillTable.getNewDefaultSkillTable();
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
	
	function initSocialClasses():Void {
		var haleAndHearty2 = {cost:2, name:"Hale and Hearty", rank:1};
		var beautiful3 = {cost:3, name:"Beautiful", rank:1};
		var folksBackHome3 = {cost:3, name:"Folks Back Home", rank:1};
		var folksBackHome6 = {cost:6, name:"Folks Back Home", rank:2};
		var literate1 = {cost:1, name:"Literate", rank:1};
		var literate2= {cost:2, name:"Literate", rank:1, qty:2};
		var literate3 = {cost:3, name:"Literate", rank:1, qty:3};
		var languages3 = {cost:3, name:"Language", rank:3};
		var languages2 = {cost:2, name:"Language", rank:2};
		var languages1 = {cost:1, name:"Language", rank:1};
		var contacts1 = {cost:1, name:"Contacts", rank:1};
		var contacts4 = {cost:4, name:"Contacts", rank:2};
		var contacts6 = {cost:6, name:"Contacts", rank:3};
		var allies5 = {cost:5, name:"Allies", rank:2};
		var allies10 = {cost:10, name:"Allies", rank:3};
		var famous2 = {cost:2, name:"Famous", rank:1};
		var famous4 = {cost:4, name:"Famous", rank:2};
		
		socialClassList = [
			{ socialClass: new SocialClass("Slave/Exile", Money.create(0, 10, 0), 0 ), boons:[haleAndHearty2, languages2, beautiful3], maxBoons:1  },
			{ socialClass: new SocialClass("Peasant", Money.create(5, 0, 0), 0 ), boons:[haleAndHearty2, folksBackHome3], maxBoons:1  },
			{ socialClass: new SocialClass("Poor Freeman", Money.create(15, 0, 0), 0 ), boons:[haleAndHearty2, folksBackHome3, literate1], maxBoons:1  },
			{ socialClass: new SocialClass("Freeman", Money.create(25, 0, 0), 1 ), boons:[haleAndHearty2, folksBackHome3, literate1] , maxBoons:2 },
			{ socialClass: new SocialClass("High Freeman", Money.create(40, 0, 0), 2 ), boons:[folksBackHome6, literate1, languages1, contacts1 ], maxBoons:2  },
			{ socialClass: new SocialClass("Minor Noble", Money.create(80, 0, 0), 3 ), boons:[haleAndHearty2, folksBackHome6, literate1, languages1, contacts1, allies5,  famous2], maxBoons:2 },
			{ socialClass: new SocialClass("Landed Noble", Money.create(150, 0, 0), 6 ), boons:[haleAndHearty2, folksBackHome6, literate2, languages2, contacts4, allies5, famous2], maxBoons:2  },
			{ socialClass: new SocialClass("High Noble", Money.create(300, 0, 0), 10 ), boons:[haleAndHearty2, folksBackHome6, literate2, languages2, contacts4, allies10, famous4, ] , maxBoons:2 },
			{ socialClass: new SocialClass("Royalty", Money.create(800, 0, 0), 15 ), boons:[haleAndHearty2, folksBackHome6, literate2, languages2, contacts4, allies10, famous4 ], maxBoons:3},
			{ socialClass: new SocialClass("High Royalty", Money.create(1500, 0, 0), 20 ), boons:[haleAndHearty2, folksBackHome6, literate3, languages3, contacts6, allies10, famous4 ], maxBoons:3}
		];
		
	}
	
	function initSocialClassesBenefits():Void {
		for (i in 0...socialClassList.length) {
			var s = socialClassList[i];
			for (b in 0...s.boons.length) {
				var sb = s.boons[b];
				if (sb.index == null) {
					sb.index = findBoonIndexByName(sb.name);
					sb.label = sb.name + " (" +  sb.cost + ")";
					if (sb.index == -1) {
						throw "Could not find Social boon by: " + sb.name;
					}
				}
			}
		}
		
		socialBenefit1 = emptySocialBenefit; // socialClassList[0].boons[0];
		socialBenefit2 = emptySocialBenefit;// socialClassList[3].boons[1];
		socialBenefit3 = emptySocialBenefit;// socialClassList[8].boons[2];
		
	}
	
	
	
	function findBoonIndexByName(boonName:String):Int {
		for ( i in 0...boonAssignList.length) {
			var b = boonAssignList[i];
			if (b.boon.name == boonName) return i;
		}
		return -1;
	}
	
	
	
	
	// Non-reactive data can be intialized here.
	public function privateInit():Void {
		
		// skills
		for (i in 0...skillPackets.length) {
			var s = skillPackets[i];
			s.fields = Reflect.fields(s.values);
			
		}
		
		
		// social class
		validateSocialBenefitsWithClass(1);
	
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
	
	public var categorySocialClassWealth(get, never):CategoryPCP;
	inline function get_categorySocialClassWealth():CategoryPCP 
	{
		return categories[CATEGORY_SOCIAL_WEALTH];
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
	
	
	
	// SOCIAL CLASS/WEALTH
	// to lookup wealth table of different social classes
	public var socialClassList:Array<SocialClassAssign>;


	var socialClassIndex:Int = 0;
	var wealthIndex:Int = 0;
	var syncSocialWealth:Bool = true; // user prefered option flag
	
	var socialBenefit1:SocialBoonAssign;
	var socialBenefit2:SocialBoonAssign;
	var socialBenefit3:SocialBoonAssign;
	
	var socialBenefitTempArr:Array<String> = [];
	var wealthAssets:Array<WealthAssetAssign> = [];
	
	var emptySocialBenefit:SocialBoonAssign = {name:"", rank:0, cost:0};
	
	public function getEmptyWealthAssign():WealthAssetAssign {
		return this.char.getEmptyWealthAssetAssign(1);
	}
	
	public function updateSocialBenefitsToBoon(newValue:SocialBoonAssign, oldValue:SocialBoonAssign):Void {
		
		var b;
		if (oldValue.rank > 0) {
			b = boonAssignList[oldValue.index];
	
			
			//b.rank > 0 && 
			if (b.rank == oldValue.rank) {
				
				if ( b.getCost(b.rank) == oldValue.cost) {
					b.rank = 0; 
				}
				
			}
			
			b._minRequired = 0;
			b.discount = 0;
		}
		
		if (newValue.rank > 0) {
			b = boonAssignList[newValue.index];
			b.discount = newValue.cost;
			if (b.rank == 0) {
				b.rank = newValue.rank;
			}
			b._minRequired = newValue.rank;
			
			
			if (newValue.qty != null) {
				// yagni setQty marker for boon
			}
		}
	}
	
	public function validateSocialBenefitsWithClass(zoneNum:Int):Void {
		
		var socialBenefit:SocialBoonAssign = null;
		if (zoneNum==1) {
			socialBenefit = socialBenefit1;
		}
		else if (zoneNum==2) {
			socialBenefit = socialBenefit2;
		}
		else if (zoneNum==3) {
			socialBenefit = socialBenefit3;
		}
		
		var maxBoons = curSelectedSocialClass.maxBoons;
		
		socialBenefitTempArr[0] = zoneNum ==1 ? null : socialBenefit1.name;
		socialBenefitTempArr[1] = zoneNum ==2  || maxBoons< 2 ? null : socialBenefit2.name;
		socialBenefitTempArr[2] = zoneNum == 3  || maxBoons < 3 ? null : socialBenefit3.name;

	
		var choices = socialBenefitChoices;
		var resolvedIndex = choices.indexOf(socialBenefit);
		
		var secondaryResolvedIndex:Int = -1;
		
		if (resolvedIndex < 0) {
			// need to disable off hash
			
			
			for (i in 0...choices.length) {
				if (secondaryResolvedIndex == -1) {
					if (  socialBenefitTempArr.indexOf(choices[i].name)  < 0 ) {
						secondaryResolvedIndex = i;
					}
				}
				if (choices[i].name == socialBenefit.name) {
					resolvedIndex = i;
					break;
				}
			}
			
			if (resolvedIndex  < 0) resolvedIndex = secondaryResolvedIndex >= 0 ? secondaryResolvedIndex : 0;
			
			
			// need to enable into hash
			if (zoneNum==1) {
				socialBenefit1 = choices[resolvedIndex];
			}
			else if (zoneNum==2) {
				socialBenefit2 = choices[resolvedIndex];
			}
			else if (zoneNum==3) {
				socialBenefit3 = choices[resolvedIndex];
			}
		}
		
		if (resolvedIndex < 0) throw "Should have resolved index for social benefit choice!";
	}
	
	public function socialBenefitSelectChangeHandler(zoneNum:Int, selectedIndex:Int):Void {
		var choices = socialBenefitChoices;
		if (zoneNum==1) {
			socialBenefit1 = choices[selectedIndex];
		}
		else if (zoneNum==2) {
			socialBenefit2 = choices[selectedIndex];
		}
		else if (zoneNum==3) {
			socialBenefit3 = choices[selectedIndex];
		}
	}
	
	public var availableWealthPoints(get,never):Int;
	inline function get_availableWealthPoints():Int {
		return socialClassList[wealthIndex].socialClass.wealth;
	}
	
	
	public var remainingWealthPointsFull(get,never):Int;
	inline function get_remainingWealthPointsFull():Int {
		return availableWealthPoints - wealthAssetsWorthFullArray();
	}
	
	public var remainingWealthPoints(get,never):Int;
	inline function get_remainingWealthPoints():Int {
		return availableWealthPoints - wealthAssetsWorth();
	}
	
	function wealthAssetsWorthFullArray():Int {
		var i:Int = wealthAssets.length;
		var c:Int = 0;
		while (--i > -1) {
			c += wealthAssets[i].worth;
		}
		return c;
	}
	
	inline function wealthAssetsWorthLen():Int {
		var len:Int = wealthAssets.length;
		var max = maxWealthAssets;
		return ( len >= max ? max : len);
	}
	function wealthAssetsWorth():Int {
		var c:Int = 0;
		var len:Int = wealthAssetsWorthLen();
		for (i in 0...len) {
			c += wealthAssets[i].worth;
		}
		return c;
	}
	
	public var socialBenefitChoices(get,never):Array<SocialBoonAssign>;
	inline function get_socialBenefitChoices():Array<SocialBoonAssign> {
		return curSelectedSocialClass.boons;
	}
	
	public var curSelectedSocialClass(get,never):SocialClassAssign;
	inline function get_curSelectedSocialClass():SocialClassAssign {
		return socialClassList[socialClassIndex];
	}
	
	public var maxSocialClassIndex(get, never):Int;
	inline function get_maxSocialClassIndex():Int 
	{
		return categorySocialClassWealth.pcp  - 1;
	}
	
	public function constraintSocialWealth():Void {
		if (syncSocialWealth) {
			var max = maxSocialClassIndex;
			
			if (socialClassIndex > max) {
				socialClassIndex = max;
			}
			
			wealthIndex = socialClassIndex;
		}
		else {  
			// constraint the wealth first
			
			var max = unevenMaxWealthIndex;

			if (wealthIndex > max) {
				wealthIndex = max;
			}
			
			// priotitiese to keep social class 
			
			max =  unevenMaxSocialClassIndex;  
			if (socialClassIndex > max) {
				socialClassIndex = max;
			}
		}
	}
	
	public var socialEitherMaxIndex(get, never):Int;
	function get_socialEitherMaxIndex():Int {
		var a = maxSocialClassIndex;
		var b = unevenMaxSocialClassIndex;
		return syncSocialWealth ? a : b;
	}
	
	public var wealthEitherMaxIndex(get, never):Int;
	function get_wealthEitherMaxIndex():Int {
		var a = maxSocialClassIndex;
		var b = unevenMaxWealthIndex;
		return syncSocialWealth ? a : b;
	}
	
	public var socialClassPlaceHolderName(get, never):String;
	function get_socialClassPlaceHolderName():String {
		return socialClassIndex != wealthIndex ? socialClassList[socialClassIndex].socialClass.name + " -$: " + socialClassList[wealthIndex].socialClass.name : socialClassList[socialClassIndex].socialClass.name;
	}
	public var promptSettleSocialTier(get, never):Bool;
	inline function get_promptSettleSocialTier():Bool {
		return socialPCPRequired != categorySocialClassWealth.pcp;// this.maxSocialClassIndex;
	}
	
	public var socialPCPRequired(get, never):Int;
	inline function get_socialPCPRequired():Int {
		return socialClassIndex != wealthIndex ? unevenSocialPCPRequired : socialClassIndex + 1;
	}
	
	
	public function settleSocialTier():Void {
		//if (socialClassIndex == wealthIndex) {
			syncSocialWealth = socialClassIndex == wealthIndex; // lazy imperative fix.
		//}
		categorySocialClassWealth.pcp = socialPCPRequired;
	}
	
	inline function solveSocialOrWealthMaxX(x:Int, y:Int, C:Int):Int {
		x = C * 2 - 4 - y;
		x -= ((x & 1) ^ (y & 1)); 
		return x;
	}
	
	public var unevenSocialPCPRequired(get, never):Int;
	function get_unevenSocialPCPRequired():Int {
		var x =  socialClassIndex + 1;
		var y = wealthIndex + 1;
		var C = categorySocialClassWealth.pcp;
		return Math.ceil((x + y)/2) + 2;
	}
	
	public var unevenMaxSocialClassIndex(get, never):Int; 
	function get_unevenMaxSocialClassIndex():Int 
	{
		var r =  solveSocialOrWealthMaxX(socialClassIndex + 1, wealthIndex + 1, categorySocialClassWealth.pcp) - 1;
		return r >= 0 ? r : 0;
	}
	
	public var unevenMaxWealthIndex(get, never):Int; 
	function get_unevenMaxWealthIndex():Int 
	{
		var r =  solveSocialOrWealthMaxX(wealthIndex + 1, socialClassIndex + 1, categorySocialClassWealth.pcp) - 1;
		return r >= 0 ? r : 0;
	}
	
	public function setSocialClassIndex(index:Int):Void {
		socialClassIndex = index;
		if (syncSocialWealth) {
			wealthIndex = index;
		}
	}
	
	public function setWealthIndex(index:Int):Void {
		wealthIndex = index;
	}
	
	public function updateSocialToCharsheet():Void {
		var s =  socialClassList[socialClassIndex];
		
		this.validateSocialBenefitsWithClass(1);
		if (s.maxBoons >= 2) this.validateSocialBenefitsWithClass(2);
		else {
			socialBenefit2  = emptySocialBenefit;
		}
		if (s.maxBoons >= 3)  this.validateSocialBenefitsWithClass(3);
		else {
			socialBenefit3 = emptySocialBenefit;
		}

		this.char.socialClass.classIndex = socialClassIndex;
		
	}
	

	
	public var maxWealthAssets(get, never):Int;
	function get_maxWealthAssets():Int {
		return wealthAssets.length + remainingWealthPointsFull;
	}
	
	public function updateMoneyToCharsheet():Void {
		var s =  socialClassList[wealthIndex];
		this.char.socialClass.wealthIndex = wealthIndex;
		this.char.socialClass.money.matchWith(s.socialClass.money );
		this.char.socialClass.wealth = s.socialClass.wealth;
	}
	
	
	
	function filterAwayLiquidatedAssets(w:WealthAssetAssign):Bool
	{
		return !w.liquidate;
	}
	
	
	public function saveFinaliseSocial():Void {
		if (socialClassIndex == wealthIndex || this.char.socialClass.name == "") this.char.socialClass.name = socialClassPlaceHolderName; 

		
		var len:Int = wealthAssetsWorthLen();
		var a = this.wealthAssets.slice(0, len);
		a =  a.filter(filterAwayLiquidatedAssets);
		this.char.wealthAssets = a;
	}
	
	
	// CHECKOUT  
	
	public var moneyAvailableStr(get,never):String;
	inline function get_moneyAvailableStr():String {
		return socialClassList[wealthIndex].socialClass.money.getLabel();
	}
	

	public var notBankrupt(get, never):Bool; // TODO:
	function get_notBankrupt():Bool {
		return true; 
	}
	
	public var checkoutBonuses(get, never):String; 
	function get_checkoutBonuses():String {
		return "0"; 
	}

	public var checkoutPenalties(get, never):String; 
	function get_checkoutPenalties():String {
		return "0"; 
	}
	public var checkoutSchool(get, never):String; 
	function get_checkoutSchool():String {
		return (char.school != null && char.school.costMoney != null ?  char.school.costMoney.getLabel() : "0"); 
	}
	
	public var checkoutInventory(get, never):String; 
	function get_checkoutInventory():String {
		return "0"; 
	}

	
	public var moneyLeftStr(get,never):String; // TODO:
	inline function get_moneyLeftStr():String {  
		return  socialClassList[wealthIndex].socialClass.money.tempCalc().addValues(this.liquidity, 0, 0).subtractAgainst(char.school != null && char.school.costMoney != null ? char.school.costMoney : Money.ZERO ).getLabel(); 
	}

	public var liquidity(get, never):Int; 
	inline function get_liquidity():Int {
		var len:Int = wealthAssetsWorthLen();
		return CharSheet.getTotalLiquidity(wealthAssets, len); 
	}
	
	public var liquidityStr(get, never):String; 
	function get_liquidityStr():String {
		return Money.getLabelWith(this.liquidity, 0,0);
	}
	
	
	public function isValidAll(showWarnings:Bool=false):Bool { 
		return true;
	}
	
	public function saveFinaliseAll():Void { // TODO
		if (isValidAll(true)) {
			char.ingame = true;
			// save data
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
		var restored:Bool = false;
		var restoredBane:troshx.sos.core.BoonBane.BaneAssign = null;
		var restoredBoon:troshx.sos.core.BoonBane.BoonAssign = null;
		
		for (i in 0...arr.length) {  // banes first
			var a = arr[i];
			if ( a._canceled && (a.bane.channels & msk)!=0 ) {
				a._canceled = false;
				
				if (a.rank > 0)  {
					restoredBane = a;
					break;
				}
			}
		}
	
		
		if (restoredBane == null) {
			for (i in 0...arr2.length) {
				var a = arr2[i];
				if ( a._canceled &&  (a.boon.channels & msk)!=0 ) {
					a._canceled = false;
					if (a.rank > 0)  {
						restoredBoon = a;
						break;
					}
				}
			}
		}
		
		if (restoredBoon != null) {
			checkBoonAgainstOthers(restoredBoon);
		}
		else if (restoredBane != null) {
			checkBaneAgainstOthers(restoredBane);
		}
		
	}
	
	public function resetBB(bba:troshx.sos.core.BoonBane.BoonBaneAssign, isBane:Bool):Void {
		//trace("REMOVING:" + bba + " , " + isBane);
		if (isBane) {
			//char.removeBane(cast bba);
			var bane:Bane = cast bba.getBoonOrBane();
			var ba;
			var i = baneAssignList.indexOf(cast bba);
			ba = bane.getAssign(0, char);
			ba._costCached = bane.costs[0];
			ba._forcePermanent = bba._forcePermanent;
			
			ba._minRequired = bba._minRequired;
			ba._canceled = bba._canceled;
			CharGenData.dynSetArray(this.baneAssignList, i, ba );
			
		}
		else {
			var boonAssign:BoonAssign = cast bba;
			var boon:Boon = boonAssign.boon;
			var ba;
			var i = boonAssignList.indexOf(cast bba);
			ba = boon.getAssign(0, char);
			ba.discount = boonAssign.discount;
			ba.rank = bba._minRequired;
			ba._remainingCached = maxBoonsSpendableLeft;
			
			
			
			ba._costCached = boon.costs[0];
			ba._forcePermanent = bba._forcePermanent;
			ba._minRequired = bba._minRequired;
			ba._canceled = bba._canceled;
			CharGenData.dynSetArray(this.boonAssignList, i, ba );
			if (ba.rank > 0) {
				i = char.boonsArray.indexOf(boonAssign);
				CharGenData.dynSetArray(char.boonsArray, i, ba );
				
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
			if (b.bane.channels != 0 ) {
				restoreAnyBnBWithMask(b.bane.channels);
				
			}
			
		}
		else {
			var b:BoonAssign = cast bba;
			char.removeBoon(b);
			if (b.boon.channels != 0){
				restoreAnyBnBWithMask(b.boon.channels);
			}
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
			total += !b.dontCountCost() ? b._costCached : 0;
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
			var countCost = !b.dontCountCost();
			var amt:Int = countCost ? b._costCached : 0;
			
			if (b.discount != 0) {  // check for social benefit discount
				amt -= b.discount;
				if (amt < 0) amt = 0;
			}
			total += amt;
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
		return BnBpoints + totalBanePointsEarned  - totalBoonExpenditure;
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
	
	public static function dynSetArray<T>(of:Array<T>, i:Int, value:T):Void {
		of[i] = value;
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
		
		truncateSkillPacketHistory();
	}
	
	
	
	public function onSkillPacketChange(index:Int, vector:Int, clickedPlus:Bool):Void {
		var packet = skillPackets[index];
		
		if (packet.history == null) {
			for (i in 0...packet.fields.length) {
				var f = packet.fields[i];
				LibUtil.setField(skillPacketValues, f, LibUtil.field(skillPacketValues, f) + LibUtil.field(packet.values, f) * vector);
			}
		}
		else {
			var start:Int = packet.qty - vector;
			var forward:Bool = vector >= 0;
			var step:Int = forward ? 1 : -1;  // assume vector cannot be zero
			var h:Int = forward ? start : start - 1;
			var limit:Int = start + vector;
			while ( (forward ? h <  limit : h >= limit) ) {
				var history = packet.history[h];
		
				for (i in 0...packet.fields.length) {
					var f = packet.fields[i];
					var p = LibUtil.field(history, f);
					LibUtil.setField(skillPacketValues, p, LibUtil.field(skillPacketValues, p) + LibUtil.field(packet.values, f) * step);
				}
				h += step;
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
	
	public function saveFinaliseSkillsFromPackets():Void {
		// to do this when finailising char sheet
		
	}
	public inline function clampSkillValue(value:Int):Int {
		return value >= MAX_PACKET_SKILL_LEVEL ? MAX_PACKET_SKILL_LEVEL : value;
	}

	public inline function isSkillLabelBinded(s:String):Bool {
		return  CharGenSkillPackets.isSkillLabelBinded(s);
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
					skillsTable.setSkill(f, 0);
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

	
	// SCHOOL/PROFECIENCIES
	//static var PCP_COLUMN_PROFS:Array<Int> = [0,3,6,9,12,15,18,21,24,27];
	var profCoreListMelee:Array<Int> = [];
	var profCoreListRanged:Array<Int> = [];
	
	var schoolAssignList:Array<SchoolAssign>;
	var schoolLevelCosts:Array<Int>;
	var talentsAvailable:Array<Int>;
	var superiorsAvailable:Array<Int>;
	
	public function selectSchoolAssign(s:SchoolAssign):Void {
		if (s != null) {
			char.school = s.school;
			char.schoolBonuses = s.bonuses;
			
		}
		else {
			char.school = null;
			char.schoolBonuses = null;
		}
	}
	
	public function canStillSpendSchool(remainingPoints:Int):Bool {
		var affordMin:Int = 0;
		
		if (char.school == null ) {
			if (ProfPoints == 0) return false;
			return true;
		}
		else {
			var lv = char.schoolLevel + 1;
			
			if (lv <= School.MAX_LEVELS) {
				affordMin = schoolLevelCosts[lv - 1] - (lv  >= 2 ? schoolLevelCosts[lv-2] : 0);
			
			}
			/*  // not relavant i feel..
			var profCost = profArcCost;
			if (profCost != 0 && profCost < affordMin ) {
				affordMin = profCost;
			}
			*/
		}
		return affordMin > 0 && remainingPoints >= affordMin;
	}
	
	
	public var hasSchool(get, never):Bool;
	inline function get_hasSchool():Bool {
		return char.school != null;	
	}
	
	public var schoolProfLevel(get, never):Int;
	inline function get_schoolProfLevel():Int {
		return hasSchool ? char.schoolLevel : 0;	
	}
	
	public var schoolTags(get, never):Array<String>;
	inline function get_schoolTags():Array<String> {
		return hasSchool  && char.schoolBonuses != null ? char.schoolBonuses.getTags() : [];	
	}
	

	
	public var ProfPoints(get, never):Int;
	inline function get_ProfPoints():Int {
		return (categories[CATEGORY_PROFECIENCIES].pcp-1) * 3;	
	}
	
	public var totalAvailProfSlots(get, never):Int;
	inline function get_totalAvailProfSlots ():Int {
		return hasSchool ? char.school.profLimit : 0;
	}
	
	public var profArcCost(get, never):Int;
	inline function get_profArcCost():Int {
		return  isHuman ? 0 : 3;
	}
	
	public var schoolArcCost(get, never):Int;
	inline function get_schoolArcCost():Int {
		return  hasSchool ? char.school.costArc : 0;
	}
	
	public var profExpenditure(get, never):Int;
	function get_profExpenditure():Int {
		return  profArcCost * totalProfecienciesBought;
	}
	
	public var totalProfSlotExpenditure(get, never):Int;
	inline function get_totalProfSlotExpenditure():Int {
		var c:Int = profArcCost;
		return c * profCoreListRanged.length + c * profCoreListMelee.length;
	}
	
	
	public var maxAvailableProfSlots(get, never):Int;
	inline function get_maxAvailableProfSlots():Int {
		return hasSchool ? char.school.profLimit : 0;
	}
	
	public var maxMeleeProfSlots(get, never):Int;
	function get_maxMeleeProfSlots():Int {
		var r =  maxAvailableProfSlots - profCoreListRanged.length;
		var c = profArcCost;
		//if (c > 0) {
			var rm:Int = ProfPoints  - schoolArcCost - levelsExpenditure  - profCoreListRanged.length * c;
			if (c > 0) {
				trace(rm + " FOR :" + c);
				
				rm = Math.floor(rm/c);
				if (rm < 0) rm = 0;
				if (rm < r) r = rm;
			}
		//}
		return hasSchool ? r < 0 ? 0 : r 
		: 0;
	}
	
	public var maxRangedProfSlots(get, never):Int;
	function get_maxRangedProfSlots():Int {
		var r =  maxAvailableProfSlots - profCoreListMelee.length;
		var c = profArcCost;
		//if (c > 0) {
			var rm:Int = ProfPoints  - schoolArcCost - levelsExpenditure - profCoreListMelee.length * c;
			if (c > 0) {
				
				rm = Math.floor(rm/c);
				if (rm < 0) rm = 0;
				if (rm < r) r = rm;
			}
		//}
		return hasSchool ? r < 0 ? 0 : r 
		: 0;
	}

	public var maxTalentSlots(get, never):Int;
	function get_maxTalentSlots():Int {
		var r = char.schoolLevel > 0 ? talentsAvailable[char.schoolLevel-1] : 0;
		return hasSchool ? r : 0;
	}
	
	public var maxSuperiorSlots(get, never):Int;
	function get_maxSuperiorSlots():Int {
		var r = char.schoolLevel > 0 ? superiorsAvailable[char.schoolLevel-1] : 0;
		return hasSchool ? r : 0;
	}
	
	public var maxMasterySlots(get, never):Int;
	function get_maxMasterySlots():Int {
		var r = char.schoolLevel >= School.MASTERY_LEVEL ? 1 : 0;
	
		return hasSchool ? r : 0;
	}
	
	public var validAffordCurrentSchool(get, never):Bool;
	function get_validAffordCurrentSchool():Bool {
		return hasSchool ? char.school.canAffordWith(ProfPoints) : true;
	}

	public var totalProfecienciesBought(get, never):Int;  // under school
	function get_totalProfecienciesBought():Int {
		return  maxClampedMeleeProfs + maxClampedRangedProfs;
	}
	public var maxClampedMeleeProfs(get, never):Int;
	inline function get_maxClampedMeleeProfs():Int {
		return LibUtil.minI_(maxMeleeProfSlots, profCoreListMelee.length);
	
	}
	public var maxClampedRangedProfs(get, never):Int;
	inline function get_maxClampedRangedProfs():Int {
		return LibUtil.minI_(maxRangedProfSlots, profCoreListRanged.length);
	}
	

	public var levelsExpenditure(get, never):Int;
	inline function get_levelsExpenditure():Int {
		return char.school != null && char.schoolLevel > 0 ? schoolLevelCosts[char.schoolLevel - 1] : 0;
	}
	
	public var totalProfArcExpenditure(get, never):Int;
	inline function get_totalProfArcExpenditure():Int {
		return totalProfecienciesBought * profArcCost;
	}
	
	
	public var profPointsLeft(get, never):Int;
	inline function get_profPointsLeft():Int {
		return ProfPoints  - totalProfArcExpenditure - schoolArcCost - levelsExpenditure;
	}
	
	
	public var profCoreMeleeListNames(get, never):Array<String>;
	function get_profCoreMeleeListNames():Array<String> {
		return Profeciency.getLabelsOfArrayProfs(Profeciency.getCoreMelee(), Profeciency.MASK_ALL);
	}
	
	public var profCoreRangedListNames(get, never):Array<String>;
	function get_profCoreRangedListNames():Array<String> {
		return Profeciency.getLabelsOfArrayProfs(Profeciency.getCoreRanged(), Profeciency.MASK_ALL);
	}
	
	public var traceProfCoreRangedCurrent(get, never):Array<String>;
	function get_traceProfCoreRangedCurrent():Array<String> {
		return Profeciency.getLabelsOfArrayProfs(Profeciency.getCoreRanged(), char.profsRanged);
	}
	
	public var traceProfCoreMeleeCurrent(get, never):Array<String>;
	function get_traceProfCoreMeleeCurrent():Array<String> {
		return Profeciency.getLabelsOfArrayProfs(Profeciency.getCoreMelee(), char.profsMelee);
	}
	
	public var traceProfCoreRangedCount(get, never):Int;
	function get_traceProfCoreRangedCount():Int {
		return Profeciency.getCountOfArrayProfs(Profeciency.getCoreRanged(), char.profsRanged);
	}
	
	public var traceProfCoreMeleeCount(get, never):Int;
	function get_traceProfCoreMeleeCount():Int {
		return Profeciency.getCountOfArrayProfs(Profeciency.getCoreMelee(), char.profsMelee);
	}

	
	function saveFinaliseSchoolProfs():Void {
		char.schoolLevel = schoolProfLevel;
		char.masteryManueverNotes = char.masteryManueverNotes.slice(0, maxMasterySlots);
		char.superiorManueverNotes = char.superiorManueverNotes.slice(0, maxSuperiorSlots);
		char.talentNotes = char.talentNotes.slice(0, maxTalentSlots);
	}



	
}

typedef SocialClassAssign = {
	var socialClass:SocialClass;
	var boons:Array<SocialBoonAssign>;
	var maxBoons:Int;
	
}

typedef SocialBoonAssign = {
	var name:String;
	var rank:Int;
	var cost:Int;
	
	@:optional var qty:Int;
	
	// used internally 
	@:optional var index:Int; 
	@:optional var label:String;
}


typedef WarningDef = {
	var warn:Bool;
	var remain:Int;
}


typedef SchoolAssign = {
	var school:School;
	var bonuses:SchoolBonuses;
}


