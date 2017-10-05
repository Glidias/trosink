package;
import haxevx.vuex.core.VxBoot;
import troshx.sos.vue.InventoryManager;
import troshx.sos.vue.InventoryStandalone;


/**
 * ...
 * @author Glidias
 */
class MainSOSCharTest
{

	var boot:VxBoot = new VxBoot();
	
	static function main() 
	{
		new MainSOSCharTest();
	}
	
	function new() {
	
		boot.startVueWithRootComponent( "#app", new InventoryStandalone(new InventoryManager()));
		VxBoot.notifyStarted();
	}
	
	
	
}