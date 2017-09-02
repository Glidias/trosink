package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import js.html.InputElement;
import troshx.sos.core.Item;


/**
 * ...
 * @author Glidias
 */
class InputName extends VComponent<NoneT, InputNameProps>
{

	public static inline var NAME:String = "input-name";
	
	public function new() 
	{
		super();
	}
	
	inline function emit(str:String):Void {
		_vEmit(str);
	}

	@:computed function get_label():String {
		return item.label;
	}
	
	override public function Mounted():Void {
		var inputElem:InputElement = untyped _vEl; // assumption
		inputElem.value = this.item.label;
	}
	
	function setValidNameOfInput(inputElement:InputElement):Void {
		
		var tarName:String = StringTools.trim( inputElement.value);
		var updated:Bool = false;
		if ( tarName != "" ) {
			item.name = tarName;
			updated = true;
		}
		inputElement.value = label;
		if (updated) emit("updated");
		
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
}


typedef InputNameProps = {
	var item:Item;
}