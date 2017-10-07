package;
import haxevx.vuex.core.VxBoot;
import troshx.sos.bnb.Banes;
import troshx.sos.bnb.Boons;
import troshx.sos.events.SOSEvent;
import troshx.sos.events.SOSNotification;
import troshx.sos.schools.Schools;
import troshx.sos.vue.CharGen;
import troshx.sos.vue.treeview.TreeView;
import troshx.sos.vue.uifields.UI;

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
		Boons;
		Banes;
		Schools;
		
		UI;
		
		boot.startVueWithRootComponent( "#app", new CharGen());
		VxBoot.notifyStarted();
	}
	
	

	
	
	
}