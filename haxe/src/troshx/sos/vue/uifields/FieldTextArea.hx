package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

/**
 * ...
 * @author Glidias
 */
class FieldTextArea extends VComponent<NoneT, BaseUIProps>
{
	public static inline var NAME:String = "FieldTextArea";

	public function new() 
	{
		super();
	}
	
	override function Template():String {
		return '<div>
			<label v-if="label">{{ label }}:&nbsp;</label>
			<textarea v-model="obj[prop]" :disabled="disabled"></textarea>
		</div>';
	}
	
}