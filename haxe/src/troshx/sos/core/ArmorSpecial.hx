package troshx.sos.core;
import troshx.sos.core.ArmorSpecial.HitModifiers;
import troshx.sos.core.ArmorSpecial.Layering;
import troshx.util.LibUtil;

/**
 * ArmorSpecial is a BodyChar specific entity. 
 * @author Glidias
 */
class ArmorSpecial 
{
	public static inline var HARD:Int = (1 << 0);
	public static inline var MAIL:Int = (1 << 1);
	public static inline var TEXTILE:Int = (1 << 2);
	public static inline var BULLETPROOF:Int = (1 << 3);
	public static inline var MOVABLE:Int = (1 << 4);
	
	@:flag public var restrictsBreathing:Int = 0;
	
	public var layer:Layering = null;
	
	public var modifiers:Array<HitModifiers> = null;
	
	// is this armor restricted to another body type or is default?
	// Changing this property will require imperative update/re-mapping of any modifiers/layers under this class
	// and possibly udner the parent Armor class as well if IntIntHash is used for coverage
	public var otherBodyType:BodyChar = null; 

	
	public function new() 
	{
		
	}
	
	public function addTagsToStrArr(arr:Array<String>) 
	{
		var instance:ArmorSpecial = this;
		
		var bodyChar:BodyChar = otherBodyType != null ? otherBodyType : BodyChar.getInstance();
		if (otherBodyType != null) {
			arr.push("For Body Type: "+bodyChar.name);
		}
		
		Item.pushVarLabelsToArr(true, "troshx.sos.core.ArmorSpecial", ":flag");
		
		/*
		if (layerings != null) {
			for (i in 0...layerings.length) {
				var layering = layerings[i];
				//if (layering.value > 0) {
				layering.addTagsToStrArr(arr, bodyChar);
				//}
			}		
		}
		*/
		if (layer != null) {
			layer.addTagsToStrArr(arr, bodyChar);
		}
		
		if (modifiers != null) {
			for (i in 0...modifiers.length) {
				var modifier = modifiers[i];
				modifier.addTagsToStrArr(arr, bodyChar);
			}
		}

	}
	
}

class Layering {
	
	public var value:Int = 1;
	
	// when this is set, it must imperatively mask& with it's parent armor's coverage
	// for the sake of sanity..
	public var coverage:Int = 0;  
	
	public function new() {
		
	}
	
	inline public function addTagsToStrArr(arr:Array<String>, bodyChar:BodyChar)  {
		if (coverage != 0) {
			var myArr:Array<String> = [];
			bodyChar.pushHitLocationNamesToStrArrByMask(arr, coverage);	
			arr.push( 'Layers ${value} ("+${myArr.join(", ")}+")' );
		}
		else {
			arr.push('Layer ${value}');
		}
	}
}

class HitModifiers {
	
	public var locationMask:Int = 0;
	public var targetZoneMask:Int = 0;
	public var multiplyAV:Float = 1;
	public var addAV:Int = 0;
	
	public function new() {
		
	}
	
	inline public function addTagsToStrArr(arr:Array<String>, bodyChar:BodyChar)  {
	
		
	}
}

