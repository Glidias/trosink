package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Item 
{
	public var weight:Float = 0;
	public var name:String;
	
	public var id:String;
	public var uid(get, null):String;

	static var UID_COUNT:Int = 0;
	
	public var twoHanded:Bool = false;
	
	public function new(id:String= null, name:String = "") 
	{
		this.id = id != null ? id : "Item_" + UID_COUNT++;
		this.name = name;
		
	}
	
	inline function get_uid():String 
	{
		return id;
	}
	
}