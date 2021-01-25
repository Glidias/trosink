package troshx.core;
import troshx.components.Bout.FightNode;
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
	
	public static inline var NO_ZONE:Int = -1;
	public static inline var LEFT_HAND_ZONE:Int = -2;
	public static inline var RIGHT_HAND_ZONE:Int = -3;
	

	public function reset():Void {
		typePreference = 0;
		usingLeftLimb  = false;
		activeItem = null;
		//activeEnemy = null;
		activeEnemyItem = null;
		activeEnemyBody = null;
		activeEnemyZone = -1;
	}
	public function setNewEnemy(body:IBodyChar):Void {
		activeEnemyZone = -1;
		activeEnemyBody = body;
		activeEnemyItem = null;
		//activeEnemy = e;
	}
	
	
	public function new() 
	{
		
	}
	
}