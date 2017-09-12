package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.BoonBaneAssign;
import troshx.sos.vue.uifields.UI;

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
	
	@:computed function get_titleheader():String {
		var qty = this.qty;
		return bb.name + (qty > 1 ? " (x"+qty+")" : "");
	}
	
	@:computed function get_typeMap():Dynamic<String> {
		return UI.getTypeMapToComponentNames();
	}
	
	
	override function Template():String {
		return '
			<div v-show="uiFields!=null && uiFields.length > 0">
				<h4>{{ titleheader }}<h4>
				<div v-if="uiFields!=null">	
					<div v-for="(li, i) in uiFields" :is="typeMap[li.type]" :obj="assign" v-bind="li"></div>
				</div>
			</div>
		';
	}
	
}

typedef BoonBaneApplyDetailsProps = {
	@:prop({required:true}) var assign:BoonBaneAssign;
}