package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import haxevx.vuex.util.VHTMacros;
import js.html.Event;
import js.html.HtmlElement;
import js.html.SelectElement;
import troshx.sos.core.Crossbow;
import troshx.sos.core.Firearm;
import troshx.sos.core.Inventory.ReadyAssign;
import troshx.sos.core.Item;
import troshx.sos.core.Profeciency;
import troshx.sos.core.Weapon;
import troshx.sos.vue.CharSheetVue.WidgetItemRequest;
import troshx.sos.vue.widgets.WProf;

/**
 * ...
 * @author Glidias
 */
class TDWeapProfSelect extends VComponent<NoneT, TDWeapProfSelectProps>
{
	public static inline var NAME:String = "td-prof";

	public function new() 
	{
		super();

	}
	
		
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>> {
		return [
			WProf.NAME => new WProf(),
		];
	}
	
	function shiftIndex(i:Int):Int {
		return (1 << i);
	}
	function emit(str:String):Void {
		_vEmit(str);
	}
	
	@:computed function get_hasNoProf():Bool {
		return this.weapon.hasNoProf();
	}
	
	@:computed function get_weaponOptionValue():Int {
		return weapon.ranged ? -weapon.profs : weapon.profs;
	}
	
	@:watch function watch_weaponOptionValue(newValue:Int, oldValue:Int):Void {
		var dom:SelectElement = _vRefs.selectDom;
		Vue.nextTick( function() {
			dom.value =  "" + newValue;  // stupid bug to reassert dom refresh?
		});

		
	}
	
	@:computed function get_gotCustomMultiCheck():Bool {
		var weap:Weapon = this.weapon;
		var a =  weap.isMultipleCoreProf();
		var b = weap.hasCustomProf();
		var c = weap.isAmmunition();
		return a || b  || c;
	}
	
	@:computed function get_showSelectMultipleFirst():Bool {
		var a =  this.gotCustomMultiCheck;
		var b = this.weapon.isAmmunition();
		return a || b;
	}
	
	@:computed function get_multiSelectedOptionLabel():String {
		var weap:Weapon = this.weapon;
		return (weap.isAmmunition() ? "^" : "" )+weap.profLabels();
	}
	
	@:computed function get_isSelectingMultiple():Bool {
		return   isVisibleWidget(section, 'profs', index);
	}
	
	@:computed function get_gotCustom():Bool {
		return this.customProfs != null && this.customProfs.length > 0;
	}
	
	override function Mounted():Void {

		if (this.weapon.profs == 0) this.weapon.profs = 1;
	}
	
	function onProfSelectChange(e:Event, weapon:Weapon):Void {
		var dyn:Dynamic = e.target;
		var htmlElem:HtmlElement = dyn;
		var val:Int = dyn.value;

		
		if (val == 0) {
			var index:Int = Std.parseInt(htmlElem.getAttribute("data-index"));
			var type:String = htmlElem.getAttribute("data-type");
			requestCurWidget(type, index);
			
		}
		else {
			var ranged:Bool = false;
			if (val < 0) {
				ranged = true;
				val = -val;
			}
			weapon.ranged = ranged;
			weapon.profs = val;
			
			if (weapon.ranged) {
				if ( ( weapon.profs & Item.getInstanceFlagsOf(Profeciency, R_CROSSBOW)) !=0 ) {
					if (weapon.crossbow == null) weapon.crossbow = new Crossbow();
				}
				
				if ( ( weapon.profs & Item.getInstanceFlagsOf(Profeciency, R_FIREARM)) !=0 ) {
					if (weapon.firearm == null) weapon.firearm = new Firearm();
					
				}
				weapon.isAmmo = false;  // both cases to reset isAmmo?
			}
			else {
				weapon.isAmmo = false;
			}
			
			requestCurWidget("", 0);
		}
		
		
		
	}
	
	
	
	inline function requestCurWidget(type:String,index:Int):Void {
		this.curWidgetRequest.type = type;
		this.curWidgetRequest.index = index;
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
}

typedef TDWeapProfSelectProps = {
	var curWidgetRequest:WidgetItemRequest;
	var weapon:Weapon;
	var entry:ReadyAssign;
	
	var section:String;
	var index:Int;
	var isVisibleWidget:String->String->Int->Bool;
	
	var meleeProfs:Array<Profeciency>;
	var rangedProfs:Array<Profeciency>;
	
	@:prop({required:false, "default":0}) 
	@:optional var profMask:Int;
	
	@:prop({required:false}) 
	@:optional var customProfs:Array<Profeciency>;
	

}