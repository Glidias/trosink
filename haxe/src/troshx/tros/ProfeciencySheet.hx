package troshx.tros;
import haxe.ds.StringMap;
import troshx.core.CharSheet;
import troshx.core.Profeciency;

/**
 * ...
 * @author Glidias
 */
class ProfeciencySheet {
	
	//http://knight.burrowowl.net/doku.php?id=rules:proficiencies
	public static var LIST:Array<Profeciency> = [
		new Profeciency("swordshield", "Sword and Shield", ManueverSheet.createOffensiveMeleeMaskFor(["bindstrike", "cut", "cut2", "feintcut", "feintthrust", "blockstrike", "thrust", "thrust2", "twitching", "masterstrike", "disarm"]), ManueverSheet.createDefensiveMeleeMaskFor(["block", "blockopenstrike", "counter", "parry", "disarm", "masterstrike", "overrun", "parry", "rota"]), { "blockopenstrike":2, "masterstrike":6 }, { "blockopenstrike":2, "counter":[3, 2], "disarm":3, "masterstrike":6, "overrun":4, "parry":[1, 0], "rota":2 }, { "caserapiers":4, "cutthrust":2, "dagger":2, "doppelhander":4, "greatlongsword":2, "massweaponshield":1, "polearms":4, "poleaxe":4, "pugilism":4, "rapier":4, "wrestling":4 } ),
		new Profeciency("cutthrust", "Cut and Thrust", ManueverSheet.createOffensiveMeleeMaskFor(["beat", "bindstrike", "cut", "disarm", "doubleattack", "drawcut", "feint", "masterstrike", "quickdraw", "blockstrike", "stopshort", "thrust", "toss", "twitch"]), ManueverSheet.createDefensiveMeleeMaskFor(["block", "counter", "disarm", "expulsion", "grapple", "masterstrike", "overrun", "parry", "rota"]), { "disarm":1, "masterstrike":6, "quickdraw":2, "twitch":2 }, { "counter":2, "disarm":3, "expulsion":2, "grapple":2, "masterstrike":6, "overrun":3 }, { "caserapiers":3, "dagger":2, "doppelhander":4, "greatlongsword":3, "massweaponshield":2, "polearms":3, "poleaxe":4, "pugilism":2, "rapier":2, "swordshield":2, "wrestling":3 } ),
		new Profeciency("rapier", "Rapier", ManueverSheet.createOffensiveMeleeMaskFor(["beat", "bindstrike", "disarm", "doubleattack", "feintthrust", "masterstrike", "blockstrike", "stopshort", "thrust", "toss"]), ManueverSheet.createDefensiveMeleeMaskFor(["block", "counter", "disarm", "expulsion", "grapple", "masterstrike", "overrun", "parry"]), { "disarm":1, "feintthrust":1, "masterstrike":6 }, { "counter":3, "disarm":3, "expulsion":2, "grapple":2, "masterstrike":6, "overrun":3, "parry":0 }, {  "caserapiers":1, "cutthrust":2, "dagger":2, "doppelhander":4, "greatlongsword":4, "massweaponshield":4, "polearms":3, "poleaxe":4, "pugilism":2, "swordshield":3, "wrestling":3 }  ),
		new Profeciency("pugilism", "Pugilism", ManueverSheet.createOffensiveMeleeMaskFor(["disarm", "grapple", "kick", "punch"]), ManueverSheet.createDefensiveMeleeMaskFor(["disarm", "grapple", "parry"]), { "disarm":2, "grapple":[2,4], "kick":1  }, { "disarm":4, "grapple":2 }, { "caserapiers":4, "cutthrust":4,  "dagger":1, "doppelhander":4, "greatlongsword":4, "massweaponshield":3, "polearms":4, "poleaxe":4, "rapier":3, "swordshield":4, "wrestling":1 })
	];
	
	public static var listHashIndexer:StringMap<Int> = createHashIndex(LIST);
	public static function getProfeciency(id:String):Profeciency {
		return LIST[listHashIndexer.get(id)];
	}
	
	public static function createHashIndex(arr:Array<Profeciency>):StringMap<Int> {
			var obj:StringMap<Int> = new StringMap<Int>();
			
			for (i in 0...arr.length) {
			//	obj[arr[i].id] = i;
				obj.set(arr[i].id, i);
			}
			return obj;
		}
		
	
	/*
	public static function getProfManueverCost(id:String):int {
		
	}
	*/
	
	public static function resolveProfManueverCostChoice(id:String, arr:Array<Int>, charSheet:CharSheet):Int {

		if (id == "counter") {
		//	charSheet = components.char;
			return charSheet.weaponOffhand != null && charSheet.weaponOffhand.shield ? arr[0] : arr[1];
		}
		else if (id == "parry") {
		//	charSheet = components.char;
			return charSheet.weaponOffhand != null && charSheet.weaponOffhand.shield ? arr[0] : arr[1];
		}
		return arr[0];
	}
}