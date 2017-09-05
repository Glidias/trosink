package troshx.sos.vue.widgets;
import haxe.Serializer;
import haxe.Unserializer;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import js.html.InputElement;
import troshx.sos.core.Armor;
import troshx.sos.core.Crossbow;
import troshx.sos.core.Firearm;
import troshx.sos.core.Item;
import troshx.sos.core.MeleeSpecial;
import troshx.sos.core.MissileSpecial;
import troshx.sos.core.Profeciency;
import troshx.sos.core.Shield;
import troshx.sos.core.Weapon;
import troshx.sos.core.WeaponCustomise;
import troshx.sos.vue.widgets.BaseItemWidget.BaseItemWidgetProps;
import troshx.util.LibUtil;

/**
 * Widget to handle various generic item tags for all class types
 * @author Glidias
 */
class WTags extends VComponent<WTagsData, BaseItemWidgetProps>
{
	public static inline var NAME:String = "w-tags";

	public function new() 
	{
		super();
	}
	
	override function Data():WTagsData {
		return {
			meleeSpecialCache:null,
			missileSpecialCache:null,
			customise: null,
			customMeleeCache:null,
			restoreOriginal:false,
			
		}
	}
	
	override function Mounted():Void { 
		updateWeaponStates();
		//trace(Type.getClassName(CustomMelee));	
	}
	
	function updateWeaponStates():Void  // imperative upadtes
	{
		if (this.firearmAmmoCapable && this.weapon.firearm == null) this.weapon.firearm = new Firearm();
		if (this.crossbowAmmoCapable && this.weapon.crossbow == null) this.weapon.crossbow = new Crossbow();
		if (this.weapon != null) {
			var weap:Weapon = this.weapon;
			if (weap.customise == null) {
				this.customise = new WeaponCustomise();
				//if (!weap.ranged) {
					//this.customise.melee = new CustomMelee();
				//}
				this.customise.original = weap;
			}
		}
	
	}
	

	
	@:watch function watch_weapon(newValue:Weapon, oldValue:Weapon):Void {
		updateWeaponStates();
	}
	
	
	@:computed function get_currentCustomise():WeaponCustomise {
		return this.weapon.customise != null ? this.weapon.customise : this.customise;
	}
	
	@:computed function get_isEnteredItem():Bool {
		return this.entryIndex != null && this.entryIndex >= 0;
	}
	
	
	function doRestoreOriginal():Void {
		var origWeapon:Weapon  = this.weapon.customise.original;
		if (origWeapon == null) throw "Exception original weapon not found!";
		
		this.restoreOriginal = false;
		Reflect.setField(this.entry, "weapon", origWeapon);
		
	}

	public function assignWeaponCustomisation():Void {
		var weap:Weapon = this.weapon;
		
		weap.customise = null;
		var curCustom:WeaponCustomise = this.currentCustomise;
		
		var serializer;

		
		serializer = new Serializer();
		
		//serializer.serialize(curCustom);
		//trace(serializer.toString());
		//return;
		
		serializer.serialize(weap);

		
		var unserializer = new Unserializer(serializer.toString());
		weap = unserializer.unserialize();
		
		weap.customise = curCustom;
		
		this.customise = null;
		
		Reflect.setField(this.entry, "weapon", weap);
	}
	
	inline function shiftIndex(i:Int):Int {
		return (1 << i);
	}
	
	@:computed function get_canRegisterCustomisation():Bool {
		return StringTools.trim(this.currentCustomise.name) != "";
	}
	
		
	function setCustomiseNameInput(inputElement:InputElement):Void {
		
		var tarName:String = StringTools.trim( inputElement.value);
		if ( tarName != "" ) {
			this.currentCustomise.name = tarName;
		}
		inputElement.value = this.currentCustomise.name;
		
	}
	
	
	function withinItemFlagRange(i:Int):Bool {
		var mask:Int = this.shield!= null  ?  ~(Item.FLAG_TWO_HANDED) : ~(Item.FLAG_TWO_HANDED|Item.FLAG_STRAPPED);
		return ((1 << i) & mask ) != 0;
	}
	@:computed function get_hasStrap():Bool {
		return this.item.strapped;
	}
	@:computed function get_handInteractable():Bool {
		return this.entry.held == null || this.entry.held == 0;
	}
	
	@:computed function get_firearmAmmo():Bool {
		return  this.firearmAmmoCapable  && this.weapon.firearm != null;	
	}
	
	@:computed function get_crossbowAmmo():Bool {
		return  this.crossbowAmmoCapable  && this.weapon.crossbow != null;	
	}
	
	@:computed function get_firearmAmmoCapable():Bool {
		return  this.isAmmo &&  (this.weapon.profs & (1 << Profeciency.R_FIREARM)) != 0;	
	}
	
	@:computed function get_crossbowAmmoCapable():Bool {
		return  this.isAmmo &&  (this.weapon.profs & (1 << Profeciency.R_CROSSBOW)) != 0;
	}
	
	

	@:computed function get_itemFlags():Array<String> {
		var arr:Array<String> = [ ];
		Item.pushFlagLabelsToArr(false, "troshx.sos.core.Item", true, ":flags");
		return arr;
	}
	
