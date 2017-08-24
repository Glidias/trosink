package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Weapon extends Item
{
	public var profs:Int = 0;
	public var profsCustom:Array<Profeciency> = null;
	
	public var reach:Int = 4;   
	
	public var variant:Weapon = null;
	
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
	public var missileSpecial:MissileSpecial = null;
	
	public var customise:WeaponCustomise = null;

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
	
	override function get_uid():String 
	{
		return super.get_uid() + (customise != null ?  "_"+customise.uid : "" ); // id != "" ? id : name;
	}
	
	override function get_label():String {
		return name + (customise != null ? "("+(customise.name != null ? customise.name : customise.uid)+")" : ""); 
	}
	
	override public function getTypeLabel():String {
		return "Weapon";
	}
	
}