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
	
	public var crest:Int = 0;
	@:crest("Identifying") public static inline var CREST_IDENTIFYING:Int = 1;
	@:crest("Intimidating") public static inline var CREST_INTIMIDATING:Int = 2;
	@:crest("Ruthlessly Fashionable") public static inline var CREST_RUTHLESSLY_FASHIONABLE:Int = 3;

	public var original:Armor;
	
	public var notes:Array<String>;
	
	public function new() 
	{
		
	}
	
	
	
	public function addTagsToStrArr(arr:Array<String>):Void
	{
		var flags:Int = crest;
		Item.pushFlagEqualLabelsToArr(true, "troshx.sos.core.ArmorCustomise", false, ":crest", "*");
	}
	
	inline function get_uid():String 
	{
		return name;
	}
	
}