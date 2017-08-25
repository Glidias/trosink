package troshx.sos.core;

/**
 * Represents a set of customisation for WeaponAttached items.
 * @author Glidias
 */
class WeaponAttachments 
{
	public var name:String = "";
	public var uid(get, never):String;
	public var list:Array<Weapon> = [];

	public function new() 
	{
		
	}
	
	function get_uid():String 
	{
		return name != "" && name != null ? name : getStringOfAttachments();
	}
	
	function getStringOfAttachments():String
	{
		var str:String = list.length > 0 ? list[0].uid : "";
		for (i in 1...list.length) {
			str += "+"+list[i].uid;
		}
		return str;
	}
	
}