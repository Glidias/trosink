package troshx.sos.core;
/**
 * A mere hit location name entry in character sheet.
 * Has additional properties regarding hit location such as symmetry and such
 * 
 * @author Glidias
 */
class HitLocation 
{
	public var name:String;
	public var id:String;
	public var twoSided:Bool;
	
	public var uid(get, never):String;

	public function new(name:String, id:String, twoSided:Bool=false) 
	{
		this.name = name;
		this.id = id;
		this.twoSided = twoSided;
	}
	
	inline function get_uid():String 
	{
		return id;
	}
	
}

