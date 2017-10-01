package troshx.sos.core;
//import troshx.ds.HashedArray;
//import troshx.ds.IDMatchArray;
import troshx.util.LibUtil;

/**
 * Armor
 * @author Glidias
 */
class Armor extends Item
{

	public var AVC:Int = 0;
	public var AVP:Int = 0;
	public var AVB:Int = 0;
	
	// generic armor coverage hash by string id.
	public var coverage:Dynamic<Int>;	// Using plain dynamic object to favor javascript object
	

	@:coverage public static inline var WEAK_SPOT:Int = (1 << 0);
	@:coverage public static inline var HALF:Int = (1 << 1);
	@:coverage public static inline var THRUST_ONLY:Int = (1 << 2);
	
	public static inline var HALF_SYMBOL:String = "*";
	public static inline var WEAK_SPOT_SYMBOL:String = "ϕ"; //☄
	public static inline var THRUST_ONLY_SYMBOL:String = "t"; 
	
	public static inline var SUPERSCRIPT_MINUS:String = "⁻";
	public static inline var SUPERSCRIPT_PLUS:String = "⁺";
	//public static inline var SUPERSCRIPT_NUM_BASE:Int = 
	public static inline var SUPERSCRIPT_NUMBERS:String = "⁰¹²³⁴⁵⁶⁷⁸⁹";
	
	
	public var pp:Int = 0;
	
	public var specialFlags:Int = 0;
	public var special:ArmorSpecial = null;
	
	// using this will uniquely identify the armor
	public var customise:ArmorCustomise = null;
	
	
	function new() 
	{
		super();

		
		
	}
	public static function createEmptyInstance():Armor {
		var armor:Armor = new Armor();
		armor.coverage = {};
		return armor;
	}
	
	override function get_uid():String 
	{
		return super.get_uid() +(customise != null ? " *"+customise.uid+"*" : ""  );
	}
	
	public function addCoverageTagsToStrArr(arr:Array<String>) 
	{	
		var bodyChar:BodyChar = special != null && special.otherBodyType != null ? special.otherBodyType : BodyChar.getInstance();
		bodyChar.pushArmorCoverageLabelsTo( coverage, arr);
	}
	
	override public function addTagsToStrArr(arr:Array<String>):Void {
		super.addTagsToStrArr(arr);
		if (pp > 0) {
			arr.push("PP -"+pp);
		}
		
		var flags:Int = specialFlags;
		
		if (flags != 0) {
			Item.pushFlagLabelsToArr(true, "troshx.sos.core.ArmorSpecial");
		}
		if (special != null) {
			special.addTagsToStrArr(arr);
		}

		if (customise != null) {
			customise.addTagsToStrArr(arr);
		}
	}
	
	override function get_label():String {
		return name + (customise != null ? " *"+(customise.name != null ? customise.name : customise.uid)+"*" : ""); 
	}
	
	override public function getTypeLabel():String {
		return "Armor";
	}
	
}