package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import troshx.sos.core.Inventory;

/**
 * ...
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
			clipboardContents:""
		}
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			"comp" => new InventoryVue()
		];
	}
	
	@:computed function get_inventories():Array<Inventory> {
		return [inventory].concat(extraInventories);
	}
	
	function openNewTab():Void {
		
	}
	
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
}

typedef InventoryManagerData = {
	var extraInventories:Array<Inventory>;
	var clipboardContents:String;

}

typedef InventoryManagerProps = {
	var inventory:Inventory;
}