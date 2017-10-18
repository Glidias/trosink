package troshx.sos.core;
import troshx.core.IUid;
import troshx.ds.IUpdateWith;

/**
 * An actual live wound inflicted on a current character
 * @author Glidias
 */
class Wound implements IUid implements IUpdateWith<Wound>
{
	
	// these parameters uniquely identify the wound and should never be changed after being set through constructor
	//public var location(default,null):HitLocation = null;
	public var locationId:String;
	public var level(default,null):Int = 0;
	public var damageType(default,null):Int = 0;
	
	// stateful applied damages for wound
	public var stun:Int = 0;
	public var pain:Int = 0;
	public var BL:Int = 0;
	public var flags:Int;

	@:flag public static inline var STAUNCHED:Int = (1 << 0);
	@:flag public static inline var TREATED:Int = (1 << 1);

	public static inline var MASK_OPENWOUND:Int = STAUNCHED | TREATED;

	public var uid(get, never):String;
	
	static  var UNIQUE_COUNT:Int = 0;
	
	public inline function isNullified():Bool {
		return stun == 0 && pain == 0 && BL == 0;
	}

	public function new(locationId:String, level:Int, damageType:Int) 
	{
		this.locationId = locationId;
		this.level = level;
		this.damageType = damageType;
	}
	
	
	public function updateAgainst(ref:Wound):Void {
		if (ref.stun > stun) stun = ref.stun;
		if (ref.pain > pain) pain = ref.pain;
		if (ref.BL > BL) BL = ref.BL;
		ref.flags &= ~MASK_OPENWOUND;
		
	}
	
	public function spliceAgainst(ref:Wound):Int {
		if (ref.stun < stun) stun = ref.stun;
		if (ref.pain < pain) pain = ref.pain;
		if (ref.BL < BL) BL = ref.BL;
		ref.flags &= ~MASK_OPENWOUND;
		return -1;
	}
	
	inline function get_uid():String 
	{
		return locationId + "_"+ level + "_"+ (damageType >= 0 ? damageType : UNIQUE_COUNT++);
	}
	
}