package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class ButtonPermaPress extends VComponent<NoneT, ButtonPermaPressProps>
{
	public static inline var NAME:String = "ButtonPermaPress";

	public function new() 
	{
		super();
	}
	
	@:computed function get_showLabel():String {
		return label != null ? label : "Activate";
	}
	
	function onClickButton():Void {
		if (!preventDefault) {
			LibUtil.setField(obj, prop, true);
		}
		callback(obj, prop);
	}
	
	override function Template():String {
		return 
		'<div class="button-perma-press">
			<div v-if="description!=null && !obj[prop]">{{description}}</div>
			<div v-if="descriptionDone!=null && obj[prop]">{{descriptionDone}}</div>
			<div><button :disabled="disabled || obj[prop]" v-on:click="onClickButton">{{ showLabel }}</button></div>
		</div>';
	}
	
}

typedef ButtonPermaPressProps = {
	>BaseUIProps,
	@:prop({required:false}) @:optional var description:String;
	@:prop({required:false}) @:optional var descriptionDone:String;
	@:prop({required:false}) @:optional var callback:Dynamic->Dynamic->Void;
	@:prop({required:false, 'default':false}) @:optional var preventDefault:Bool;
}