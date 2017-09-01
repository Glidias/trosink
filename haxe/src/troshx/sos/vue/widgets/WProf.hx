package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import js.html.InputElement;
import troshx.sos.core.Crossbow;
import troshx.sos.core.Firearm;
import troshx.sos.core.Item;
import troshx.sos.core.Weapon;
import troshx.sos.core.Profeciency;
import troshx.sos.vue.CharSheetVue.WidgetItemRequest;
import troshx.sos.vue.widgets.BaseItemWidget.BaseItemWidgetProps;
import troshx.util.LibUtil;

/**
 * Widget to handle profeiciencies selection for weapon
 * @author Glidias
 */
class WProf extends VComponent<WProfData, WProfProps>
{
	public static inline var NAME:String = "w-prof";

	public function new() 
	{
		super();
	}
	
	override function Mounted():Void {
		var weap:Weapon = this.weapon;
		
		if (weap.ranged) {
			this.rangedFlags = weap.profs;
			this.ranged = true;
			this.isAmmo = weap.isAmmunition();
		}
		else {
			this.meleeFlags = weap.profs;
			this.ranged = false;
		}
		
		
		//trace("Setting melee flags:" + this.meleeFlags);
	}
	

	
	@:computed function get_weapon():Weapon {
		return LibUtil.as(this.item, Weapon);
	}
	
	@:computed function get_gotCustomColumn():Bool {
		return this.customWidth; // ** customProfs!=null && customProfs.length > 0
	}
	
	function getProfsOfTypeIfAny(type:Int):Array<Profeciency> {
		if (this.customProfs != null) {
			var arr:Array<Profeciency> = [];
			var cArr:Array<Profeciency> = this.customProfs;
			for (i in 0...cArr.length) {
				if (cArr[i].type == type) {
					arr.push(cArr[i]);
				}
			}
			if (arr.length == 0) return null;
			return arr;
		}
		return null;
	}
	
	
	@:computed function get_meleeCustomProfs():Array<Profeciency> {
		return getProfsOfTypeIfAny(Profeciency.TYPE_MELEE);
	}
	
	@:computed function get_rangedCustomProfs():Array<Profeciency> {
		return getProfsOfTypeIfAny(Profeciency.TYPE_RANGED);
	}
	
	override function Data():WProfData {
		return new WProfData();
	}
	
	override function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	//
	inline function shiftIndex(i:Int):Int {
		return (1 << i);
	}
	
	function checkMelee(input:InputElement, index:Int):Void {
		if (input.checked) {
			meleeFlags |= (1 << index);
		}
		else {
			meleeFlags &= ~(1 << index);
		}
	}
	
	
	function checkRanged(input:InputElement, index:Int):Void {
		if (input.checked) {
			rangedFlags |= (1 << index);
		}
		else {
			rangedFlags &= ~(1 << index);
		}
	}
	
	function confirm():Void {
		if (this.confirmBtnDisabled) {
			return;
		}
		var weap:Weapon = this.weapon;
		if (this.ranged ) {
			weap.isAmmo = this.isAmmo;
			weap.profs = this.rangedFlags;
		
			if ( ( weap.profs & Item.getInstanceFlagsOf(Profeciency, R_CROSSBOW)) !=0 ) {
				if (weap.crossbow == null) weap.crossbow = new Crossbow();
			}
			
			if ( ( weap.profs & Item.getInstanceFlagsOf(Profeciency, R_FIREARM)) !=0 ) {
				if (weap.firearm == null) weap.firearm = new Firearm();
				
			}
		}
		else {
			weap.isAmmo = false;
			weap.profs = this.meleeFlags;
		}
		weap.ranged = this.ranged;
		
		if (this.curWidgetRequest != null) {
			this.curWidgetRequest.index = 0;
			this.curWidgetRequest.type = "";
		}
	}
	
	inline function myBowSlingMask():Int {
		return (1 << Profeciency.R_BOW) | (1 << Profeciency.R_SLING);
	}

	
	@:computed function get_showBtnArrows():Bool {
		var a:Bool = this.weapon.ranged != this.ranged;
		var b:Bool = this.weapon.ranged && this.weapon.isAmmo != this.isAmmo;
		//var testRangedFlag:Int = this.(1 << Profeciency.R_BOW) | (1 << Profeciency.R_SLING);
		var c:Bool = false;
		if (this.ranged) {
			var flags1:Int = this.rangedFlags;
			flags1 |= (flags1 & myBowSlingMask()) != 0 ? myBowSlingMask() : 0;
			var flags2:Int = this.weapon.profs;
			flags2 |= (flags2 & myBowSlingMask()) != 0 ? myBowSlingMask() : 0;
			c = (flags1^flags2) !=0;
		}
		//var c:Bool  = this.ranged ? ) : false;
		return a || b || c;
	}
	@:computed function get_confirmBtnDisabled():Bool {
		var meleeFlags:Int = this.meleeFlags;
		var rangedFlags:Int = this.rangedFlags;
		return this.ranged ? rangedFlags==0 : meleeFlags ==0;
	}
	
}

class WProfData {
	public var ranged:Bool = false;

	public var meleeFlags:Int = 0;
	public var rangedFlags:Int = 0;
	public var isAmmo:Bool = false;
	

	
	public function new() {
	
	}
}

typedef WProfProps = {
	> BaseItemWidgetProps,
	var meleeProfs:Array<Profeciency>;
	var rangedProfs:Array<Profeciency>;
	@:optional @:prop({required:false}) var curWidgetRequest:WidgetItemRequest;
	
	@:prop({required:false})  @:optional var customProfs:Array<Profeciency>;
	
	@:prop({required:false, 'default':false})  @:optional var customWidth:Bool;
}