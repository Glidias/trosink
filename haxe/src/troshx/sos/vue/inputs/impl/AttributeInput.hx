package troshx.sos.vue.inputs.impl;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.chargen.CharGenData;
import troshx.sos.vue.inputs.NumericInput.NumericInputProps;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class AttributeInput extends VComponent<NoneT, AttributeInputProps>
{
	public static inline var NAME:String = "AttributeInput";

	// -- standard boilerplate
	public function new() 
	{
		super();
		untyped this.mixins = [NumericInput.getSampleInstance()];
	}
	
	// customisation
	
	@:computed inline function get_bareMinAttribute():Int {
		return !magic ? 1 : 0;
	}
	
	@:computed inline function get_current():Int {
		return LibUtil.field(obj, prop);
	}
	
	@:computed function get_valid():Bool {
		return this.current + this.racialModifier >= this.bareMinAttribute;
	}

	@:computed inline function get_min():Int {
		return 	magic ? 0 : 1;
	}
	@:computed function get_max():Int {
		var r = Std.int( Math.min(current + CharGenData.MaxAttributeLevelUpsFrom(current, this.remainingAttributePoints), CharGenData.ATTRIBUTE_START_MAX) );
		var b = min;
		return r >= b ? r : b;
	}
	
}

typedef AttributeInputProps = {
	>NumericInputProps,
	@:prop({required:true}) var remainingAttributePoints:Int;
	@:prop({required:false, 'default':false}) var magic:Bool;
	@:prop({required:false, 'default':0}) var racialModifier:Int;
}