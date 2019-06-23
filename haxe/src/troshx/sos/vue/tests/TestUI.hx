package troshx.sos.vue.tests;
import haxevx.vuex.core.VxBoot;
import js.Browser;
import troshx.sos.vue.combat.ImageMapTester;

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
		
		boot.startVueWithRootComponent( "#app", new ImageMapTester() );
	}
	
	static function main() 
	{
		new TestUI();
	}
	
}