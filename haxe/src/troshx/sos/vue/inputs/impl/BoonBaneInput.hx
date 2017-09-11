package troshx.sos.vue.inputs.impl;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.BoonAssign;
import troshx.sos.vue.inputs.NumericInput;
import troshx.sos.vue.inputs.NumericInput.NumericInputProps;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class BoonBaneInput extends VComponent<NoneT, NumericInputProps>
{

	public static inline var NAME:String = "BoonBaneInput";
	
	public function new() 
	{
		super();
		untyped this.mixins = [NumericInput.getSampleInstance()];
	}
	
	@:computed function get_min():Int {
		return 0;
	}
	@:computed function get_max():Int {
		return this.bb.clampRank ? 1 : this.bb.costs.length;
	}
	
	@:computed inline function get_current():Int {
		return LibUtil.field(obj, prop);
	}
	
	@:watch function watch_current(newValue:Int, oldValue:Int):Void {
		if (oldValue > 0) { // start from "ON"
			if (newValue <= 0) {
				_vEmit(isBane ? "removeBane" : "removeBoon", bb.uid);
			}
		}
		else {  // start from "OFF"
			if (newValue > 0) {
				_vEmit(isBane ? "addBane" : "addBoon", bb.uid);
			}
		}
		
	}
	
	@:computed function get_cost():Int {
		return bba.getCost();
	}
	
	@:computed function get_qty():Int {
		return bba.getQty();
	}
	
	
	@:watch function watch_cost(newValue:Int):Void {  
		if (bba.rank > 0) {
			bba._costCached = newValue;
		}
	}
	
	
	@:computed inline function get_bba():BoonBaneAssign {
		
		return obj;
	}
	
	
	@:computed function get_isBane():Bool {
		
		return Std.is(obj, BaneAssign );
	}
	
	@:computed function get_bb():BoonBane {
		return isBane ? LibUtil.field(obj, "bane") : LibUtil.field(obj, "boon");
	}
	
}

