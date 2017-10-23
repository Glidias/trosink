package troshx.sos.vue.input;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.vue.uifields.BaseNumMixin;

/**
 * ...
 * @author Glidias
 */
class InputInt extends VComponent<NoneT, InputIntProps>
{
public static inline var NAME:String = "InputInt";
	
	public function new() 
	{
		super();
		untyped this.mixins = [BaseNumMixin.getSampleInstance()];
	}
	
	override function Template():String {
		return '<input type="number" :disabled="disabled" number v-on:blur="blurHandler($$event.target)" v-on:input="inputHandler($$event.target)" :value="obj[prop]" :min="min" :max="max" :step="1" :readonly="readonly"></input>';
	}
}


typedef InputIntProps = {
	>BaseInputProps,
	@:optional @:prop({required:false}) var min:Int;
	@:optional @:prop({required:false}) var max:Int; 
	@:optional @:prop({required:false, 'default':false}) var floating:Bool;	
}