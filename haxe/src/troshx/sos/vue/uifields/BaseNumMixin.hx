package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
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
	
		var currentVal:Float = current;
		var min:Float = this.min;
		var max:Float = this.max;
		if (currentVal < min) currentVal = min;
		if (currentVal > max) currentVal = max;
		if (currentVal != current)  LibUtil.setField(obj, prop, currentVal);
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
	

	

}

typedef BaseNumProps = {
	>BaseUIProps,
	@:optional @:prop({required:false}) var min:Float;
	@:optional @:prop({required:false}) var max:Float;
	@:optional @:prop({required:false}) var step:Float;	
}