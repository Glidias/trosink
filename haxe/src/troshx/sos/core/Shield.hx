package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Shield extends Item
{
	public var AV:Int = 0;
	public var block:Int = 0;
	public var coverage:Dynamic<HitLocation> = {};
	
	public var strapped:Bool = false;
	

	public function new() 
	{
		super();
	}
	
}