	@:computed function get_customMeleeFlags():Array<String> {
		var arr:Array<String> = [ ];
		Item.pushFlagLabelsToArr(false, "troshx.sos.core.WeaponCustomise:CustomMelee", true, ":flag");
		return arr;
	}
	
	
	@:computed function get_customMeleeIntVars():Array<String> {
		var arr:Array<String> = [];
		Item.pushVarLabelsToArr(false, "troshx.sos.core.WeaponCustomise:CustomMelee");
		return arr;
	}
	
	
	@:computed function get_customMeleeIntVarLabels():Array<String> {
		var arr:Array<String> = this.customMeleeIntVars;
		var myArr:Array<String> = arr.concat([]);
		for (i in 0...arr.length) {
			myArr[i] = Item.labelizeCamelCase( arr[i] );
		}
		return myArr;
	}
	
	@:computed function get_meleeVarNames():Array<String> {
	
		return MeleeSpecial.getIntVarNames();
		
	}
	@:computed function get_meleeVarLabels():Array<String> {
	
	
		return Item.labelizeCamelCaseArr( meleeVarNames);
		
	}
	@:computed function get_missileVarNames():Array<String> {
	
		return MissileSpecial.getIntVarNames();
		
	}
	@:computed function get_missileVarLabels():Array<String> {
	
	
		return Item.labelizeCamelCaseArr( missileVarNames);
		
	}

	
	@:computed function get_handMask():Int {
		return Item.MASK_HANDED;
	}
	
	@:computed inline function get_shield():Shield {
		return LibUtil.as(this.item, Shield);
	}
	
	@:computed inline function get_isMeleeWeap():Bool {
		return this.weapon != null && this.weapon.isMelee();
	}
	
	@:computed inline function get_meleeFlagDisablingMask():Int {
		return this.entry.attached ? MeleeSpecial.WEAPON_ATTACHMENT : 0;
	}
	@:computed inline function get_missileFlagDisablingMask():Int {
		return this.entry.attached ? MissileSpecial.CHEAT_ATTACHMENT : 0;
	}
	
	
	@:computed function get_meleeFlags():Array<String> {
		return MeleeSpecial.getFlagVarLabels();
	}
	@:computed function get_missileFlags():Array<String> {
		return MissileSpecial.getFlagVarLabels();
	}

	
	@:computed inline function get_weapon():Weapon {
		return LibUtil.as(this.item, Weapon);
	}
	
	@:computed inline function get_firearm():Firearm {
		return this.weapon != null && this.weapon.isFirearm()  ? this.weapon.firearm : null;
	}
	
	@:computed inline function get_crossbow():Crossbow {
		return this.weapon != null && this.weapon.isCrossbow() ? this.weapon.crossbow : null;
	}
	
	@:computed inline function get_isAmmo():Bool {
		return this.weapon != null &&  this.weapon.isAmmunition();
	}
	
	@:computed inline function get_armor():Armor {
		return LibUtil.as(this.item, Armor);
	}
	
	@:computed function get_isAttachment():Bool {
		return this.weapon != null && this.weapon.isAttachment();
	}
	
	function onCustomMeleeCheck(cb:InputElement) {
		if ( cb.checked ) {
			
			this.currentCustomise.melee = this.currentCustomise.melee != null ? this.currentCustomise.melee : this.customMeleeCache != null ? this.customMeleeCache  : new CustomMelee();
			
		}
		else {

			this.customMeleeCache = this.currentCustomise.melee;
			this.currentCustomise.melee = null;
			
		}
	}
	
	
	function onWeapSpecialCheck(cb:InputElement, ranged:Bool) {
		if ( cb.checked ) {
			if (ranged) {
				this.weapon.missileSpecial = this.weapon.missileSpecial != null ? this.weapon.missileSpecial : this.missileSpecialCache != null ? this.missileSpecialCache : new MissileSpecial();
			}
			else {
				this.weapon.meleeSpecial = this.weapon.meleeSpecial != null ? this.weapon.meleeSpecial : this.meleeSpecialCache != null ? this.meleeSpecialCache  : new MeleeSpecial();
			}
		}
		else {
			if (ranged) {
				this.missileSpecialCache = this.weapon.missileSpecial;
				this.weapon.missileSpecial = null;
			}
			else {
				this.meleeSpecialCache = this.weapon.meleeSpecial;
				 this.weapon.meleeSpecial = null;
			}
		}
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	function checkboxHandler(checkbox:InputElement, i:Int, targetObj:Dynamic, targetProp:String):Void {
		if (checkbox.checked) {
			untyped targetObj[targetProp] |= (1 << i);
		}
		else {
			untyped targetObj[targetProp] &= ~(1 << i);
		}
	}
	
}

typedef WTagsData = {
	var meleeSpecialCache:MeleeSpecial;
	var missileSpecialCache:MissileSpecial;
	
	var customise:WeaponCustomise;
	
	var customMeleeCache:CustomMelee;
	
	var restoreOriginal:Bool;
}


/*
Tags:
WeaponCUstomise + CustomMelee Flags (always instantiate a CustomMelee to fill in)

------
[ ] Has variant  (MuSTUNHOLD)
Variant button? (2H/1H)  (circular depedency?)  check if variant has complehant of handedness


*/