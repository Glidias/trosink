package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

/**
 * A SingleSelection of numeric values, integers prefered by default (warning, the name of this is misleading, but it's implied this only supports numeric values)
 * @author Glidias
 */
class SingleSelection extends VComponent<NoneT, SelectionProps>
{
	
	public static inline var NAME:String = "SingleSelection";
	

	public function new() 
	{
		super();
	}
	
	inline function valueAtIndex(i:Int):Int {
		return values != null ? values[i] : valueAtIndexFunc!= null ? valueAtIndexFunc(i) : i;
	}
	
	override function Template():String {
		return '<div :style="{pointerEvents:readonly ? \'none\' : \'auto\'}">
			<span v-if="label"><label>{{ label }}</label>:<br/></span>
			<select number v-model.number="obj[prop]" :disabled="disabled">
				<option v-if="includeZeroOption" :value="0">{{ zeroValueLabel }}</option> 
				<option v-for="(li, i) in labels" :value="valueAtIndex(i)" :disabled="!(validateOptionFunc == null || validateOptionFunc(i))">{{ li }}</option> 
			</select>
		</div>';
	}
}

typedef SelectionProps = {
	>BaseUIProps,
	@:prop({required:true}) var labels:Array<String>;
	@:prop({required:false}) @:optional var values:Array<Dynamic>;
	@:prop({required:false}) @:optional var validateOptionFunc:Int->Void;
	@:prop({required:false}) @:optional var valueAtIndexFunc:Int->Int;
	@:prop({required:false, 'default':""}) @:optional var zeroValueLabel:String;
	@:prop({required:false, 'default':false}) @:optional var includeZeroOption:Bool;
}