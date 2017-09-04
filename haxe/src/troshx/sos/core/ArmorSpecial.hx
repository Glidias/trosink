package troshx.sos.core;
import troshx.sos.core.ArmorSpecial.Layering;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class ArmorSpecial 
{
	
	public static inline var HARD:Int = (1 << 0);
	public static inline var MAIL:Int = (1 << 1);
	public static inline var TEXTILE:Int = (1 << 2);
	public static inline var BULLETPROOF:Int = (1 << 3);
	
	@:flag public var restrictsBreathing:Int = 0;
	
	public var layerings:Dynamic<Layering> = null;
	
	public var disableAVMask:Int = 0;
	
	
	// TODO:
	// layerings (number, and coverage)
	// no AV vs attack direction masks
	
	// modifier avs multiplier on attack direction
	// modifier avs on adder on  attack direction
	// above *2 for part
	
	public function new() 
	{
		
	}
	
	/*
	public static function getAVWithFlags(flags:Int, av:Int):Int {
		
	}
	*/
	
	public function addTagsToStrArr(arr:Array<String>) 
	{
		var instance:ArmorSpecial = this;
		Item.pushVarLabelsToArr(true, "troshx.sos.core.ArmorSpecial", ":flag");
		
		if (layerings != null) {
			for (f in Reflect.fields(layerings)) {
				var layering = LibUtil.field(layerings, f);
			
				if (layering.value > 0) {
					
				}
				
				//arr.push( layering.coverage );
			}		
		}

	}
	
}

class Layering {
	
	public var value:Int = 0;
	public var coverage:Dynamic<HitLocation> = null;
	
	public function new() {
		
	}
}

class HitLocationModifiers {
	public function new() {
		
	}
}

