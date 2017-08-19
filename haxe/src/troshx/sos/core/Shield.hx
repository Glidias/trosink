package troshx.sos.core;

/**
 * 
 * @author Glidias
 */
class Shield extends Item
{
	public var AV:Int = 1;
	public var block:Int = 7;
	public var coverage:Dynamic<HitLocation> = {};

	
	// bob/ss
	public var strapType:Int = 0;
	public static inline var STRAP_ARM:Int = 0;
	public static inline var STRAP_SHOULDER:Int = 1;

	
	public function new() 
	{
		super();
	
	}
	
	override public function getTypeLabel():String {
		return "Shield";
	}
	
}