package troshx.components;
import troshx.core.ICharacterSheet;

/**
 * ...
 * @author Glidias
 */
class Bout
{

	public var state:FightState = new FightState();
	public var combatants:List<FightNode> = new List<FightNode>();
	
	public function new() 
	{
		
	}
	
}

// if using Ash framework, will extend from Ash's Node class
class FightNode { 
	public var fight:FightState;
	public var charSheet:ICharacterSheet;
}