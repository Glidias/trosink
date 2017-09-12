package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.core.Money;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class MoneyField  extends VComponent<NoneT, BaseUIProps>
{
	public static inline var NAME:String = "Money";

	public function new() 
	{
		super();
	}
	
	@:computed inline function get_current():Money {
		return LibUtil.field(obj, prop);
	}
	
	override function Template():String {
		return '<div>
			<h6>Money:</h6>
			<label><input type="number" step="1" v-model.number="current.gp"></input>&nbsp;GP</label> &nbsp;
			<label><input type="number" step="1" v-model.number="current.sp"></input>&nbsp;SP</label> &nbsp;
			<label><input type="number" step="1" v-model.number="current.cp"></input>&nbsp;CP</label> &nbsp;
		</div>';
	}
	
}