package troshx.sos.vue;
import haxe.Serializer;
import haxe.Timer;
import haxe.Unserializer;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import js.html.InputElement;
import js.html.svg.Number;

import troshx.sos.core.Inventory.ItemQty;

import troshx.sos.sheets.CharSheet;

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
	
	function focusOutRowFieldQty(qtyEntry:QtyEntry, mask:Int):Void {
		//qtyEntry.focusedFlags &= ~mask;
		Timer.delay(function() { qtyEntry.focusedFlags &= ~mask; } , 0);
		
	}
	
	function executeQtyEntry(qtyEntry:QtyEntry):Bool {
		if ( qtyEntry.isValidQtyEntry() )  {
			var tarInventoryList = qtyEntry != this.packedEntry ? this.char.inventory.dropped : this.char.inventory.packed;
			var item:Item = new Item();
			item.name = qtyEntry.name;
			item.weight = qtyEntry.weight;
			
			tarInventoryList.add( new ItemQty(  item, qtyEntry.qty ) );
			qtyEntry.reset();
			return true;
		}
		else { 
			//trace("invalid entry entered");
			return false;
		}
	}
	
	function focusInRowFieldQty(qtyEntry:QtyEntry, mask:Int) {
		qtyEntry.focusedFlags = mask;
		
	}

	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	@:computed function get_isValidDroppedEntry():Bool 
	{
		return this.droppedEntry.isValidQtyEntry();
	}
	
	@:computed  function get_isValidPackedEntry():Bool 
	{
		return this.packedEntry.isValidQtyEntry();
	}
	
	@:computed  function get_droppedEntryFocus():Int 
	{
		return this.droppedEntry.focusedFlags;
	}
	
	@:computed  function get_droppedEntryGotFocus():Bool 
	{
		return this.droppedEntry.focusedFlags !=0;
	}
	
	
	@:computed  function get_packedEntryFocus():Int 
	{
		return this.packedEntry.focusedFlags;
	}
	@:computed function get_packedEntryGotFocus():Bool 
	{
		return this.packedEntry.focusedFlags != 0;
	}
	
	@:watch(packedEntryGotFocus) function onPackedEntryFocusChanged(newValue:Bool, oldValue:Bool) {
		if (!newValue) {
			executeQtyEntry(this.packedEntry);
		}
	}
	
	@:watch(droppedEntryGotFocus) function onDroppedEntryFocusChanged(newValue:Bool, oldValue:Bool) {
		if (!newValue) {
			executeQtyEntry(this.droppedEntry);
		}
	
	}
	
	

}

class CharSheetVueData  {
	var droppedEntry:QtyEntry = new QtyEntry();
	var packedEntry:QtyEntry = new QtyEntry();
	
	var copyToClipboard:String = "";
	
	@:vueInclude var char:CharSheet = new CharSheet();
	
	public function new() {
		
	}

}

class QtyEntry {
	public var name:String="";
	public var qty:Int = 1;
	public var focusedFlags:Int = 0;// false;
	public var weight:Int = 0;
	
	
	public function new() {
		
	}
	
	public function reset():Void {
		name = "";
		qty = 1;
		
	}
	
	public function getTotalWeight():Int {
		return qty*weight;
	}
	
	public function isValidQtyEntry():Bool {
		
		return qty  > 0 && name != null && name != "";
	}
	
	
}
	
