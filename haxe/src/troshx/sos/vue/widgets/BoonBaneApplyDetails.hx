package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.BoonBaneAssign;
import troshx.sos.vue.uifields.UI;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class BoonBaneApplyDetails extends VComponent<NoneT, BoonBaneApplyDetailsProps>
{
	public static inline var NAME:String = "bb-apply";

	public function new() 
	{
		super();
	
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>> {
		return UI.getComponents();
	}
	
	@:computed function get_uiFields():Array<Dynamic> {
		
		return assign.getUIFields();
	}
	
	@:computed function get_bb():BoonBane {
		return this.assign.getBoonOrBane();
	}
	
	@:computed function get_qty():Int {
		return assign.getQty();
	}
	
	@:computed function get_cost():Int {
		return assign.getCost(assign.rank);
	}
	
	@:computed function get_titleheader():String {
		//var qty = this.qty;
		//var remainingCached:Dynamic=  Reflect.field(assign, "_remainingCached");
		
		return bb.name + ( !assign.ingame ? " ["+clampCost+(remainingPoints!=null ? "/"+(remainingPoints+clampCost) : "")+"]" : "");
	}
	
	@:computed function get_clampCost():Int {
		return Std.int( Math.max(this.cost, bb.costs[0]) );
	}
	
	@:computed function get_typeMap():Dynamic<String> {
		return UI.getTypeMapToComponentNames();
	}
	
	public static inline function getSlug(name:String):String {
		return 'bb-detail-'+name.split(" ").join("-").toLowerCase();
	}
	
	@:computed function get_slug():String {
		return getSlug(bb.name);
	}
	
	override function Template():String {
		return '
			<div class="bb-detail" v-show="assign.__hasUIFields__" :id="slug">
				<h4>{{ titleheader }}</h4>
				<div>	
					<div v-for="(li, i) in uiFields" :is="typeMap[li.type]" :obj="assign" v-bind="li" :key="li.prop"></div>
				</div>
			</div>
		';
	}
	
}

typedef BoonBaneApplyDetailsProps = {
	@:prop({required:true}) var assign:BoonBaneAssign;
	@:prop({required:false}) var remainingPoints:Int;
}