package troshx.core;


/**
 * Client side ManueverSpec model data for current manuever consideration
 * @author Glidias
 */
class ManueverSpec 
{
	public var typePreference:Int = 0;
	public var activeItem:Dynamic = null;
	public var usingOffhand:Bool = false;
	public var activeEnemyBody:IBodyChar = null;
	public var activeEnemyZone:Int = -1;
	public var activeEnemyItem:Dynamic = null;
	
	public function new() 
	{
		
	}
	
}