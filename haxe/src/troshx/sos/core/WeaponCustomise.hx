package troshx.sos.core;

/**
 * Weapon customisation state flags and state trackings.
 * @author Glidias
 */
class WeaponCustomise 
{
	public var flags:Int = 0;
	public var name:String = "";
	
	public var uid(get, never):String;

	public var melee:CustomMelee = null;
	//public var ranged:CustomRanged = null;
	
	public var cost:Int = 0;  // if specified, will use this instead of defualt market pricing
	
	function get_uid():String 
	{
		return "_"+(name != "" ? name : flags+"");
	}
	
}

class CustomMelee {
	public var bizarreGimmickDesc:String = null;  // BIZARRE_GIMMICK must be flagged for this to be usable.
	public var sharpened:Bool = true; //  RIDICULOUSLY_SHARP must be flagged for this to be usable.
	
	@:prop({max:2}) public var customGrip:Int = 0; 
	@:prop({max:3}) public var fineForging:Int = 0;
	
	@:prop({max:2}) public var integratedPistol:Int = 0;
	public static inline var PISTOL:Int = 1;
	public static inline var DRAGON:Int = 2;
	
	public static inline var CUSTOM_HILT:Int = (1 << 0); 
	public static inline var RIDICULOUSLY_SHARP:Int = (1 << 1);
	public static inline var EXQUISITE_DECORATION:Int = (1 << 2);
	public static inline var FINE_FORGING:Int = (1 << 3);
	public static inline var BIZARRE_GIMMICK:Int = (1 << 4);
	
}

/*
class CustomRanged {
	
}
*/