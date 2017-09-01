package troshx.sos.vue.widgets;
import haxevx.vuex.util.VHTMacros;

/**
 * Widget to handle melee DTN and Guard
 * @author Glidias
 */
class WMeleeDef extends BaseItemWidget
{
	public static inline var NAME:String = "w-melee-def";

	public function new() 
	{
		super();
	}
	

	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	
}