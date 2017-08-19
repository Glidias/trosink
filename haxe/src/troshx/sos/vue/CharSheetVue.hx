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
	}
	
	function executeQtyEntry(qtyEntry:RowEntry<ItemQty>, tarInventoryList:IDMatchArray<Dynamic>):Bool {
		
		if ( qtyEntry.isValid() )  {
			tarInventoryList.add( qtyEntry.e );
			qtyEntry.reset();
			return true;
		}
		
		return false;
	}
	
	function executeEquipEntry(equipEntry:RowReadyEntry, typeId:String):Bool {
		
		if ( equipEntry.isValid() )  {
			var tarList = this.char.inventory.getEquipedAssignList(typeId);
			tarList.push( equipEntry.e );
			equipEntry.reset( Inventory.getEmptyReadyAssign(typeId) );
			return true;
		}
		return false;
	}
	
	function executeArmorEntry():Bool {
		
		if ( this.armorEntry.isValid() )  {
			this.char.inventory.wornArmor.push( armorEntry.e );
			this.armorEntry.reset();
			
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
	
	@:computed function get_isValidDroppedEntry():Bool 
	{
		return this.droppedEntry.isValid();
	}
	
	@:computed  function get_isValidPackedEntry():Bool 
	{
		return this.packedEntry.isValid();
	}
	
	@:computed function get_droppedEntryGotFocus():Bool 
	{
		return this.droppedEntry.focusedFlags !=0;
	}
	@:computed function get_packedEntryGotFocus():Bool 
	{
		return this.packedEntry.focusedFlags != 0;
	}
	
	@:computed function get_miscEntryGotFocus():Bool 
	{
		return this.miscItemEntry.focusedFlags !=0;
	}
	@:computed function get_weaponEntryGotFocus():Bool 
	{
		return this.weaponEntry.focusedFlags != 0;
	}
	@:computed function get_shieldEntryGotFocus():Bool 
	{
		return this.shieldEntry.focusedFlags != 0;
	}
	
	@:computed function get_armorEntryGotFocus():Bool 
	{
		return this.armorEntry.focusedFlags != 0;
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
	
	@:vueInclude var char:CharSheet = new CharSheet();
	
	public function new() {
		
	}

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
	
	
