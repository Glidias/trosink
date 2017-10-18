package troshx.sos.vue;
import haxe.Serializer;
import haxe.Timer;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import haxevx.vuex.util.VHTMacros;
import js.Browser;
import js.html.HtmlElement;
import js.html.SelectElement;
import js.html.TextAreaElement;
import troshx.sos.chargen.CampaignPowerLevel;
import troshx.sos.chargen.CategoryPCP;
import troshx.sos.chargen.CharGenData;
import troshx.sos.chargen.SkillPacket;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.Inventory;
import troshx.sos.core.Modifier;
import troshx.sos.core.Money;
import troshx.sos.core.Skill;
import troshx.sos.sheets.CharSheet;
import troshx.sos.sheets.CharSheet.WealthAssetAssign;
import troshx.sos.vue.inputs.impl.InputNameLabel;


import troshx.sos.vue.inputs.impl.AttributeInput;
import troshx.sos.vue.inputs.impl.BoonBaneInput;
import troshx.sos.vue.inputs.impl.CategoryPCPInput;
import troshx.sos.vue.inputs.impl.SchoolLevelInput;
import troshx.sos.vue.inputs.impl.SkillLibInput;
import troshx.sos.vue.inputs.impl.SkillPacketInput;
import troshx.sos.vue.uifields.ArrayOf;
import troshx.sos.vue.uifields.ArrayOfBits;
import troshx.sos.vue.widgets.BoonBaneApplyDetails;
import troshx.sos.vue.widgets.SchoolSheetDetails;
import troshx.sos.vue.widgets.SkillSubjectCreator;

/**
 * ...
 * @author Glidias
 */
@:vueIncludeDataMethods
class CharGen extends VComponent<CharGenData,CharGenProps>
{

	public function new() 
	{
		super();
		untyped this.mixins = [
			CharVueMixin.getSampleInstance()
		];
	}
	

	override function Data():CharGenData {
		return new CharGenData();
	}
	
	override function Created():Void {
		_vData.privateInit();
		untyped CharGenData.dynSetField = Vue.set;
		untyped CharGenData.dynDeleteField = Vue.delete;
		untyped CharGenData.dynSetArray = Vue.set;
	}
	
	
	@:watch function watch_maxBoonsSpendableLeft(newValue:Int):Void {
		var arr = this.boonsArray;
		var i = arr.length;
		while (--i > -1) {
			var v = arr[i];
			v.updateRemainingCache(newValue);
		}
		
	}
	@:watch function watch_raceTier(newValue:Int):Void {
		
		if (this.selectedTierIndex >= newValue) {
			this.resetToHuman();
		}
	}
	
	@:watch function watch_socialEitherMaxIndex(newValue:Int):Void {
		this.constraintSocialWealth();
	}
	
	@:watch function watch_wealthEitherMaxIndex(newValue:Int):Void {
		this.constraintSocialWealth();
	}
	@:watch function watch_syncSocialWealth(newValue:Bool):Void {
		this.constraintSocialWealth();
	}
	
	@:watch function watch_socialClassIndex(newValue:Int, lastValue:Int):Void {
		this.updateSocialToCharsheet();
	}
	@:watch function watch_wealthIndex(newValue:Int):Void {
		this.updateMoneyToCharsheet();
	}
	
	@:watch function watch_socialBenefit1(newValue:SocialBoonAssign, oldValue:SocialBoonAssign):Void {
		this.updateSocialBenefitsToBoon(newValue, oldValue);
		
	}
	@:watch function watch_socialBenefit2(newValue:SocialBoonAssign, oldValue:SocialBoonAssign):Void {
		this.updateSocialBenefitsToBoon(newValue, oldValue);
	}
	@:watch function watch_socialBenefit3(newValue:SocialBoonAssign, oldValue:SocialBoonAssign):Void {
		this.updateSocialBenefitsToBoon(newValue, oldValue);
	}
	
	function schoolSelectChangeHandler(select:SelectElement):Void {
		var valueAsNum = Std.parseInt(select.value);
		if (valueAsNum >= 0) {
			this.selectSchoolAssign(this.schoolAssignList[valueAsNum]);
		}
		else {
			this.selectSchoolAssign(null);
		}
	}
	
