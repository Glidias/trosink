package;

import haxe.web.Request;
import haxevx.vuex.core.VxBoot;
import haxevx.vuex.native.Vue;
import js.Browser;
import js.html.URLSearchParams;
import js.html.Window;
import troshx.sos.vue.CharSheetVue;
import troshx.sos.vue.RangeCalculator;
import troshx.sos.vue.externs.SweetModal;
import troshx.util.LibUtil;

import troshx.sos.sheets.CharSheet;
import troshx.sos.vue.CharGen;
import troshx.sos.vue.Globals;
import troshx.sos.vue.InventoryManager;
import troshx.sos.vue.InventoryStandalone;

import troshx.sos.core.Manuever;
import troshx.sos.BoutController;



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
		
		Vue.use(SweetModal);
		
		//Browser.window.localStorage.removeItem(CharSheetVue.SESSION_KEY );
		//Browser.window.localStorage.removeItem(CharGen.SAVED_CHARS_KEY);
		
		var urlSplit = Browser.window.location.href.split("#")[0].split("?");
		var params = Request.getParams();
		if (params.get("inventories")!=null) {
			Globals.DOMAIN_INVENTORY = params.get("inventories");
		}
		if (params.get("characters")!=null) {
			Globals.DOMAIN_CHARACTER = params.get("characters");
		}
		if (params.get("ranging")!=null) {
			Globals.DOMAIN_RANGECALC = params.get("ranging");
		}
		if (params.get("autoload")!=null) {
			Globals.AUTO_LOAD = params.get("autoload");
		}
		if (params.get("host") != null || (untyped Browser.window["USE_HOST"]) ) {
			var h;
			if ( (h=params.get("host"))!=null && (h.substr(0, 7) == "http://" || h.substr(0, 8) == "https://" )) {
				Globals.CURL_DOMAIN = h;
			}
			else Globals.CURL_DOMAIN = Browser.window.location.protocol + "//" + Browser.window.location.hostname;
			//Browser.alert(Globals.CURL_DOMAIN);
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
		else if (hash == "range") {
			boot.startVueWithRootComponent( "#app", new RangeCalculator());
			VxBoot.notifyStarted();	
		}
		else {
			var templateStr:String = '<div>
					<h1>Song of Swords Core Utilities</h1>
					<ul>
						<li><a href="${url}?chargen">Create a Character</a></li>
						<li><a href="${url}?charsheet">Load a Character</a></li>
						<li><a href="${url}?inventory">Inventory Manager</a></li>
					</ul>
					<h1>Song of Swords Tactical Utilities</h1>
					<ul>
						<li><a href="${url}?range">Range Viability Calculator</a></li>
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