package troshx.sos.core;
import troshx.core.IUid;
import troshx.ds.IUpdateWith;

/**
 * Core profiency class for SoS
 * @author Glidias
 */
class Profeciency implements IUid  implements IUpdateWith<Profeciency>
{
	public var name:String;

	public var uid(get, never):String;
	
	public var type:Int;
	public static inline var TYPE_MELEE:Int = 0;
	public static inline var TYPE_RANGED:Int = 1;
	
	public static inline var MASK_ALL:Int = 2147483647;
	
	// melee core
	public static inline var M_1H_SWORD:Int = 0;
	public static inline var M_1H_BLUNT:Int = 1;
	public static inline var M_2H_BLUNT:Int = 2;
	public static inline var M_2H_SWORD:Int = 3;
	public static inline var M_SPEAR:Int = 4;
	public static inline var M_POLEARM:Int = 5;
	public static inline var M_DAGGER:Int = 6;
	public static inline var M_WRESTLING:Int = 7;
	public static inline var M_PUGILISM:Int = 8;
	static inline var TOTAL_M:Int = 9;
	
	static var CORE_MELEE:Array<Profeciency>;  
	public static function getCoreMelee():Array<Profeciency> {
		return CORE_MELEE != null ? CORE_MELEE : (CORE_MELEE=getNewCoreMelee());
	}
	public static function getNewCoreMelee():Array<Profeciency> {
		var a:Array<Profeciency> = [];
		a[M_WRESTLING] = new Profeciency("Wrestling", TYPE_MELEE);
		a[M_PUGILISM] = new Profeciency("Pugilism", TYPE_MELEE);
		a[M_DAGGER] = new Profeciency("Dagger", TYPE_MELEE);
		a[M_1H_SWORD] = new Profeciency("1H Sword", TYPE_MELEE);
		a[M_1H_BLUNT] = new Profeciency("1H Blunt", TYPE_MELEE);
		a[M_2H_BLUNT] = new Profeciency("2H Blunt", TYPE_MELEE);
		a[M_2H_SWORD] = new Profeciency("2H Sword", TYPE_MELEE);
		a[M_SPEAR] = new Profeciency("Spear", TYPE_MELEE);
		a[M_POLEARM] = new Profeciency("Polearm", TYPE_MELEE);
		return a;
	}
	
	// ranged core
	public static inline var R_BOW:Int = 0;
	public static inline var R_SLING:Int = 1;
	public static inline var R_CROSSBOW:Int = 2;
	public static inline var R_FIREARM:Int = 3;
	public static inline var R_THROWING:Int = 4;
	static inline var TOTAL_R:Int = 5;
	
	static var CORE_RANGED:Array<Profeciency>;  
	public static  inline function getCoreRanged():Array<Profeciency> {
		return CORE_RANGED != null ? CORE_RANGED : (CORE_RANGED=getNewCoreRanged());
	}
	public static function getNewCoreRanged():Array<Profeciency> {
		var a:Array<Profeciency> = [];
		a[R_BOW] = new Profeciency("Bow", TYPE_RANGED);
		a[R_SLING] = new Profeciency("Sling", TYPE_RANGED);
		a[R_CROSSBOW] = new Profeciency("Crossbow", TYPE_RANGED);
		a[R_FIREARM] = new Profeciency("Firearm", TYPE_RANGED);
		a[R_THROWING] = new Profeciency("Throwing", TYPE_RANGED);
		return a;
	}
	
	public static inline function getProfsLabelsMelee(mask:Int):Array<String> {
		return getLabelsOfArrayProfs(getCoreMelee(), mask);
	}
	
	public static inline function getProfsLabelsRanged(mask:Int):Array<String> {
		return getLabelsOfArrayProfs(getCoreRanged(), mask);
	}
	
	public static inline function getProfsCountMelee(mask:Int):Int {
		return getCountOfArrayProfs(getCoreMelee(), mask);
	}
	
	public static inline function getProfsCountRanged(mask:Int):Int {
		return getCountOfArrayProfs(getCoreRanged(), mask);
	}
	
	public static function getCountOfArrayProfs(a:Array<Profeciency>, mask:Int):Int {	
		var count:Int = 0;
		for (i in 0...a.length) {
			count +=  (mask & (1 << i )) != 0  ? 1 : 0;
		}
		return count;
	}
	
	public static function getLabelsOfArrayProfs(a:Array<Profeciency>, mask:Int):Array<String> {	
		var arr:Array<String> = [];
		for (i in 0...a.length) {
			if ( (mask & (1 << i )) != 0 ) {
				arr.push(a[i].name);
 			}
		}
		return arr;
	}
	
	public function new(name:String="", type:Int=0) 
	{
		this.type = type;
		this.name = name;
	}
	
	
	/* INTERFACE troshx.ds.IUpdateWith.IUpdateWith<W> */
	
	public function updateAgainst(ref:Profeciency):Void 
	{
		// do nothing, you can't really duplicate profeciencies
	}
	
	public function spliceAgainst(ref:Profeciency):Int 
	{
		return 0;
	}
	
	inline function get_uid():String 
	{
		return name + SEPERATOR + type;
	}
	
	static var SEPERATOR:String = "_$_";
	
}