package troshx.sos.core;
import troshx.sos.core.Firearm.Ammunition;
import troshx.sos.core.Firearm.FiringMechanism;

/**
 * ...
 * @author Glidias
 */
class Firearm
{
	@:flagInstances(Ammunition) public var ammunitions:Int = 0;
	public var ammunitionsCustom:Array<String> = null;
	
	@:tag4ammo() public var load:Int = 0;
	
	public var double:Bool = false;
	public var multishot:Int = 0;
	public var magazine:Int = 0;
	public var revolver:Int = 0;
	public var highCaliber:Int = 0;
	
	public var firingMechanism:FiringMechanism = null;
	
	
	public function new() 
	{
		
	}
	
	public function  addTagsToStrArr(arr:Array<String>, addSign:Bool, forAmmo:Bool):Void {
		if (double) arr.push("Double");
		if (multishot != 0) arr.push("Multishot " + (addSign ? Item.sign(multishot) : "") + multishot);
		if (magazine != 0) arr.push("Magazine " + (addSign ? Item.sign(magazine) : "") +  magazine);
		if (revolver !=0) arr.push("Revolver " + (addSign ? Item.sign(revolver) : "") +  revolver);
		if (revolver != 0) arr.push("High Caliber " + (addSign ? Item.sign(highCaliber) : "") +  highCaliber);
		if (forAmmo && load != 0)  arr.push("Load " + (addSign ? Item.sign(load) : "") +  load);
	}
	
	
	public function getAmmunitionsStrArr():Array<String> {
		var arr:Array<String> = Item.getLabelsOfArray(Ammunition.getDefaultList(), ammunitions);
		if (ammunitionsCustom != null) arr = ammunitionsCustom.concat(arr);
		return arr;
	}
	
}

class FiringMechanism extends Item
{
	
	@:flagInstances(LoadingMechanism) public var loadingMechanisms:Int;
	public var loadingMechanismsCustom:Array<String> = null;
	
	// todo: specials as a series of stats, or modifying functions?
	
	public static inline var CAPLOCK:Int = 0;
	public static inline var FIRELOCK:Int = 1;
	public static inline var FLINTLOCK:Int = 2;
	public static inline var MATCHLOCK:Int = 3;
	public static inline var NEEDLEFIRE:Int = 4;
	public static inline var SNAPLOCK:Int = 5;
	public static inline var WHEELOCK:Int = 6;
	
	static var LIST:Array<FiringMechanism>;  
	public static function getDefaultList():Array<FiringMechanism> {
		return LIST != null ? LIST : (LIST=getNewDefaultList());
	}
	public static function getNewDefaultList():Array<FiringMechanism> {
		var a:Array<FiringMechanism> = [];
		var f;
		a[CAPLOCK] = f= new FiringMechanism("Caplock", Item.getInstanceFlagsOf( LoadingMechanism, [MANUAL, PAPER_CATRIDGE])).setWeightCost(0, 12, Item.GP);
		a[FIRELOCK] = f= new FiringMechanism("Firelock", Item.getInstanceFlagsOf( LoadingMechanism, MANUAL) );
		a[FLINTLOCK] = f= new FiringMechanism("Flintlock", Item.getInstanceFlagsOf( LoadingMechanism, [MANUAL, PAPER_CATRIDGE])).setWeightCost(0, 3, Item.SP);
		a[MATCHLOCK] = f= new FiringMechanism("Matchlock", Item.getInstanceFlagsOf( LoadingMechanism, [MANUAL, PAPER_CATRIDGE])).setWeightCost(0, 6, Item.CP);
		a[NEEDLEFIRE] = f= new FiringMechanism("Needlefire", Item.getInstanceFlagsOf( LoadingMechanism, [PAPER_MACHE_CATRIDGE, BRASS_CATRIDGE])).setWeightCost(0, 5, Item.GP);
		a[SNAPLOCK] = f= new FiringMechanism("Snaplock", Item.getInstanceFlagsOf( LoadingMechanism, [MANUAL,PAPER_CATRIDGE])).setWeightCost(0, 2, Item.SP);
		a[WHEELOCK] = f= new FiringMechanism("Wheelock", Item.getInstanceFlagsOf( LoadingMechanism, [MANUAL,PAPER_CATRIDGE])).setWeightCost(0, 8, Item.SP);
		return a;
	}

	public function new(name:String="", loadingMechanisms:Int=0, id:String="") 
	{
		super(id, name);
		this.loadingMechanisms = loadingMechanisms;
	}
}

