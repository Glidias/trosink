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
			<label v-if="label">{{ label }}<label>:&nbsp;
			<input type="number" number v-model.number="obj[prop]" :min="min" :max="max" :step="step"></input>
		</div>';
	}
	
	
}

typedef FieldNumberProps = {
	>BaseUIProps,
	@:optional @:prop({required:false}) var min:Float;
	@:optional @:prop({required:false}) var max:Float;
	@:optional @:prop({required:false}) var step:Float;	
}