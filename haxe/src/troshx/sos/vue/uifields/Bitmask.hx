package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import js.html.InputElement;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class Bitmask extends VComponent<NoneT, BitmaskProps>
{

	public static inline var NAME:String = "Bitmask";
	
	public function new() 
	{
		super();
	}
	
	override function Template():String {
		return '<div class="troshx-uifields" :class="{disabled:disabled}">
			<label v-if="label">{{ label }}:&nbsp;</label>
			<div v-for="(li, i) in labels"><label><input type="checkbox" v-on:click="checkboxHandler($$event.target, i)" :checked="(valueAtIndex(i)&current)!=0" :disabled="!(validateOptionFunc == null || validateOptionFunc())"></input>{{ li }}</label></div>
		</div>';
	}
	
	function checkboxHandler(checkbox:InputElement, i:Int):Void {
		if (checkbox.checked) {
			untyped obj[prop] |= valueAtIndex(i);
		}
		else {
			untyped obj[prop] &= ~valueAtIndex(i);
		}
	}
	
	inline function valueAtIndex(i:Int):Int {
		return values != null ? values[i] : (1 << i);
	}
	
	@:computed inline function get_current():Int {
		return LibUtil.field(obj, prop);
	}
}

typedef BitmaskProps = {
	>BaseUIProps,
	@:prop({required:true}) var labels:Array<String>;
	@:prop({required:false}) @:optional var values:Array<Int>;
	@:prop({required:false}) @:optional var validateOptionFunc:Void->Void;
	
}