package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class ArrayOf extends VComponent<NoneT, ArrayOfProps>
{

	public static inline var NAME:String = "ArrayOf";
	static var COMPONENTS:Dynamic;
	
	public function new() 
	{
		super();
	}
	
	/*
	override public function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return COMPONENTS != null ? COMPONENTS : (COMPONENTS = UI.getNewSetOfComponents(true));
	}
	*/
	
	override public function Template():String {
		return '<div>
		<label v-if="label">{{label}}</label>
		<ul>
			<li v-for="(li, i) in current">
				<div :is="typeMap[of]" :obj="li"></div>
			</li>
		</ul>
		<button v-if="current.length > minLength" v-on:click="popEntry()">-</button>
		<button v-if="maxLength != null && current.length + 1 < maxLength" v-on:click="pushEntry()">+</button>
		</div>';
	}

	function pushEntry():Void {
		var arr = current;
		var defValue:Dynamic = defaultValue;
		
		var valueToUse:Dynamic;
		// push what? need to inspect type...
		if (Reflect.isFunction(defValue)) {
			// invoke
			valueToUse = defValue();
		}
		else if (Std.is(defValue, Array)) {
			trace("Warning, nested array not supported");
			valueToUse = defValue.concat([]);
		}
		else {
			var tt = Type.typeof(defValue);
			switch( tt ) {
				case TClass(c):
					valueToUse = Type.createInstance(c, []); // warning: assumed class can be instantaited with no constructor parameters
				default:
					valueToUse = defValue;
			}
		}
		
		arr.push(valueToUse);
	}
	
	function popEntry():Void {
		current.pop();
	}
	
	@:computed inline function get_current():Array<Dynamic> {
		return LibUtil.field(obj, prop);
	}
	
	@:computed function get_typeMap():Dynamic<String> {
		return UI.getTypeMapToComponentNames();
	}
	
}

typedef ArrayOfProps = {
	>BaseUIProps,
	@:prop({required:true}) var of:String;
	@:prop({required:true}) var defaultValue:Dynamic;
	
	@:prop({required:false, 'default':0}) var minLength:Int;
	@:prop({required:false}) var maxLength:Int;
	
}