package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class HitLocation 
{
	public var name:String = "";
	public var id:String = "";
	public var uid(get, never):String;
	


	public function new() 
	{
		
	}
	
	inline function get_uid():String 
	{
		var n:String = name;
		return (id != "" && id != null ? id : n);
	}
	
}