package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import troshx.sos.core.DamageType;
import troshx.sos.core.Item;
import troshx.sos.vue.widgets.BaseItemWidget.BaseItemWidgetProps;

/**
 * Widget to handle melee TN and Damage
 * @author Glidias
 */
class WMeleeAtk extends VComponent<NoneT, MeleeAtkProps>
{
	public static inline var NAME:String = "w-melee-atk";

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

typedef MeleeAtkProps = {
	> BaseItemWidgetProps,
	@:prop({required:true}) var thrusting:Bool;
}