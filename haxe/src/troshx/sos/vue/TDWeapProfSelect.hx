package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import troshx.sos.core.Profeciency;
import troshx.sos.core.Weapon;
import troshx.sos.vue.CharSheetVue.WidgetItemRequest;

/**
 * ...
 * @author Glidias
 */
class TDWeapProfSelect extends VComponent<NoneT, TDWeapProfSelectProps>
{
	public static inline var NAME:String = "td-prof";

	public function new() 
	{
		super();
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
}

typedef TDWeapProfSelectProps = {
	var curWidgetRequest:WidgetItemRequest;
	var weapon:Weapon;
	
	var section:String;
	var index:Int;
	var isVisibleWidget:String->String->Int->Bool;
	
	var meleeProfs:Array<Profeciency>;
	var rangedProfs:Array<Profeciency>;
	

}