package troshx.sos.vue.inputs;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import js.html.InputElement;
import troshx.sos.vue.inputs.NumericInput.NumericInputProps;
import troshx.util.LibUtil;

/**
 * Base numeric input class to use as a mixin
 * @author Glidias
 */
class NumericInput extends VComponent<NoneT, NumericInputProps>
{
	
	public static var TEMPLATE:String = '<input type="number" number :value="obj[prop]" v-on:input="inputHandler($$event.target)" :class="{invalid:!valid}" :min="min" :max="max"></input>';
	
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
	
		var theCurrent:Float = this.current;
		var currentVal:Float = theCurrent;
		var min:Float = this.min;
		var max:Float = this.max;
		if (min != null && currentVal < min) currentVal = min;
		if (max != null && currentVal > max) currentVal = max;
		if (currentVal != theCurrent)  LibUtil.setField(obj, prop, currentVal);
	}
	
	@:watch function watch_min(newVal:Int):Void {
		checkConstraints();
	}
	@:watch function watch_max(newVal:Int):Void {
		checkConstraints();
	}
	
	function inputHandler(input:InputElement):Void {
		var max = this.max;
		var min = this.min;
		var result = input.valueAsNumber;
		if (result > max) {
			input.valueAsNumber = result = max;
		}
		if (result < min) {
			input.valueAsNumber = result = min;
		}
		
		LibUtil.setField(obj, prop, result);
		
	}
	

	@:computed inline function get_current():Int {
		return LibUtil.field(obj, prop);
	}
	
	
	
	
}

typedef NumericInputProps = {
	@:prop({required:true}) var obj:Dynamic;
	@:prop({required:true}) var prop:String;

}

