package troshx.sos.core;
import troshx.sos.core.Arrows.Arrow;

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
	
	public function Arrow(name:String = "", catchChance:Int = 0, id:String = "")) {
		super(id, name);
		stuckChance = catchChance;
		isAmmo = true;
	}
	
	
	public static function getNewDefaultList():Array<Ammunition> {
		var a:Array<Ammunition> = [];
		var f;
		a[BODKIN] = f= new Arrow("Bodkin", 1).setWeightCost(0, 1, Item.SP).setUnit(20);
		a[BARBED_BROADHEAD] = f= new Arrow("Barbed Broadhead", 10).setWeightCost(0, 4, Item.SP).setUnit(20);
		a[BLUDGEON_STUN] = f= new Arrow("Bludgeon/Stun Arrow", 0).setWeightCost(0, 10, Item.CP).setUnit(20);
		a[BROADHEAD] = f = new Arrow("Broadhead", 5).setWeightCost(0, 2, Item.SP).setUnit(20);
		//a[SHOT] = f = new Arrow("Shot", 9).setWeightCost(0, 1, Item.CP).setUnit(20);
		//a[SPIKE] = f = new Arrow("Spike", 1).setWeightCost(0, 1, Item.CP).setUnit(20);
		return a;
	}
}