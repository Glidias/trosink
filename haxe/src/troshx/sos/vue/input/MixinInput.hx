package troshx.sos.vue.input;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.vue.input.InputInt;
import troshx.sos.vue.input.InputNumber;

/**
 * A package to simply allow for plain input components
 * that satisty numeric min/max/step constraints with given 
 * dynamic v-model props supplied via "obj" and "prop" properties.
 * 
 * @author Glidias
 */
class MixinInput extends VComponent<NoneT,NoneT>
{

	function new() 
	{
		super();
	
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			InputInt.NAME => new InputInt(),
			InputNumber.NAME => new InputNumber()
		];
	}
	
	static var INSTANCE:MixinInput;
	public static function getInstance():MixinInput {
		return INSTANCE != null ? INSTANCE : (INSTANCE = new MixinInput());
	}
	
}