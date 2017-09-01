package troshx.sos.vue.widgets;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import js.html.InputElement;
import troshx.sos.core.Crossbow;
import troshx.sos.vue.widgets.BaseItemWidget.BaseItemWidgetProps;

/**
 * ...
 * @author Glidias
 */
class WSpanTools extends VComponent<WSpanToolsData,BaseItemWidgetProps>
{
	public static inline var NAME:String = "w-span-tools";

	public function new() 
	{
		super();
		
	}
	
	override function Data() {
		return {
			list: SpanningTool.getDefaultList(),
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
	
}

typedef WSpanToolsData = {
	var list:Array<SpanningTool>;
}
