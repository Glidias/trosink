package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue.CreateElement;
import haxevx.vuex.native.Vue.VNode;
import troshx.sos.core.BodyChar;
import troshx.sos.vue.uifields.Bitmask.BitmaskProps;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class HitLocationMultiSelector extends VComponent<NoneT, HitLocationProps>
{
	public static inline var NAME:String = 'HitLocationMultiSelector';

	public function new() 
	{
		super();
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		var src = UI.getComponents();
	
		var me:Dynamic<VComponent<Dynamic,Dynamic>>= {};
		LibUtil.setField(me, Bitmask.NAME, LibUtil.field(src, Bitmask.NAME) );
		return me;
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
		var props:BitmaskProps = {
			
			label:this.label,
			obj:this.obj,
			prop:this.prop,
			//values: null,
			labels: this.labels
			
		};
		return c(SingleSelection.NAME, props);
	}
	

}

