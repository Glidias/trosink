package troshx.sos.chargen;

import haxevx.vuex.core.IBuildListed;
import troshx.sos.chargen.CategoryPCP;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.BoonBane.BoonAssign;
import troshx.sos.core.BoonBane.BoonBaneAssign;
import troshx.sos.sheets.CharSheet;


/**
 * ...
 * @author Glidias
 */

class CharGenData implements IBuildListed
{
	
	public var char:CharSheet;
	
	static public inline var INT_MAX:Int = 2147483647;
	
	public function new(charSheet:CharSheet=null) 
	{
		this.char = charSheet != null ?charSheet : new CharSheet();

		
		this.categories = getNewCharGenCategories();
	}
	
	// CAMPAIGN POWER LEVEL
	public var campaignPowerLevels:Array<CampaignPowerLevel> = [
		new CampaignPowerLevel("TestLevel", 32, 18),
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
		arr[CATEGORY_RACE] = new CategoryPCP("Race");
		arr[CATEGORY_ATTRIBUTES] = new CategoryPCP("Attributes");
		arr[CATEGORY_BNB] = new CategoryPCP("Boons & Banes");
		arr[CATEGORY_RACE] = new CategoryPCP("Race");
		arr[CATEGORY_RACE] = new CategoryPCP("Race");
		arr[CATEGORY_RACE] = new CategoryPCP("Race");
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
	 * With Boones/Bane list, create BoonBaneInput for each boonBaneAssign.rank numeric stepper.
		--------------------


		For each list item of Boones/Banes....(If rank > 0) add send signal to add it into CharSheet,   If (rank == 0), send signal to remove from Charsheet. 
		Remember to register/un-register any modifiers assosiated with each boon/bane adding/removal from CharSheet.

		Each BoonBane sheet has their own computed cost variable to getCost(), and a watch: for that cost in order to dispatch any cost changes
		Anytime computed cost changes within each Boon/Bane component assign while rank > 0, send another signal to indicate cost change to update cost cached..

		totalCosts() of bNb is caslculated from cost cached variables.

		Calcualted costs always clamped to baseCost always as bare minimum for purpose of character creation.
		Math.max( baseCost(), signalCost) 

		_____

		

		*/
	
	public static function getAvailableBnBFromPCP(pcp:Int) {
		// TODO:
		return pcp;
	}
	
	var categoryBnB(get, never):CategoryPCP;
		function get_categoryBnB():CategoryPCP 
	{
		return categories[CATEGORY_BNB];
	}
	
	public var totalBaneExpenditure(get, never):Int;
	public function get_totalBaneExpenditure():Int {
		// TODO:
		return 0;
	}
	
	public var availableBnBpoints(get, never):Int;
	function get_availableBnBpoints():Int {
		return getAvailableBnBFromPCP(categoryBnB.pcp);
	}
	
	public var remainingBnBpoints(get, never):Int;
	function get_remainingBnBpoints():Int {
		return availableBnBpoints - totalBaneExpenditure;
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
