package troshx.sos.core;

/**
 * Must work in conjunectinon with a BodyChar to look up Hit location WoundDef from
 * @author Glidias
 */
class ArmorHitLocation
{
	public var index:Int;
	
	public var flags:Int;
	public static inline var HALF:Int = (1 << 0);
	public static inline var WEAK_SPOT:Int = (1 << 1);
	
	public function new() 
	{
		//super();
	}

	
}