package troshx.sos.core;
import troshx.core.IUid;

/**
 * ...
 * @author Glidias
 */
class Talent implements IUid
{
	public var name:String = "";
	public var level:Int = 0;

	public var uid(get, never):String;
	public var label(get, null):String;
	
	public function new() 
	{
		
	}
	
	inline function get_uid():String 
	{
		return name + "_" + level;
	}
	
	function get_label():String 
	{
		return name + (level >=1 ? "("+level+")" : "");
	}
	
	
	
}