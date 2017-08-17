package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Profeciency 
{
	public var name:String = "";

	
	public var uid(get, null):String;

	public function new() 
	{
		
	}
	
	inline function get_uid():String 
	{
		return name;
	}
	
}