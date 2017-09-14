package troshx.sos.chargen;

import haxevx.vuex.core.IBuildListed;
import troshx.sos.bnb.Banes;
import troshx.sos.bnb.Boons;
import troshx.sos.chargen.CategoryPCP;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.BoonBane.BoonAssign;
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

		// Categories
		this.categories = getNewCharGenCategories();
		this.categories[CATEGORY_BNB].pcp = 4;
		
		// Boones and banes
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
	
	// CAMPAIGN POWER LEVEL
	public var campaignPowerLevels:Array<CampaignPowerLevel> = [
		new CampaignPowerLevel("TestLevel", 30, 10),
	];
	public var campaignPowLevelIndex:Int = 0;

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
	static function getNewCharGenCategories():Array<CategoryPCP> {
		var arr:Array<CategoryPCP> = [];
		var a;
		arr[CATEGORY_RACE] = a = new CategoryPCP("Race"); a.slug = "gen-race";
		arr[CATEGORY_ATTRIBUTES] =a= new CategoryPCP("Attributes"); a.slug = "gen-attributes";
		arr[CATEGORY_BNB] = a=new CategoryPCP("Boons & Banes"); a.slug = "gen-bnb";
		
		//arr[CATEGORY_RACE] = a=new CategoryPCP("Race");
		//arr[CATEGORY_RACE] = a=new CategoryPCP("Race");
		//arr[CATEGORY_RACE] = a=new CategoryPCP("Race");
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
	
	public var raceTier(get, never):Int;
	function get_raceTier():Int {
		return getRaceTierFromPCP(categoryRace.pcp);
	}
	public static function getRaceTierFromPCP(pcp:Int):Int {
		// TODO: lookup table
		return pcp;
	}
	
	// ATTRIBUTES
	static public inline var ATTRIBUTE_START_MAX:Int = 8; 
	static public inline var MORTAL_MAX:Int = 12;
	
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
		return getAvailableAttributePointsFromPCP(categoryAttributes.pcp);
	}
	
	public static function getAvailableAttributePointsFromPCP(pcp:Int):Int {
		// TODO: lookup table
		return pcp;
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

		
	public static inline function getBnBFromPCP(pcp:Int):Int {
		return -BaneAssign.MAX_BANE_EARNABLE + (pcp*5-5);
	}

		
	public function addBB(bba:troshx.sos.core.BoonBane.BoonBaneAssign, isBane:Bool):Void {
		//trace("ADDING:" + bba + " , " + isBane);
		if (isBane) {
			char.addBane(cast bba);
		}
		else {
			char.addBoon(cast bba);
		}
		
	}
	public function removeBB(bba:troshx.sos.core.BoonBane.BoonBaneAssign, isBane:Bool):Void {
		//trace("REMOVING:" + bba + " , " + isBane);
		if (isBane) {
			char.removeBane(cast bba);
		}
		else {
			char.removeBoon(cast bba);
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
	function get_boonsArray():Array<BoonAssign> {
		return char.boonsArray;
	}
	public var banesArray(get, never):Array<troshx.sos.core.BoonBane.BaneAssign>;
	function get_banesArray():Array<BaneAssign> {
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
	
	

	// TODO final: validate all char generation categories
	
	public function isValidAll(showWarnings:Bool=false):Bool { 
		return true;
	}
	
	
	
	
}

typedef WarningDef = {
	var warn:Bool;
	var remain:Int;
}
