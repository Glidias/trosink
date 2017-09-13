package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

/**
 * ...
 * @author Glidias
 */
class FieldString extends VComponent<NoneT, BaseUIProps>
{
	public static inline var NAME:String = "FieldString";

	public function new() 
	{
		super();
	}
	
	override function Template():String {
		return '<div>
			<label v-if="label">{{ label }}:&nbsp;</label>
			<input type="text" v-model="obj[prop]" :disabled="disabled"></input>
		</div>';
	}
	
}