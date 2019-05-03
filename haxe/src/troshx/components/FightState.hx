package troshx.components;

/**
 * Bare bones component state class for FightState per entity common for all TROSLike games
 * @author Glidias
 */

 
typedef ManueverResult = {
	// resolution results information
	@:optional var marginSuccess:Int;
	@:optional var successes:Int;
	
	// anything flag as canceled will be skipped by controller
	@:optional var canceled:Bool;
}

typedef ManueverDeclare = {

	var result:ManueverResult;
	
	// Core stuff
	var reflexScore:Float;	// used by controller for sorting
	
	// manuever declare properties
	var id:String;
	var numDice:Int;
	@:optional var investments:Array<Int>;
	@:optional var tn:Int;
		
	@:optional var from:Int;
	@:optional var to:Int;
	
	@:optional var targetZone:Int;
	@:optional var cost:Int;
	@:optional var replies:ManueverDeclare;
}


class FightState
{	
	// riddle stuff here
	public var initiative:Int = 0;  // initaitive  flag, use as either a boolean or bitmask depending on game needs
	public var cp:Int = 0;	// the CP remaining
	public var shock:Int = 0;	// unresolved shock that is accumulated and needs to be resolved by the end of the exchange
	
	public var reachFlags:Int = 0;  // the reach in relation to opponents
	public var opponents:Int = 0;	// the opponents he is currently facing up against as a mask for the exchange
	public var lastAttacking:Bool = false; // flag to indicate if was attacking on last declared move
	
	// own character reference of declared manuevers for easy manipulation on the fly
	public var attackManuevers:Array<ManueverDeclare>;
	public var defensiveManevers:Array<ManueverDeclare>;
	
	public function new() 
	{
	
	}
	
}