package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Shield extends Item
{
	public var AV:Int = 1;
	public var block:Int = 7;
	public var coverage:Dynamic<HitLocation> = {};

	

	public function new() 
	{
		super();
	
	}
	
	override public function getTypeLabel():String {
		return "Shield";
	}
	
}