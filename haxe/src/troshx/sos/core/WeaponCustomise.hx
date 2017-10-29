package troshx.sos.core;
import troshx.core.IUid;

/**
 * Weapon customisation state flags and state trackings. Adding this to a weapon uniquely identifies it.
 * @author Glidias
 */
class WeaponCustomise implements IUid
{
	public var meleeFlags:Int = 0;
	public var melee:CustomMelee = null;
	
	public var name:String = "";
	
	public var uid(get, never):String;
	
	public function new() {
		
	}
	
	public function  addMeleeTagsToStrArr(arr:Array<String>):Void {
		var flags:Int = meleeFlags;
		Item.pushFlagLabelsToArr(true, "troshx.sos.core.WeaponCustomise:CustomMelee", true, ":flag", "*");
		if (melee != null) {
			var instance = melee;
			Item.pushVarLabelsToArr(true, "troshx.sos.core.WeaponCustomise:CustomMelee", ":flag", "*");
		}
		
		
	}
	
	public inline function hasBizarreGimmick():Bool {
		return (meleeFlags & CustomMelee.BIZARRE_GIMMICK) != 0;
	}
	
	public inline function hasExquisiteDecoration():Bool {
		return (meleeFlags & CustomMelee.EXQUISITE_DECORATION) != 0;
	}
	
	public inline function isRidiculouslySharp():Bool {
		return (meleeFlags & CustomMelee.RIDICULOUSLY_SHARP) != 0;
	}

	
	//public var ranged:CustomRanged = null;
	
	public var original:Weapon  = null; // this may be added in to restore an item back to "original", or just a reference to the canonical item for comparison
	
	function get_uid():String 
	{
		return "_"+name + "_"+meleeFlags + (melee != null ? melee.getUID(meleeFlags) : "" );
	}
	
}

class CustomMelee  {
	@:flag() @:prop({max:2}) public var customGrip:Int = 0; 
	@:flag() @:prop({max:3}) public var fineForging:Int = 0;
	@:flag() @:prop({max:2}) public var integratedPistol:Int = 0;
	
	
	@:state public var sharpened:Bool = true; //  RIDICULOUSLY_SHARP must be flagged for this to be usable.
	@:state public var bizarreGimmickDesc:String = "";  // BIZARRE_GIMMICK must be flagged for this to be usable
	@:state public var exquisiteDecorDesc:String = "";  // EXQUISITE_DECORATION must be flagged for this to be usable.
	
	public function getUID(flags:Int):String   // consider macro for this in the future?
	{
		return "_"+customGrip+"_"+fineForging+"_"+integratedPistol;
	}
	
	public static inline var PISTOL:Int = 1;
	public static inline var DRAGON:Int = 2;
	
	@:flag() public static inline var CUSTOM_HILT:Int = (1 << 0); 
	@:flag() public static inline var RIDICULOUSLY_SHARP:Int = (1 << 1);
	@:flag() public static inline var EXQUISITE_DECORATION:Int = (1 << 2);
	@:flag() public static inline var BIZARRE_GIMMICK:Int = (1 << 3);
	
	public function new() {
		
	}
	
	
	
	
	/* INTERFACE troshx.core.IUid */
	
	
}

/*
class CustomRanged {
	
}
*/