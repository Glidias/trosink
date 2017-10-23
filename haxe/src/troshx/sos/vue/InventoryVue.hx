package troshx.sos.vue;
import haxe.Constraints.Constructible;
import haxe.Serializer;
import haxe.Timer;
import haxe.Unserializer;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import haxevx.vuex.util.VHTMacros;
import js.Browser;
import js.Lib;
import js.html.Event;
import js.html.HtmlElement;
import js.html.InputElement;
import js.html.TextAreaElement;
import msignal.Signal.Signal1;
import troshx.sos.core.ArmorSpecial;
import troshx.sos.core.ArmorSpecial.WornWith;
import troshx.sos.core.BodyChar;
import troshx.sos.core.Money;
import troshx.sos.core.TargetZone;
import troshx.sos.vue.input.MixinInput;

import troshx.sos.core.Armor;
import troshx.sos.core.Crossbow;
import troshx.sos.core.DamageType;
import troshx.sos.core.Firearm;
import troshx.sos.core.HitLocation;
import troshx.sos.core.Item;
import troshx.sos.core.ItemQty;
import troshx.sos.core.Profeciency;
import troshx.sos.core.Shield;
import troshx.sos.vue.widgets.InputName;
import troshx.sos.vue.widgets.InputNameQty;
import troshx.sos.vue.widgets.SelectHeld;
import troshx.sos.vue.widgets.WAmmoSpawner;
import troshx.sos.vue.widgets.WAmmunition;
import troshx.sos.vue.widgets.WCoverage;
import troshx.sos.vue.widgets.WMeleeAtk;
import troshx.sos.vue.widgets.WMeleeDef;
import troshx.sos.vue.widgets.WMissileAtk;
import troshx.sos.vue.widgets.WProf;
import troshx.sos.vue.widgets.WSpanTools;
import troshx.sos.vue.widgets.WTags;

import troshx.ds.IDMatchArray;
import troshx.ds.IValidable;

import troshx.util.LibUtil;
import troshx.sos.core.Weapon;

import troshx.sos.sheets.CharSheet;
import troshx.sos.core.Inventory;


/**
 * ...
 * @author Glidias
 */
@:expose
class InventoryVue extends VComponent<InventoryVueData, InventoryVueProps> 
{

	public static inline var LABEL_YOUR:String = "Your";
	
	public function new() 
	{
		super();
		untyped this.mixins = [ MixinInput.getInstance() ];
	}
	
