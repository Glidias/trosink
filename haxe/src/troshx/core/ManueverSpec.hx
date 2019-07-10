package troshx.core;
import troshx.components.FightState.ManueverDeclare;


/**
 * Client side ManueverSpec model data for current manuever consideration
 * @author Glidias
 */
class ManueverSpec 
{
	public var typePreference:Int = 0;
	//public var activeBody:IBodyChar = null;
	public var activeItem:Dynamic = null;
	public var usingLeftLimb:Bool = false;
	public var activeEnemyBody:IBodyChar = null;
	public var activeEnemyZone:Int = -1;
	public var activeEnemyItem:Dynamic = null;
	
	public var replyTo:ManueverDeclare = null;
	
	public function new() 
	{
		
	}
	
}