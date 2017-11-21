package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import js.html.InputElement;
import troshx.sos.core.Weapon;
import troshx.sos.core.Item;
import troshx.util.LibUtil;


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
		var lbl = item.label;
		//var wpn:Weapon = this.weapon;//&& wpn !=null
		return weaponHeldOff != null   ? this.weapon.getLabelHeld(weaponHeldOff) : lbl;
	}
	@:computed function get_weapon():Weapon {
		return LibUtil.as(item, Weapon);
	}
	
	override public function Mounted():Void {
		var inputElem:InputElement = untyped _vEl; // assumption
		inputElem.value = this.item.label;
	}
	
	@:watch function watch_item(newVal:Item):Void {
		var inputElem:InputElement = untyped _vEl; 
		inputElem.value = newVal.label;
		
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
	@:prop({required:false, 'default':null}) @:optional var weaponHeldOff:Bool;
}