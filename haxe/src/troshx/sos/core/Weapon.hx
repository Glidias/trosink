package troshx.sos.core;
import troshx.ds.IDMatchArray;

/**
 * ...
 * @author Glidias
 */
class Weapon extends Item
{
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
	
	
	public var variant:Weapon = null;	// default secondary fire options
	public var attachments:WeaponAttachments = null; // custom attachments
	
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
	
	public var customise:WeaponCustomise = null;
	
	// ranged
	@:tag4ammo(1) public var range:Int = 0;
	@:tag4ammo(1) public var atnM:Int = 0;
	@:tag4ammo(1) public var damageM:Int = 0;
	public var damageTypeM:Int = DamageType.PIERCING;
	
	public var missileFlags:Int = 0;
	public var missileSpecial:MissileSpecial = null;

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
	
	public function sanity():Void {
		if (!ranged) {
			firearm = null;
			crossbow = null;
		}
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
	
	public function profLabels():String {
		var arr = Profeciency.getLabelsOfArrayProfs(ranged ? Profeciency.getCoreRanged() : Profeciency.getCoreMelee(), profs);
		if (profsCustom != null) {
			for (i in 0...profsCustom.length) {
				arr.push(profsCustom.list[i].name);
			}
		}
		return arr.join(", ");
	}
	
	
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
		return super.get_uid() + (firearm != null && firearm.firingMechanism != null ? ":"+firearm.firingMechanism.uid : "") + (customise != null ?  "_"+customise.uid : "" ) + (attachments != null ? attachments.uid : ""); // id != "" ? id : name;
	}
	
	override function get_label():String {
		
		return (isFirearm() && firearm.firingMechanism != null  ? firearm.firingMechanism.name+ " " : "") + name + (customise != null ? "("+(customise.name != null ? customise.name : customise.uid)+")" : ""); 
	}
	
	override public function getTypeLabel():String {
		return "Weapon";
	}
	
}