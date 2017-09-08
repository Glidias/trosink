package;
import haxevx.vuex.core.VxBoot;
import troshx.sos.bnb.Rich;
import troshx.sos.events.SOSEvent;
import troshx.sos.events.SOSNotification;
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
		
		
		SOSEvent;
		SOSNotification;
		new Rich();
		boot.startVueWithRootComponent( "#app", new CharGen());
		VxBoot.notifyStarted();
	}
	
	

	
	
	
}