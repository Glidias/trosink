package troshx.sos.vue.inputs.impl;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue.ComponentOptions;
import troshx.sos.vue.inputs.NumericInput;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class CategoryPCPInput extends VComponent<NoneT, CategoryPCPProps>
{
	public static inline var NAME:String = "CategoryPCPInput";

	// -- standard boilerplate
	public function new() 
	{
		super();
		untyped this.mixins = [NumericInput.getSampleInstance()];
	}
	
	// customisation
	@:computed inline function get_current():Int {
		return LibUtil.field(obj, prop);
	}
	
	@:computed function get_valid():Bool {
		return this.current >= min && this.max <= maxPCPPerCategory;
	}

	@:computed function get_min():Int {
		return 	magic ? 0 : 1;
	}
	@:computed function get_max():Int {
		var r = Std.int( Math.min( this.current + this.remainingAssignable, maxPCPPerCategory ) );
		var m = magic ? 0 : 1;
		return r >= m ? r : m;
	}
	
}

typedef CategoryPCPProps = {
	> NumericInputProps,
	@:prop({required:true}) var remainingAssignable:Int;
	@:prop({required:true}) var maxPCPPerCategory:Int;

	@:optional @:prop({required:false, 'default':false}) var magic:Bool;
	
}