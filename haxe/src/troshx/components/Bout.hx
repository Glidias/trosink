package troshx.components;


/**
 * ...
 * @author Glidias
 */
class Bout<C>
{

	public var state:FightState = new FightState();
	public var combatants:List<FightNode<C>> = new List<FightNode<C>>();
	
	public function new() 
	{
		
	}
	
}

// if using Ash framework, will extend from Ash's Node class
class FightNode<C> { 
	public var fight:FightState;
	public var charSheet:C;
}