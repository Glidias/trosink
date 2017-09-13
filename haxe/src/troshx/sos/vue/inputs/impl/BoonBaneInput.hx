package troshx.sos.vue.inputs.impl;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import js.html.Event;
import js.html.InputElement;
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
	
	override function Template():String {
		return  '<span class="gen-comp-bb" :class="{enabled:max>=1, selected:obj[prop]>0}">
		<label><input type="checkbox" v-if="coreMax<2" :checked="obj[prop]>=1" v-on:click.stop="checkboxHandler($$event.target)"></input><input type="number" v-if="coreMax>=2" number v-on:input="inputHandler($$event.target)" :value="obj[prop]" :class="{invalid:!valid}" :min="min" :max="max"></input><span v-html="label" v-on:click="toggleIfPossible($$event)"></span><span v-show="showClose">&nbsp;<a href="#" v-on:click.stop.prevent="obj[prop]=0">[x]</a></span></label>
		</span>';
	}
	
	@:computed function get_min():Int {
		return 0;
	}
	@:computed function get_max():Int {
		return this.coreMax;
	}
	
	@:computed function get_coreMax():Int {
		return this.bb.clampRank ? 1 : this.bb.costs.length;
	}
	
	@:computed inline function get_current():Int {
		return LibUtil.field(obj, prop);
	}
	
	function toggleIfPossible(e:Event):Void {
		
		var cur:Int = LibUtil.field(obj, prop);
		if (cur ==0) {
			LibUtil.setField(obj, prop, 1);
			e.stopPropagation();
			e.preventDefault();
		}
		/*else if (cur == 1) {
			LibUtil.setField(obj, prop, 0);
			e.stopPropagation();
			e.preventDefault();
		}*/
		
		
	}
	
	@:computed inline function get_showClose():Bool {

		return LibUtil.field(obj, prop) >= 1 && coreMax >= 2;  // 2
	}
	
	function checkboxHandler(htmlInput:InputElement) {
		LibUtil.setField(obj, prop, htmlInput.checked ? 1 : 0);
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
		return bba.getCost(bba.rank);
	}
	
	@:computed function get_qty():Int {
		return bba.getQty();
	}
	
	
	@:watch function watch_cost(newValue:Int):Void {  
		if (bba.rank > 0) {
			bba._costCached = newValue;
		}
	}
	
	
	@:computed function get_label():String {
		var bber:BoonBane = this.bb;
		var bba:BoonBaneAssign = this.bba;
		var customCostInnerSlashes:String = bber.customCostInnerSlashes;
		var qty = this.qty;
		var closeBracket:String = ")";
		var openBracket:String = "(";
		if ( bber.multipleTimes != 1 && bber.multipleTimes !=0  ){
			closeBracket = "]";
			openBracket = "[";
		}
		
		var joinStr =  bber.multipleTimes != BoonBane.TIMES_VARYING ? "/" : "|";
		var costArr = bber.costs;
		var costJoin = ""+( bba.rank == 1 ? "<b>"+costArr[0]+"</b>" : ""+costArr[0]);
		
		for (i in 1...costArr.length) {
			costJoin += (customCostInnerSlashes!=null ?  customCostInnerSlashes.charAt(i-1) : joinStr ) + ( bba.rank == i+1 ? "<b>"+costArr[i]+"</b>" : ""+costArr[i]);
		}
		var costDisp = openBracket + costJoin + closeBracket;
		
		//<span style="color:red"></span>
		//var costC = this.cost;
		return bb.name + " " +costDisp + (qty > 1 ? "<b>(x"+qty+")</b>" : '');
	}
	
	
	@:computed inline function get_bba():BoonBaneAssign {
		
		return obj;
	}
	
	
	@:computed function get_isBane():Bool {
		
		return Std.is(obj, BaneAssign );
	}
	
	@:computed function get_bb():BoonBane {

		return bba.getBoonOrBane();
	}
	
}


