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


class FightState // represents individual fight state of single combatant
{	
	// riddle stuff here
	public var cp:Int = 0;	// the CP remaining of individual
	public var initiative:Int = 0;  // game-specific flag to track individual initaitives if needed, use as either a boolean or bitmask depending on game needs

	public var dead:Bool = false; // dead marker to faciliate for Bout management/cleanup
	public var flags:Int = 0; // game specific flags goes here for individual fight state
	
	// own character list of declared attack/defensive manuevers
	public var attackManuevers:Array<ManueverDeclare> = [];
	public var defensiveManevers:Array<ManueverDeclare> = [];
	
	// unresolved shock that is accumulated and needs to be resolved by the end of the exchange
	//public var shock:Int = 0;
	// flag to indicate if was attacking on last declared move (game-system specific. use "flags" instead)
	//public var lastAttacking:Bool = false; 
	
	public function new() 
	{
	
	}
	
}