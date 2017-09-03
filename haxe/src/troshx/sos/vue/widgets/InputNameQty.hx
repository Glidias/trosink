package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import js.html.InputElement;
import troshx.sos.core.Item;
import troshx.sos.core.ItemQty;


/**
 * ...
 * @author Glidias
 */
class InputNameQty extends VComponent<NoneT, InputNameQtyProps>
{

	public static inline var NAME:String = "input-name-qty";
	
	public function new() 
	{
		super();
	}
	
	inline function emit(str:String):Void {
		_vEmit(str);
	}

	@:computed function get_label():String {
		return this.itemQty.label;
	}
	
	override public function Mounted():Void {
		var inputElem:InputElement = untyped _vEl; // assumption
		inputElem.value = this.itemQty.item.label;
	}
	
	function setValidNameOfInput(inputElement:InputElement):Void {
		
		var tarName:String = StringTools.trim( inputElement.value);
		var updated:Bool = false;
		if ( tarName != "" ) {
			this.itemQty.item.name = tarName;
			updated = true;
		}
		inputElement.value = label;
		if (updated) emit("updated");
		
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
}


typedef InputNameQtyProps = {
	var itemQty:ItemQty;
}