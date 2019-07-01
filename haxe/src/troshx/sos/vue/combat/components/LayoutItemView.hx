package troshx.sos.vue.combat.components;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import hxGeomAlgo.PolyTools.Poly;
import js.html.CanvasRenderingContext2D;
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
		var obj:Dynamic = {left:x + "px", top:y + "px", width: width+"px", height:height+"px", boxSizing:"border-box"};
		if (GlobalCanvas2D.getContext() != null) {
			return obj;
		}
		if (!this.gotSVG) {
			if (this.showShape || this.debug) {
				obj.outline = strokeColor+' solid '+strokeWidth+'px';
				obj.backgroundColor = fillColor;
				if (item.shape == LayoutItem.SHAPE_CIRCLE) {
					obj.borderRadius = '50%';
					obj.backgroundColor = fillColor;
					if (!this.debug) obj.outline = "none";
				} 
			}
		}
		return obj;
	}
	
	@:computed var gotSVG(get, never):Bool;
	inline function get_gotSVG():Bool 
	{
		if (GlobalCanvas2D.getContext()!=null) return false;
		return this.item.shape == LayoutItem.SHAPE_POLYGON;
	}
	
	@:computed var pStyle(get, never):Dynamic;
	inline function get_pStyle():Dynamic 
	{
		return {
			strokeWidth: strokeWidth + 'px',
			stroke:strokeColor, fill:fillColor
		}
	}
	
	@:computed var polyPoints(get, never):String;
	function get_polyPoints():String 
	{
		return getPolyString(item.uvs);
	}
	
	function getPolyString(poly:Poly):String {
		var xScale:Float = width;
		var yScale:Float = height;
		var pts:Array<Float> = [];
		for (i in 0...poly.length) {
			pts.push(poly[i].x*xScale);
			pts.push(poly[i].y*yScale);
		}
		return pts.join(" ");
	}
	
	override function Updated():Void {
		if (showShape && GlobalCanvas2D.getContext() != null) renderToCanvas();
	}
	
	function renderToCanvas():Void {
		var canvas = GlobalCanvas2D.CANVAS;
		var ctx = GlobalCanvas2D.getContext();
		ctx.clearRect(0, 0, canvas.width, canvas.height);
		var shape = this.item.shape;
		ctx.fillStyle = fillColor;
		ctx.strokeStyle = strokeColor;
		ctx.lineWidth = strokeWidth;
		
		
		var x:Float = this.x;
		var y:Float = this.y;
		var xScale:Float = width;
		var yScale:Float = height;
		
		switch (shape) {
			case LayoutItem.SHAPE_RECT:
				ctx.fillRect(x, y, xScale, yScale);
				ctx.strokeRect(x, y, xScale, yScale);
			case LayoutItem.SHAPE_CIRCLE:
				drawEllipse(ctx, x * width * 0.5, y * height * 0.5, width, height);
			case LayoutItem.SHAPE_POLYGON:
				//context.rect(x, y, width, height);
				var poly = item.uvs;
				ctx.beginPath();
				ctx.moveTo(x + poly[0].x * xScale,
				y + poly[0].y * yScale);
				for (i in 1...poly.length) {
					ctx.lineTo(x + poly[i].x * xScale,
					y + poly[i].y * yScale);
				}
				ctx.closePath();
				ctx.fill();
				ctx.stroke();
		}
	}
	
	static inline function drawEllipse(context:CanvasRenderingContext2D, centerX:Float, centerY:Float, width:Float, height:Float) {
	
		  context.beginPath();
		  
		  context.moveTo(centerX, centerY - height*.5); // A1
		  
		  context.bezierCurveTo(
			centerX + width*.5, centerY - height*.5, // C1
			centerX + width*.5, centerY + height*.5, // C2
			centerX, centerY + height/2); // A2

		  context.bezierCurveTo(
			centerX - width*.5, centerY + height*.5, // C3
			centerX - width*.5, centerY - height*.5, // C4
			centerX, centerY - height/2); // A1

		  context.closePath();	
		  context.fill();
		  context.stroke();
		}
	
	
	
	
	@:computed var polyDecompPoints(get, never):Array<String>;
	function get_polyDecompPoints():Array<String> 
	{
		return item.hitDecomposition != null ? item.hitDecomposition.map(getPolyString) : null;
	}
	
	
	@:computed var titleClasses(get, never):Array<String>;
	function get_titleClasses():Array<String> 
	{
		var splits = this.title.split("-");
		for (i in 1...splits.length) {
			splits[i] = "-" + splits[i];
		}
		return splits;
	}
	
	
	override function Template():String {
		//pointer-events:none;
		return '<div class="layout-item" :class="[{debug}, titleClasses]" :data-vis="showShape" :data-title="title" style="position:absolute;z-index:1;" :style="computedStyle">
			<svg v-if="gotSVG" v-show="debug || showShape" xmlns="http://www.w3.org/2000/svg" version="1.2" baseProfile="tiny" :width="width" :height="height" style="position:absolute">
				<g style="transform-origin:0 0;">
					<polygon :style="pStyle" :points="polyPoints"></polygon>
				</g>
				<g v-if="debug" style="transform-origin:0 0;position:absolute" v-for="(p, i) in polyDecompPoints">
					<polygon style="stroke-width:0.5, stroke:#ff0000; fill:transparent" :points="p" :key="i"></polygon>
				</g>
			</svg>
			<slot />
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
	
	@:optional @:prop({"default":1}) var strokeWidth:Float;
	@:optional @:prop({"default":"#00F"}) var strokeColor:String;
	@:optional @:prop({"default":"rgba(0,255,0,0.4)"}) var fillColor:String;
	
	@:optional @:prop({"default":false}) var debug:Bool;
	@:optional @:prop({"default":false}) var showShape:Bool;
}