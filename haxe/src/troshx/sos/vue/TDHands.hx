package troshx.sos.vue;
import js.html.HtmlElement;
import troshx.sos.core.Inventory.WeaponAssign;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import js.html.Event;
import troshx.sos.core.Item;
import troshx.sos.core.Weapon;

/**
 * 
 * @author Glidias
 */
class TDHands extends VComponent<NoneT, TDHandsProps>
{

	public static inline var NAME:String = "td-hands";
	
	public function new() 
	{
		super();
	}
	
	
	
	@:computed function get_isTwoHanded():Bool {
		return this.entry.weapon.twoHanded;
	}
	
	function onSelectChange(e:Event, weapon:Weapon):Void {
		var dyn:Dynamic = e.target;
		var htmlElem:HtmlElement = dyn;
		var val:Int = dyn.value;
		if (val == 1) {
			this.entry.weapon.flags |= Item.FLAG_TWO_HANDED;
		}
		else {
			this.entry.weapon.flags &= ~Item.FLAG_TWO_HANDED;
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