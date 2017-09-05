package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */

class DamageType 
{
	@:abbr("c") public static inline var CUTTING:Int = 0;
	@:abbr("p") public static inline var PIERCING:Int = 1;
	@:abbr("b") public static inline var BLUDGEONING:Int = 2;
	@:abbr("u") public static inline var UNARMED:Int = 3;

	@:abbr("fl") public static inline var FALLING:Int = 4;
	@:abbr("br") public static inline var BURN:Int = 5;
	@:abbr("el") public static inline var ELECTRICAL:Int = 6;
	@:abbr("cl") public static inline var COLD:Int = 7;

	public function new() 
	{
		
	} 
	
	public static inline function isMelee(type:Int):Bool {
		return type < FALLING;
	}
	
	static function getNewFlagVarNames():Array<String> {
		var arr:Array<String> = [];
		Item.pushFlagAbbrToArr(false, false, "troshx.sos.core.DamageType");
		return arr;	
	}
	
	public static var FLAG_VAR_NAMES:Array<String> = null;
	public static function getFlagVarNames():Array<String> {
		return FLAG_VAR_NAMES != null ? FLAG_VAR_NAMES : (FLAG_VAR_NAMES = getNewFlagVarNames());
	}
	
	
	// ---
	
	static function getNewFlagLabels():Array<String> {
		var arr:Array<String> = [];
		Item.pushFlagLabelsToArr(false, "troshx.sos.core.DamageType", true);
		return arr;	
	}
	
	public static var FLAG_LABELS:Array<String> = null;
	public static function getFlagLabels():Array<String> {
		return FLAG_LABELS != null ? FLAG_LABELS : (FLAG_LABELS = getNewFlagLabels());
	}
	

	
	
	
	
}