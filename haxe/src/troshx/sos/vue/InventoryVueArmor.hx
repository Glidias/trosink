package troshx.sos.vue;
import haxevx.vuex.util.VHTMacros;

/**
 * ...
 * @author Glidias
 */
class InventoryVueArmor extends InventoryVue
{

	public function new() 
	{
		super();
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
}