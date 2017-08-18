package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Weapon extends Item
{

	public var reach:Int = 4;
	public var atnSwing:Int = 7;
	public var atnThrust:Int = 7;
	
	public var dtn:Int = 7;
	public var guard:Int = 0;

	public function new(id:String= "", name:String = "" ) 
	{
		super(id, name);
	}
	
	override public function getTypeLabel():String {
		return "Weapon";
	}
	
}