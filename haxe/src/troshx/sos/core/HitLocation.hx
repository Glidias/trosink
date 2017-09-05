package troshx.sos.core;
/**
 * A mere hit location name entry in character sheet.
 * Has additional properties regarding hit location such as symmetry and such
 * 
 * @author Glidias
 */
class HitLocation 
{
	public var name:String = "";
	public var id:String = "";
	public var twoSided:Bool = false;
	
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

