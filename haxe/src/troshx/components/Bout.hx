package troshx.components;


/**
 * Stuff typical to all TROS bouts
 * @author Glidias
 */
class Bout<C>
{

	// for internal use for any game controller if needed
	public var c:Int = 0;
	public var s:Int = 0;
	//
	public var combatants:List<FightNode<C>> = new List<FightNode<C>>();
	
	// The standard tros convention of rounds and half tempos
	public var secondTempo:Bool = false;
	public var roundCount:Int = 0;
	
	public static inline var STEP_NEXT:Int = 0;
	public static inline var STEP_NEW_CYCLE:Int = 1;
	public static inline var STEP_NEW_ROUND:Int = 2;
	
	public function new() 
	{
		
	}
	
	public inline function step(stepAction:Int):Void {
		if (stepAction == STEP_NEXT) {
			s++;
		}
		else if (stepAction == STEP_NEW_CYCLE) {
			s = 0;
			c++;
		} else if (stepAction == STEP_NEW_ROUND) {
			s = 0;
			c = 0;
			roundCount++;
		}
	}
	
}

// if using Ash framework, will extend from Ash's Node class
class FightNode<C> { 
	public var fight:FightState;
	public var charSheet:C;
	public var sideIndex:Int;
}