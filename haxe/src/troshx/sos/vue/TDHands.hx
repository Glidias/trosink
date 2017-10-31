package troshx.sos.vue;
import js.html.HtmlElement;
import troshx.sos.core.Inventory.WeaponAssign;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import js.html.Event;
import troshx.sos.core.Item;
import troshx.sos.core.MeleeSpecial;
import troshx.sos.core.Profeciency;
import troshx.sos.core.Weapon;
import troshx.sos.vue.TDHands.TDHandsData;

/**
 * 
 * @author Glidias
 */
class TDHands extends VComponent<TDHandsData, TDHandsProps>
{

	public static inline var NAME:String = "td-hands";
	
	public function new() 
	{
		super();
	}
	
	override function Data():TDHandsData {
		return {
			handOffCache: null
		}
	}
	
	
	@:computed function get_isTwoHandedHandOff():Bool {
		return Weapon.isTwoHandedOff(entry.weapon);
	}
	
	@:watch function watch_isTwoHandedHandOff(newVal:Bool):Void {
		
		if (!newVal) {
			
			if (entry.weapon.ranged) {
				this.handOffCache = null;
				
				entry.weapon.variant = null;
				entry.holding1H = false;
			}
			else {
				this.handOffCache = entry.weapon.variant;
				entry.weapon.variant = null;
			}
		}
		else {
			if (entry.weapon.variant==null) {
				entry.weapon.variant = this.handOffCache;
			}
			
		}
	}
	
	@:computed function get_gotVariant():Bool {
		var a =  entry.holding1H;
		
		var b = this.entry.weapon.variant != null;
		return a && b;
	}
	
	@:computed function get_isTwoHanded():Bool {
		return this.entry.weapon.twoHanded;
	}
	
	function onSelectChange(e:Event, weapon:Weapon):Void {
		var dyn:Dynamic = e.target;
		var htmlElem:HtmlElement = dyn;
		var val:Int = dyn.value;
		if (this.isTwoHandedHandOff) {
			
			if (this.entry.weapon.variant == null) {
				this.entry.weapon.variant = new Weapon(this.entry.weapon.id, this.entry.weapon.name);
				this.entry.weapon.variant.profs = Profeciency.matchHandOffProfs(this.entry.weapon.profs);
			}
			if (val == 1) {
				entry.holding1H = false;
				
			}
			else {
				entry.holding1H = true;

			}
		}
		else {
			if (val == 1) {
				this.entry.weapon.flags |= Item.FLAG_TWO_HANDED;
			}
			else {
				this.entry.weapon.flags &= ~Item.FLAG_TWO_HANDED;
			}
		}

	}
	
	function shiftIndex(i:Int):Int {
		return (1 << i);
	}
	function emit(str:String):Void {
		_vEmit(str);
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
}

typedef TDHandsProps = {
	var entry:WeaponAssign;
}

typedef TDHandsData = {
	var handOffCache:Weapon;
}