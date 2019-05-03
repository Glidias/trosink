package troshx.components;


/**
 * ...
 * @author Glidias
 */
class Bout<C>
{

	public var r:Int = 0;
	public var s:Int = 0;
	public var combatants:List<FightNode<C>> = new List<FightNode<C>>();
	
	public function new() 
	{
		
	}
	
	public function step(newRound:Bool):Void {
		
	}
	
}

// if using Ash framework, will extend from Ash's Node class
class FightNode<C> { 
	public var fight:FightState;
	public var charSheet:C;
}