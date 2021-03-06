package troshx.sos.core;

/**
 * Special flags and values for Missile weapons
 * @author Glidias
 */
class MissileSpecial 
{

	public var AP:Int = 0;
	public var bleed:Int = 0;
	public var calvaryBow:Int = 0;
	public var flaming:Int = 0;
	public var scatter:Int = 0;
	public var scatter_y:Int = 1;
	public var shock:Int = 0;
	public var winged:Int = 0;
	
	public static inline var BLUDGEON:Int = (1 << 0);
	public static inline var NARROW:Int = (1 << 1);
	public static inline var SHIELD_STICK:Int = (1 << 2);
	public static inline var AP_FIRST_HIT_ONLY:Int = (1 << 3);
	// by default, Sog of Swords has no attachment slots for ranged weapons. This is a cheat for GMs to abjucate forced ranged attachables for their own homebrews.
	public static inline var CHEAT_ATTACHMENT:Int = (1 << 4);  
	
	public static inline var TOTAL_FLAGS:Int = 5;
	
	public var custom:Array<Dynamic> = null;  // gm homebrews if any..
	
	public static function getLabelsOfFlags(instance:MissileSpecial=null, flags:Int=0):Array<String> {	
		var arr:Array<String> = [];
		
		if (flags != 0) {
			Item.pushFlagLabelsToArr(true, "troshx.sos.core.MissileSpecial");
		}
		
		if (instance != null) { 
			Item.pushVarLabelsToArr(true, "troshx.sos.core.MissileSpecial");
		}
		return arr;
	}
	
	
	public static function getFlagVarNames():Array<String> {	
		var arr:Array<String> = [];
		Item.pushFlagLabelsToArr(false, "troshx.sos.core.MissileSpecial");
		return arr;
	}
	
	public static function getFlagVarLabels():Array<String> {	
		var arr:Array<String> = [];
		Item.pushFlagLabelsToArr(false, "troshx.sos.core.MissileSpecial", true);
		return arr;
	}
	
	
	
	public static  function getIntVarNames():Array<String> {	
		var arr:Array<String> = [];
		Item.pushVarLabelsToArr(false, "troshx.sos.core.MissileSpecial");
		return arr;
	}
	
	/*
	public tatic function getVarNameProps():Dynamic<Array<String>> {	
		var hash:Dynamic<Array<String>> = {};
		
		return hash;
	}
	*/
	
	public function new() 
	{
		
	}
	
}