//  class to set up official ammo. Custom weapon ammo may simply be a weapon with isAmmo == true
class Ammunition extends Weapon
{
	// todo: specials as a series of hard modifiers
	
	public function new(name:String="", catchChance:Int=0, id:String="") 
	{

		super(id, name);
		stuckChance = catchChance;	
		ranged = true;
		isAmmo = true;
		profs = (1 << Profeciency.R_FIREARM);
	}
	
	static var LIST:Array<Ammunition>;  
	public static function getDefaultList():Array<Ammunition> {
		return LIST != null ? LIST : (LIST=getNewDefaultList());
	}
	
	public static inline var BALL:Int = 0;
	public static inline var BUCK_AND_BALL:Int = 1;
	public static inline var HEAVY_SHOT:Int = 2;
	public static inline var RIFLE_BALL:Int = 3;
	public static inline var SHOT:Int = 4;
	public static inline var SPIKE:Int = 5;
	
	
	public static function getNewDefaultList():Array<Ammunition> {
		var a:Array<Ammunition> = [];
		var f:Ammunition;
		
		a[BALL] = f = new Ammunition("Ball", 9).setWeightCost(0, 1, Item.CP).setUnit(10);
		f.missileSpecial = new MissileSpecial();
		f.missileSpecial.AP = 4;
		
		a[BUCK_AND_BALL] = f = new Ammunition("Buck and Ball", 9).setWeightCost(0, 1, Item.CP).setUnit(10);
		f.missileSpecial = new MissileSpecial();
		f.missileSpecial.scatter = 3;
		f.missileSpecial.scatter_y = 6;
		f.missileSpecial.AP = 2;
		f.missileFlags = MissileSpecial.AP_FIRST_HIT_ONLY;
		
		a[HEAVY_SHOT] = f = new Ammunition("Heavy Shot", 9).setWeightCost(0, 3, Item.CP).setUnit(10);
		f.missileSpecial = new MissileSpecial();
		f.missileSpecial.scatter = 8;
		f.missileSpecial.scatter_y = 6;
		
		a[RIFLE_BALL] = f = new Ammunition("Rifle Ball", 8).setWeightCost(0, 6, Item.CP).setUnit(10);
		f.atnM = -1;
		f.missileSpecial = new MissileSpecial();
		f.missileSpecial.AP = 4;
		f.firearm = new Firearm();
		f.firearm.load = -10;
		
		
		a[SHOT] = f = new Ammunition("Shot", 9).setWeightCost(0, 1, Item.CP).setUnit(10);
		f.missileSpecial = new MissileSpecial();
		f.missileSpecial.scatter = 6;
		f.missileSpecial.scatter_y = 6;
		
		a[SPIKE] = f = new Ammunition("Spike", 1).setWeightCost(0, 1, Item.CP);
		f.damageM = 2;
		f.atnM = -1;
		f.range = 3;
		f.firearm = new Firearm();
		f.firearm.load = 10;
		
		return a;
	}
}
	
class LoadingMechanism
{
	public var name:String;
	public var loadBonus:Int;
	public var ammunitionCostModifier:Int;  // in percentage
	public var ammunitionCostRatio(get, never):Float;
	function get_ammunitionCostRatio():Float 
	{
		return ammunitionCostModifier/100;
	}
	
	public static inline var MANUAL:Int = 0;
	public static inline var BRASS_CATRIDGE:Int = 1;
	public static inline var PAPER_CATRIDGE:Int = 2;
	public static inline var PAPER_MACHE_CATRIDGE:Int = 3;
	
	static var LIST:Array<LoadingMechanism>;  
	public static function getDefaultList():Array<LoadingMechanism> {
		return LIST != null ? LIST : (LIST=getNewDefaultList());
	}
	public static function getNewDefaultList():Array<LoadingMechanism> {
		var a:Array<LoadingMechanism> = [];
		var f;
		a[MANUAL] = f= new LoadingMechanism("Manual", 0, 100);
		a[BRASS_CATRIDGE] = f= new LoadingMechanism("Brass Catridge", 10, 1000);
		a[PAPER_CATRIDGE] = f= new LoadingMechanism("Paper Catridge", 3, 200);
		a[PAPER_MACHE_CATRIDGE] = f= new LoadingMechanism("Paper Mache Catridge", 5, 300);
	
		return a;
	}
	
	
	public function new(name:String="", loadBonus:Int=0, ammunitionCostModifier:Int=100) 
	{
		this.name = name;
		this.loadBonus = loadBonus;
		this.ammunitionCostModifier = ammunitionCostModifier;
	}
	
	
	
}