package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import troshx.sos.core.Armor;
import troshx.sos.core.Inventory;
import troshx.sos.core.Inventory.ReadyAssign;
import troshx.sos.core.Item;


/**
 * ...
 * @author Glidias
 */
class SelectHeld extends VComponent<NoneT, SelectHeldProps>
{

	public static inline var NAME:String = "select-held";
	
	public function new() 
	{
		super();
		untyped this.mixins = [  MeleeVariantMixin.getInstance() ];
	}
	@:computed function get_gotVariant():Bool {
		
		return MeleeVariantMixin.inlineGotVariant(this.weaponAssign);
	}
	
	
	
	@:computed function get_item():Item {
		if (entry.weapon != null) return entry.weapon;
		else if (entry.shield != null) return entry.shield;
		else if (entry.armor != null) return entry.armor;
		else if (Std.is(entry, Armor)) return entry;
		else return entry.item;
	}
	@:computed function get_twoHanded():Bool {
		var stdH = this.item.twoHanded;
		var b = gotVariant ? this.weaponAssign.holding1H && this.weaponAssign.weapon.variant != null : false;
		return b ? false : stdH;
	}
	
	function holdItemHandler(itemEntry:ReadyAssign, held:Int):Void {
		this.inventory.holdEquiped(itemEntry, held);
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

typedef SelectHeldProps = {
	var entry:Dynamic;
	var inventory:Inventory;
	@:prop({required:false}) @:optional var weaponAssign:WeaponAssign;
}