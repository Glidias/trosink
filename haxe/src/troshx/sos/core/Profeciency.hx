package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Profeciency 
{
	public var name:String = "";

	public var uid(get, never):String;
	
	public var type:Int = 0;
	public static inline var TYPE_MELEE:Int = 0;
	public static inline var TYPE_RANGED:Int = 1;

	
	public function new() 
	{
		
	}
	
	inline function get_uid():String 
	{
		return name;
	}
	
}