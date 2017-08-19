package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Item 
{
	public var weight:Float = 0;
	public var name:String;
	
	public var id(default,null):String;
	public var uid(get, never):String;

	static var UID_COUNT:Int = 0;
	
	public var flags:Int = 0;
	public static inline var FLAG_TWO_HANDED:Int = 1;
	public static inline var FLAG_STRAPPED:Int = 2;
	
	public var twoHanded(get, never):Bool;
	public var strapped(get, never):Bool;
	
	/**
	 * 
	 * @param	id	Empty string by default, which resolves to name dynamically if you wish. Set to explicit null to auto-generate a unique immutable id.
	 * @param	name	The name label of the item
	 */
	public function new(id:String= "", name:String = "") 
	{
		this.id = id != null ? id : "Item_" + UID_COUNT++;
		this.name = name;
		
	}
	
	
	
	public function getTypeLabel():String {
		return "MiscItem";
	}
	
	inline function get_uid():String 
	{
		return id != "" ? id : name;
	}
	
	inline function get_twoHanded():Bool 
	{
		return (flags & FLAG_TWO_HANDED) != 0;
	}
	inline function get_strapped():Bool 
	{
		return (flags & FLAG_STRAPPED) != 0;
	}
	
}