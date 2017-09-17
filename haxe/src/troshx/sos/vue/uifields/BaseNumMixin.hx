package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import js.html.InputElement;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class BaseNumMixin extends VComponent<NoneT, BaseNumProps>
{
	

	public function new() 
	{
		super();
	
	}
	
	static var INSTANCE:BaseNumMixin;
	public static function getSampleInstance():BaseNumMixin {
		return (INSTANCE != null  ? INSTANCE : INSTANCE = new BaseNumMixin());
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
	
	@:watch function watch_min(newVal:Float):Void {
		checkConstraints();
	}
	@:watch function watch_max(newVal:Float ):Void {
		checkConstraints();
	}

	@:computed inline function get_current():Float {
		return LibUtil.field(obj, prop);
	}
	
	
	function inputHandler(input:InputElement):Void {
		var max = this.max;
		var min = this.min;
		
		var result:Float =  floating ? input.valueAsNumber : Std.int(input.valueAsNumber); // Std.parseInt( (~/[^0-9]/g).replace( input.value, '') );
		
		if (result == null || Math.isNaN(result) ) {
			input.valueAsNumber =  LibUtil.field(obj, prop);
			return;
		}
		if (result != input.valueAsNumber) input.valueAsNumber = result;
		
		if (result > max) {
			input.valueAsNumber = result = max;
		}
		if (result < min) {
			input.valueAsNumber = result = min;
		}
		
		LibUtil.setField(obj, prop, result);
		
	}
	

	

}

typedef BaseNumProps = {
	>BaseUIProps,
	@:optional @:prop({required:false}) var min:Float;
	@:optional @:prop({required:false}) var max:Float;
	@:optional @:prop({required:false}) var step:Float;	
	@:optional @:prop({required:false, 'default':true}) var floating:Bool;	
}