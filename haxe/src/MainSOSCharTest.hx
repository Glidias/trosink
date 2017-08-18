package;
import haxevx.vuex.core.VxBoot;
import troshx.sos.vue.CharSheetVue;

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
		boot.startVueWithRootComponent( "#app", new CharSheetVue());
		VxBoot.notifyStarted();
	}
	
	
	
}