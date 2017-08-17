package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class DamageType 
{
	public static inline var CUTTING:Int = (1 << 0);
	public static inline var THRUSTING:Int = (1 << 1);
	public static inline var BLUDGEONING:Int = (1 << 2);

	public static inline var FALLING:Int = ( 1 << 3);
	public static inline var BURN:Int = ( 1 << 4);
	public static inline var ELECTRICAL:Int = ( 1 << 5);
	public static inline var COLD:Int = ( 1 << 6);

	public function new() 
	{
		
	}
	
}