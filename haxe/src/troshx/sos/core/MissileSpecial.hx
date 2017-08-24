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
	
	public static inline var TOTAL_FLAGS:Int = 3;
	
	public var custom:Array<Dynamic> = null;  // gm homebrews if any..
	
	public static function getLabelsOfFlags(instance:MissileSpecial=null, flags:Int=0):Array<String> {	
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