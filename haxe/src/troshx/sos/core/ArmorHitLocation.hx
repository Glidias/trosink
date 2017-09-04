package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class ArmorHitLocation extends HitLocation
{
	
	public var flags:Int;
	public static inline var HALF:Int = (1 << 0);
	public static inline var WEAK_SPOT:Int = (1 << 1);
	
	public function new() 
	{
		super();
	}

	
}