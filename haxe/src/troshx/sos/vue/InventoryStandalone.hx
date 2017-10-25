package troshx.sos.vue;

import haxe.Unserializer;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue.CreateElement;
import haxevx.vuex.native.Vue.VNode;
import js.Browser;
import troshx.sos.core.Inventory;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class InventoryStandalone extends VComponent<InventoryStandaloneData, NoneT>
{
	public function new(theComp:VComponent<Dynamic,Dynamic>) 
	{
		super();
		if (theComp != null) {
			untyped this.components = {
				"comp":theComp
			};
		}
		else {
			Reflect.deleteField(this, "data");
		}
	}
	
	public function getNewInventory(contents:String):Inventory {
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
	
	public function setInventory(chk:Inventory):Void {
		this.inventory = chk;
	}
	
	public function loadSheet(contents:String):Void {
		var chk:Inventory = getNewInventory(contents);
		if (chk == null) return;
		this.setInventory(chk);
		
	}
	
	
	override function Data():InventoryStandaloneData {
		return {
			inventory: new Inventory(),
			autoLoad: Globals.AUTO_LOAD
		}
	}
	
	override function Template():String {
		return '<comp :inventory="inventory" v-on:loadSheet="loadSheet" :autoLoad="autoLoad"></comp>';
	}
	
}

typedef InventoryStandaloneData = {
	var inventory:Inventory;
	var autoLoad:String;
}


