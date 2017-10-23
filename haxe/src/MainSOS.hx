package;

import haxe.web.Request;
import haxevx.vuex.core.VxBoot;
import js.Browser;
import troshx.sos.vue.CharSheetVue;

import troshx.sos.sheets.CharSheet;
import troshx.sos.vue.CharGen;
import troshx.sos.vue.Globals;
import troshx.sos.vue.InventoryManager;
import troshx.sos.vue.InventoryStandalone;



/**
 * ...
 * @author test
 */
class MainSOS 
{

	var boot:VxBoot = new VxBoot();
		
	static function main() 
	{
		new MainSOS();
	}
	
	function new() {
		var urlSplit = Browser.window.location.href.split("#")[0].split("?");
		var params = Request.getParams();
		if (params.get("inventories")!=null) {
			Globals.DOMAIN_INVENTORY = params.get("inventories");
		}
		if (params.get("characters")!=null) {
			Globals.DOMAIN_CHARACTER = params.get("characters");
		}
		
		var url = urlSplit[0];
		var hash:String = urlSplit.pop();
		hash = hash.split("&")[0];
		
		if (hash=="chargen") {
			boot.startVueWithRootComponent( "#app", new CharGen());
			VxBoot.notifyStarted();
		}
		else if (hash == "charsheet") {
			boot.startVueWithRootComponent( "#app", new CharSheetVue());
			VxBoot.notifyStarted();	
		}
		else if (hash == "inventory") {
			boot.startVueWithRootComponent( "#app", new InventoryStandalone(new InventoryManager()));
			VxBoot.notifyStarted();	
		}
		else {
			var templateStr:String = '<div>
					<h1>Song of Swords Utilities</h1>
					<ul>
						<li><a href="${url}?chargen">Create a Character</a></li>
						<li><a href="${url}?charsheet">Load a Character</a></li>
						<li><a href="${url}?inventory">Inventory Manager</a></li>
					</ul>
					<h2>General TROSLike Utilities</h2>
					<ul>
						<li><a href="http://glidias.github.io/Asharena/demos/trosdev/probability.html" target="_blank">Dice Pool Probability Calculator</a></li>
					</ul>
					</div>';
					
			var mock:Dynamic =  { 
				template:templateStr
			};
			boot.startVueWithRootComponent( "#app", mock );
		}
	}
	
}