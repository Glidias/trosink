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
			<select v-model="obj[prop]">
				<option v-for="(li, i) in labels" :value="valueAtIndex(i)">{{ li }}</option> 
			</select>
		</div>';
	}
}

typedef SelectionProps = {
	>BaseUIProps,
	@:prop({required:true}) var labels:Array<String>;
	@:prop({required:false}) @:optional var values:Array<Dynamic>;
}