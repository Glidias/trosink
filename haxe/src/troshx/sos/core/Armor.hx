package troshx.sos.core;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class Armor extends Item
{

	public var AVC:Int = 0;
	public var AVP:Int = 0;
	public var AVB:Int = 0;
	
	public var coverage:Dynamic<ArmorHitLocation> = {};
	public var tags:String = "";
	
	public var helmet:Bool = false;
	
	public var pp:Int = 0;
	
	public var specialFlags:Int = 0;
	public var special:ArmorSpecial = null;
	
	// using this will uniquely identify the armor
	public var customise:ArmorCustomise = null;
	
	
	public function new() 
	{
		super();
		
	}
	
	override function get_uid():String 
	{
		return super.get_uid() +(customise != null ? " *"+customise.uid+"*" : ""  );
	}
	
	override public function addTagsToStrArr(arr:Array<String>):Void {
		super.addTagsToStrArr(arr);
		if (pp > 0 ) {
			arr.push("PP -" + pp);
		}
		var flags:Int = specialFlags;
		
		
		
		if (flags != 0) {
			Item.pushFlagLabelsToArr(true, "troshx.sos.core.ArmorSpecial");
		}
		if (special != null) {
			special.addTagsToStrArr(arr);
		}
		
		
	}
	
	
	
	
	override public function getTypeLabel():String {
		return "Armor";
	}
	
}