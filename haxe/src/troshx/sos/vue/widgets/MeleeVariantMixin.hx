package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.core.Inventory.WeaponAssign;

/**
 * ...
 * @author Glidias
 */
class MeleeVariantMixin extends VComponent<NoneT, MeleeVariantProps>
{

	function new() 
	{
		super();
	}
	
	
	static var INSTANCE:MeleeVariantMixin;
	public static function getInstance():MeleeVariantMixin {
		return INSTANCE != null ? INSTANCE : (INSTANCE = new MeleeVariantMixin());
	}
	
	@:computed function get_gotVariant():Bool {
		
		return inlineGotVariant(this.weaponAssign);
	}
	
	public static inline function inlineGotVariant(weaponAssign:WeaponAssign):Bool {
		var result:Bool = false;
		if (weaponAssign != null ) {
			var a =  weaponAssign.weapon.variant != null;
			var b = weaponAssign.holding1H;
			result = a && b;
		}
		
		return result;
	}
	
}
typedef MeleeVariantProps = {
	@:prop({required:false}) @:optional var weaponAssign:WeaponAssign;
}
