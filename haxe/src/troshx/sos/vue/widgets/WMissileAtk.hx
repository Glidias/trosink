package troshx.sos.vue.widgets;
import haxevx.vuex.util.VHTMacros;
import troshx.sos.core.DamageType;

/**
 * Widget to handle missile TN and damage for missile weapons
 * @author Glidias
 */
class WMissileAtk extends BaseItemWidget
{
	
	public static inline var NAME:String = "w-missile-atk";

	public function new() 
	{
		super();
	}
	
	@:computed function get_damageTypeLabels():Array<String> {

		return DamageType.getFlagLabels();
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
}