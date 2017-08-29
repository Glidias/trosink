package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import troshx.sos.core.Armor;
import troshx.sos.core.Inventory.WeaponAssign;
import troshx.sos.core.Item;
import troshx.sos.vue.widgets.*;

/**
 * A standard holder for read-only input text field widgets
 * @author Glidias
 */
class TDWidgetHolder extends VComponent<NoneT, TDWidgetHolderProps>
{
	public static inline var NAME:String = "td-widget";

	public function new() 
	{
		super();
	}
	
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>> {
		return [

			WAmmunition.NAME => new WAmmunition(),
			WCoverage.NAME => new WCoverage(),
			WMeleeAtk.NAME => new WMeleeAtk(),
			WMeleeDef.NAME => new WMeleeDef(),
			WMissileAtk.NAME => new WMissileAtk(),
			WProf.NAME => new WProf(),
			WSpanTools.NAME => new WSpanTools(),
			WTags.NAME => new WTags(),
		];
	}
	

	@:computed function get_item():Item {
		if (entry.weapon != null) return entry.weapon;
		else if (entry.shield != null) return entry.shield;
		else if (entry.armor != null) return entry.armor;
		else if (Std.is(entry, Armor)) return entry;
		else return entry.item;
	}
	
	function shiftIndex(i:Int):Int {
		return (1 << i);
	}
	function emit(str:String):Void {
		_vEmit(str);
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
}

typedef TDWidgetHolderProps = {
	var entry:Dynamic;  
	
	var value:Dynamic;
	var showWidget:Bool;
	var requestCurWidget:String->Int->Void;
	var widgetName:String;
	var index:Int;
	var widgetTagName:String;
	@:prop({required:false})  @:optional public var widgetProps:Dynamic;
	
}