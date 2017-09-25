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
class BoonBaneInput extends VComponent<NoneT, BoonBaneInputProps>
{

	
	public static inline var NAME:String = "BoonBaneInput";
	
	public function new() 
	{
		super();
		untyped this.mixins = [NumericInput.getSampleInstance()];
	}
	
	override function Template():String {
		return  '<span class="gen-comp-bb" :class="{canceled:obj._canceled, \'required\':min>0, \'force-perm\':obj._forcePermanent, disabled:max<1, selected:obj[prop]>0}">
		<label><input type="checkbox" :disabled="obj._canceled || obj._forcePermanent" v-if="coreMax<2" :checked="obj[prop]>=1" v-on:click.stop="checkboxHandler($$event.target)"></input><input type="number" :disabled="obj._canceled || obj._forcePermanent" v-if="coreMax>=2" number v-on:input="inputHandler($$event.target)" v-on:blur="blurHandler($$event.target)" :value="obj[prop]" :class="{invalid:!valid}" :min="min" :max="max"></input><span v-html="label" v-on:click="toggleIfPossible($$event)"></span><span class="close-btn" v-show="showClose">&nbsp;<a href="#" v-on:click.stop.prevent="closeBB()">[x]</a></span><span style="opacity:1;pointer-events:auto;" v-show="showReset" class="reset-btb">[<a href="#" v-on:click.stop.prevent="resetBB()">c</a>]</span></label>
		</span>';
	}
	

	
	@:computed function get_showReset():Bool {
		var costArr = bb.costs;
		var cc = this.cost;
		if (cc == null) cc = costArr[0];
		cc = cc < costArr[0] ? costArr[0] : cc;
		var rank = bba.rank;
		return cc != costArr[rank > 1 ? rank -1 : 0];
		
	}
	
	function resetBB():Void {
		_vEmit("resetBB", bba, isBane);
	}
	
	@:computed function get_discount():Int {
		return isBane ? 0 :  asBoonAssign.discount; 
	}
	
	@:computed function get_min():Int {
		return bba._minRequired != 0  ? bba._minRequired : 0;
	}

	@:computed function get_max():Int {
		var cm = this.coreMax;
		if (this.remaining != null) {
			var bba = this.bba;
			var re = this.remaining + (this.current > 0 ? bba._costCached : 0);
			var b = 0;
			var lowestCost = this.bb.costs[0];
			for (i in 0...cm) {
				var c =  bba.getCost(i+1);
				c = c < lowestCost ? lowestCost : c;
				if ( re < c) break;
				b = i+1;
			}
			return b;
			
		}
		return cm;
	}
	
	@:computed function get_coreMax():Int {
		return this.bb.clampRank ? 1 : this.bb.costs.length;
	}
	
	@:computed inline function get_current():Int {
		return LibUtil.field(obj, prop);
	}
	
	function toggleIfPossible(e:Event):Void {
		
		
		
		var bba = this.bba;
		if (gotDiscount || bba._forcePermanent) return;
		var cur:Int = LibUtil.field(obj, prop);
		
		
		if (bba._canceled) {	
			bba._canceled = false;
			if (cur == 0) {
				LibUtil.setField(obj, prop, 1);
				e.stopPropagation();
				e.preventDefault();
			}
			else {
				_vEmit("uncancel", bba, isBane);
			}
			return;
		}
		
		if (cur == 0 ) {
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
	
	function closeBB():Void {
		LibUtil.setField(obj, prop, 0);// = 0;
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
				_vEmit("removeBB", bba, isBane);
			}
		}
		else {  // start from "OFF"
			if (newValue > 0) {
				_vEmit("addBB", bba, isBane);
			}
		}
		
	}
	
	@:computed function get_cost():Int {
		return bba.getCost(bba.rank);
	}
	
	@:computed function get_qty():Int {
		return bba.getQty();
	}
	
	@:computed inline function get_gotDiscount():Bool {
		return this.asBoonAssign.discount > 0;
	}
	
	
	@:watch function watch_cost(newValue:Int):Void { 
		var bba = this.bba;
		var rank = bba.rank;

		var test = bb.costs[0];
		bba._costCached = newValue >= test ? newValue : test;
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
		var rankCost = bba.rank < 2 ? costArr[0] : costArr[bba.rank - 1];
		var costJoin = ""+( bba.rank == 1 ? "<b>"+costArr[0]+"</b>" : ""+costArr[0]);
		var max = this.max;
		for (i in 1...costArr.length) {
			var joinChar = (customCostInnerSlashes != null ?  customCostInnerSlashes.charAt(i - 1) : (joinStr) );
			
			costJoin += (i==max ? '<span class="limit-join">'+joinChar+"</span>" : joinChar) + ( bba.rank == i+1 ? "<b>"+costArr[i]+"</b>" : ""+costArr[i]);
		}
		var costDisp = openBracket + costJoin + closeBracket;
		
		//<span style="color:red"></span>
		//var costC = this.cost;
		var cc = this.cost;
		//if (cc == null) cc = costArr[0];
		//if (Math.isNaN(cc)) trace();
		cc = cc < costArr[0] ? costArr[0] : cc;
		
		return bb.name + " " +costDisp + (qty > 1 ? "~"+qty+"~" : '') + (cc!=rankCost ? "=<b>"+cc+"</b>" : "") + (gotDiscount ?  "-"+this.asBoonAssign.discount : "");
	}
	
	
	@:computed inline function get_bba():BoonBaneAssign {
		
		return obj;
	}
	
	@:computed inline function get_asBoonAssign():BoonAssign {
		
		return obj;
	}
	
	
	@:computed function get_isBane():Bool {
		
		return Std.is(obj, BaneAssign );
	}
	
	@:computed function get_bb():BoonBane {

		return bba.getBoonOrBane();
	}
	
}


typedef BoonBaneInputProps = {
	>NumericInputProps,
	@:optional @prop({required:false}) var remaining:Int;
}