	// can current school be afforded with base Profeciency Points and school accepts character?
	@:watch function watch_validAffordCurrentSchool(newValue:Bool, oldValue:Bool):Void {
		if (!newValue) {
			 // we assume first school in list is always affordable in this context and is always downgradable towards
			this.selectSchoolAssign(this.schoolAssignList[0]);
		}
	}
	
	@:computed function get_totalDraftedProfSlots():Int {
		return profCoreListRanged.length  + profCoreListMelee.length;
	}
	
	@:computed function get_maxBuyableProfSlots():Int {
		var rm:Int = ProfPoints  - schoolArcCost - levelsExpenditure;
		var cost = this.profArcCost;
		rm = cost > 0 ? Std.int(rm/cost) : this.totalAvailProfSlots;
		return char.school != null ? rm : 0;
	}
	
	@:computed function get_excessDraftedSlots():Int {
		return this.totalDraftedProfSlots - this.maxBuyableProfSlots;
	}
	
	@:watch function watch_excessDraftedSlots(newValue:Int, oldValue:Int):Void {
		if (newValue < 1) return;
		
		var a = this.profCoreListRanged;  // cull away empty +ranged profeciency slots if any
		var newArr:Array<Int> = [];
		for (i in 0...a.length) {
			if (newValue > 0 && a[i] == 0) {
				newValue--;
			}
			else {
				newArr.push(a[i]);
			}
		}
		this.profCoreListRanged = newArr;
		
		if (newValue < 1) return;
		
		a = this.profCoreListMelee;   // cull away empty melee profeciency slots if any
		newArr = [];
		for (i in 0...a.length) {
			if (newValue > 0 && a[i] == 0) {
				newValue--;
			}
			else {
				newArr.push(a[i]);
			}
		}
		this.profCoreListMelee = newArr;
		
		if (newValue < 1) return;
		
		a = this.profCoreListRanged; 
		while (--newValue >= 0 && a.length > 0) {  // kill off any +ranged profeciencies if needed
			a.pop();
		}
		
	}
	
	var validAffordCurrentSchool(get, never):Bool;
	function get_validAffordCurrentSchool():Bool {
		return hasSchool ? char.school.canAffordWith(ProfPoints, moneyAvailable ) && char.school.customRequire(char) : true;
	}

	

	// CHECKOUT  (for the interest of performance, need to move this section out to Vue instead)
	
	@:computed function get_notBankrupt():Bool {
		
		return !moneyLeft.isNegative(); 
	}
	
	public  function isValidAll(warnings:Array<String> = null):Bool { 
		var score:Int;
		
		if (char.name == "") {
			warnings.push("Please enter a Character name!");
		}
	
		var r1 = promptSettleRaceTier;
		if (r1) {
			warnings.push("Race: Please Finalise Race tier by clicking on the button!");
		}
		
		var r2 = promptSettleSocialTier;
		if (r2) {
			warnings.push("Social Class: Please Finalise Social class tier by clicking on the button!");
		}
		
		var a = (score = categoriesRemainingAssignable) >= 0;
		if (warnings != null) {
			if (a && score > 0) {
				warnings.push("Categories: You still have PCP to spend on categories.");
			}
			if (!a) {
				warnings.push("Categories: You are at a deficit of Character PCP usage!");
			}
		}
		
		var b = (score = remainingAttributePoints) >= 0 && untyped !this.negativeOrZeroStat;
		if (warnings != null) {
			if (b && score > 0) {
				warnings.push("Attributes: You still have Attribute points to spend.");
			}
			if (!b) {
				if (untyped this.negativeOrZeroStat)  {
					warnings.push("Attributes: You aren't allowed to checkout with zero or negative core stat!");
				}
				if (score < 0) {
					warnings.push("Attributes: You are at a deficit of Attribute points!");
				}
			}
		}
		
		var c = (score = totalBnBScore) >= 0;
		if (warnings != null) {
			if (c && score > 0) {
				warnings.push("Boons & Banes: You still have B&B points to spend.");
			}
			if (!c) {
				warnings.push("Boons & Banes: You still have a deficit of B&B points!");
			}
		}
		
		
		
		var d = notBankrupt;
		if (warnings != null) {
			if (!d) {
				warnings.push("Inventory: You have negative cash value!");
			}
		}
		
		// skills
		var e = (score=totalSkillPointsLeft) >= 0;
		if (warnings != null) {
			if (e && score>0) {
				warnings.push("Skills: You still have skill points left to spend.");
			}
			if (!e) {
				warnings.push("Skills: You are at a deficit of skill points!");
			}
		}
		
		var f = (score = profPointsLeft) >= 0 && (this.ProfPoints == 0 ? true :  char.school != null);
		if (warnings != null) {
			if (f  ) {
				if (stillHaveProfSpend) warnings.push("School: You can still spend profeciency points on school/school-levels.");
				if ( !(profCoreListMelee.length >= maxMeleeProfSlots && traceProfCoreMeleeCount == maxMeleeProfSlots) ) {
					warnings.push("Profeciencies: You still have have melee profeciency slots to use.");
				}
				if ( !(profCoreListRanged.length>=maxRangedProfSlots && traceProfCoreRangedCount == maxRangedProfSlots) ) {
					warnings.push("Profeciencies: You still have have ranged profeciency slots to use.");
				}
				
			}
			if (!f) {
				if (score < 0) warnings.push("School & Profeciencies: You are at a deficit of Prof points!");
				if ( (this.ProfPoints > 0 && char.school == null) ) {
					warnings.push("School: You must select at least a school (eg. Scrapper) if you have at least 1 Prof point!");
				}
			}
		}
		
		this.warningMsgs = warnings;
		
		return char.name != "" && a && b && c && d && e && f && !r1 && !r2;
	}
	
