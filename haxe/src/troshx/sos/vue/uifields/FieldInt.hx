package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;


/**
 * ...
 * @author Glidias
 */
class FieldInt extends VComponent<NoneT, FieldIntProps>
{
	public static inline var NAME:String = "FieldInt";

	public function new() 
	{
		super();
		untyped this.mixins = [BaseNumMixin.getSampleInstance()];
	}

	override function Template():String {
		return '<div>
			<label v-if="label">{{ label }}<label>:&nbsp;
			<input type="number" number v-on:input="inputHandler($$event.target)" :value="obj[prop]" :min="min" :max="max" :step="step"></input>
		</div>';
	}
	
	
	
}

typedef FieldIntProps = {
	>BaseUIProps,
	@:optional @:prop({required:false}) var min:Int;
	@:optional @:prop({required:false}) var max:Int;
	@:optional @:prop({required:false}) var step:Int;	
}