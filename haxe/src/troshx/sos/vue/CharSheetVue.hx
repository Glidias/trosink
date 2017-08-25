package troshx.sos.vue;
import haxe.Constraints.Constructible;
import haxe.Serializer;
import haxe.Timer;
import haxe.Unserializer;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import js.Browser;
import js.Lib;
import js.html.Event;
import js.html.HtmlElement;
import js.html.InputElement;
import troshx.ds.IDMatchArray;
import troshx.ds.IValidable;
import troshx.sos.vue.CharSheetVue.IFocusFlags;
import troshx.sos.vue.CharSheetVue.RowReadyEntry;
import troshx.util.LibUtil;

import troshx.sos.sheets.CharSheet;
import troshx.sos.core.Inventory;



import troshx.sos.core.*;

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
			TDWeapProfSelect.NAME =>new TDWeapProfSelect(),
		];
	}
	override public function Created():Void {
		this.char.inventory.getSignaler().add(onInventorySignalReceived);
	}
	
	function onInventorySignalReceived(e:InventorySignal) 
	{
		switch(e ) {
			case InventorySignal.DeleteItem:
				this.itemTransitionName = "";
			default:
				this.itemTransitionName = "fade";
		}
	}
	// standard
	
	public function loadSheet(contents:String = null):Void {
		if (contents == null) contents = this.copyToClipboard;
	
		var unserializer:Unserializer = new Unserializer(contents);
	
		this.char = unserializer.unserialize();
	}
	
	
	public function saveSheet():String {
		var serializer = new Serializer();
		serializer.useCache = true;
		//serializer.useEnumIndex = true;
		
		//this.char
		serializer.serialize(this.char);
		var output:String = serializer.toString();
		this.copyToClipboard = output;
		return output;
	}
	
	// inventory
	
	function onBaseInventoryClick(e:Event):Void {
		clearWidgets();
	}
	
	inline function clearWidgets():Void {
		this.curWidgetRequest.type = "";
		this.curWidgetRequest.index = 0;
	}
	
	inline function stopPropagation(e:Event):Void {
		e.stopPropagation();
	}
	function onProfSelectChange(e:Event, weapon:Weapon):Void {
		var dyn:Dynamic = e.target;
		var htmlElem:HtmlElement = dyn;
		var val:Int = dyn.value;
		var ranged:Bool = false;
		if (val < 0) {
			ranged = true;
			val = -val;
		}
		
		weapon.ranged = ranged;
		
		if (val == 0) {
			var index:Int = Std.parseInt(htmlElem.getAttribute("data-index"));
			var type:String = htmlElem.getAttribute("data-type");
			requestCurWidget(type, index);
		}
		else {
			weapon.profs = val;
			if (weapon.ranged) {
				if ( ( weapon.profs & Item.getInstanceFlagsOf(Profeciency, R_CROSSBOW)) !=0 ) {
					if (weapon.crossbow == null) weapon.crossbow = new Crossbow();
				}
				
				if ( ( weapon.profs & Item.getInstanceFlagsOf(Profeciency, R_FIREARM)) !=0 ) {
					if (weapon.firearm == null) weapon.firearm = new Firearm();
				}
			}
		}
		
	}
	function setCurWidgetSection(sectName:String,e:Event):Void {
		e.stopPropagation();
		this.curWidgetRequest.section = sectName;
		clearWidgets();
	}
	
	inline function requestCurWidget(type:String,index:Int):Void {
		this.curWidgetRequest.type = type;
		this.curWidgetRequest.index = index;
	}
	inline function isVisibleWidget(section:String, type:String, index:Int):Bool {
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

	
	function setValidNameOfInput(inputElement:InputElement, backupName:String):String {
		if (inputElement.value != "" ) {
			return inputElement.value;
		}
		else {
			inputElement.value = backupName;
			return backupName;
		}
		
	}
	
	function focusOutRowField(targ:IFocusFlags, mask:Int):Void {
		Timer.delay(function() { targ.focusedFlags &= ~mask; } , 0);
		
	}
	
	function focusInRowField(targ:IFocusFlags, mask:Int) {
		targ.focusedFlags = mask;
		clearWidgets();
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
			tarList.push( equipEntry.e );
			equipEntry.reset( Inventory.getEmptyReadyAssign(typeId) );
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
	
	function holdItemHandler(itemEntry:ReadyAssign, held:Int):Void {
		this.char.inventory.holdEquiped(itemEntry, held);
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	@:computed function get_hasPopup():Bool {
		return this.popupIndex >= 0;
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
	@:computed function get_bowMask():Int {
		return (1<<Profeciency.R_BOW);
	}
	@:computed function get_firearmMask():Int {
		return (1<<Profeciency.R_FIREARM);
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
		e = new Armor();
	}
	
	public function reset():Void {
		e = new Armor();
	}
	
	public function isValid():Bool {
		return e.name != null && e.name != "";
		
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
	
	public function isValid():Bool {	
		//return e.isValid();
		if (itemToValidate == null) setupValidable();

		return itemToValidate.name != null && itemToValidate.name != "";
	}
}
	
	
