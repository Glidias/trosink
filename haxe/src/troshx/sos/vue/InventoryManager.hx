package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.core.Inventory;

/**
 * ...
 * @author Glidias
 */
class InventoryManager extends VComponent<InventoryManagerData, NoneT>
{


	public function new() 
	{
		super();
	}
	
	override function Data():InventoryManagerData {
		return {
			inventories:[]
		}
	}
	
}

typedef InventoryManagerData = {
	var inventories:Array<Inventory>;
}