package troshx.tros;
import haxe.ds.StringMap;

/**
 * ...
 * @author Glidias
 */
@:expose
class WeaponSheet
{

	public function new() 
	{
		
	}
	
	public static function getWeaponByName(name:String):Weapon {
		return HASH.get(name);
	}
	
	public static inline function weaponNameIsShield(name:String):Bool {
		var weap:Weapon = getWeaponByName(name);
		return weap != null ? weaponIsShield(weap) : false;
	}
	
	public static inline function weaponIsShield(weapon:Weapon):Bool {
		return weapon.shield;
	}

	public static function createHashLookupViaName(arr:Array<Weapon>):StringMap<Weapon> {
		var obj:StringMap<Weapon> = new StringMap<Weapon>();
		for (i in 0...arr.length) {
			var lookinFor:Weapon = arr[i];
			obj.set(lookinFor.name, lookinFor);
		}
		return obj;
	}
		
	//http://knight.burrowowl.net/doku.php?id=equipment:weapons
	public static var LIST:Array<Weapon> = [
		//Weapon.createDyn("Akinakes", "
		Weapon.createDyn("Short Sword", ["cutthrust", "swordshield"], { "range":1, "atn":7, "atn2":5, "dtn":7,   "damage": -1, "damage2":1  } )
	//	,Weapon.createDyn("Kick", ["pugilism"], { "range":0, "atn":7, "dtn":8,  "shieldLimit":1, "damage":-1, "blunt":true  } )
	//	,Weapon.createDyn("Punch", ["pugilism"], { "range":0, "atn":5, "dtn":6, "shieldLimit":1,  "damage":-2, "blunt":true  } )
		
		,Weapon.createDyn("Gladius", ["swordshield"], { "range":1, "atn":6, "atn2":6, "dtn":7,   "damage":0, "damage2":1, "drawCutModifier":0  } )
		,Weapon.createDyn("Blunted Sword", ["swordshield", "cutthrust"], { "range":2, "atn":6, "atn2":6, "dtn":6,   "damage":0, "damage2":0, "drawCutModifier":0  } )
		,Weapon.createDyn("Arming Sword", ["swordshield", "cutthrust"], { "range":2, "atn":6, "atn2":7, "dtn":6,   "damage":1, "damage2":0, "drawCutModifier":0  } )
		,Weapon.createDyn("Rapier", ["rapier", "caserapiers"], { "range":3, "atn":7, "atn2":5, "dtn":8, "dtnT":6,  "damage": -3, "damage2":2, "drawCutModifier":1  } )
		
		//,Weapon.createDyn("Arming Glove", ["swordshield", "massweaponshield"], { "range":0, "shield":true, "shieldLimit":4, "atn":5, "dtn":7,  "damage":-1, "blunt":true } )
		,Weapon.createDyn("Hand Shield", ["swordshield", "massweaponshield"], { "shield":true, "dtn":7, "dtn2":9 } )
		,Weapon.createDyn("Small Shield", ["swordshield", "massweaponshield"], { "shield":true, "dtn":6, "dtn2":8 } )
		,Weapon.createDyn("Medium Shield", ["swordshield", "massweaponshield"], { "shield":true, "dtn":5, "dtn2":7, "cpPenalty":0.5, "movePenalty":0.5 } )
		,Weapon.createDyn("Large Shield", ["swordshield", "massweaponshield"], {"shield":true, "dtn":5, "dtn2":6, "cpPenalty":0.5, "movePenalty":1} )
	
	];
	
	public static var HASH:StringMap<Weapon> = createHashLookupViaName(LIST);
	
}