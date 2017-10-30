package troshx.sos.vue.widgets;
import haxevx.vuex.util.VHTMacros;
import troshx.sos.vue.input.MixinInput;

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
		untyped this.mixins = [ MixinInput.getInstance(), MeleeVariantMixin.getInstance() ];
	}
	

	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	
}