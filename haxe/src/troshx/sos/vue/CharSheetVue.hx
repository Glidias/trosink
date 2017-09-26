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
import msignal.Signal.Signal1;
import troshx.sos.core.BodyChar;

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
import troshx.sos.vue.CharSheetVue.IFocusFlags;
import troshx.sos.vue.CharSheetVue.RowReadyEntry;
import troshx.util.LibUtil;
import troshx.sos.core.Weapon;

import troshx.sos.sheets.CharSheet;
import troshx.sos.core.Inventory;


/**
 * ...
 * @author Glidias
 */
@:expose
class CharSheetVue extends VComponent<CharSheetVueData, NoneT> 
{

	public function new() 
	{
		super();
	}
	
	override public function Data():CharSheetVueData {
		return new CharSheetVueData();
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
		
		this.char.inventory.getSignaler().add(onInventorySignalReceived);
	}
	
	// internal methods
	
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
	

	
	public function loadSheet(contents:String = null):Void {
		if (contents == null) contents = this.copyToClipboard;
	
		this.char.inventory.getSignaler().removeAll();
		var unserializer:Unserializer = new Unserializer(contents);
	
		this.char = unserializer.unserialize();
		
		this.char.inventory.getSignaler().add(onInventorySignalReceived);
	}
	
	
	public function saveSheet():String {
		var serializer = new Serializer();
		serializer.useCache = true;
		//serializer.useEnumIndex = true;
		
		//this.char
		var oldSignaler = this.char.inventory.getSignaler();
		this.char.inventory.setSignaler(null);
		serializer.serialize(this.char);
		
		
		var output:String = serializer.toString();
		this.copyToClipboard = output;
		this.char.inventory.setSignaler(oldSignaler);
		return output;
		
	
	}
	
	// inventory Methods
	
	inline function resetItemTransitionName() {
		this.itemTransitionName = "fade";
	}
	
	function onBaseInventoryClick(e:Event):Void {
		clearWidgets();
	}
	
	
	
	function getCoverage(coverage:Dynamic<Int>, body:BodyChar=null):String {  // todo: return string representation
		if (body == null) {
			body = BodyChar.getInstance();
		}
		var arr:Array<String> = [];
		var hitLocations = body.hitLocations;
		var fields = Reflect.fields(coverage);
		for (i in 0...hitLocations.length) {
			var ider = hitLocations[i].id;
			var specs:Int = LibUtil.field(coverage, ider);
			if (specs != null) {
				arr.push((i+1) + ( (specs & Armor.WEAK_SPOT)!=0 ? Armor.WEAK_SPOT_SYMBOL : "") + ( (specs & Armor.HALF)!=0 ? Armor.HALF_SYMBOL : "")  );
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
	
	function executeQtyEntry(qtyEntry:RowEntry<ItemQty>, tarInventoryList:IDMatchArray<Dynamic>):Bool {
		
		if ( qtyEntry.isValid() )  {
			tarInventoryList.add( qtyEntry.e );
			qtyEntry.reset();
			this.itemTransitionName = "fade"; // or something else
			return true;
		}
		
		return false;
	}
	
	function executeEquipEntry(equipEntry:RowReadyEntry, typeId:String):Bool {
		
		if ( equipEntry.isValid() )  {
			var tarList = this.char.inventory.getEquipedAssignList(typeId);
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
	
	
	
	function executeArmorEntry():Bool {
		
		if ( this.armorEntry.isValid() )  {
			this.char.inventory.wornArmor.push( armorEntry.e );
			this.armorEntry.reset();
			this.itemTransitionName = "fade"; // or something else?
			return true;
		}
		return false;
	}
	
	
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
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
	
	// computed proxy to inventory filtered lists
	
	@:computed function get_filteredMelee():Array<WeaponAssign>  {
		return this.char.inventory.getWeildableWeaponsTypeFiltered(false);
	}
	@:computed function get_filteredCrossbow():Array<WeaponAssign>   {
		return this.char.inventory.getWeildableWeaponsTypeFiltered(true, Item.getInstanceFlagsOf(Profeciency, R_CROSSBOW ) );
	}
	@:computed function get_filteredFirearm():Array<WeaponAssign>   {
		return this.char.inventory.getWeildableWeaponsTypeFiltered(true, Item.getInstanceFlagsOf(Profeciency, R_FIREARM ) );
	}
	@:computed function get_filteredBow():Array<WeaponAssign>   {
		return this.char.inventory.getWeildableWeaponsTypeFiltered(true, Item.getInstanceFlagsOf(Profeciency, [R_BOW] ) );
	}
	@:computed function get_filteredThrowing():Array<WeaponAssign>   {
		return this.char.inventory.getWeildableWeaponsTypeFiltered(true, Item.getInstanceFlagsOf(Profeciency, [R_THROWING, R_SLING] ) );
	}
	@:computed function get_filteredAmmo():Array<WeaponAssign>   {
		return this.char.inventory.ammoFiltered;
	}
	
	
	// watchers
	
	@:watch function on_packedEntryGotFocus(newValue:Bool, oldValue:Bool) {
		if (!newValue) {
			executeQtyEntry(this.packedEntry, this.char.inventory.packed);
		}
	}
	
	@:watch function on_droppedEntryGotFocus(newValue:Bool, oldValue:Bool) {
		if (!newValue) {
			executeQtyEntry(this.droppedEntry, this.char.inventory.dropped);
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
			executeArmorEntry();
		}
	}

	

}

class CharSheetVueData  {
	

	// dropped/packed item misc entry
	var droppedEntry:RowEntry<ItemQty> = new RowEntry<ItemQty>();
	var packedEntry:RowEntry<ItemQty> = new RowEntry<ItemQty>();
	
	// equiped items entry
	var shieldEntry:RowReadyEntry = new RowReadyEntry( Inventory.getEmptyReadyAssign("shield") );
	var weaponEntry:RowReadyEntry= new RowReadyEntry( Inventory.getEmptyReadyAssign("weapon") );
	var miscItemEntry:RowReadyEntry = new RowReadyEntry( Inventory.getEmptyReadyAssign("item") );
	
	// worn armor
	var armorEntry:ArmorEntry = new ArmorEntry();

	// save/load copy box data
	var copyToClipboard:String = "";
	
	var coreMeleeProfs:Array<Profeciency> = Profeciency.getCoreMelee();
	var coreRangedProfs:Array<Profeciency> = Profeciency.getCoreRanged();
	
	var popupIndex:Int = -1;
	
	var damageTypeSuffixes:Array<String> = DamageType.getFlagVarNames();
	
	var curWidgetRequest:WidgetItemRequest = {
		section: "",
		type: "",
		index: 0
	};
	
	var itemTransitionName:String = "fade";
	
	// to factor this out later
	@:vueInclude var char:CharSheet = new CharSheet();
	
	public function new() {
		
	}

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

class ArmorEntry implements IValidable implements IFocusFlags {
	
	public var e:Armor;
	public var focusedFlags:Int = 0;
	
	public function new():Void {
		e =Armor.createEmptyInstance();
	}
	
	public function reset():Void {
		e = Armor.createEmptyInstance();
	}
	
	public function isValid():Bool {
		return e.name != null && StringTools.trim(e.name) != "";
		
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
	
	
