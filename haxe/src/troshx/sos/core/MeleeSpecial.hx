package troshx.sos.core;


/**
 * Special flags and values for Melee weapons
 * @author Glidias
 */
class MeleeSpecial 
{
	// by string convention, imply label from property name's camel case.
	public var APSwing:Int = 0;
	public var APThrust:Int = 0;
	public var bleed:Int = 0;
	public var chain:Int = 0;
	public var crushing:Int = 0;
	public var draw:Int = 0;
	
	public var multiHit:Int = 0;
	public var multiHit_Y:Int = 0;
	
	public var shock:Int = 0;
	public var spatulateTip:Int = 0;
	
	// by string convention, imply label from static property name's underscore case.
	public static inline var BRACE:Int = (1 << 0);
	public static inline var CALVARY_SWORD:Int = (1 << 1);
	public static inline var COMPANION_WEAPON:Int = (1 << 2);
	public static inline var COUCHED_CHARGE:Int = (1 << 3);
	public static inline var FLUID_THRUSTS:Int = (1 << 4);
	
	public static inline var FORWARD_SWEPT:Int = (1 << 5);
	public static inline var FREAKISHLY_LARGE:Int = (1 << 6);
	public static inline var HAND_OFF:Int = (1 << 7);
	public static inline var HEAVY_WEAPON:Int = (1 << 8);
	public static inline var HOOK:Int = (1 << 9);
	public static inline var LIGHT_BLADE:Int = (1 << 10);
	public static inline var PARRYING_TEETH:Int = (1 << 11);
	public static inline var SWINGING_SLOT:Int = (1 << 12);
	
	
	public static inline var TOTAL_FLAGS:Int = 13;
	
	public var custom:Array<Dynamic> = null;  // gm homebrews if any..
	
	public static function getLabelsOfFlags(instance:MeleeSpecial=null, flags:Int=0):Array<String> {	
		var arr:Array<String> = [];
		
		if (flags != 0) {
			Item.pushFlagLabelsToArr();
		}
		
		if (instance != null) { 
			Item.pushVarLabelsToArr();
		}
		return arr;
	}
	
	
	public static function getFlagVarNames():Array<String> {	
		var arr:Array<String> = [];
		Item.pushFlagLabelsToArr(false);
		return arr;
	}
	
	public function getIntVarNames():Array<String> {	
		var arr:Array<String> = [];
		Item.pushVarLabelsToArr(false);
		return arr;
	}
	
	public function getVarNameProps():Dynamic<Array<String>> {	
		var hash:Dynamic<Array<String>> = {};
		
		return hash;
	}
	
	
	public function new() 
	{
		
	}
	
}