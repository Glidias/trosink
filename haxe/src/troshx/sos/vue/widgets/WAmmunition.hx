package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import js.html.InputElement;
import troshx.sos.core.Firearm.Ammunition;
import troshx.sos.vue.widgets.BaseItemWidget.BaseItemWidgetProps;

/**
 * Widget to handle available ammunitions for weapon's firearm.
 * @author Glidias
 */
class WAmmunition extends VComponent<AmmunitionData, AmmunitionProps>
{
	public static inline var NAME:String = "w-ammunition";

	public function new() 
	{
		super();
	}
	override function Data() {
		return {
			list: Ammunition.getDefaultList(),
		}
	}
	
	function checkboxHandler(checkbox:InputElement, i:Int, targetObj:Dynamic, targetProp:String):Void {
		if (checkbox.checked) {
			untyped targetObj[targetProp] |= (1 << i);
		}
		else {
			untyped targetObj[targetProp] &= ~(1 << i);
		}
	}
	
	inline function shiftIndex(i:Int):Int {
		return (1 << i);
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	@:computed function get_addAmmoMethod():Ammunition->Void {
		return this.addAmmo != null ? this.addAmmo : this.parentAttr.addAmmo;
	}
	
}


typedef AmmunitionData = {
	var list:Array<Ammunition>;
}

typedef AmmunitionProps = {
	>BaseItemWidgetProps,
	@:prop({required:false}) @:optional var addAmmo:Ammunition->Void;
}
