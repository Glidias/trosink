package troshx.sos.core;
import troshx.core.IUid;

/**
 * Any stateful customisations/alterations of a given armor
 * @author Glidias
 */
class ArmorCustomise implements IUid
{
	public var name:String = "";
	
	public var hitLocationAllAVModifiers:Dynamic<Int> = null;
	public var uid(get, null):String;

	public function new() 
	{
		
	}
	
	inline function get_uid():String 
	{
		return name;
	}
	
}