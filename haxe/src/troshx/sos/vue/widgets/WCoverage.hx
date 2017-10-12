package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import haxevx.vuex.util.VHTMacros;
import js.html.InputElement;
import troshx.sos.core.Armor;
import troshx.sos.core.BodyChar;
import troshx.sos.core.BodyChar.Humanoid;
import troshx.sos.core.HitLocation;
import troshx.sos.vue.widgets.BaseItemWidget.BaseItemWidgetProps;
import troshx.util.LibUtil;

/**
 * Widget to handle various body coverage for armor/shield protection
 * @author Glidias
 */
class WCoverage extends VComponent<NoneT, WCoverageProps>
{
	public static inline var NAME:String = "w-coverage";

	public function new() 
	{
		super();
	
	}
	
	
	function checkboxHandler(checkbox:InputElement, i:Int):Void {
		var armor:Armor = this.armor;
		var hitLocations:Array<HitLocation> = this.hitLocations;
		var ider:String = hitLocations[i].id;
		if (checkbox.checked) {
			Vue.set(armor.coverage, ider, 0); 
		}
		else {
			Vue.delete(armor.coverage, ider); 
			if (armor.special != null ) {
				armor.special.layerCoverage &= ~(1 << i);
				if (armor.special.hitModifier != null) {
					armor.special.hitModifier.locationMask &= ~(1 << i);
				}
			}
			if (armor.customise != null && armor.customise.hitLocationAllAVModifiers!=null) {
				Vue.delete( armor.customise.hitLocationAllAVModifiers, ider);
			}
			
		}
	}
	
	@:computed inline function get_isCustomBody():Bool {
		return customBody != null && customBody != BodyChar.getInstance();
	}
	
	@:computed function get_hitLocations():Array<HitLocation> {
		// etNewHitLocationsFrontSlice()
		return !this.isCustomBody ? BodyChar.getInstance().hitLocations  : this.customBody.hitLocations;
	}
	
	@:computed inline function get_armor():Armor {
		return LibUtil.as(item, Armor);
	}
	
	function isInnerChecked(i:Int, flagIndex:Int):Bool {
		var hitLocations:Array<HitLocation> = this.hitLocations;
		return (LibUtil.field(this.armor.coverage, hitLocations[i].id) & (1 << flagIndex))!=0;
	}
	
	function innerCheckboxHandler(checkbox:InputElement, i:Int, flagIndex:Int):Void {
		var armor:Armor = this.armor;
		var hitLocations:Array<HitLocation> = this.hitLocations;
		var ider:String = hitLocations[i].id;
		var curValue = LibUtil.field(armor.coverage, ider);
		if (checkbox.checked) {
			Vue.set(armor.coverage, ider, curValue|(1<<flagIndex)); 
		}
		else {
			Vue.set(armor.coverage, ider, curValue&(~(1<<flagIndex)) );
		}
	}
	
	override function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	
}

typedef WCoverageProps = {
	>BaseItemWidgetProps,
	@:prop({required:false}) @:optional var customBody:BodyChar;
}