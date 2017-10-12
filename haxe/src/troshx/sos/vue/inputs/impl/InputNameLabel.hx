package troshx.sos.vue.inputs.impl;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import js.html.InputElement;
import troshx.sos.vue.input.BaseInputProps;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class InputNameLabel extends VComponent<NoneT, BaseInputProps>
{
	public static inline var NAME:String = "InputNameLabel";

	public function new() 
	{
		super();
	}
	
	function onBlur(input:InputElement):Void {
		var val:String = input.value;
		val = StringTools.trim(val);
		LibUtil.setField(obj, prop, val);
		input.value = val;
	}
	
	override function Template():String {
		return '<input type="text" :disabled="disabled" :value="obj[prop]" v-on:blur="onBlur($$event.target)"></input>';
	}
	
}