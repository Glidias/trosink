package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue.CreateElement;
import haxevx.vuex.native.Vue.VNode;
import troshx.sos.core.BodyChar;
import troshx.sos.vue.uifields.SingleSelection.SelectionProps;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class HitLocationSelector extends VComponent<NoneT, HitLocationProps>
{
	public static inline var NAME:String = 'HitLocationSelector';

	public function new() 
	{
		super();
	}
	
	/*
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		var src = UI.getComponents();
	
		var me:Dynamic<VComponent<Dynamic,Dynamic>>= {};
		LibUtil.setField(me, SingleSelection.NAME, LibUtil.field(src, SingleSelection.NAME) );
		return me;
	}
	*/
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			"comp" => new SingleSelection()
		];
	}
	
	@:computed function get_labels():Array<String> {
		var bd = this.body;
		var collect:Array<String> = [];
		var hitLocations = bd.hitLocations;
		for (i in 0...hitLocations.length) {
			collect.push( hitLocations[i].name );
		}
		return collect;
	}
	

	override function Render(c:CreateElement):VNode {
		var props:SelectionProps = {
			
			label:this.label,
			obj:this.obj,
			prop:this.prop,
			//values: null,
			labels: this.labels
			
		};
		var otherAttrs = _vAttrs;
		LibUtil.override2ndObjInto(props, otherAttrs);
		return c("comp", {props:props});
	}
	

}

