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

	public inline function writeAVVAluesTo(values:Dynamic<AV3>, body:BodyChar, targetZoneMask:Int=0):Void {
		for (f in Reflect.fields(coverage)) {
			var cur:AV3 = LibUtil.field(values, f);
			var flags = LibUtil.field(coverage, f);
		
			var hitLocationId:String = f;
			var hitLocationMask:Int = (1 << LibUtil.field(body.hitLocationHash, hitLocationId));
			var multiplier:Float = (flags & HALF) != 0 ? 0.5 : 1;
			var adder:Int = 0;
				
			if (hitLocationMask != 0 && special != null && special.hitModifier != null) {
				if ( targetZoneMask == 0 && special.hitModifier.targetZoneMask==0  && (special.hitModifier.locationMask & hitLocationMask) != 0 ) {
					//trace("IN...");
					// apply modifiers
					if (special.hitModifier.multiplyAV < 1 && special.hitModifier.multiplyAV < multiplier) {
						multiplier = special.hitModifier.multiplyAV; 
					}
					if (special.hitModifier.multiplyAV > 1 && special.hitModifier.multiplyAV > multiplier) {
						multiplier = special.hitModifier.multiplyAV; 
					}
					
					adder += special.hitModifier.addAV;	
				}
				
				// Assumption warning: if targetZoneMask !=0 , we assume hitLocationMask also !=0 and is supplied
				if ( targetZoneMask != 0 && (special.hitModifier.targetZoneMask & targetZoneMask) != 0 && (special.hitModifier.locationMask == 0 || (special.hitModifier.locationMask & hitLocationMask) != 0 ) ) {
					
					// apply modifiers
					if (special.hitModifier.multiplyAV < 1 && special.hitModifier.multiplyAV < multiplier) {
						multiplier = special.hitModifier.multiplyAV; 
					}
					if (special.hitModifier.multiplyAV > 1 && special.hitModifier.multiplyAV > multiplier) {
						multiplier = special.hitModifier.multiplyAV; 
					}
					
					adder += special.hitModifier.addAV;
					
				}
			}
			
			
				
			if (hitLocationMask!=0 && customise != null && customise.hitLocationAllAVModifiers != null && LibUtil.field(customise.hitLocationAllAVModifiers, hitLocationId) != null ) {
				adder += LibUtil.field(customise.hitLocationAllAVModifiers, hitLocationId);
			}
			
			var avc:Int = Std.int(AVC * multiplier) + adder;
			var avp:Int = Std.int(AVP * multiplier) + adder;
			var avb:Int = Std.int(AVB * multiplier) + adder;
		
			
			if (avc < 0) avc = 0;
			if (avp < 0) avp = 0;
			if (avb < 0) avb = 0;
			
			if (avc > cur.avc) {
				cur.avc = avc;
			}
			if (avp > cur.avp) {
				cur.avp = avp;
			}
			if (avb > cur.avb) {
				cur.avb = avb;
			}
		}
	}

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
			special.addTagsToStrArr(arr, this);
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

typedef AV3 = {
	var avc:Int;
	var avp:Int;
	var avb:Int;
}