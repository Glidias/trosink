package troshx.sos.vue.tests.layout;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import hxGeomAlgo.HxPoint;
import js.Browser;
import troshx.util.layout.AspectConstraint;
import troshx.util.layout.LayoutItem;
import troshx.util.layout.PointScaleConstraint;

/**
 * ...
 * @author Glidias
 */
class LayoutItemTest extends VComponent<LayoutItemTestData, NoneT>
{

	public function new() 
	{
		super();
	}
	
	static var TEST_POS:HxPoint = new HxPoint();
	static var TEST_SCALE:HxPoint = new HxPoint();
	

	
	
	
	private function onResize():Void {
		var container = _vRefs.container;
		this.screenWidth = Std.parseFloat(container.clientWidth);
		this.screenHeight = Std.parseFloat(container.clientHeight);
		
		
		/*
		this.layoutItem.findScales(testScale, screenWidth / refWidth, screenHeight / refHeight);

		
		_vRefs.testItem.attributes.style = this.testStyle;
		
		this.debugField = this.layoutItem.aspect + "<br/>" +  (_vRefs.testItem.clientWidth / _vRefs.testItem.clientHeight);
		trace(this.debugField);
		*/
	}
	
	override public function Mounted():Void {
		var container = _vRefs.container;
		this.refWidth = Std.parseFloat(container.clientWidth);
		this.refHeight = Std.parseFloat(container.clientHeight);
		
		var width:Float = 255;
		var height:Float = 200;
		this.layoutItem = LayoutItem.createRect(this.refWidth, this.refHeight, 100, 50, width, height)
		.pin(PointScaleConstraint.createRelative(0, 0).scaleMinRelative(0.0, 0.0).scaleMaxRelative(3.0, 3.0))
		.pivot(PointScaleConstraint.createRelative(0.0, 0.0).scaleMinRelative(0.0, 0.0).scaleMaxRelative(3.0, 3.0))
		.aspect(AspectConstraint.createRelative(1, 1).enablePreflight());
		//
		
		Browser.window.addEventListener("resize", onResize);
		onResize();
	}
	
	
	override public function Data():LayoutItemTestData {
		return {
			screenWidth: 0,
			screenHeight: 0,
			layoutItem: null,
			refWidth:550, 
			refHeight:400,
			
			debugField: ""
		};
	}

	
	@:computed var testStyle(get, never):Dynamic;
	function get_testStyle():Dynamic 
	{
		var testPos = TEST_POS;
		var testScale = TEST_SCALE;
		this.layoutItem.solve(testPos, testScale, this.screenWidth / this.refWidth, this.screenHeight / this.refHeight);
		
		var w = testScale.x * this.screenWidth;
		var h = testScale.y * this.screenHeight;
		var x = testPos.x * this.screenWidth;
		var y = testPos.y * this.screenHeight;
		
		//x = this.layoutItem.u * this.screenWidth;
		//y = this.layoutItem.v * this.screenHeight;
		
		
		return { 'overflow':"hidden", 'background-color':"rgba(255,0,0,.5)", 'position':"absolute", 'box-sizing':"border-box", 'border':"1px solid #00ff00",
			width: w+"px", height: h+"px", top: y+"px", left: x+"px"};
	}
	
	

	
	
	override public function Template():String {
		return '<div>
			<div ref="container" style="font-size:22px; background-color:orange; position:absolute; top:0; left;0; width:100%; height:100%">
				<div ref="testItem" v-if="layoutItem" :style="testStyle" v-html="debugField"></div>
			</div>
		</div>';
	}
	
	
	
}

typedef LayoutItemTestData = {
	var screenWidth:Float;
	var screenHeight:Float;
	var refWidth:Float;
	var refHeight:Float;
	var layoutItem:LayoutItem;

	var debugField:String;
}