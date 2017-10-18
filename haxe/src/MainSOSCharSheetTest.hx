package;
import haxevx.vuex.core.VxBoot;
import troshx.sos.bnb.Banes;
import troshx.sos.bnb.Boons;
import troshx.sos.events.SOSEvent;
import troshx.sos.events.SOSNotification;
import troshx.sos.schools.Schools;
import troshx.sos.vue.CharGen;
import troshx.sos.vue.CharSheetVue;
import troshx.sos.vue.treeview.TreeView;
import troshx.sos.vue.uifields.UI;

/**
 * ...
 * @author Glidias
 */
class MainSOSCharSheetTest
{

	var boot:VxBoot = new VxBoot();
	
	static function main() 
	{
		new MainSOSCharSheetTest();
	}
	
	function new() {
		
		
		SOSEvent;
		SOSNotification;
		Boons;
		Banes;
		Schools;
		
		UI;
		
		boot.startVueWithRootComponent( "#app", new CharSheetVue());
		VxBoot.notifyStarted();
	}
	
	

	
	
	
}