package troshx.sos.vue.combat.components;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.util.layout.LayoutItem;

/**
 * ...
 * @author Glidias
 */
class LayoutItemView extends VComponent<NoneT, LayoutItemViewProps>
{

	public function new() 
	{
		super();
	}
	
	@:computed var computedStyle(get, never):Dynamic;
	function get_computedStyle():Dynamic 
	{
		var obj:Dynamic = {left:x + "px", top:y + "px"};
		if (!this.gotSVG) {
			obj.width = width + "px";
			obj.height = height + "px";
			obj.backgroundColor = 'rgba(0,255,0,0.4)';
			obj.outline = 'green solid 1px';
		}
		return obj;
	}
	
	@:computed var gotSVG(get, never):Bool;
	inline function get_gotSVG():Bool 
	{
		return this.item.shape == LayoutItem.SHAPE_POLYGON;
	}
	
	@:computed var gStyle(get, never):Dynamic;
	inline function get_gStyle():Dynamic 
	{
		//transform: 'scale(${width}, ${height})'
		return {
			
		}
	}
	
	@:computed var pStyle(get, never):Dynamic;
	inline function get_pStyle():Dynamic 
	{
		return {
			strokeWidth: (0.5)+'px',
		}
	}
	
	@:computed var polyPoints(get, never):String;
	function get_polyPoints():String 
	{
		var uvs = item.uvs;
		var xScale:Float = width;
		var yScale:Float = height;
		var pts:Array<Float> = [];
		for (i in 0...uvs.length) {
			pts.push(uvs[i].x*xScale);
			pts.push(uvs[i].y*yScale);
		}
		return pts.join(" ");
		
	}
	

	
	override function Template():String {
		//pointer-events:none;
		return '<div class="layout-item" :data-title="title" style="position:absolute;z-index:1;" :style="computedStyle">
			<svg v-if="gotSVG" xmlns="http://www.w3.org/2000/svg" version="1.2" baseProfile="tiny" :width="width" :height="height">
				<g style="transform-origin:0 0;" :style="gStyle">
					<polygon :style="pStyle" style="stroke:#00F; fill:rgba(0,255,0,0.4)" :points="polyPoints"></polygon>
				</g>	
			</svg>
		</div>';
	}
	
	
	
	
	
}

typedef LayoutItemViewProps = {
	var item:LayoutItem;
	var x:Float;
	var y:Float;
	var width:Float;
	var height:Float;
	
	var title:String;
}