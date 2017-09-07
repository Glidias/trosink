package troshx.sos.vue.inputs;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.vue.inputs.NumericInput.NumericInputProps;
import troshx.util.LibUtil;

/**
 * Base numeric input class to use as a mixin
 * @author Glidias
 */
class NumericInput extends VComponent<NoneT, NumericInputProps>
{
	
	public static var TEMPLATE:String = '<input type="number" number v-model.number.range="obj[prop]" :class="{invalid:!valid}" :min="min" :max="max"></input>';
	
	static var INSTANCE:NumericInput;
	public static function getSampleInstance():NumericInput {
		return (INSTANCE != null  ? INSTANCE : INSTANCE = new NumericInput());
	}

	public function new() 
	{
		super();
	}
	
	@:computed function get_min():Int {
		return 0;
	}
	@:computed function get_max():Int {
		return 999999999;
	}
	@:computed function get_valid():Bool {
		return true;
	}
	
	
	// -- standard base
	override function Template():String {
		return NumericInput.TEMPLATE;
	}
	
	override function Mounted():Void {
		checkConstraints();
	}
	
	function checkConstraints():Void
	{
	
		var currentVal:Int = current;
		var min:Int = this.min;
		var max:Int = this.max;
		if (currentVal < min) currentVal = min;
		if (currentVal > max) currentVal = max;
		if (currentVal != current)  LibUtil.setField(obj, prop, currentVal);
	}
	
	@:watch function watch_min(newVal:Int):Void {
		checkConstraints();
	}
	@:watch function watch_max(newVal:Int):Void {
		checkConstraints();
	}
	

	@:computed inline function get_current():Int {
		return LibUtil.field(obj, prop);
	}
	
	
	
	
}

typedef NumericInputProps = {
	@:prop({required:true}) var obj:Dynamic;
	@:prop({required:true}) var prop:String;

}

