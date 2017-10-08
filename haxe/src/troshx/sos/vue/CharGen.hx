package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import haxevx.vuex.util.VHTMacros;
import js.Browser;
import js.html.HtmlElement;
import js.html.SelectElement;
import troshx.sos.chargen.CampaignPowerLevel;
import troshx.sos.chargen.CategoryPCP;
import troshx.sos.chargen.CharGenData;
import troshx.sos.chargen.SkillPacket;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.Inventory;
import troshx.sos.core.Money;
import troshx.sos.core.Skill;
import troshx.sos.sheets.CharSheet;
import troshx.sos.sheets.CharSheet.WealthAssetAssign;
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
class CharGen extends VComponent<CharGenData,NoneT>
{

	public function new() 
	{
		super();
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

	
	
	@:computed function get_notBankrupt():Bool {
		
		return !moneyLeft.isNegative(); 
	}
	
		
	var moneyLeft(get, never):Money;
	function get_moneyLeft():Money {
		if (tempMoneyLeft == null) tempMoneyLeft = new Money();
		return tempMoneyLeft.matchWith(socialClassList[wealthIndex].socialClass.money).addValues(this.liquidity, 0, 0).subtractAgainst(char.school != null && char.school.costMoney != null ? char.school.costMoney : Money.ZERO ).subtractAgainst(inventoryCost);
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
	
	var inventoryCost(get, never):Money;
	function get_inventoryCost():Money {
		return char.inventory.calculateTotalCost();
	}
	
	// CHECKOUT  (for the interest of performance, need to move this section out to Vue instead)
	
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
		return "0"; 
	}

	var checkoutPenalties(get, never):String; 
	function get_checkoutPenalties():String {
		return "0"; 
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
	
	
	function getBnBSlug(name:String):String {
		return BoonBaneApplyDetails.getSlug(name);
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

