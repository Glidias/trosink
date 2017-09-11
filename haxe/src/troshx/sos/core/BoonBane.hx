package troshx.sos.core;
import troshx.sos.sheets.CharSheet;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.Modifier.EventModifierBinding;
import troshx.sos.core.Modifier.SituationalCharModifier;
import troshx.sos.core.Modifier.StaticModifier;

/**
 * A Boon or Bane for the purpose of recording in Character sheet
 * @author Glidias
 */
class BoonBane 
{
	public var isBane(default,null):Bool;
	public var name(default, null):String;
	public var flags(default, null):Int;
	public var clampRank(default, null):Bool;
	public var costs(default, null):Array<Int>;
	public var multipleTimes(default, null):Int;
	public var channels(default, null):Int;

	// these modifiers are for returning a specific value for hardcoded cases
	public var staticModifiers(default, null):Array<StaticModifier>;
	public var situationalModifiers(default, null):Array<SituationalCharModifier>;
	
	// these modifiers are only triggered upon events
	public var eventBasedModifiers:Array<EventModifierBinding>;
	
	public var conditions(default, null):Array<CharSheet->Int->Bool>;
	
	@:channel public static inline var __GOOD_EYES__BAD_EYES:Int = (1 << 0);
	@:channel public static inline var __GOOD_EARS_BAD_EARS:Int = (1 << 1);
	@:channel public static inline var __GOOD_EARS_BAD_NOSE:Int = (1 << 2);
	@:channel public static inline var __RICH__POOR:Int = (1 << 3);
	@:channel public static inline var __TRUE_GRIT:Int = (1 << 4);
	@:channel public static inline var __ROBUST_FRAIL:Int = (1 << 5);
	@:channel public static inline var __BLIND__ONE_EYED_BANE:Int = (1 << 6);
	@:channel public static inline var __CRAVEN__HONORABLE:Int = (1 << 7);
	@:channel public static inline var __SHELTERED:Int = (1 << 8);
	@:channel public static inline var __HONORABLE__COMPLETE_MONSTER:Int = (1 << 9);
	@:channel public static inline var __TALL__SHORT:Int = (1 << 10);
	
	@:flag public static inline var CHARACTER_CREATION_ONLY:Int = (1 << 0);
	@:flag public static inline var CANNOT_BE_REMOVED:Int = (1 << 1);
	
	public inline function isAvailableCharaterCreation():Bool {
		return this.costs != null;
	}
	
	public static inline var TIMES_INFINITE:Int = -1;
	public static inline var TIMES_VARYING:Int = -2;
	
	public var uid(default, never):String;
	inline function get_uid():String 
	{
		return name;
	}
	
	public function new(name:String, costs:Array<Int>) 
	{
		this.name = name;
		this.costs = costs;
		this.flags = 0;
		this.clampRank = false;
		this.multipleTimes = 0;
	}
	
	
	
}

class Boon extends BoonBane {
	public function new(name:String, costs:Array<Int>) {
		super(name, costs);
	}
	
	function getEmptyAssignInstance(char:CharSheet):BoonAssign {
		return new BoonAssign();
	}
	
	public function getAssign(boon:Boon, rank:Int, char:CharSheet):BoonAssign {
		var me:BoonAssign = getEmptyAssignInstance(char);
		me.boon = boon;
		me.rank = rank;
		//if ( boon.costs != null) me._costCached = boon.costs[(rank >= 1 ? rank - 1 : 0];  // for reference only
		return me;
	}
}


class Bane extends BoonBane {
	public function new(name:String, costs:Array<Int>) {
		super(name, costs);
		isBane = true;
	}
	
	function getEmptyAssignInstance(char:CharSheet):BaneAssign {
		return new BaneAssign();
	}
	
	public function getAssign(bane:Bane, rank:Int, char:CharSheet):BaneAssign {
		var me:BaneAssign =  getEmptyAssignInstance(char);
		me.bane = bane;
		me.rank = rank;
		//if ( bane.costs != null) me._costCached = boon.costs[(rank >= 1 ? rank - 1 : 0]; // for reference only
		return me;
	}
}


// -------

class BoonBaneAssign
{
	public var rank:Int;
	//public var qty:Int;
	
	public var _costCached:Int;  // used internally by engine to calculate cached costs of boons/banes. Do not touch!

	public var situationalModifiers(default, null):Array<SituationalCharModifier>;
	public var eventBasedModifiers:Array<EventModifierBinding>;
	
	// ingame only
	public function onFurtherAdded(char:CharSheet):Void {
		
	}
	public function onRemoved(char:CharSheet):Void {
		
	}
	public function onInited(char:CharSheet):Void {
		
	}
	
	public function getQty():Int {	// override this to reflect a different qty depending on Boon/Bane situation.
		return 1;
	}
	
	public inline function getCosting(bb:BoonBane):Int {
		return bb.costs[rank-1];  // assumed assigned rank is always > 0, else this method should NOT be called
	}
	
	public function isValid():Bool {	// mainly used as validation check for Character creation forms
		return true;
	}

}

class BoonAssign extends BoonBaneAssign
{
	public var boon:Boon;
	
	public function new() {
		
	}
	
	public function getCost():Int {
		return getCosting(boon);
	}
	public inline function getBaseCost():Int {
		return getCosting(boon);
	}
	
}

class BaneAssign extends BoonBaneAssign
{

	public var bane:Bane;
	
	public function new() {
		
	}
	
	public function getCost():Int {
		return getCosting(bane);
	}
	public inline function getBaseCost():Int {
		return getCosting(bane);
	}
	
}