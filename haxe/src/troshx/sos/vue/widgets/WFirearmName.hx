package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import haxevx.vuex.util.VHTMacros;
import troshx.sos.core.Firearm.FiringMechanism;
import troshx.sos.core.Weapon;
import troshx.sos.vue.widgets.BaseItemWidget.BaseItemWidgetProps;
import troshx.util.LibUtil;


/**
 * ...
 * @author Glidias
 */
class WFirearmName extends VComponent<WFirearmNameData, WFirearmNameProps>
{
	public static inline var NAME:String = "w-firearm-name";

	public function new() 
	{
		super();
	
	}
	
	override function Data():WFirearmNameData {
		return {
			mechanismCache:null,
			selectedMechanismIndex: -1,
		}
	}
	
	override function Mounted():Void {

		this.selectedMechanismIndex = this.firingMechanism != null ?  this.availableFiringMechanisms.indexOf( this.firingMechanism ) : null;
	}
	
	
	@:computed function get_availableFiringMechanisms():Array<FiringMechanism> {
		return this.customFiringMechanisms != null ? this.customFiringMechanisms.concat(FiringMechanism.getDefaultList()) : FiringMechanism.getDefaultList();
	}
	
	@:computed function get_weapon():Weapon {
		return LibUtil.as(item, Weapon);
	}
	
	@:computed function get_firingMechanism():FiringMechanism {
		return this.weapon.firearm != null ?  this.weapon.firearm.firingMechanism : null;
	}
	
	@:watch function watch_selectedMechanismIndex(newValue:Int, oldValue:Int) {
		var avail:Array<FiringMechanism> = availableFiringMechanisms;
		if (newValue >= 0) {
			this.weapon.firearm.firingMechanism = avail[newValue];
		}
		else {
			this.weapon.firearm.firingMechanism = null;
		}
	}
	
	override function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	
}

typedef WFirearmNameData = {
	var mechanismCache:FiringMechanism;
	var selectedMechanismIndex:Int;
}

typedef WFirearmNameProps = {
	>BaseItemWidgetProps,
	@:optional @:prop({required:false}) public var customFiringMechanisms:Array<FiringMechanism>;
}