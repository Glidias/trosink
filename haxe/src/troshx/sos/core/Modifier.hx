package troshx.sos.core;


import haxe.macro.Context;
import troshx.sos.core.Modifier.EventModifierBinding;
import troshx.sos.events.SOSEvent;
import troshx.sos.sheets.CharSheet;


#if macro
import haxe.macro.Expr;
#end

/**
 * Some basic modifier conventions are defined here.
 * @author Glidias
 */
class Modifier  
{
	
	// Static and Situaional CharSheet-only hard context modifiers
	public static inline var ATTR_STR:Int = 0;
	public static inline var ATTR_AGI:Int = 1;
	public static inline var ATTR_END:Int = 2;
	public static inline var ATTR_HLT:Int = 3;
	public static inline var ATTR_WIL:Int = 4;
	public static inline var ATTR_WIT:Int = 5;
	public static inline var ATTR_INT:Int = 6;
	public static inline var ATTR_PER:Int = 7;
	
	public static inline var CMP_ADR:Int = 8;
	public static inline var CMP_MOB:Int = 9;
	public static inline var CMP_CAR:Int = 10;
	public static inline var CMP_CHA:Int = 11;
	public static inline var CMP_TOU:Int = 12;
	
	public static inline var CP:Int = 13;
	public static inline var REACH:Int = 14;
	
	// Character generation modifiers
	public static inline var STARTING_WEALTH:Int = 15;
	public static inline var STARTING_MONEY:Int = 16;
	public static inline var STARTING_GRIT:Int = 17;
	
	
	// These are context-specific modifiers for per-Manuever context with CharSheet
	//public static inline var MANUEVER_TN:Int = 3;
	//public static inline var MANUEVER_COST:Int = 4;


	public function new() 
	{
		
	}
	
}

class StaticModifier
{
	
	public var multiply:Float = 1;
	public var add:Float = 0;
	//public var applyMax:Float = 0;
	//public var applyMin:Float = 0;

	
	public function new() 
	{
		
	}
	
	public inline function getModifiedValue(value:Int):Float {
		return value * multiply + add;
	}
}

class SituationalCharModifier 
{

	public function new() 
	{
		
	}
	public function getModifiedValue(char:CharSheet, value:Int):Int {
		return value;
	}
	
}

/**
 * Situational modifiers that trigger off based off in-game events only.
 * @see troshx.sos.events.SOSEvent for more info
 */
class EventModifierBinding { 
	
	public var types:Array<String>;
	public var handler:SOSEvent->Int;
	
	function new() {
	
	}
	
	public static function create(types:Array<String>, handler:SOSEvent->Int):EventModifierBinding {
		
		var me = new EventModifierBinding();
		me.types = types;
		me.handler = handler;
		return me;
	}

	public static macro function build( exprHandler:Expr):Expr {
		
		//trace( Context.getLocalClass().get().fields.get()[0]. );
		//trace(exprType);
		// fields prefixed with _e_ are assumed to be relating to handler method names and watched signal names
		// where _MAPPINGS_ is simply  a generated static inline var _e_exprHandlerName:Array<String> = [...];
		return macro {EventModifierBinding.create(_MAPPINGS_, ${exprHandler});  };
	
		//this.handler = handler;
	}

	
}

