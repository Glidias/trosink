package troshx.sos.vue.tests;
import haxevx.vuex.core.VxBoot;
import haxevx.vuex.native.Vue;
import js.Browser;
import js.html.CanvasElement;
import troshx.sos.vue.combat.components.DollView;
import troshx.sos.vue.externs.VueScroll;
import troshx.sos.vue.externs.WebGL2D;
import troshx.util.AbsStringMap;
import troshx.sos.vue.combat.components.ImageMapTester;

import troshx.util.layout.PointScaleConstraint;
import troshx.util.layout.BorderConstraint;
import troshx.util.layout.AspectConstraint;

import troshx.sos.vue.tests.layout.AspectConstraintTest;
import troshx.sos.vue.tests.layout.LayoutItemTest;

/**
 * Testing simple ui constraint Layout engine
 * @author Glidias
 */
class TestUI 
{
	var boot:VxBoot = new VxBoot();

	public function new() 
	{
		Browser.document.body.style.padding = "0";
		Browser.document.body.style.margin = "0";
		Browser.document.body.style.overflow = "hidden";
		Browser.document.body.style.width = "100%";
		Browser.document.body.style.height = "100%";
		
		Browser.document.body.style.backgroundColor = "#e4e5e7";
		
		Vue.use(VueScroll);
		var abc = new AbsStringMap();
		
		var cvsGL:CanvasElement = cast Browser.document.getElementById("canvasGL");
		if (cvsGL != null) {
			untyped cvsGL.style.pointerEvents = "none";
			cvsGL.style.position = "absolute";
			WebGL2D.enable(cvsGL);
			var ctx;
			GlobalCanvas2D.__setupContext(cvsGL, ctx=cvsGL.getContext("webgl-2d"), true);
			/*
			ctx.fillStyle = "rgba(50, 0, 50, 0.5)";
			//ctx.fillRect(0, 0, 34, 44);
			ctx.beginPath();
			ctx.moveTo(0, 0);
			ctx.lineTo(100,50);
			ctx.lineTo(50, 100);
			ctx.lineTo(0, 90);
			ctx.closePath();
			
			ctx.fill();
			ctx.stroke();
			*/
		}
		
		boot.startVueWithRootComponent( "#app", new DollView() );
	}
	
	static function main() 
	{
		new TestUI();
	}
	
}