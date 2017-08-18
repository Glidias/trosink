package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Skill 
{
	public var name:String = "";
	public var uid(get, never):String;

	public function new() 
	{
		
	}
	
	inline function get_uid():String 
	{
		return name;
	}

	
}