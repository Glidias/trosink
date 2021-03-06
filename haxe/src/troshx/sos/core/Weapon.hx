package troshx.sos.core;
import troshx.ds.IDMatchArray;
//import troshx.sos.core.BurdinadinArmory.BurdinadinWeapon;
import troshx.sos.core.MissileSpecial;

/**
 * ...
 * @author Glidias
 */
class Weapon extends Item
{
	
	//public var attachments:WeaponAttachments = null; // custom attachments
	public var customise:WeaponCustomise = null;  // before assigning this, make sure the Weappon is deeply cloned to a unique instance to make it unique!
	
	public var profs:Int = 0;
	public var profsCustom:IDMatchArray<Profeciency> = null;
	public var ranged:Bool = false; // to represent missile weapons and missile profeciencies
	
	public var reach:Int = 4;  
	public static inline var REACH_HA:Int = 1;
	public static inline var REACH_H:Int = 2;
	public static inline var REACH_S:Int = 3;
	public static inline var REACH_M:Int = 4;
	public static inline var REACH_L:Int = 5;
	public static inline var REACH_VL:Int = 6;
	public static inline var REACH_EL:Int = 7;
	public static inline var REACH_LL:Int = 8;
	
	public var variant:Weapon = null;	// used to hold 1h variant
	
	public var atnS:Int = 0;
	public var atnT:Int = 0;
	
	public var damageS:Int = 0;
	public var damageT:Int = 0;
	
	public var damageTypeS:Int = DamageType.CUTTING;
	public var damageTypeT:Int = DamageType.PIERCING;

	
	public var dtn:Int = 0; 
	public var guard:Int = 0;
	
	public var meleeFlags:Int = 0;
	public var meleeSpecial:MeleeSpecial = null;
	
	// ranged
	@:tag4ammo(1) public var range:Int = 0;
	@:tag4ammo(1) public var atnM:Int = 0;
	@:tag4ammo(1) public var damageM:Int = 0;
	public var damageTypeM:Int = DamageType.PIERCING;
	
	public var missileFlags:Int = 0;
	public var missileSpecial:MissileSpecial = null;
	
	//public var burdinadin: BurdinadinWeapon= null;

	public var stuckChance:Int = 0; // the use of ammunition may overwrite this, and defaults for ranged category will overwrite this
	
	// Bow 
	@:tag4ammo() public var requiredStr:Int = 0; 
	
	// Crossbow (if specified, overrides bow)
	public var crossbow:Crossbow = null;
	
	// Firearm (if specified, may stack with crossbow for a crossbow+firearm hybrid)
	public var firearm:Firearm = null;
	
	public var isAmmo:Bool = false;
	

	public function new(id:String= "", name:String = "" ) 
	{
		super(id, name);
	}
	
	public static inline function isTwoHandedOff(weap:Weapon):Bool {
		var a = weap.meleeFlags;
		var b = weap.flags;
		var c = weap.isMelee();
		return c &&  (a & MeleeSpecial.HAND_OFF) != 0 &&  (b & Item.FLAG_TWO_HANDED) != 0;
	}
	
	
	override public function normalize():Item {
		if (ranged) {
			if (!isBow()) {
				requiredStr = 0;
			}
			
			// reset melee
			meleeFlags = 0;
			meleeSpecial = null;
			atnS = 0;
			atnT = 0;
			dtn = 0;
			guard = 0;
			damageS = 0;
			damageT = 0;
			damageTypeS = DamageType.CUTTING;
			damageTypeT  = DamageType.PIERCING;
			variant = null;
			reach = 4;
			
		}
		else {
			// reset missile
			missileFlags = 0;
			missileSpecial = null;
			stuckChance = 0;
			requiredStr = 0;
			firearm = null;
			crossbow = null;
			isAmmo = false;
			damageTypeM = DamageType.PIERCING;
			
		}
		return this;
	}
	
	public inline function isAttachment():Bool {
		var m = (meleeFlags & MeleeSpecial.WEAPON_ATTACHMENT) != 0;
		var r = (missileFlags & MissileSpecial.CHEAT_ATTACHMENT) != 0;
		return ranged ? r : m;
	}
	
	public function isMeleeAttachmentFor(other:Weapon):Bool {
		
		return ranged ? false : (meleeFlags & MeleeSpecial.WEAPON_ATTACHMENT) != 0  && other.supportsMeleeAttachment();
	}
	public function supportsMeleeAttachment():Bool {
		var ranged = this.ranged;
		return (meleeFlags & (MeleeSpecial.THRUSTING_SLOT|MeleeSpecial.SWINGING_SLOT)) !=0 && !ranged;
	}
	
	public inline function hasNoProf():Bool {
		return ( profsCustom == null || profsCustom.length == 0) && profs == 0;
	}
	
