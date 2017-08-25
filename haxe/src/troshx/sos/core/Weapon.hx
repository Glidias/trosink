package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Weapon extends Item
{
	public var profs:Int = 0;
	public var profsCustom:Array<Profeciency> = null;
	public var ranged:Bool = false; // to represent missile weapons and missile profeciencies
	
	public var reach:Int = 4;   // also used to represent range for missile weapons
	
	public var variant:Weapon = null;	// default secondary fire options
	public var attachments:WeaponAttachments = null; // custom attachments
	
	public var atn:Int = 0;
	public var atnT:Int = 0;
	
	public var damage:Int = 0;
	public var damageT:Int = 0;
	
	public var damageType:Int = DamageType.CUTTING;
	public var damageTypeT:Int = DamageType.PIERCING;
	
	public var dtn:Int = 0; 
	public var guard:Int = 0;
	
	public var specialFlags:Int = 0;
	public var meleeSpecial:MeleeSpecial = null;
	
	public var customise:WeaponCustomise = null;
	
	// ranged
	public var missileSpecial:MissileSpecial = null;

	public var stuckChance:Int = 0; // the use of ammunition may overwrite this, and defaults for ranged category will overwrite this
	
	// Bow 
	public var requiredStr:Int = 0; 
	
	// Crossbow (if specified, overrides bow)
	public var crossbow:Crossbow = null;
	
	// Firearm (if specified, may stack with crossbow for a crossbow+firearm hybrid)
	public var firearm:Firearm = null;
	

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
	
	public function matchesTypes(ranged:Bool, ?profs:Int):Void {
		var thisProfs = this.profs;
		this.ranged = ranged && (profs == null || (profs & thisProfs) != 0);
	}
	
	public function isBow():Bool {
		var a = (profs & (1<<Profeciency.R_BOW)) != 0;
		return ranged && a;
	}
	public function isCrossbow():Bool {
		var a = this.crossbow != null;
		return ranged && a;
	}
	public function isFirearm():Bool {
		var a = this.firearm != null;
		return ranged && a;
	}

	

	
	public function profLabels():String {
		var arr = Profeciency.getLabelsOfArrayProfs(ranged ? Profeciency.getCoreRanged() : Profeciency.getCoreMelee(), profs);
		if (profsCustom != null) {
			for (i in 0...profsCustom.length) {
				arr.push(profsCustom[i].name);
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
		return (firearm != null && firearm.firingMechanism != null ? firearm.firingMechanism.name+ " " : "") + name + (customise != null ? "("+(customise.name != null ? customise.name : customise.uid)+")" : ""); 
	}
	
	override public function getTypeLabel():String {
		return "Weapon";
	}
	
}