package;
import haxevx.vuex.core.VxBoot;
import troshx.sos.vue.CharGen;

/**
 * ...
 * @author Glidias
 */
class MainSOSCharGenTest
{

	var boot:VxBoot = new VxBoot();
	
	static function main() 
	{
		new MainSOSCharGenTest();
	}
	
	function new() {
		
		
		
		
		boot.startVueWithRootComponent( "#app", new CharGen());
		VxBoot.notifyStarted();
	}
	
	

	
	
	
}