	override public function Data():InventoryVueData {
		return new InventoryVueData();
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>> {
		return [
			TDWeapProfSelect.NAME => new TDWeapProfSelect(),
			TDHands.NAME => new TDHands(),
			TDWidgetHolder.NAME => new TDWidgetHolder(),
			
			TDUnheld.NAME => new TDUnheld(),
			
			InputName.NAME => new InputName(),
			InputNameQty.NAME => new InputNameQty(),
			SelectHeld.NAME => new SelectHeld(),
			
			WAmmunition.NAME => new WAmmunition(),
			WCoverage.NAME => new WCoverage(),
			WMeleeAtk.NAME => new WMeleeAtk(),
			WMeleeDef.NAME => new WMeleeDef(),
			WMissileAtk.NAME => new WMissileAtk(),
			WProf.NAME => new WProf(),
			WSpanTools.NAME => new WSpanTools(),
			WTags.NAME => new WTags(),
			
			WAmmoSpawner.NAME => new WAmmoSpawner(),
	
		];
	}
	override public function Created():Void {
		
		this.inventory.getSignaler().add(onInventorySignalReceived);
	}
	
	// internal methods
	
	
	// money calc
	
	@:computed function get_copperMaxToPieces():Money {
		if (privateData.money == null) privateData.money = new Money();
		return privateData.money.matchWithValues(0, 0, maxCostCopper).changeToHighest();
	}
	
	@:computed function get_moneyLeft():Money {
		if (privateData.moneyLeft == null) privateData.moneyLeft = new Money();
		return privateData.moneyLeft.matchWith(this.copperMaxToPieces).subtractAgainst(this.totalCostMoney);
	}
	@:computed function get_moneyLeftStr():String {
		return moneyLeft.getLabel();
	}
	@:computed function get_exceededCost():Bool {
		return moneyLeft.isNegative();
	}
	
	@:computed function get_weightRemaining():Float {
		return maxWeight - totalWeight;
	}
	@:computed function get_weightRemainingLbl():Float {
		return Std.parseFloat( LibUtil.toFixed( this.weightRemaining, 2) );
	}
	@:computed function get_exceededWeight():Bool {
		return weightRemaining <= 0;
	}
	
	@:computed function get_maxCostGP():Int {
		return copperMaxToPieces.gp;	
	}
	@:computed function get_maxCostSP():Int {
		return copperMaxToPieces.sp;	
	}
	@:computed function get_maxCostCP():Int {
		return copperMaxToPieces.cp;	
	}
	

	
	
	function onInventorySignalReceived(e:InventorySignal) 
	{
		switch(e ) {
			case InventorySignal.DeleteItem:
				this.itemTransitionName = "";
				Vue.nextTick(resetItemTransitionName);
			default:
				resetItemTransitionName();
				
		}
	}
	// standard Methods
	

	public function loadSheet():Void {
		_vEmit("loadSheet", this.copyToClipboard);
	}
	
	@:watch function watch_inventory(newValue:Inventory, oldValue:Inventory):Void {
		oldValue.getSignaler().removeAll();
		newValue.getSignaler().add(onInventorySignalReceived);
		
		this.itemTransitionName = "";
		Vue.nextTick(resetItemTransitionName);
	}
	
	public function saveSheet():String {
		this.inventory.normalizeAllItems();
		
		var serializer = new Serializer();
		serializer.useCache = true;
		//serializer.useEnumIndex = true;
		
		//this.char
		var oldSignaler = this.inventory.getSignaler();
		this.inventory.setSignaler(null);
		
		serializer.serialize(this.inventory);
		
		
		var output:String = serializer.toString();
		this.copyToClipboard = output;
		this.inventory.setSignaler(oldSignaler);
		return output;
	
	}
	
	
	public function loadDropList(contents:String = null):Void {
		this.inventory.normalizeDroppedItems();
		
		if (contents == null) contents = this.copyToClipboardDropList;
	
		this.inventory.getSignaler().removeAll();
		var unserializer:Unserializer = new Unserializer(contents);
		
		var dyn:Dynamic = null;
		var okay:Bool = true;
		try {
			dyn = unserializer.unserialize();
		}
		catch (e:Dynamic) {
			trace(e);
			Browser.alert("Sorry, failed to unserialize string to dropped zone!");
			okay = false;
			
		
		}
		if (okay) {
			if (!Std.is(dyn, IDMatchArray)) {
				trace(dyn);
				Browser.alert("Sorry, unserialized object isn't of dropped zone IDMatchArray type!");
				okay = false;
			}
		}
		if ( okay) this.inventory.setNewDroppedList( dyn);
		
		this.inventory.getSignaler().add(onInventorySignalReceived);
	}
	
	public function saveDropList():String {
		var serializer = new Serializer();
		serializer.useCache = true;
	
		serializer.serialize(this.inventory.dropped);
		
		var output:String = serializer.toString();
		this.copyToClipboardDropList = output;
		
		return output;
	}
	
	
	// inventory Methods
	
	inline function resetItemTransitionName() {
		this.itemTransitionName = "fade";
	}
	
	function onBaseInventoryClick(e:Event):Void {
		clearWidgets();
	}
	
	
	
	// item overwrite warning
	function confirmOverwriteItem():Void {
		
		var tarArray = itemToOverwriteToPacked ? this.inventory.packed : this.inventory.dropped;
		tarArray.add(itemToOverwriteWith);
		var itemQty:ItemQty = tarArray.getMatchingItem(itemToOverwriteWith);
		itemQty.item = itemToOverwriteWith.item;
		itemQty.attachments = itemToOverwriteWith.attachments;
		if (privateData.dynArray != null) {
			privateData.dynArray.splice( privateData.dynArray.indexOf(privateData.dynAssign) , 1);
		}
		else {
			var srcArray = itemToOverwriteToPacked ? this.inventory.dropped : this.inventory.packed;
			srcArray.splicedAgainst( privateData.origQtyItem);
		}
		
		closeOverwriteModal();
		_vRefs.overwriteItemWarning.close();
	}
	
	function confirmQtyMultipleSend():Void {
		
		//
		if (itemToOverwriteToPacked) {
			packItemEntryFromGround(this.itemQtyMultiple, this.itemQtyMultiple.qty);
		}
		else {
			dropItemEntryFromPack(this.itemQtyMultiple, this.itemQtyMultiple.qty);
		}
		
		
		closeMultipleQtyItem();
		_vRefs.itemQtyMultipleModal.close();
	}
	
	inline function closeMultipleQtyItem(canceling:Bool=false):Void {
		itemQtyMultiple = null;
		
	}
	
	inline function closeOverwriteModal(canceling:Bool=false):Void {
		itemToOverwriteWith = null;
		if (!canceling) {
			privateData.dynArray = null;
			privateData.origQtyItem = null;
		}
	}
	
	@:watch function watch_itemToOverwriteWith(newValue:ItemQty):Void {
		if (newValue != null) {
			itemToOverwriteWithChecked = false;
			_vRefs.overwriteItemWarning.open();
		}
		else {
			_vRefs.overwriteItemWarning.close();
		}
	}
	
	@:watch function watch_itemQtyMultiple(newValue:ItemQty):Void {
		if (newValue != null) {
			_vRefs.itemQtyMultipleModal.open();
		}
		else {
			_vRefs.itemQtyMultipleModal.close();
		}
	}
	
	
	// inventory proxy methods with additional vue checks
	function packItemEntryFromGround(itemQ:ItemQty, qty:Int = 0):Void {
		itemToOverwriteToPacked = true;
		if (qty == 0 && itemQ.qty > 1) {
			itemQtyMultipleMax = itemQ.qty;
			itemQtyMultiple = itemQ.getQtyCopy(itemQ.qty);
			return;
		}
		itemToOverwriteWith = this.inventory.packItemEntryFromGround(itemQ, qty);
		if (itemToOverwriteWith != null) {
			privateData.origQtyItem = itemQ;
			privateData.dynArray = null;
		}
	}
	
	function dropItemEntryFromPack(itemQ:ItemQty, qty:Int = 0):Void {
		itemToOverwriteToPacked = false;
		if (qty == 0 && itemQ.qty > 1) {
			itemQtyMultipleMax = itemQ.qty;
			itemQtyMultiple = itemQ.getQtyCopy(itemQ.qty);
			return;
			
		}
		itemToOverwriteWith = this.inventory.dropItemEntryFromPack(itemQ, qty);
		if (itemToOverwriteWith != null) {
			privateData.origQtyItem = itemQ;
			privateData.dynArray = null;
		}
	}
	
	function dropEquipedShield(alreadyEquiped:ShieldAssign, doDestroy:Bool = false):Void {  // Not applicable for shield
		itemToOverwriteWith = this.inventory.dropEquipedShield(alreadyEquiped, doDestroy);
		itemToOverwriteToPacked = false;
		if (itemToOverwriteWith != null) {
			privateData.origQtyItem = null;
			privateData.dynArray = this.inventory.shields;
			privateData.dynAssign = alreadyEquiped;
		}
	}
	function dropMiscItem(alreadyEquiped:ItemAssign, doDestroy:Bool = false):Void {
		itemToOverwriteWith = this.inventory.dropMiscItem(alreadyEquiped, doDestroy);
		itemToOverwriteToPacked = false;
		if (itemToOverwriteWith != null) {
			privateData.origQtyItem = null;
			privateData.dynArray = this.inventory.equipedNonMeleeItems;
			privateData.dynAssign = alreadyEquiped;
		}
		
	}
	function dropEquipedWeapon(alreadyEquiped:WeaponAssign, doDestroy:Bool = false):Void {
		itemToOverwriteWith = this.inventory.dropEquipedWeapon(alreadyEquiped, doDestroy);
		itemToOverwriteToPacked = false;
		if (itemToOverwriteWith != null) {
			privateData.origQtyItem = null;
			privateData.dynArray = this.inventory.weapons;
			privateData.dynAssign = alreadyEquiped;
		}
	}
	
	function dropWornArmor(alreadyEquiped:ArmorAssign, doDestroy:Bool = false):Void {
		itemToOverwriteWith = this.inventory.dropWornArmor(alreadyEquiped, doDestroy);
		itemToOverwriteToPacked = false;
		if (itemToOverwriteWith != null) {
			privateData.origQtyItem = null;
			privateData.dynArray = this.inventory.wornArmor;
			privateData.dynAssign = alreadyEquiped;
		}
	}
	
	function packEquipedShield(alreadyEquiped:ShieldAssign):Void {
		itemToOverwriteWith = this.inventory.packEquipedShield(alreadyEquiped);
		itemToOverwriteToPacked = true;
		if (itemToOverwriteWith != null) {
			privateData.origQtyItem = null;
			privateData.dynArray = this.inventory.shields;
			privateData.dynAssign = alreadyEquiped;
		}
	}
	
	function packMiscItem(alreadyEquiped:ItemAssign):Void {
		itemToOverwriteWith = this.inventory.packMiscItem(alreadyEquiped);
		itemToOverwriteToPacked = true;
		if (itemToOverwriteWith != null) {
			privateData.origQtyItem = null;
			privateData.dynArray = this.inventory.equipedNonMeleeItems;
			privateData.dynAssign = alreadyEquiped;
		}
	}
	function packEquipedWeapon(alreadyEquiped:WeaponAssign):Void {
		itemToOverwriteWith = this.inventory.packEquipedWeapon(alreadyEquiped);
		itemToOverwriteToPacked = true;
		if (itemToOverwriteWith != null) {
			privateData.origQtyItem = null;
			privateData.dynArray = this.inventory.weapons;
		}
	}
	
	function packWornArmor(alreadyEquiped:ArmorAssign):Void {
		itemToOverwriteWith = this.inventory.packWornArmor(alreadyEquiped);
		itemToOverwriteToPacked = true;
		if (itemToOverwriteWith != null) {
			privateData.origQtyItem = null;
			privateData.dynArray = this.inventory.wornArmor;
			privateData.dynAssign = alreadyEquiped;
		}
	}
	
	
	function getSuperscriptNum(ref:String, value:Int):String {
		var str = Std.string(value);
		var result:String = value >= 0 ? Armor.SUPERSCRIPT_PLUS : Armor.SUPERSCRIPT_MINUS;
		
		for (i in (value < 0 ? 1 : 0)...str.length) {
			result += ref.charAt( Std.parseInt(str.charAt(i)) );
		}
		return result;
	}
	
	
	
	function getCoverage(armor:Armor, body:BodyChar = null):String {  // todo: return string representation
		var coverage = armor.coverage;
		var superscriptDigits:String = Armor.SUPERSCRIPT_NUMBERS;
		var gotSuperScript:Bool =armor.customise != null && armor.customise.hitLocationAllAVModifiers != null;
		var avModifiers = gotSuperScript ? armor.customise.hitLocationAllAVModifiers : null;
		
		if (body == null) {
			body = BodyChar.getInstance();
		}
		var arr:Array<String> = [];
		var hitLocations = body.hitLocations;
		var fields = Reflect.fields(coverage);
		for (i in 0...hitLocations.length) { //body.rearStartIndex
			var ider = hitLocations[i].id;
			var specs:Int = LibUtil.field(coverage, ider);
			if (specs != null) {
				arr.push((i + 1) + ( (specs & Armor.WEAK_SPOT) != 0 ? Armor.WEAK_SPOT_SYMBOL : "") +  ( (specs & Armor.THRUST_ONLY) != 0 ? Armor.THRUST_ONLY_SYMBOL : "") + ( (specs & Armor.HALF) != 0 ? Armor.HALF_SYMBOL : "") + (gotSuperScript && LibUtil.field(avModifiers, ider)!=null ? getSuperscriptNum(superscriptDigits, LibUtil.field(avModifiers, ider)) : "" )
				);
			}
			
		}
	
		return arr.join("-");
	}

	
	function getTags(item:Item):String {
		var arr:Array<String> = [];
		item.addTagsToStrArr(arr);
		return arr.join(", ");
	}
	
	inline function getDefGuard(wpn:Weapon):String {
		return wpn.dtn + "(" + wpn.guard + ")";
	}
	
	inline function getSwingAtkStr(wpn:Weapon):String {
		return wpn.atnS + "(" + wpn.damageS + this.damageTypeSuffixes[wpn.damageTypeS]+ ")";
	}
	inline function getThrustAtkStr(wpn:Weapon):String {
		return wpn.atnT + "(" + wpn.damageT + this.damageTypeSuffixes[wpn.damageTypeT]+ ")";
	}
	
	inline function getMissileAtkStr(wpn:Weapon):String {
		return wpn.atnM + "(" + wpn.damageM + this.damageTypeSuffixes[wpn.damageTypeM]+")";
	}
	
	inline function getAmmunitions(firearm:Firearm):String {
		return firearm.getAmmunitionsStrArr().join(", ");
	}
	

	
	inline function getSpanTools(crossbow:Crossbow):String {
		return crossbow.getSpanningToolsStrArr().join(", ");
	}
	
	
	inline function clearWidgets():Void {
		this.curWidgetRequest.type = "";
		this.curWidgetRequest.index = 0;
		this.focusValueText = "";
	}
	
	inline function stopPropagation(e:Event):Void {
		e.stopPropagation();
	}
	
	function setCurWidgetSection(sectName:String,e:Event):Void {
		e.stopPropagation();
		
		this.curWidgetRequest.section = sectName;
	}
	
	inline function requestCurWidget(type:String,index:Int):Void {
		this.curWidgetRequest.type = type;
		this.curWidgetRequest.index = index;
		
	}
	
	inline function isVisibleWidget(section:String, type:String, index:Int):Bool {
		this.curWidgetRequest.section;
		this.curWidgetRequest.type;
		this.curWidgetRequest.index;
		return this.curWidgetRequest.section == section && this.curWidgetRequest.type == type && this.curWidgetRequest.index == index;
	}
	
	inline function openPopup(index:Int):Void {
		this.popupIndex = index;
	}
	
	inline function closePopup():Void {
		this.popupIndex = -1;
	}
	
	function getValidName(testName:String, backupName:String):String {

		return testName != ""  && testName != null ? testName : backupName;
	}

	function onInputNameUpdated():Void {
		this.itemTransitionName = "";
		Vue.nextTick( resetItemTransitionName);
	}
	
	
	@:computed function get_coverageHitLocations():Array<HitLocation> {
		return this.body.hitLocations; // getNewHitLocationsFrontSlice();
	}
	
	@:computed function get_hitLocationZeroAVValues():Dynamic<AV3> {
		var ch = coverageHitLocations;
		var dyn:Dynamic<AV3> = {};
		//trace("Hit dummy set up...");
		for (i in 0...ch.length) {
			var h = ch[i];
			LibUtil.setField(dyn, h.id, { avp:0, avc:0, avb:0 }); 
		}
		return dyn;
	}
	
	@:computed function get_shouldCalcMeleeAiming():Bool {
		return !calcArmorNonFirearmMissile && calcArmorMeleeTargeting;
	}
	
	@:computed inline function get_targetingZoneMask():Int {
		var i:Int = this.calcMeleeTargetingZoneIndex;
		return shouldCalcMeleeAiming ? (1<<i) : 0;
	}
	
	@:computed inline function get_hasArmorResultProtecting():Bool {
		return this.calcArmorResults.armorsProtectable.length != 0;
	}
	@:computed inline function get_hasArmorResultLayers():Bool {
		return this.hasArmorResultProtecting && this.calcArmorResults.armorsLayer.length != 0;
	}
	@:computed inline function get_hasArmorCrushables():Bool {
		return this.calcArmorResults.armorsCrushable.length != 0;
	}
	
	
	function isDisabledHitLocation(i:Int):Bool {
		return shouldCalcMeleeAiming && ( (1 << i) & targetZoneHitAreaMasks[calcMeleeTargetingZoneIndex] ) == 0;
	}
	
	@:computed inline function get_targetZoneHitAreaMasks():Array<Int> {
		return this.body.getTargetZoneHitAreaMasks();
	}
	
	@:computed function get_isYourInventory():Bool {
		return inventoryLabel == LABEL_YOUR;
	}
	
	@:computed function get_whoseInventoryPrefix():String {
		return inventoryLabel != null ? inventoryLabel != LABEL_YOUR ? inventoryLabel+(includeOwnerSlash ? "'s " : " ") : LABEL_YOUR+ " " : "";
	}
	
	@:computed function get_hitLocationArmorValues():Dynamic<AV3> {
		var armors:Array<ArmorAssign> = inventory.wornArmor;
		var values:Dynamic<AV3>  = this.hitLocationZeroAVValues;
		var ch = coverageHitLocations;
		var body:BodyChar = this.body;

		var targMask:Int = targetingZoneMask;
		
		for (i in 0...ch.length) {
			var ider = ch[i].id;
			var cur = LibUtil.field(values, ider);
			cur.avc = 0;
			cur.avp = 0;
			cur.avb = 0;
		}
		
		for (i in 0...armors.length) {
			var a:Armor = armors[i].armor;
			var layerMask:Int = 0;

			if (a.special != null && a.special.wornWith != null && a.special.wornWith.name != "" ) {
				layerMask = inventory.layeredWearingMaskWith(a, a.special.wornWith.name, body);	
			}
			a.writeAVVAluesTo(values, body, layerMask, this.calcArmorNonFirearmMissile, targMask);
		}
		
		return values;
	}
	
	function sortArmorLayers(a:ArmorLayerCalc, b:ArmorLayerCalc):Int {
	  if (a.layer < b.layer) return -1;
	  else if (a.layer > b.layer) return 1;
	  return 0;
	} 

	function calcAVColumnRowIndex(columnNum:Int, rowIndex:Int):Void {
		this.calcAVColumn = columnNum;
		this.calcAVRowIndex = rowIndex;
		
		
		// perfrorm calculation
		
		var hitLocArmorValues = this.hitLocationArmorValues;
		var coverageLocs = coverageHitLocations;
		var hitLocationId:String = coverageLocs[rowIndex].id;
		var hitLocationMask:Int = (1 << rowIndex);
		var curRow:AV3 = LibUtil.field( hitLocArmorValues, hitLocationId);
		
		var results:ArmorCalcResults = this.calcArmorResults;
		results.damageType = columnNum - 1;
		results.hitLocationIndex = rowIndex;
		results.layer = 0;
		results.av = columnNum == 1 ? curRow.avc : columnNum == 2  ? curRow.avp : curRow.avb;
		
		results.armorsLayer = [];
		results.armorsProtectable = [];
		results.armorsCrushable = [];
			
	
		
		// else look for armors whose computed AVs at hit location is tabulated to match results.av
		var sampleAV:AV3 = SAMPLE_AV;
		var armorList = inventory.wornArmor;
		var body:BodyChar = this.body;
		var targetingZoneMask:Int = this.targetingZoneMask;
		

		if (results.av != 0) {  // av found at location, find dominant armors and layers
			var comparisonLayerMasks:Array<Int>  = [];  // temp for case to layers
		
			for (i in 0...armorList.length) {
				var a:Armor = armorList[i].armor;
				if (LibUtil.field(a.coverage, hitLocationId) == null) {
					comparisonLayerMasks.push(0);
					continue;
				}
			
				var layerMask:Int = 0;
				
				if (a.special != null && a.special.wornWith != null && a.special.wornWith.name != "" ) {
					layerMask = inventory.layeredWearingMaskWith(a, a.special.wornWith.name, body);	
				}
				comparisonLayerMasks.push(layerMask);
				
				
				if ( a.writeAVsAtLocation(body, hitLocationId, hitLocationMask, sampleAV, layerMask, this.calcArmorNonFirearmMissile, targetingZoneMask, true) ) {
					var compareAV:Int =  columnNum == 1 ? sampleAV.avc : columnNum == 2  ? sampleAV.avp : sampleAV.avb;
					
					if (compareAV == results.av) {
						results.armorsProtectable.push(a);
					}
					
				}
			}
			
			if (results.armorsProtectable.length != 0)  {
				
				// now, find highest possible layers
				var highest:Int = 0;
				
				
				var comparisonLayeredArmor:Array<ArmorLayerCalc> = [];
				
				for (i in 0...armorList.length) {
					var a:Armor = armorList[i].armor;
					if (LibUtil.field(a.coverage, hitLocationId) == null) continue;
					
					var c = a.getLayerValueAt(hitLocationMask, comparisonLayerMasks[i]);
					// get layer value of armor.. get highest layer value among all to be sorted later on
					if (c > 0) {
						comparisonLayeredArmor.push({armor:a, layer:c});
					}	
				}
				
				if (comparisonLayeredArmor.length > 0) {
				

					haxe.ds.ArraySort.sort(comparisonLayeredArmor, sortArmorLayers);

					if (results.armorsProtectable.length == 1 && results.armorsProtectable[0]== comparisonLayeredArmor[comparisonLayeredArmor.length-1].armor) {
						comparisonLayeredArmor.pop();
					}
					if (comparisonLayeredArmor.length > 0) {
						results.layer = comparisonLayeredArmor[comparisonLayeredArmor.length - 1].layer;
						
						var i = comparisonLayeredArmor.length;
						while(--i > -1) {
							if (comparisonLayeredArmor[i].layer == results.layer) {
								results.armorsLayer.push(comparisonLayeredArmor[i].armor);
							}
						}
						var ind:Int;
						if (results.armorsProtectable.length == 1 && (ind = results.armorsLayer.indexOf(results.armorsProtectable[0])  )>=0 ) {
							comparisonLayeredArmor.splice(ind, 1);
						}
					
						if (results.armorsProtectable.length >=2 && results.armorsLayer.length == 1 && (ind = results.armorsProtectable.indexOf(results.armorsLayer[0] ) )>=0 ) {
							results.armorsProtectable.splice(ind, 1);
						}
					}
					
					
					
				
				}
			
			}
			
		}
		
		
		if (!this.calcArmorCrushing) return;
		
		// , find highest possible crushables

		var i:Int;
		var highest:Int = 0;
		var crushableSortList:Array<ArmorLayerCalc> = [];
		
		for (i in 0...armorList.length) {
			var a:Armor = armorList[i].armor;
			if ( (a.specialFlags & ArmorSpecial.HARD) == 0 || LibUtil.field(a.coverage, hitLocationId) == null ) {
				continue;
			}
			
			if (a.customise != null && a.customise.hitLocationAllAVModifiers != null && a.checkFubarCrushed(body, targetingZoneMask, columnNum - 1) ) {
				continue;
			}
			
			if ( a.writeAVsAtLocation(body, hitLocationId, hitLocationMask, sampleAV, 0, false, targetingZoneMask, false) ) {
				var compareAV:Int =  columnNum == 1 ? sampleAV.avc : columnNum == 2  ? sampleAV.avp : sampleAV.avb;
				crushableSortList.push({
					layer:compareAV,
					armor:a
				});
			}

		}
		if (crushableSortList.length > 0) {
			haxe.ds.ArraySort.sort(crushableSortList, sortArmorLayers);
			highest = crushableSortList[crushableSortList.length - 1].layer;
			
			i = crushableSortList.length;
			while(--i > -1) {
				if (highest == crushableSortList[i].layer) results.armorsCrushable.push(crushableSortList[i].armor);
				
			}
		}
		
		
		
		
	}
	
	@:computed function get_shieldAVHigherOrEqual():Bool {
		var calculating = this.calcAVColumn != 0;
		var shield:Shield = carriedShield;
		var av = this.calcArmorResults.layer + this.calcArmorResults.av;
		return calculating && shield != null && shield.AV > av;
	}
	
	static var SAMPLE_AV:AV3 = {avc:0, avp:0, avb:0};
	
	function focusOutAVColumnRowIndex(columnNum:Int, rowIndex:Int):Void {
		Timer.delay(function() { if (this.calcAVColumn == columnNum && this.calcAVRowIndex == rowIndex) this.calcAVColumn = 0; } , 0);
	}
	
	function test():Void {
		trace("TEST");
	}
	
	function focusOutRowField(targ:IFocusFlags, mask:Int):Void {
		Timer.delay(function() { targ.focusedFlags &= ~mask; } , 0);
		
	}
	
	function focusInRowField(targ:IFocusFlags, mask:Int) {
		targ.focusedFlags = mask;
		if (mask < 20) clearWidgets();

	}
	
	function focusWidgetValue(value:String):Void {

		this.focusValueText = value;
	}
	
	function executeQtyEntry(qtyEntry:RowEntry<ItemQty>, tarInventoryList:IDMatchArray<Dynamic>):Bool {
		
		if ( qtyEntry.isValid() )  {
			tarInventoryList.add( qtyEntry.e );
			qtyEntry.reset();
			this.itemTransitionName = "fade"; // or something else
			return true;
		}
		
		return false;
	}
	
	function validateQtyName(name:String, itemQty:ItemQty, isPacked:Bool):Bool {
		
		var matchArr:IDMatchArray<ItemQty> = isPacked ?  this.inventory.packed : this.inventory.dropped;
		var testItem:Item =  itemQty.item;
		var lastName:String = testItem.name;
		testItem.name = name;
		var testId:String = itemQty.uid;
		testItem.name = lastName;
		for (i in 0...matchArr.list.length) {
			var it = matchArr.list[i];
			if (it == itemQty) {
				continue;
			}
			if (it.uid == testId) {
				return false;
			}
		}
		
		return true;
	}
	
	function validateQtyNamePacked(name:String, itemQty:ItemQty):Bool {
		return validateQtyName(name, itemQty, true);
	}
	
	function validateQtyNameDropped(name:String, itemQty:ItemQty):Bool {
		return validateQtyName(name, itemQty, false);
	}
	
	
	function executeEquipEntry(equipEntry:RowReadyEntry, typeId:String):Bool {
		
		if ( equipEntry.isValid() )  {
			var tarList = this.inventory.getEquipedAssignList(typeId);
			var lastWeap = equipEntry.getWeapon();
			tarList.push( equipEntry.e );
			var newAssign = Inventory.getEmptyReadyAssign(typeId);
			
			equipEntry.reset( newAssign );
			var newWeap = equipEntry.getWeapon();
			
			if (lastWeap != null && newWeap != null) { // sync type of weapon
				newWeap.profs = lastWeap.profs;
				newWeap.ranged = lastWeap.ranged;
				newWeap.isAmmo = lastWeap.isAmmo;
				
				if (newWeap.ranged && (newWeap.profs &  (1 << Profeciency.R_CROSSBOW)) != 0) {
					newWeap.crossbow = new Crossbow();
				}
				if (newWeap.ranged && (newWeap.profs &  (1 << Profeciency.R_FIREARM)) != 0) {
					newWeap.firearm = new Firearm();
				}
			}
			
			this.itemTransitionName = "fade";  // or something else?
			return true;
		}
		return false;
	}
	

	
	
	function addAmmo(ammo:Weapon):Void {
		this.inventory.weapons.push( Inventory.getReadyAssignOf(ammo) );
	}
	
	
	function getHitLocationMaskNameOf(index:Int):String {
		return "";
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	
	
	inline function shiftIndex(i:Int):Int {
		return (1 << i);
	}
	
	// computed
	
	@:computed function get_hasPopup():Bool {
		var a = this.popupIndex >= 0;
		return this.curWidgetRequest.type != "" || a;
	}
	
	@:computed function get_isValidDroppedEntry():Bool 
	{
		return this.droppedEntry.isValid();
	}
	
	@:computed  function get_isValidPackedEntry():Bool 
	{
		return this.packedEntry.isValid();
	}
	
	@:computed function get_crossbowMask():Int {
		return (1<<Profeciency.R_CROSSBOW);
	}
	@:computed function get_bowMask():Int {	// we treat bows and slings as part of the same table category
		return (1<<Profeciency.R_BOW) | (1<<Profeciency.R_SLING);
	}
	@:computed function get_bowSlingAndCrossbowMask():Int {
		return (1<<Profeciency.R_CROSSBOW) | (1<<Profeciency.R_BOW) | (1<<Profeciency.R_SLING);
	}
	@:computed function get_firearmMask():Int {
		return (1<<Profeciency.R_FIREARM);
	}
	
	@:computed function get_throwMask():Int {
		return (1<<Profeciency.R_THROWING) | (1<<Profeciency.R_SLING);
	}
	
	@:computed function get_droppedEntryGotFocus():Bool 
	{
		var hasPopup = this.hasPopup;
		return this.droppedEntry.focusedFlags !=0 || hasPopup;
	}
	@:computed function get_packedEntryGotFocus():Bool 
	{
		var hasPopup = this.hasPopup;
		return this.packedEntry.focusedFlags != 0 || hasPopup;
	}
	
	@:computed function get_miscEntryGotFocus():Bool 
	{
		var hasPopup = this.hasPopup;
		return this.miscItemEntry.focusedFlags !=0 || hasPopup;
	}
	@:computed function get_weaponEntryGotFocus():Bool 
	{
		var hasPopup = this.hasPopup;
		return this.weaponEntry.focusedFlags != 0 || hasPopup;
	}
	@:computed function get_shieldEntryGotFocus():Bool 
	{
		var hasPopup = this.hasPopup;
		return this.shieldEntry.focusedFlags != 0 || hasPopup;
	}
	
	@:computed function get_armorEntryGotFocus():Bool 
	{
		var hasPopup = this.hasPopup;
		return this.armorEntry.focusedFlags != 0 || hasPopup;
	}
	
	@:computed function get_carriedShield():Shield {
		return this.inventory.findHeldShield();
	}
	
	@:computed function get_shieldSizeLabels():Array<String> {
		var arr:Array<String> = [];
		Item.pushFlagLabelsToArr(false, "troshx.sos.core.Shield", true, ":size");
		return arr;
	}
	
	@:computed function get_shieldCoverage():Dynamic<Bool> {
		var shield = this.carriedShield;
		var index:Int = shield != null ? shield.size : 0; 
		return this.inventory.shieldPosition == Shield.POSITION_HIGH ? this.shieldHighProfiles[index] : this.shieldLowProfiles[index];
	}
	
	@:computed function get_totalCostMoney():Money {
		return inventory.calculateTotalCost(includeDroppedCost);
	}
	
	@:computed function get_totalCostGP():Int {
		return this.totalCostMoney.gp;
	}
	@:computed function get_totalCostSP():Int {
		return this.totalCostMoney.sp;
	}
	@:computed function get_totalCostCP():Int {
		return this.totalCostMoney.cp;
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
	
	@:computed function get_totalWeight():Float {
		return injectWeight!=null ? injectWeight : inventory.calculateTotalWeight();
	}
	@:computed function get_totalWeightLbl():Float {
		return Std.parseFloat( LibUtil.toFixed(this.totalWeight, 2) );
	}
	
	@:computed function get_showTally():Bool {  // may include other props
		return this.userShowTally;
	}
	
	@:computed function get_body():BodyChar {
		return this.bodyChar != null ? this.bodyChar : BodyChar.getInstance();
	}
	
	// computed proxy to inventory filtered lists
	
	@:computed function get_filteredMelee():Array<WeaponAssign>  {
		return this.inventory.getWeildableWeaponsTypeFiltered(false);
	}
	@:computed function get_filteredCrossbow():Array<WeaponAssign>   {
		return this.inventory.getWeildableWeaponsTypeFiltered(true, Item.getInstanceFlagsOf(Profeciency, R_CROSSBOW ) );
	}
	@:computed function get_filteredFirearm():Array<WeaponAssign>   {
		return this.inventory.getWeildableWeaponsTypeFiltered(true, Item.getInstanceFlagsOf(Profeciency, R_FIREARM ) );
	}
	@:computed function get_filteredBow():Array<WeaponAssign>   {
		return this.inventory.getWeildableWeaponsTypeFiltered(true, Item.getInstanceFlagsOf(Profeciency, [R_BOW] ) );
	}
	@:computed function get_filteredThrowing():Array<WeaponAssign>   {
		return this.inventory.getWeildableWeaponsTypeFiltered(true, Item.getInstanceFlagsOf(Profeciency, [R_THROWING, R_SLING] ) );
	}
	@:computed function get_filteredAmmo():Array<WeaponAssign>   {
		return this.inventory.ammoFiltered;
	}
	
	// watchers
	
	@:watch function on_packedEntryGotFocus(newValue:Bool, oldValue:Bool) {
		if (!newValue) {
			executeQtyEntry(this.packedEntry, this.inventory.packed);
		}
	}
	
	@:watch function on_droppedEntryGotFocus(newValue:Bool, oldValue:Bool) {
		if (!newValue) {
			executeQtyEntry(this.droppedEntry, this.inventory.dropped);
		}
	}
	
	@:watch function on_shieldEntryGotFocus(newValue:Bool, oldValue:Bool) {
		if (!newValue) {
			executeEquipEntry(this.shieldEntry, "shield");
			
		}
		
	}
	@:watch function on_weaponEntryGotFocus(newValue:Bool, oldValue:Bool) {
		if (!newValue) {
			executeEquipEntry(this.weaponEntry, "weapon");
		}
	}
	@:watch function on_miscEntryGotFocus(newValue:Bool, oldValue:Bool) {
		if (!newValue) {
			executeEquipEntry(this.miscItemEntry, "item");
		}
	}
	
	@:watch function on_armorEntryGotFocus(newValue:Bool, oldValue:Bool) {
		if (!newValue) {
			executeEquipEntry(this.armorEntry, "armor");
			
		}
	}
	
	

	

}

class InventoryVueData  {

	// dropped/packed item misc entry
	var droppedEntry:RowEntry<ItemQty> = new RowEntry<ItemQty>();
	var packedEntry:RowEntry<ItemQty> = new RowEntry<ItemQty>();
	
	// confirm to overwrite above
	var itemToOverwriteWith:ItemQty = null;
	var itemToOverwriteToPacked:Bool = false;
	var itemToOverwriteWithChecked:Bool = false;
	
	var itemQtyMultiple:ItemQty = null;
	var itemQtyMultipleMax:Int = 1;
	
	var privateData:InventoryVuePrivate = {};
	
	// equiped items entry
	var shieldEntry:RowReadyEntry = new RowReadyEntry( Inventory.getEmptyReadyAssign("shield") );
	var weaponEntry:RowReadyEntry= new RowReadyEntry( Inventory.getEmptyReadyAssign("weapon") );
	var miscItemEntry:RowReadyEntry = new RowReadyEntry( Inventory.getEmptyReadyAssign("item") );
	
	var userShowTally:Bool = true;
	
	// worn armor
	var armorEntry:RowReadyEntry = new RowReadyEntry( Inventory.getEmptyReadyAssign("armor") );

	// save/load copy box data
	var copyToClipboard:String = "";
	var copyToClipboardDropList:String = "";
	
	var coreMeleeProfs:Array<Profeciency> = Profeciency.getCoreMelee();
	var coreRangedProfs:Array<Profeciency> = Profeciency.getCoreRanged();
	
	var popupIndex:Int = -1;
	
	var shieldLowProfiles:Array<Dynamic<Bool>> = Shield.getLowCoverage();
	var shieldHighProfiles:Array<Dynamic<Bool>> = Shield.getHighCoverage();
	
	var damageTypeSuffixes:Array<String> = DamageType.getFlagVarNames();
	
	var curWidgetRequest:WidgetItemRequest = {
		section: "",
		type: "",
		index: 0
	};
	
	var itemTransitionName:String = "fade";
	var focusValueText:String = "";
	
	// armor hit calculator
	var calcArmorNonFirearmMissile:Bool = false;
	var calcArmorCrushing:Bool = false;
	var calcArmorMeleeTargeting:Bool = false;
	var calcMeleeTargetingZoneIndex:Int = 0;
	
	var calcAVColumn:Int = 0;
	var calcAVRowIndex:Int = 0;
	
	var calcArmorResults:ArmorCalcResults = {
		hitLocationIndex:0,
		damageType: 0,
		layer:0,
		av:0,
	
		armorsProtectable:[],
		armorsLayer:[],
		armorsCrushable:[],
	}
	
	// to factor this out later
	//@:vueInclude var char:CharSheet = new CharSheet();
	
	
	public function new() {
		
	}

}

typedef InventoryVuePrivate = {
	@:optional var dynArray:Array<Dynamic>;
	@:optional var dynAssign:Dynamic;
	@:optional var origQtyItem:ItemQty;
	@:optional var money:Money;
	@:optional var moneyLeft:Money;
}

typedef WidgetItemRequest = {
	var section:String;
	var type:String;
	var index:Int;
}

interface IFocusFlags {
	var focusedFlags:Int;
}

@:generic
class RowEntry<E:(IValidable, Constructible<Dynamic>)> implements IValidable implements IFocusFlags {

	public var e:E;
	public var focusedFlags:Int = 0;
	
	public function new() {
		e = new E();
	}
	
	public function reset():Void {
		e = new E();
	}
	
	public function isValid():Bool {	
		return e.isValid();
	}
}



class RowReadyEntry implements IValidable implements IFocusFlags {

	public var e:ReadyAssign;
	public var focusedFlags:Int = 0;
	
	var itemToValidate:Item;
	
	public function new(e:ReadyAssign) {
		reset(e);
	}
	
	public function reset(e:ReadyAssign):Void {
		// we assume that the type of object remains immutable
		itemToValidate = null;
		this.e = e;
	}
	
	
	function setupValidable():Void {
		if ( Reflect.hasField(e, "weapon") ) {
			itemToValidate = LibUtil.as( Reflect.field(e, "weapon"), Weapon);
		}
		else if ( Reflect.hasField(e, "shield") ) {
			itemToValidate =  LibUtil.as(Reflect.field(e, "shield"), Shield);
		}
		else if (Reflect.hasField(e, "armor")) {
			itemToValidate =  LibUtil.as(Reflect.field(e, "armor"), Armor);
		}
		else if ( Reflect.hasField(e, "item") ) {
			itemToValidate = LibUtil.as( Reflect.field(e, "item"), Item);
		}
		else {
			throw "Could not resolve RowReadyEntry reflect type!";
		}
		
		if (itemToValidate == null)  throw "Could not resolve item to validate to Item type:"+e;
	}
	
	
	public function getWeapon():Weapon {
		if ( Reflect.hasField(e, "weapon") ) {
			return LibUtil.as( Reflect.field(e, "weapon"), Weapon);
		}
		return null;
	}
	
	
	public function isValid():Bool {	
		//return e.isValid();
		if (itemToValidate == null) setupValidable();

		return itemToValidate.name != null && StringTools.trim(itemToValidate.name) != "";
	}
	

}
	
	
typedef ArmorLayerCalc = {
	var armor:Armor;
	var layer:Int;
}

typedef InventoryVueProps = {
	@:prop({required:true}) var inventory:Inventory;
	@:prop({required:false, 'default':true}) @:optional var showArmorCoverage:Bool;
	@:prop({required:false}) @:optional var bodyChar:BodyChar;
	@:prop({required:false}) @:optional var inventoryLabel:String;
	@:prop({required:false, 'default':false}) @:optional var includeOwnerSlash:Bool;
	@:prop({required:false, 'default':true}) @:optional var saveAvailable:Bool;
	@:prop({required:false, 'default':true}) @:optional var loadAvailable:Bool;
	
	@:prop({required:false}) @:optional var maxCostCopper:Int;
	@:prop({required:false}) @:optional var maxWeight:Float;
	
	@:prop({required:false}) @:optional var injectWeight:Float;
	@:prop({required:false, 'default':false}) @:optional var includeDroppedCost:Bool;
}