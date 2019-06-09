package troshx.sos.vue.tests.layout;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import js.Browser;
import troshx.util.layout.AspectConstraint;
import troshx.util.layout.Vec2;

/**
 * ...
 * @author Glidias
 */
class AspectConstraintTest extends VComponent<AspectConstraintTestData, NoneT>
{

	public function new() 
	{
		super();
	}
	
	override public function Mounted():Void {
		Browser.window.addEventListener("resize", onResize);
		onResize();
	}
	
	override public function Created():Void {
		this.aspectConstraint = AspectConstraint.createRelative(2, 0);
		trace(this.aspect * this.aspectConstraint.max );
		trace(this.aspect * this.aspectConstraint.min);
	}
	
	
	private function onResize():Void {
		var container = _vRefs.container;
		this.screenWidth = Std.parseFloat(container.clientWidth);
		this.screenHeight = Std.parseFloat(container.clientHeight);
		
		this.aspectConstraint.findScales(testScale, screenWidth / refWidth, screenHeight / refHeight);
		
		
		_vRefs.testAspect.attributes.style = this.testStyle;
		
		this.debugField = this.aspect + "<br/>" +  (_vRefs.testAspect.clientWidth / _vRefs.testAspect.clientHeight);
		trace(this.debugField);
	}
	
	override public function Data():AspectConstraintTestData {
		return {
			screenWidth: 0,
			screenHeight: 0,
			aspectConstraint: null,
			refWidth:150, 
			refHeight:200,
			testScale: new Vec2(1, 1),
			debugField: ""
		};
	}
	
	@:computed var aspect(get, never):Float;
	function get_aspect():Float {
		return this.refWidth/ this.refHeight;
	}
	
	@:computed var testStyle(get, never):Dynamic;
	function get_testStyle():Dynamic 
	{
		var w = this.refWidth * testScale.x;
		var h = this.refHeight * testScale.y;
		var x = 0;
		var y = 0;
		
		return { 'overflow':"hidden", 'background-color':"rgba(255,0,0,.5)", 'position':"absolute", 'box-sizing':"border-box", 'border':"1px solid #00ff00",
			width: w+"px", height: h+"px", top: y+"px", left: x+"px"};
	}
	
	

	
	
	override public function Template():String {
		return '<div>
			<div ref="container" style="font-size:22px; background-color:orange; position:absolute; top:0; left;0; width:100%; height:100%">
				<div ref="testAspect" v-if="aspectConstraint" :style="testStyle" v-html="debugField"></div>
			</div>
		</div>';
	}
	
	
	
}

typedef AspectConstraintTestData = {
	var screenWidth:Float;
	var screenHeight:Float;
	var refWidth:Float;
	var refHeight:Float;
	var aspectConstraint:AspectConstraint;
	var testScale:Vec2;
	var debugField:String;
}