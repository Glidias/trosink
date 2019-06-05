package troshx.sos.vue.tests;
import haxevx.vuex.core.VxBoot;
import js.Browser;

import troshx.sos.vue.tests.layout.AspectConstraintTest;

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
		boot.startVueWithRootComponent( "#app", new AspectConstraintTest() );
	}
	
	static function main() 
	{
		new TestUI();
	}
	
}