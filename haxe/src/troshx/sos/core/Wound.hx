package troshx.sos.core;
import troshx.core.IUid;
import troshx.ds.IUpdateWith;

/**
 * ...
 * @author Glidias
 */
class Wound implements IUid implements IUpdateWith<Wound>
{
	
	// these parameters uniquely identify the wound
	public var location:HitLocation = null;
	public var level:Int = 0;
	public var damageType:Int = 0;
	
	// stateful applied damages for wound
	public var stun:Int = 0;
	public var pain:Int = 0;
	public var BL:Int = 0;
	public var treated:Bool = false;
	
	public var labelLocation(get, never):String;
	
	public var uid(get, never):String;
	
	static  var UNIQUE_COUNT:Int = 0;

	public function new() 
	{
		
	}
	
	function get_labelLocation():String 
	{
		return location != null ? location.name : "";
	}
	
	public function updateAgainst(ref:Wound):Void {
		if (ref.stun > stun) stun = ref.stun;
		if (ref.pain > pain) pain = ref.pain;
		if (ref.BL > BL) BL = ref.BL;
		ref.treated = false;
	}
	
	public function spliceAgainst(ref:Wound):Int {
		if (ref.stun < stun) stun = ref.stun;
		if (ref.pain < pain) pain = ref.pain;
		if (ref.BL < BL) BL = ref.BL;
		ref.treated = true;
		return -1;
	}
	
	inline function get_uid():String 
	{
		return location.uid + "_"+ level + "_"+ (damageType >= 0 ? damageType : UNIQUE_COUNT++);
	}
	
}