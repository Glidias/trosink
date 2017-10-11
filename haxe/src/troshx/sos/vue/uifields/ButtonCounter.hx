package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class ButtonCounter extends VComponent<NoneT, ButtonCounterProps>
{

	public static inline var NAME:String = "ButtonCounter";
	
	public function new() 
	{
		super();
	}
	
	@:computed function get_showLabel():String {
		return label != null ? label : "Add";
	}
	
	function onClickButton():Void {
		if (!preventDefault) {
			LibUtil.setField(obj, prop, LibUtil.field(obj, prop) + 1);
		}
		callback(obj, prop);
	}
	
	override function Template():String {
		return '<div class="button-counter-press"><button :disabled="disabled" v-on:click="onClickButton">{{ showLabel }}</button><span class="colon">:</span> <span class="num">{{obj[prop]}}</span></div>';
	}
	
}

typedef ButtonCounterProps = {
	>BaseUIProps,
	@:prop({required:false}) @:optional var callback:Dynamic->Dynamic->Void;
	@:prop({required:false, 'default':false}) @:optional var preventDefault:Bool;
}