package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class ArmorCustomise 
{
	public var name:String = "";
	
	public var hitLocationAllAVModifiers:Dynamic<Float> = null;
	public var uid(get, null):String;

	public function new() 
	{
		
	}
	
	function get_uid():String 
	{
		return name;
	}
	
}