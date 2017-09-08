package troshx.sos.core;

/**
 * This is a skill record entry for purpose of character generation
 * @author Glidias
 */
class Skill 
{
	public var name:String = "";
	public var uid(get, never):String;
	public var coreAttribute:Int = 0;
	@:attrib("") public static inline var ATTRIB_NONE:Int = 0;
	@:attrib("Strength") public static inline var ATTRIB_STR:Int = 1;
	@:attrib("Agility") public static inline var ATTRIB_AGI:Int = 2;
	@:attrib("Endurance") public static inline var ATTRIB_END:Int = 3;
	@:attrib("Health") public static inline var ATTRIB_HLT:Int = 4;
	@:attrib("Willpower") public static inline var ATTRIB_WIL:Int = 5;
	@:attrib("Wit") public static inline var ATTRIB_WIT:Int = 6;
	@:attrib("Intelligence") public static inline var ATTRIB_INT:Int = 7;
	@:attrib("Perception") public static inline var ATTRIB_PER:Int = 8;
	
	@:attrib("Various") public static inline var ATTRIB_VARIOUS:Int = -1;
	
	public var attributeMask:Int = 0;

	public function new(name:String, coreAttribute:Int, attributeMask:Int=0) 
	{
		this.name = name;
		this.coreAttribute = coreAttribute;
		this.attributeMask = attributeMask;
	}
	
	inline function get_uid():String 
	{
		return name;
	}

	
}