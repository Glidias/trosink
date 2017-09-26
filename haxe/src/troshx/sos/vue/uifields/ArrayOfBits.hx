package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import haxevx.vuex.native.Vue.CreateElement;
import haxevx.vuex.native.Vue.VNode;
import troshx.sos.vue.uifields.ArrayOf.ArrayOfProps;
import troshx.sos.vue.uifields.SingleBitSelection.SingleBitSelectionProps;
import troshx.util.LibUtil;


/**
 * A bitmask-orietned component represented as an array of bits,
 * implemented as an Higher order component of ArrayOf to compose an array list of SingleBitSelection components instead
 * @author Glidias
 */
class ArrayOfBits extends VComponent<NoneT, ArrayOfBitsProps>
{
	
	public static inline var NAME:String = "ArrayOfBits";

	public function new() 
	{
		super();
		untyped this["inheritAttrs"] = false;
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			"comp" => new ArrayOf()
		];
	}
	
	override function Mounted():Void {
		// yagni atm: if (bitmaskSetObj != null && bitmaskSetProp != null) { }  // adjust bitarray to reflect given bit values
	}
	
	override function Render(c:CreateElement):VNode {
		var props:ChildArrayOfBits = {
			// relavant to ArrayOf:
			obj:this.obj,
			prop:this.prop,
			maxLength: this.maxLength,
			of: SingleBitSelection.NAME,
			defaultValue:0,
			

			
		};
		//trace("REUPDATING WIth new bitmask:" + this.currentBitmask);
		var propsForBitSingle:Dynamic = {
			currentBitmask:this.currentBitmask, 
			bitList:this.currentBitArray,
			labels: this.labels
		};
		
		var otherAttrs = _vAttrs;
		LibUtil.override2ndObjInto(props, otherAttrs);
		
		return c("comp", {props:props, attrs:propsForBitSingle });
	}
	
	
	
	@:computed function get_currentBitmask():Int {
		var arr:Array<Int> = currentBitArray;
		var bits:Int = 0;
		var len:Int = arr.length;
		if (maxLength != null && maxLength < len) {
			len = maxLength;
		}
		for (i in 0...len) {
			bits |= arr[i];
		}
		return bits;
	}
	
	@:watch function watch_currentBitmask(newValue:Int):Void {
		if (bitmaskSetObj != null && bitmaskSetProp != null) {
			LibUtil.setField(bitmaskSetObj, bitmaskSetProp, newValue);
		}
		//trace("Detected new bitmask value.."+newValue);
		
		var arr:Array<Int> = currentBitArray;
		var len:Int = arr.length;
		var bits:Int = 0;
		if (maxLength != null && maxLength < len) {
			len = maxLength;
		}
		for (i in 0...len) {
			if ( (bits & arr[i]) != 0) {  // reset the bits
				Vue.set(arr, i, 0);
				continue;
			}
			bits |= arr[i];
			
		}
	}
	
	@:computed function get_currentBitArray():Array<Int> {
		return LibUtil.field(obj, prop);
	}
	
}

typedef ArrayOfBitsProps =  {
//	@:prop({required:false, 'default':0}) @:optional var minLength:Int;

	// the array
	@:prop({required:true}) var obj:Dynamic;
	@:prop({required:true}) var prop:String; 
	@:prop({required:false}) @:optional var maxLength:Int;

	
	// The single selection
	@:prop({required:true}) var labels:Array<String>;
	
	// SetInto the bitmask obj value holder to be reflected into
	@:prop({required:false}) var bitmaskSetObj:Dynamic;
	@:prop({required:false}) var bitmaskSetProp:String; 
}

typedef ChildArrayOfBits = {
	>ArrayOfProps,
	//>SingleBitSelectionProps,
}
