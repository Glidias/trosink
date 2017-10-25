package troshx.sos.vue;
import haxe.Unserializer;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import haxevx.vuex.util.VHTMacros;
import js.Browser;
import js.html.ButtonElement;
import troshx.sos.core.Inventory;
import troshx.sos.vue.treeview.TreeView;
import troshx.sos.vue.widgets.GingkoTreeBrowser;
import troshx.util.LibUtil;

/**
 * An multi-tab inventory component to open/manage multiple inventories side by side with the same shared Drop zone.
 * @author Glidias
 */
class InventoryManager extends VComponent<InventoryManagerData, InventoryManagerProps>
{
	public function new() 
	{
		super();
		untyped this["inheritAttrs"] = false;
	}
	
	override function Data():InventoryManagerData {
		return {
			extraInventories:[],
			clipboardContents:"",
			curInventoryIndex:0,
			newTabCounter:0,
			showBrowser:this.autoLoad!=null
		}
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			"comp" => new InventoryVue(),
			"tree-browser" => new GingkoTreeBrowser()
		];
	}
	
	function loadSheet(contents:String):Void {
		
		_vEmit("loadSheet", contents);
		
	}
	
	function closeBtnClick():Void {
		if (curInventoryIndex > 0) {
			var spliceIndex = this.curInventoryIndex - 1;
			extraInventories.splice(spliceIndex, 1);
			if (this.curInventoryIndex > extraInventories.length) {
				this.curInventoryIndex--;
			}
		}
	}
	
	function openFromTreeBrowser(contents:String, filename:String, disableCallback:Void->Void):Void {
		loadNewTab(contents, filename);
	}
	
	
	@:watch function watch_inventory(newValue:Inventory):Void {
		// sync tabs dropped list if inventory changes
		for (i in 0...extraInventories.length) {
			extraInventories[i].inventory.setNewDroppedList(newValue.dropped);
		}
	}
	
	@:computed function get_tabs():Array<InventoryTab> {
		return [{inventory:this.inventory, tabName:firstTabName}].concat(extraInventories);
	}
	
	@:computed function get_availableTypes():Dynamic<Bool> {
		return {
			"troshx.sos.core.Inventory": true
		};
	}
	
	function getNewInventory(contents:String):Inventory {
		var newInventory:Dynamic;
		
		try {
			newInventory = new Unserializer(contents).unserialize();
		}
		catch (e:Dynamic) {
			trace(e);
			Browser.alert("Sorry, failed to unserialize save-content string!");
			return null;
		}
		
		if (!Std.is(newInventory, Inventory) ) {
			trace(newInventory);
			Browser.alert("Sorry, unserialized type isn't Inventory!");
			return null;
		}
		return LibUtil.as(newInventory, Inventory);
	}
	
	function loadNewTabClick():Void {
	
		loadNewTab();
	}
	
	function loadNewTab(contents:String = null, tabName:String=null):Void {
		if (contents == null) contents = clipboardContents;
		var inventory:Inventory = getNewInventory(contents);
		if (inventory == null) return;
		
		
		inventory.setNewDroppedList(this.inventory.dropped);
		
		extraInventories.push({
			inventory:inventory,
			tabName: (tabName != null ? validateTabName(tabName) : "New Tab ("+ (++newTabCounter) + ")" )
		});
		curInventoryIndex = extraInventories.length;
	}
	
	function validateTabName(tabName:String):String {
		var curTabs = tabs;
		for (i in 0...curTabs.length) {
			if ( curTabs[i].tabName == tabName) return tabName + " (" + (++newTabCounter) + ")";
		}
		
		return tabName;
	}
	
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
}

typedef InventoryManagerData = {
	var extraInventories:Array<InventoryTab>;
	var clipboardContents:String;
	var curInventoryIndex:Int;
	var newTabCounter:Int;
	var showBrowser:Bool;
}

typedef InventoryManagerProps = {
	@:prop({required:true}) var inventory:Inventory;
	@:prop({required:false, "default":"Current"}) @:optional var firstTabName:String;
	@:prop({required:false}) @:optional var backBtnCallback:Void->Void;
	@:prop({required:false, 'default':true}) @:optional var loadAvailable:Bool;
	
	@:prop({required:false}) @:optional var maxCostCopper:Int;
	@:prop({required:false}) @:optional var maxWeight:Float;
	@:prop({required:false}) @:optional var autoLoad:String;
}

typedef InventoryTab = {
	var inventory:Inventory;
	var tabName:String;
	
	
}