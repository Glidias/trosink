package troshx.sos.vue.input;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

/**
 * ...
 * @author Glidias
 */
class InputString extends VComponent<NoneT, BaseInputProps>
{

	public static inline var NAME:String = "InputString";
	
	public function new() 
	{
		super();
	}
	
	override function Template():String {
		return '<input type="text" :disabled="disabled"  v-model="obj[prop]"></input>';
	}
	
}