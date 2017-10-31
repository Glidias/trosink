package troshx.sos.core;
//import troshx.ds.HashedArray;
//import troshx.ds.IDMatchArray;
import troshx.sos.core.ArmorSpecial.WornWith;
import troshx.sos.core.BurdinadinArmory.BurdinadinArmor;
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
	var _coverageValues:Array<Int>;
	//var _hitLocationAVModifiers:Array<Int>; // yagni, any Armor with ArmorCustomise is considered always unique usually
	
	public var burdinadin:BurdinadinArmor = null;
	
	public function writeAVsAtLocation(body:BodyChar, hitLocationId:String, hitLocationMask:Int, result:AV3, layerMask:Int, nonFirearmMissile:Bool, targetZoneMask:Int, includeCrushedAVS:Bool):Bool {
		var flags = LibUtil.field(coverage, hitLocationId);

			
			if ( (layerMask & hitLocationMask) != 0 && special.wornWith.layer == WornWith.USE_AV_OTHER) {
				return false;
			}
			
			var multiplier:Float = (flags & HALF) != 0 ? 0.5 : 1;
			if ( (flags & THRUST_ONLY) != 0 && (body.thrustMask & targetZoneMask) == 0  ) {
				multiplier = 0;
			}
		
			var adder:Int = 0;
			
				
			if (hitLocationMask != 0 && special != null && special.hitModifier != null && multiplier !=0 ) {
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
			
				
			if (includeCrushedAVS && hitLocationMask!=0 && customise != null && customise.hitLocationAllAVModifiers != null && LibUtil.field(customise.hitLocationAllAVModifiers, hitLocationId) != null ) {
				adder += LibUtil.field(customise.hitLocationAllAVModifiers, hitLocationId);
			}
			
			var multiplierP:Float = (nonFirearmMissile && (specialFlags & ArmorSpecial.TEXTILE) != 0) ? multiplier * 2 : multiplier; 
			
			var avc:Int = Std.int(AVC * multiplier) + adder;
			var avp:Int = Std.int(AVP * multiplierP) + adder;
			var avb:Int = Std.int(AVB * multiplier) + adder;
		
			
			if (avc < 0) avc = 0;
			if (avp < 0) avp = 0;
			if (avb < 0) avb = 0;
			
			result.avc = avc;
			result.avp = avp;
			result.avb = avb;
			
			return true;
	}
	
	static var TEMPAVS:AV3;

	//inline
	public function writeAVVAluesTo(values:Dynamic<AV3>, body:BodyChar, layerMask:Int, nonFirearmMissile:Bool, targetZoneMask:Int):Void {
		var tempAvs;
		if (TEMPAVS == null) TEMPAVS = {avc:0, avp:0, avb:0};
		tempAvs = TEMPAVS;
		
		for (f in Reflect.fields(coverage)) {
			var cur:AV3 = LibUtil.field(values, f);
			
			var hitLocationId:String = f;
			var hitLocationMask:Int = (1 << LibUtil.field(body.hitLocationHash, hitLocationId));
			
			if (!writeAVsAtLocation(body, hitLocationId, hitLocationMask, tempAvs, layerMask, nonFirearmMissile, targetZoneMask, true) ) {
				continue;
			}
			
			if (tempAvs.avc > cur.avc) {
				cur.avc = tempAvs.avc;
			}
			if (tempAvs.avp > cur.avp) {
				cur.avp = tempAvs.avp;
			}
			if (tempAvs.avb > cur.avb) {
				cur.avb = tempAvs.avb;
			}
		}
	}
	
	
	public function checkFubarCrushed(body:BodyChar, targetZoneMask:Int, damageType:Int):Bool {
		var tempAvs;
		if (TEMPAVS == null) TEMPAVS = {avc:0, avp:0, avb:0};
		tempAvs = TEMPAVS;
		
		for (f in Reflect.fields(coverage)) {
			
			
			var hitLocationId:String = f;
			var hitLocationMask:Int = (1 << LibUtil.field(body.hitLocationHash, hitLocationId));
			
			if (!writeAVsAtLocation(body, hitLocationId, hitLocationMask, tempAvs, 0, false, targetZoneMask, true) ) {
				continue;
			}
			var chk:Int = damageType == DamageType.CUTTING ? tempAvs.avc :  damageType == DamageType.PIERCING ? tempAvs.avp : tempAvs.avb;
			
			if (chk != 0) return false;
		}
		
		return true;
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
	
	override public function normalize():Item {
		if (coverage == null) coverage = {};
		var bodyChar:BodyChar = special != null && special.otherBodyType != null ? special.otherBodyType : BodyChar.getInstance();

		var tempSpecial:ArmorSpecial = special;
		var tempCoverage:Dynamic<Int> = coverage;
		coverage = null;
		special  = null;
		
		
		var fakeMe:Armor = cast serializeClone();	// remove all dynamic hashes on fakeMe and reflect via array
		fakeMe._coverageValues = [];
		//fakeMe._hitLocationAVModifiers = customise != null && customise.hitLocationAllAVModifiers!=null ?  [] : null;
		for (i in 0...bodyChar.hitLocations.length) {
			var ider = bodyChar.hitLocations[i].id;
			if ( LibUtil.field( tempCoverage, ider) != null ) {
				fakeMe._coverageValues.push( i );
				fakeMe._coverageValues.push( LibUtil.field(tempCoverage, ider) );
			}
			else {
				fakeMe._coverageValues.push( 0 );
				fakeMe._coverageValues.push( 0 );
			}
			/*
			if (fakeMe._hitLocationAVModifiers != null) {
				if ( LibUtil.field( fakeMe.customise.hitLocationAllAVModifiers, ider) != null ) {
					fakeMe._hitLocationAVModifiers.push( i );
					fakeMe._hitLocationAVModifiers.push( LibUtil.field(fakeMe.customise.hitLocationAllAVModifiers, ider) );
				}
				else {
					fakeMe._hitLocationAVModifiers.push( 0 );
					fakeMe._hitLocationAVModifiers.push( 0 );
				}
			}
			*/
		}
		
		/*
		if (fakeMe._hitLocationAVModifiers != null) {
			fakeMe.customise.hitLocationAllAVModifiers = null;
		}
		*/
		
		if (tempSpecial != null){
			special = tempSpecial;
			fakeMe.special = tempSpecial;
		}
		coverage = tempCoverage;
		
		return fakeMe;
	}
	
	public function getCoverageMask(body:BodyChar):Int {
		var mask:Int = 0;
		for (f in Reflect.fields(coverage)) {
			mask |= ( 1 << LibUtil.field( body.hitLocationHash, f) );
		}
		return mask;
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
		
		if (burdinadin != null) {
			burdinadin.addTagsToStrArr(arr);
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
	
	/**
	 * 
	 * @param	locMask	hit location masked index
	 * @param	layerMask any overlapping areas (if any) with special other particular armor piece...
	 * @return
	 */
	public inline function getLayerValueAt(locMask:Int, layerMask:Int):Int 
	{
		var result:Int = special != null && special.layer != 0 ? ((special.layerCoverage == 0 || (special.layerCoverage & locMask) != 0) ? 1 : 0) * special.layer : 0;
		if ( layerMask !=0 &&  special.wornWith.layer > 0) {
			if (special.wornWith.layer > result) result = special.wornWith.layer;
		}
		return result;
	}
	

	
	
}

typedef AV3 = {
	var avc:Int;
	var avp:Int;
	var avb:Int;
}


typedef ArmorCalcResults = {
	var hitLocationIndex:Int;
	var damageType:Int;
	
	var layer:Int;
	var av:Int;
	
	
	var armorsProtectable:Array<Armor>;
	var armorsLayer:Array<Armor>; //@:optional 
	var armorsCrushable:Array<Armor>; //@:optional 
	
}