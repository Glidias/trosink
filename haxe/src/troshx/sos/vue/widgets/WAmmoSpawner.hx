package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import troshx.sos.core.Weapon;
import troshx.sos.core.Arrow;
import troshx.sos.core.Firearm.Ammunition;
import troshx.sos.vue.widgets.WAmmunition.AmmunitionData;

/**
 * ...
 * @author Glidias
 */
class WAmmoSpawner extends VComponent<WAmmoSpawnerData, WAmmoSpawnerProps>
{
	
	public static inline var NAME:String = "w-ammo-spawner";

	public function new() 
	{
		super();
	}
	
	override function Data() {
		return {
			ammoList: Ammunition.getDefaultList(),
			arrowList: Arrow.getDefaultList(),
		}
	}
	
	override public function Template() {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	@:computed function get_combinedList():Array<Weapon> {
		var arr:Array<Weapon> = [];
		for (i in 0...ammoList.length) {
			arr.push(ammoList[i]);
		}
		
		for (i in 0...arrowList.length) {
			arr.push(arrowList[i]);
		}
	
		return arr;
	}
	
	@:computed function get_filteredList():Array<Weapon> {

		var arr:Array<Weapon> = [];
		var mask = this.mask;
		var list = this.combinedList;
		for (i in 0...list.length) {
			var w = list[i];
			if ( mask == 0 || (mask & w.profs) != 0) arr.push(w);
		}
		return arr;
	}
	
	
	
	
}

typedef WAmmoSpawnerProps = {
	@:prop({required:false, "default":0}) @:optional var mask:Int;
	@:prop({required:true}) var addAmmo:Weapon->Void;
}

typedef WAmmoSpawnerData = {
	var ammoList:Array<Ammunition>;
	var arrowList:Array<Arrow>;
}