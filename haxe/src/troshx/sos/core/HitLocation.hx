package troshx.sos.core;
import troshx.sos.core.HitLocation.WoundDef;

/**
 * ...
 * @author Glidias
 */
class HitLocation 
{
	public var name:String = "";
	public var id:String = "";
	public var uid(get, never):String;
	
	public var woundTable:Array<Array<WoundDef>>;  // damage type -> level
	

	public function new() 
	{
		
	}
	
	inline function get_uid():String 
	{
		var n:String = name;
		return (id != "" && id != null ? id : n);
	}
	
}

typedef WoundDef = {
	var stun:Int;
	var pain:Int;
	var BL:Int;
}