	public function matchesTypes(ranged:Bool, ?profs:Int):Bool {
		var thisProfs = this.profs;
		return (this.ranged == ranged) && (profs == null || ((profs & thisProfs) != 0));
	}

	// ammo discriminant type checkers and includes required dependencies?
	public inline function isMelee():Bool {
		return !ranged && !isAmmo;
	}
	public inline function isRangedWeap():Bool {
		return ranged && !isAmmo;
	}
	public inline function isBow():Bool {
		var a = (profs & (1<<Profeciency.R_BOW)) != 0;
		return ranged && a && !isAmmo;
	}
	public inline function isSling():Bool {
		var a = (profs & (1<<Profeciency.R_SLING)) != 0;
		return ranged && a && !isAmmo;
	}
	public inline function isCrossbow():Bool {
		var a = (profs & (1<<Profeciency.R_CROSSBOW)) != 0;
		return ranged && a && !isAmmo && crossbow != null;
	}
	public inline function isFirearm():Bool {
		var a = (profs & (1<<Profeciency.R_FIREARM)) != 0;
		return ranged && a && !isAmmo && firearm != null;
	}
	public inline function isThrowing():Bool {
		var a = (profs & (1<<Profeciency.R_THROWING)) != 0;
		return ranged && a && !isAmmo;
	}
	public inline function isAmmunition():Bool {
		return isAmmo && ranged;
	}
	
	public function profLabelStdFirst():String {
		var arr = Profeciency.getLabelsOfArrayProfs(ranged ? Profeciency.getCoreRanged() : Profeciency.getCoreMelee(), profs);
		return arr[0];
	}
	
	public function profLabels():String {
		var arr = Profeciency.getLabelsOfArrayProfs(ranged ? Profeciency.getCoreRanged() : Profeciency.getCoreMelee(), profs);
		if (profsCustom != null) {
			for (i in 0...profsCustom.length) {
				arr.push(profsCustom.list[i].name);
			}
		}
		return arr.join(", ");
	}
	
	override public function  addTagsToStrArr(arr:Array<String>):Void {
		super.addTagsToStrArr(arr);
		var flags:Int = ranged ? this.missileFlags : this.meleeFlags;
		var myArr:Array<String>;
		var valCheck:Int;
		if (ranged) {
		
			myArr =MissileSpecial.getLabelsOfFlags(missileSpecial, missileFlags);
			for (i in 0...myArr.length) {
				 arr.push(myArr[i] );
			}

			
			if (isAmmo) {
				if (crossbow != null && (  (profs & (1<<Profeciency.R_CROSSBOW)) != 0 ) ) {
					crossbow.addAmmoTagsToStrArr(arr);
				}
				
				if (  (profs & (1 << Profeciency.R_BOW)) != 0 ) {
					if (requiredStr != 0) arr.push( "Required STR " + Item.sign(requiredStr)+requiredStr );
				}
			}
			if ( firearm != null && (  (profs & (1<<Profeciency.R_FIREARM)) != 0 ) ) {
				firearm.addTagsToStrArr(arr, isAmmo, isAmmo);
			}
			
		}
		else {
		
			myArr =MeleeSpecial.getLabelsOfFlags(meleeSpecial, meleeFlags);
			for (i in 0...myArr.length) {
				 arr.push(myArr[i] );
			}
			
			if (customise != null && _showCustomTags) {
				customise.addMeleeTagsToStrArr(arr);
			}
		}
	}
	
	public var _showCustomTags:Bool = true;
	
	static inline function IsPowerOfTwoOrZero(x:Int)
	{
		return (x & (x - 1)) == 0;
	}

	public inline function isMultipleCoreProf():Bool {
		return profs != 0 && !IsPowerOfTwoOrZero(profs);
	}
	public inline function hasCustomProf():Bool {
		return profsCustom != null && profsCustom.length > 0;
	}
	
	
	
	
	
	public function setSingleProfIndex(index:Int):Void {
		profs = (1 << index);
	}
	public function setMultipleProf(mask:Int):Void {
		profs = mask;
	}
	
	override function get_uid():String 
	{
		//+ (firearm != null && firearm.firingMechanism != null ? ":" + firearm.firingMechanism.uid : "")
		return super.get_uid()  + (customise != null ?  "_" + customise.uid : "" ); // + (attachments != null ? attachments.uid : ""); // id != "" ? id : name;
	}
	
	inline function getWeapLabel(handOff:Bool):String {
		return (isFirearm() && firearm.firingMechanism != null  ? firearm.firingMechanism.name+ " " : "") + name + (handOff ? "*" : "") + (customise != null ? " *"+(customise.name != null ? customise.name : customise.uid)+"*" : ""); 
	}
	override function get_label():String {
		
		return getWeapLabel(false);
	}
	
	public function getLabelHeld(handOff:Bool):String {
		return getWeapLabel(handOff);
	}
	
	override public function getTypeLabel():String {
		return "Weapon";
	}
	
}