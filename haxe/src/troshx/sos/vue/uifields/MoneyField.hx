package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.core.Money;
import troshx.sos.vue.input.MixinInput;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class MoneyField  extends VComponent<NoneT, MoneyFieldProps>
{
	public static inline var NAME:String = "Money";

	public function new() 
	{
		super();
		untyped this.mixins = [ MixinInput.getInstance() ];
	}
	
	@:computed inline function get_current():Money {
		return LibUtil.field(obj, prop);
	}
	
	override function Template():String {
		return '<div class="moneyfields">
			<div>Money:</div>
			<label><InputInt :obj="current" prop="gp" :disabled="disabled" :readonly="readonly" style="width:70px" />&nbsp;GP</label> &nbsp;
			<label><InputInt :obj="current" prop="sp" :disabled="disabled" :readonly="readonly" style="width:70px"/>&nbsp;SP</label> &nbsp;
			<label><InputInt :obj="current" prop="cp" :disabled="disabled" :readonly="readonly"  style="width:70px"/>&nbsp;CP</label> &nbsp;
		</div>';
	}
	
}

typedef MoneyFieldProps = {
	>BaseUIProps,
	@:prop({required:false,'default':false}) @:optional var readonly:Bool;
}