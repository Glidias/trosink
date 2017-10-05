package troshx.sos.vue;

import haxe.Unserializer;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue.CreateElement;
import haxevx.vuex.native.Vue.VNode;
import troshx.sos.core.Inventory;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class InventoryStandalone extends VComponent<InventoryStandaloneData, NoneT>
{
	

	public function new() 
	{
		super();
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			"comp" => new InventoryVue()
		];
	}
	
	public function loadSheet(contents:String):Void {
		var newInventory:Dynamic = new Unserializer(contents).unserialize();
		
		if (!Std.is(newInventory, Inventory) ) {
			trace(newInventory);
			throw "Serialized Inventory not valid!";
		}
		this.inventory = LibUtil.as(newInventory, Inventory);
		
	}
	
	
	override function Data():InventoryStandaloneData {
		return {
			inventory: new Inventory()
		}
	}
	
	override function Template():String {
		return '<comp :inventory="inventory" v-on:loadSheet="loadSheet"></comp>';
	}
	
}

typedef InventoryStandaloneData = {
	var inventory:Inventory;
}