package troshx.sos.vue.inputs.impl;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.vue.inputs.NumericInput.NumericInputProps;
import troshx.util.LibUtil;


/**
 * ...
 * @author Glidias
 */
class SchoolLevelInput extends VComponent<NoneT, SchoolLevelInputProps>
{
	public static inline var NAME:String = "SchoolLevelInput";

	public function new() 
	{
		super();
		untyped this.mixins = [NumericInput.getSampleInstance()];
	}
	
	
	@:computed function get_max():Int {
		var cr:Int = current;
		var rm = this.remainingArc + (cr > 0 ? levelCosts[(cr - 1)] :  0);
		var result:Int = 0;
		for (i in 0...levelCosts.length) {
			if (levelCosts[i] > rm) {
				return result;
			}
			result = i + 1;
		}
		return result;
	}
	
	
	@:computed function get_min():Int {
		return this.minAmount;
	}
	
	
	@:computed inline function get_current():Int {
		return LibUtil.field(obj, prop);
	}
	
}

typedef SchoolLevelInputProps = {
	>NumericInputProps,
	@:prop({required:true}) var remainingArc:Int;
	@:prop({required:true}) var levelCosts:Array<Int>;
	@:prop({required:false, 'default':0}) var minAmount:Int;
}