	@:computed function get_stillHaveProfSpend():Bool {
		var a = profPointsLeft > 0;
		var b = canStillSpendSchool(profPointsLeft);
		return a && b;
	}
	
	
	public function saveFinaliseAll(finalising:Bool=false):Void { 
		var warnings:Array<String> = finalising ? null : [];
		if (isValidAll(warnings)) {
			if (warnings != null && warnings.length > 0) {
				//Browser.alert(warnings.join("\n"));
				_vRefs.finaliseWarning.open();
				return;
			}
			else {
				saveFinaliseCleanupChar();
				var savedCharString = saveCharToBox();
				char.ingame = true;
				if (finaliseSaveCallback != null) {
					finaliseSaveCallback(savedCharString);
				}
			}
		}
		else {
			if (warnings != null && warnings.length > 0) {
				//Browser.alert(warnings.join("\n"));
				_vRefs.finaliseError.open();
			}
		}
	}
	
	
	function saveCharToBox():String
	{
		var s = new Serializer();
		s.useCache = true;
		s.serialize(this.char);
		var str = s.toString();
		this.savedCharContents = str;
		return str;
	}
	
	function executeCopyContents():Void {
		var textarea:TextAreaElement = _vRefs.savedTextArea;
		
		textarea.select();
		var result:Bool = Browser.document.execCommand("copy");
		if (result != null) {
			//Browser.alert("Copied to clipboard.");
			var htmlElem:HtmlElement = _vRefs.copyNotify;
			htmlElem.style.display = "inline-block";
			Timer.delay( function() {
				htmlElem.style.display = "none";
			}, 3000);
		}
		else {
			Browser.alert("Sorry, failed to copy to clipboard!");
		}
	}
	
	function confirmFinaliseAll():Void {
		saveFinaliseAll(true);
	}
	
		
	var moneyLeft(get, never):Money;
	function get_moneyLeft():Money {
		if (tempMoneyLeft == null) tempMoneyLeft = new Money();
		return tempMoneyLeft.matchWith(socialClassList[wealthIndex].socialClass.money).addValues(this.liquidity, 0, 0).subtractAgainst(char.school != null && char.school.costMoney != null ? char.school.costMoney : Money.ZERO ).subtractAgainst(inventoryCost).addValues(0,0,startingMoneyBonusCP).subtractValues(0,0,startingMoneyPenaltyCP);
	}
	
	var moneyLeftStr(get,never):String; 
	inline function get_moneyLeftStr():String {  
		return  moneyLeft.changeToHighest().getLabel(); 
	}

	var liquidity(get, never):Int; 
	inline function get_liquidity():Int {
		var len:Int = wealthAssetsWorthLen();
		return CharSheet.getTotalLiquidity(wealthAssets, len); 
	}
	
