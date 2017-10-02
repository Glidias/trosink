package troshx.sos.vue.input;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.vue.input.BaseInputProps;
import troshx.sos.vue.uifields.BaseNumMixin;

/**
 * Just a plain input number
 * @author Glidias
 */
class InputNumber extends VComponent<NoneT,InputNumberProps>
{

	public static inline var NAME:String = "InputNumber";
	
	public function new() 
	{
		super();
		untyped this.mixins = [BaseNumMixin.getSampleInstance()];
	}
	
	override function Template():String {
		return '<input type="number" :disabled="disabled" number v-on:blur="blurHandler($$event.target)" v-on:input="inputHandler($$event.target)" :value="obj[prop]" :min="min" :max="max" :step="step"></input>';
	}
	
}

typedef InputNumberProps = {
	> BaseInputProps,
	@:optional @:prop({required:false}) var min:Float;
	@:optional @:prop({required:false}) var max:Float;
	@:optional @:prop({required:false}) var step:Float;	
	@:optional @:prop({required:false, 'default':true}) var floating:Bool;	
}