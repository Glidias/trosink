package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

/**
 * ...
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
		return values != null ? values[i] : i;
	}
	
	override function Template():String {
		return '<div>
			<label v-if="label">{{ label }}</label>:<br/>
			<select v-model="obj[prop]" :disabled="disabled">
				<option v-for="(li, i) in labels" :value="valueAtIndex(i)" :disabled="!(validateOptionFunc == null || validateOptionFunc())">{{ li }}</option> 
			</select>
		</div>';
	}
}

typedef SelectionProps = {
	>BaseUIProps,
	@:prop({required:true}) var labels:Array<String>;
	@:prop({required:false}) @:optional var values:Array<Dynamic>;
	@:prop({required:false}) @:optional var validateOptionFunc:Void->Void;
}