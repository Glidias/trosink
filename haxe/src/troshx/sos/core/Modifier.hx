package troshx.sos.core;


import haxe.macro.Context;
import troshx.sos.core.Modifier.EventModifierBinding;
import troshx.sos.core.Modifier.StaticModifier;
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
	public static inline var MP:Int = 15;
	
	public static inline var CAR_END:Int = 16;
	public static inline var FATIQUE_END:Int = 17;

	// Character generation modifiers
	public static inline var STARTING_WEALTH:Int = 18;
	public static inline var STARTING_MONEY:Int = 19;
	public static inline var STARTING_GRIT:Int = 20;
	
	public static inline var TOTAL_SLOTS:Int = 21;
	
	public static function getStaticModifierSlots():Array<Array<StaticModifier>> {
		var a = [];
		for (i in 0...TOTAL_SLOTS) {
			a[i] = [];
		}
		return a;
	}
	public static function getSituationalModifierSlots():Array<Array<SituationalCharModifier>> {
		var a = [];
		for (i in 0...TOTAL_SLOTS) {
			a[i] = [];
		}
		return a;
	}
	
	// These are context-specific modifiers for per-Manuever context with CharSheet
	//public static inline var MANUEVER_TN:Int = 3;
	//public static inline var MANUEVER_COST:Int = 4;


	public function new() 
	{
		
	}
	
}

class StaticModifier
{
	public var name(default, null):String;
	
	public var multiply:Float;
	public var add:Float;
	public var index(default,null):Int;
	//public var applyMax:Float = 0;
	//public var applyMin:Float = 0;
	public var next:StaticModifier;
	
	public var custom:Bool;
	
	function new() 
	{
		
	}
	public static function create(index:Int, name:String, add:Float, multiply:Float=1):StaticModifier {
		var me = new StaticModifier();
		me.name = name;
		me.index = index;
		me.multiply = multiply;
		me.add = add;
		return me;
	}
	
	public inline function getModifiedValueMultiply(value:Float):Float {
		return value * multiply;
	}
	public inline function getModifiedValueAdd(value:Float):Float {
		return value + add;
	}
}

class SituationalCharModifier 
{
	public var name(get, null):String;
	function get_name():String {
		return this.name;
	}
	
	public var next:SituationalCharModifier;
	public var index(default, null):Int;
	
	function new(index:Int, name:String) 
	{
		this.index = index;
		this.name = name;
	}
	
	
	
	public function getModifiedValueMultiply(char:CharSheet, base:Float, value:Float):Float {
		return value;
	}
	public function getModifiedValueAdd(char:CharSheet, base:Float, value:Float):Float {
		return value;
	}
	
}

/**
 * Situational modifiers that trigger off based off in-game events only.
 * @see troshx.sos.events.SOSEvent for more info
 */
class EventModifierBinding { 
	
	public var name(default, null):String;
	public var types:Array<String>;
	public var handler:SOSEvent->Int;
	
	function new() {
	
	}
	
	public static function create(types:Array<String>, name:String, handler:SOSEvent->Int):EventModifierBinding {
		
		var me = new EventModifierBinding();
		me.types = types;
		me.name = name;
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

