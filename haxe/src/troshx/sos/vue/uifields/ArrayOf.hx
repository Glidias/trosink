package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.core.IUid;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class ArrayOf extends VComponent<ArrayOfData, ArrayOfProps>
{

	public static inline var NAME:String = "ArrayOf";
	static var COMPONENTS:Dynamic;
	
	public function new() 
	{
		super();
		untyped this["inheritAttrs"] = false;
	}
	
	override function Data():ArrayOfData {
		return {
			selectedIndex:-1,
		};
	}
	
	function getKey(obj:Dynamic, i:Int):Dynamic {
		var castToIder = LibUtil.as(obj, IUid);

		return  castToIder != null ? castToIder.uid : LibUtil.field(obj, "uid") != null ?  LibUtil.field(obj, "uid") : i;
	}
	
//	/*
	override public function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return COMPONENTS != null ? COMPONENTS : (COMPONENTS = UI.getNewSetOfComponents(true));
	}
	//*/
	
	override public function Template():String {
		return '<div>
		<label v-if="label!=null">{{label}}:&nbsp;| {{maxLength}}</label><label v-if="label==null && maxLength!=null">| {{maxLength}} </label><button v-show="!readonly" :disabled="!(maxLength == null || current.length + 1 <= maxLength)" v-on:click="pushEntry()">+</button> &nbsp;<button  v-show="!readonly" :disabled="!(current.length > (minLength != null ? minLength : 0))" v-on:click="popEntry()">-</button> &nbsp;<button v-on:click="clearSelect" v-show="selectedIndex>=0">No-Select</button>
		<ul class="array-of" style="list-style-type:none">
			<li v-for="(li, i) in current" :class="{disabled:!(maxLength == null || i < maxLength)}" :key="getKey(li, i)">
				<input type="radio" v-on:click="selectedIndex=i" :checked="selectedIndex==i"></input>
				<span :is="typeMap[of]" v-bind="$$attrs" :index="i" :readonly="readonly" :obj="current" :prop="i" :class="{disabled:!(maxLength == null || i < maxLength)}" :disabled="!(maxLength == null || i < maxLength)"></span>
			</li>
		</ul>
		
		</div>';
	}
	
	function clearSelect():Void {
		this.selectedIndex = -1;
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
		
		if (this.selectedIndex < -1) arr.push(valueToUse);
		else arr.insert(this.selectedIndex, valueToUse);
	}
	
	@:watch function watch_maxLength(newValue:Int, oldValue:Int):Void {
		if (autoExpand && newValue > oldValue) {
			while (--newValue >= oldValue) {
				pushEntry();
			}
		}
	}
	
	function popEntry():Void {
		if (this.selectedIndex < 0) current.pop();
		else current.splice(this.selectedIndex, 1);
	}
	
	@:computed inline function get_current():Array<Dynamic> {
		return LibUtil.field(obj, prop);
	}
	
	@:computed function get_typeMap():Dynamic<String> {
		return UI.getTypeMapToComponentNames();
	}
	
	@:computed function get_arrayLength():Int {
		return this.current.length;
	}
	@:watch function watch_arrayLength(newVal:Int, oldVal:Int):Void {
		if (newVal <= this.selectedIndex) {
			this.selectedIndex = newVal - 1;
		}
	}
	
	
}

typedef ArrayOfProps = {
	>BaseUIProps,
	@:prop({required:true}) var of:String;
	@:prop({required:true}) var defaultValue:Dynamic;
	
	@:prop({required:false, 'default':0}) @:optional var minLength:Int;
	@:prop({required:false}) @:optional var maxLength:Int;
	
	@:prop({required:false, 'default':false}) @:optional var autoExpand:Bool;
	@:prop({required:false, 'default':false}) @:optional var readonly:Bool;
	
}

typedef ArrayOfData = {
	var selectedIndex:Int;
}