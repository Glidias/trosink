package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

/**
 * Single selection component of basic String
 * @author Glidias
 */
class SingleSelectionStr extends VComponent<NoneT, SingleSelectionStrProps>
{
	
	public static inline var NAME:String = "SingleSelectionStr";
	

	public function new() 
	{
		super();
	}
	
	inline function valueAtIndex(i:Int):Int {
		return values != null ? values[i] : labels[i];
	}
	

	override function Template():String {
		return '<div>
			<span v-if="label"><label>{{ label }}</label>:<br/></span>
			<select v-model="obj[prop]" :disabled="disabled">
				<option v-for="(li, i) in labels" :value="valueAtIndex(i)" :disabled="!(validateOptionFunc == null || validateOptionFunc(i))">{{ li }}</option> 
			</select>
		</div>';
	}
}

typedef SingleSelectionStrProps = {
	>BaseUIProps,
	@:prop({required:true}) var labels:Array<String>;
	@:prop({required:false}) var values:Array<String>;
	@:prop({required:false}) @:optional var validateOptionFunc:Int->Void;
}