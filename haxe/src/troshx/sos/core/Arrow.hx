package troshx.sos.core;


/**
 * ...
 * @author Glidias
 */
class Arrow extends Weapon
{
	static var LIST:Array<Arrow>;  
	public static function getDefaultList():Array<Arrow> {
		return LIST != null ? LIST : (LIST=getNewDefaultList());
	}
	
	public static inline var BODKIN:Int = 0;
	public static inline var BARBED_BROADHEAD:Int = 1;
	public static inline var BLUDGEON_STUN:Int = 2;
	public static inline var BROADHEAD:Int = 3;
	public static inline var FIRE_ARROW:Int = 4;
	public static inline var HEAVY_BROADHEAD:Int = 5;
	public static inline var LOZENGE_HEAD:Int = 6;
	public static inline var SWALLOWTAIL:Int = 7;
	
	public function new(name:String = "", catchChance:Int = 0, id:String = "") {
		super(id, name);
		stuckChance = catchChance;
		isAmmo = true;
		ranged = true;
		profs = (1 << Profeciency.R_BOW) | (1 << Profeciency.R_CROSSBOW);
	}
	
	
	public static function getNewDefaultList():Array<Arrow> {
		var a:Array<Arrow> = [];
		var f:Arrow;
		
		a[BODKIN] = f = new Arrow("Bodkin", 1).setWeightCost(0, 1, Item.SP).setUnit(20);
		f.range = 10;
		f.missileFlags = MissileSpecial.NARROW;
		
		a[BARBED_BROADHEAD] = f = new Arrow("Barbed Broadhead", 10).setWeightCost(0, 4, Item.SP).setUnit(20);
		f.missileSpecial = new MissileSpecial();
		f.missileSpecial.winged = 2;
		
		a[BLUDGEON_STUN] = f = new Arrow("Bludgeon/Stun Arrow", 0).setWeightCost(0, 10, Item.CP).setUnit(20);
		f.missileSpecial = new MissileSpecial();
		f.missileSpecial.shock = 2;
		f.missileFlags = MissileSpecial.BLUDGEON;
		f.range = -5;
		
		a[BROADHEAD] = f = new Arrow("Broadhead", 5).setWeightCost(0, 2, Item.SP).setUnit(20);
		f.damageM = -1;
		f.missileSpecial = new MissileSpecial();
		f.missileSpecial.winged = 2;
		
		
		a[FIRE_ARROW] = f = new Arrow("Fire Arrow", 5).setWeightCost(0, 2, Item.SP).setUnit(20);
		f.damageM = -1;
		f.atnM = 1;
		f.range = -5;
		f.missileSpecial = new MissileSpecial();
		f.missileSpecial.flaming = 1;
		
		a[HEAVY_BROADHEAD] = f = new Arrow("Heavy Broadhead", 5).setWeightCost(0, 3, Item.SP).setUnit(20);
		f.damageM = -2;
		f.range = -5;
		f.missileSpecial = new MissileSpecial();
		f.missileSpecial.winged = 2;
		
		a[LOZENGE_HEAD] = f = new Arrow("Lozenge-Head", 2).setWeightCost(0, 2, Item.SP).setUnit(20);
		f.range = -5;
		f.missileSpecial = new MissileSpecial();
		f.missileSpecial.AP = 2;
		
		a[SWALLOWTAIL] = f = new Arrow("Swallowtail", 8).setWeightCost(0, 4, Item.SP).setUnit(20);
		f.requiredStr = -1;
		f.missileSpecial = new MissileSpecial();
		f.missileSpecial.winged = 1;
		
		return a;
	}
}