	var liquidityStr(get, never):String; 
	function get_liquidityStr():String {
		return Money.getLabelWith(this.liquidity, 0,0);
	}
	
	
	static var STARTING_MONEY_MOD:Money;
	var startingMoneyModifiedCP(get, never):Int;
	public function get_startingMoneyModifiedCP():Int {
		var sample = STARTING_MONEY_MOD != null ? STARTING_MONEY_MOD : (STARTING_MONEY_MOD = new Money());
		sample._resetToZero();
		var baseCP = this.moneyAvailable.getCPValue();
		return Std.int( this.char.getModifiedValue(Modifier.STARTING_MONEY, this.moneyAvailable.getCPValue() ) ) - baseCP;
	}
	
	
	var startingMoneyBonusCP(get, never):Int;
	public function get_startingMoneyBonusCP():Int {
		return startingMoneyModifiedCP > 0 ? startingMoneyModifiedCP : 0;
	}
	
	var startingMoneyPenaltyCP(get, never):Int;
	public function get_startingMoneyPenaltyCP():Int {
		return startingMoneyModifiedCP < 0 ? -startingMoneyModifiedCP : 0;
	}
	
	
	var inventoryCost(get, never):Money;
	function get_inventoryCost():Money {
		return char.inventory.calculateTotalCost();
	}
	
	var moneyAvailable(get,never):Money;
	inline function get_moneyAvailable():Money {
		return socialClassList[wealthIndex].socialClass.money;
	}
	
	var moneyAvailableStr(get,never):String;
	inline function get_moneyAvailableStr():String {
		return moneyAvailable.getLabel();
	}
	
	var checkoutBonuses(get, never):String; 
	function get_checkoutBonuses():String {
		
		return startingMoneyBonusCP!= 0 ? Money.ZERO.tempCalc().matchWithValues(0,0,startingMoneyBonusCP).changeToHighest().getLabel() : "0"; 
	}

	var checkoutPenalties(get, never):String; 
	function get_checkoutPenalties():String {
		return startingMoneyPenaltyCP != 0 ? Money.ZERO.tempCalc().matchWithValues(0,0,startingMoneyPenaltyCP).changeToHighest().getLabel() : "0"; 
	}
	var checkoutSchool(get, never):String; 
	function get_checkoutSchool():String {
		return (char.school != null && char.school.costMoney != null ?  char.school.costMoney.getLabel() : "0"); 
	}
	
	var checkoutInventory(get, never):String; 
	function get_checkoutInventory():String {
		return inventoryCost.getLabel(); 
	}
	
	
	
	
	function exitInventory():Void {
		
		insideInventory = false;
		Vue.nextTick( function() {
			var htmlElement:HtmlElement = _vRefs.checkoutHeader;
			Browser.window.scroll({top:htmlElement.offsetTop});
		});
	}
	
	
	function proceedToInventory():Void {
		

		insideInventory = true;
		
		Vue.nextTick( function() {
			var htmlElement:HtmlElement = _vRefs.inventoryHolder;
			Browser.window.scroll({top:htmlElement.offsetTop});
		});
	}
	
	
	
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			CategoryPCPInput.NAME => new CategoryPCPInput(),
			AttributeInput.NAME => new AttributeInput(),
			SchoolLevelInput.NAME => new SchoolLevelInput(),
			
			BoonBaneInput.NAME => new BoonBaneInput(),
			BoonBaneApplyDetails.NAME => new BoonBaneApplyDetails(),
			
			SchoolSheetDetails.NAME => new SchoolSheetDetails(),
			
			SkillPacketInput.NAME => new SkillPacketInput(),
			SkillLibInput.NAME => new SkillLibInput(),
			SkillSubjectCreator.NAME => new SkillSubjectCreator(),
			
			InputNameLabel.NAME => new InputNameLabel(),
			
			ArrayOf.NAME => new ArrayOf(),
			ArrayOfBits.NAME => new ArrayOfBits(),
			
			"inventory" => new InventoryManager()
		];
	}
	
	override function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	@:computed function get_placeholder():String {
		return "[placeholder]";
	}
}

typedef CharGenProps = {
	@:prop({required:false}) @:optional var exitBtnCallback:Void->Void;
	@:prop({required:false}) @:optional var finaliseSaveCallback:String->Void;
}