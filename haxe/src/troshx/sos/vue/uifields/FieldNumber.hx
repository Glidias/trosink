package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

/**
 * ...
 * @author Glidias
 */
class FieldNumber extends VComponent<NoneT, FieldNumberProps>
{
	public static inline var NAME:String = "FieldNumber";

	public function new() 
	{
		super();
		untyped this.mixins = [BaseNumMixin.getSampleInstance()];
	}

	override function Template():String {
		return '<div>
			<label v-if="label">{{ label }}:&nbsp;</label>
			<input type="number"  :disabled="disabled" number v-on:blur="blurHandler($$event.target)" v-on:input="inputHandler($$event.target)" :value="obj[prop]" :min="min" :max="max" :step="step"></input>
		</div>';
	}
	
	
}

typedef FieldNumberProps = {
	>BaseUIProps,
	@:optional @:prop({required:false}) var min:Float;
	@:optional @:prop({required:false}) var max:Float;
	@:optional @:prop({required:false}) var step:Float;	
	
	@:optional @:prop({required:false, 'default':true}) var floating:Bool;	
}