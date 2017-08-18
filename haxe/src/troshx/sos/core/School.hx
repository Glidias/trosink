package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class School 
{
	public var name:String = "";
	public var profLimit:Int = 0;
	
	public var uid(get, never):String;

	public function new() 
	{
		
	}
	
	inline function get_uid():String 
	{
		return name;
	}
	
}