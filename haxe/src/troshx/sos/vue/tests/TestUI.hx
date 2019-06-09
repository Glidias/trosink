package troshx.sos.vue.tests;
import haxevx.vuex.core.VxBoot;
import js.Browser;

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
		boot.startVueWithRootComponent( "#app", new LayoutItemTest() );
	}
	
	static function main() 
	{
		new TestUI();
	}
	
}