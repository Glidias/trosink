package troshx.sos.events;
import troshx.ds.ValueHolder;
import troshx.sos.core.Skill;
import troshx.sos.sheets.CharSheet;

/**
 * 
 * @author Glidias
 */
class Challenge 
{
	// Details
	public var contestingChars:Array<CharSheet>; // REQUIRED: ALL contestng characters, thus, may also include the initiatingChar (if any) within the set...
	public var rs:Int;  // base RS of challenge
	public var tn:Int;  // base TN of challenge
	public var description:String;  // (optional) short description of challenge
	
	public var initiatingChar:CharSheet; // any character that was involved in initaiting the challenge (if any..)
	public var pluralInitiatingChars:Array<CharSheet>; // any combining initiating charas involved
	
	// Executions
	public var rolls:Array<ChallengeRoll> = null;  // (optional) any roll specs for each character prior to being rolled
	
	// Results
	public var totalSuccesses:Array<Int> = null;  // total rolled successes  for contesting chars
	
	public inline function isResolved():Bool {
		return  totalSuccesses!=null;
	}

	public function new() 
	{
		
	}
	
}

typedef ChallengeRoll = {
	var skill:Skill;  // any skill used if any
	var attribute:Int; // any attribute used, if any.
	var numDice:Int;
	
	//var preRolledSuccesses:Int; // optional...may be used for turn-based rolls instead of simulatenous rolls for challenge
}