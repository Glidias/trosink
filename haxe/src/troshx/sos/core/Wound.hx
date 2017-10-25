package troshx.sos.core;
import troshx.core.IUid;
import troshx.ds.IUpdateWith;

/**
 * An actual live wound inflicted on a current character
 * @author Glidias
 */
class Wound implements IUpdateWith<Wound>  //implements IUid 
{
	
	// these parameters uniquely identify the wound and should never be changed after being set through constructor
	//public var location(default,null):HitLocation = null;
	public var locationId:String;
	public var level(default,null):Int = 0;
	public var damageType(default, null):Int = 0;
	public var leftSide(default, null):Bool = false;
	
	// stateful applied damages for wound
	public var stun:Int = 0;
	public var pain:Int = 0;
	public var BL:Int = 0;
	public var flags:Int = 0;

	@:flag public static inline var STAUNCHED:Int = (1 << 0);
	@:flag public static inline var TREATED:Int = (1 << 1);

	public static inline var MASK_OPENWOUND:Int = STAUNCHED | TREATED;
	
	static function getNewFlagLabels():Array<String> {
		var arr:Array<String> = [];
		Item.pushFlagLabelsToArr(false, "troshx.sos.core.Wound", true, ":flag");
		return arr;	
	}
	
	public static var FLAG_LABELS:Array<String> = null;
	public static function getFlagLabels():Array<String> {
		return FLAG_LABELS != null ? FLAG_LABELS : (FLAG_LABELS = getNewFlagLabels());
	}
	

	
	static  var UNIQUE_COUNT:Int = 0;
	
	public var uidSuffix:String = "";
	public var notes:String;
	public var age:Float = 0;
	
	public inline function isNullified():Bool {
		return stun == 0 && pain == 0 && BL == 0;
	}
	
	public static function getNewEmptyAssign():Wound {
		var w:Wound = new Wound("", 0, 0);
		w.notes = "";
		return w;
	}

	public function new(locationId:String, level:Int, damageType:Int) 
	{
		this.locationId = locationId;
		this.level = level;
		this.damageType = damageType;
	}
	
	public function getDescLabel(body:BodyChar, damageTypeLabels:Array<String>):String {
		var dmgLabel:String =  (damageType >= 0 && damageType < damageTypeLabels.length) ? " " +damageTypeLabels[damageType] : "";
		var hitLoc:HitLocation = body.getHitLocationById(locationId);
		return "Level "+this.level + dmgLabel + " wound" + (locationId != "" ? " on the " + (hitLoc != null && hitLoc.twoSided ? leftSide ?  "Left " : "Right " : "")  +  body.getHitLocationLabelFromId(locationId) : "" );
	}
	
	public function updateAgainst(ref:Wound):Void {
		if (ref.stun > stun) stun = ref.stun;
		if (ref.pain > pain) pain = ref.pain;
		if (ref.BL > BL) BL = ref.BL;
		flags &= ~MASK_OPENWOUND;
		age = 0;
	}
	
	public function spliceAgainst(ref:Wound):Int {
		updateAgainst(ref);
		return -1;
	}
	
	public function makeUnique():Void
	{
		uidSuffix = "^" + UNIQUE_COUNT;
	}
	
	public inline function isTreated():Bool
	{
		return (flags & TREATED)  != 0;
	}
	
	public inline function gotBloodLost():Bool
	{
		return (flags & (STAUNCHED | TREATED))  == 0;
	}
	
	public function getUID(body:BodyChar):String 
	{
		return locationId + "_"+ level + "_"+ damageType +  (body.gotSideWithId(locationId) ? (leftSide ? "l" : "r") : "" ) +  uidSuffix;
	}
	
	
	
}