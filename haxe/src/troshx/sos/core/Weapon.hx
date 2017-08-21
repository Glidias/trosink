package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Weapon extends Item
{
	
	public var customiseFlags:Int = 0;
	
	public var profs:Array<Profeciency> = [];
	
	public var reach:Int = 4;
	
	public var variant:Weapon = null;
	
	public var atn:Int = 0;
	public var atnT:Int = 0;
	
	public var damageType:Int = DamageType.CUTTING;
	public var damageTypeT:Int = DamageType.PIERCING;
	
	public var dtn:Int = 0; 
	public var guard:Int = 0;
	
	public var specialFlags:Int = 0;
	public var meleeSpecial:MeleeSpecial = null;
	public var missileSpecial:MissileSpecial = null;
	
	
	// Bow
	public var requiredStr:Int = 0;  // may be used for others?
	
	// Crossbow
	public var span:Int = 0;
	public var spanningTool:Int = 0;
	
	

	public function new(id:String= "", name:String = "" ) 
	{
		super(id, name);
	}
	
	override function get_uid():String 
	{
		return super.get_uid() + "_" + customiseFlags; // id != "" ? id : name;
	}
	
	override function get_label():String {
		return name + (customiseFlags != 0 ? "(_"+customiseFlags+")" : "");  // todo: get labeling for customise flags
	}
	
	override public function getTypeLabel():String {
		return "Weapon";
	}
	
}