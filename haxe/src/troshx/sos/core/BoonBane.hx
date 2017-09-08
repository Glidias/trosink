package troshx.sos.core;
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
	public var flags(default,null):Int;
	public var costs(default, null):Array<Int>;
	public var multipleTimes(default, null):Int;
	public var channels(default, null):Int;
	
	// these modifiers are for returning a specific value for hardcoded cases
	public var staticModifiers(default, null):Array<StaticModifier>;
	public var situationalModifiers(default, null):Array<SituationalCharModifier>;
	
	// these modifiers are only triggered upon events
	public var eventBasedModifiers:Array<EventModifierBinding>;
	
	@:channel public static inline var __GOOD_EYES__BAD_EYES:Int = (1 << 0);
	@:channel public static inline var __RICH__POOR:Int = (1 << 1);
	
	@:flag public static inline var CHARACTER_CREATION_ONLY:Int = (1 << 0);
	@:flag public static inline var CANNOT_BE_REMOVED:Int = (1 << 1);
	
	
	inline function get_uid():String 
	{
		return name;
	}
	
	public function new(name:String, costs:Array<Int>) 
	{
		this.name = name;
		this.costs = costs;
		this.flags = 0;
		this.multipleTimes = 0;
	}
	
}

class Boon extends BoonBane {
	public function new(name:String, costs:Array<Int>) {
		super(name, costs);
	}
	
	function getEmptyAssignInstance():BoonAssign {
		return new BoonAssign();
	}
	
	public function getAssign(boon:Boon, rank:Int, qty:Int):BoonAssign {
		var me:BoonAssign = getEmptyAssignInstance();
		me.boon = boon;
		me.rank = rank;
		me.qty = qty;
		return me;
	}
}


class Bane extends BoonBane {
	public function new(name:String, costs:Array<Int>) {
		super(name, costs);
		isBane = true;
	}
	
	function getEmptyAssignInstance():BaneAssign {
		return new BaneAssign();
	}
	
	public function getAssign(bane:Bane, rank:Int, qty:Int ):BaneAssign {
		var me:BaneAssign =  getEmptyAssignInstance();
		me.bane = bane;
		me.rank = rank;
		me.qty = qty;
		return me;
	}
}


// -------

class BoonBaneAssign
{
	public var rank:Int;
	public var qty:Int;

}

class BoonAssign extends BoonBaneAssign
{
	public var boon:Boon;
	
	public function new() {
		
	}
	
}

class BaneAssign extends BoonBaneAssign
{

	public var bane:Bane;
	
	public function new() {
		
	}
	
}