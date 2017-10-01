package troshx.sos.vue.widgets;
import haxe.Serializer;
import haxe.Unserializer;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import haxevx.vuex.util.VHTMacros;
import js.html.InputElement;
import troshx.sos.core.ArmorCustomise;
import troshx.sos.core.BodyChar;
import troshx.sos.core.Armor;
import troshx.sos.core.ArmorSpecial;
import troshx.sos.core.Crossbow;
import troshx.sos.core.Firearm;
import troshx.sos.core.Item;
import troshx.sos.core.MeleeSpecial;
import troshx.sos.core.MissileSpecial;
import troshx.sos.core.Profeciency;
import troshx.sos.core.Shield;
import troshx.sos.core.Weapon;
import troshx.sos.core.WeaponCustomise;
import troshx.sos.vue.input.MixinInput;
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
		untyped this.mixins = [ MixinInput.getInstance() ];
	}
	
	override function Data():WTagsData {
		return {
			meleeSpecialCache:null,
			missileSpecialCache:null,
			armorSpecialCache:null,
			armorSpecialHitModifierCache:null,
			customise: null,
			customMeleeCache:null,
			customiseArmor:null,
			restoreOriginal:false,

			
			//layerCoverageBits:0
		}
	}
	
	override function Mounted():Void { 
		updateWeaponStates();
		updateArmorStates();
		//trace(Type.getClassName(CustomMelee));	
		
	}
	
	
	function updateArmorStates():Void {
		var armor = this.armor;
		/*
		if (armor != null && armor.special!=null) {
			armor.special.layerCoverage &= layerCoverageBits;
		}
		*/
		if (armor != null) {
			if (armor.customise == null) {
				this.customiseArmor = new ArmorCustomise();
				this.customiseArmor.original = armor;
			}
		}
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
	
	@:computed function get_currentArmorCustomise():ArmorCustomise {
		return this.armor.customise != null ? this.armor.customise : this.customiseArmor;
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
	
	function doRestoreOriginalArmor():Void {
		var origArmor:Armor  = this.armor.customise.original;
		if (origArmor == null) throw "Exception original armor not found!";
		
		this.restoreOriginal = false;

		Reflect.setField(this.entry, "armor", origArmor);
		
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
	
	public function assignArmorCustomisation():Void {
		var armor:Armor = this.armor;
		
		armor.customise = null;
		var curCustom:ArmorCustomise = this.currentArmorCustomise;
		
		var serializer;

		
		serializer = new Serializer();
		
		//serializer.serialize(curCustom);
		//trace(serializer.toString());
		//return;
		
		serializer.serialize(armor);

		
		var unserializer = new Unserializer(serializer.toString());
		armor = unserializer.unserialize();
		
		armor.customise = curCustom;
		
		this.customiseArmor = null;
		
		Reflect.setField(this.entry, "armor", armor);
	}
	
	@:computed function get_armorCrestLabels():Array<String> {
		var arr:Array<String> = [];
		Item.pushFlagLabelsToArr(false, "troshx.sos.core.ArmorCustomise", true, ":crest");
		return arr;
	}
	
	inline function shiftIndex(i:Int):Int {
		return (1 << i);
	}
	
	@:computed function get_canRegisterCustomisation():Bool {
		return StringTools.trim(this.currentCustomise.name) != "";
	}
	@:computed function get_canRegisterArmorCustomisation():Bool {
		return StringTools.trim(this.currentArmorCustomise.name) != "";
	}
	
	
		
	function setCustomiseNameInput(inputElement:InputElement):Void {
		
		var tarName:String = StringTools.trim( inputElement.value);
		if ( tarName != "" ) {
			this.currentCustomise.name = tarName;
		}
		inputElement.value = this.currentCustomise.name;
		
	}
	
	function setArmorCustomiseNameInput(inputElement:InputElement):Void {
		
		var tarName:String = StringTools.trim( inputElement.value);
		if ( tarName != "" ) {
			this.armor.customise.name = tarName;
		}
		inputElement.value = this.armor.customise.name;
		
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
	
	@:computed function get_armorFlags():Array<String> {
		var arr:Array<String> = [ ];
		Item.pushFlagLabelsToArr(false, "troshx.sos.core.ArmorSpecial", true);
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
	
	///*
	@:computed function get_layerCoverageFlags():Array<BitFlag> {
		var armor = this.armor;
		
		if (armor == null) return null;
		var body:BodyChar = this.bodyForArmor;
	
		var arr:Array<BitFlag> = [];
		var fields = Reflect.fields(armor.coverage);
		for (i in 0...fields.length) {
			var f = fields[i];
			var id = LibUtil.field(body.hitLocationHash, f);
			arr.push({
				label: body.hitLocations[id].name,
				id: body.hitLocations[id].id,
				value: (1 << id),
				index:id
			});
		}
		arr.sort(sortCoverageFlag);
		return arr;
	}


	
	@:computed function get_layerCoverageBits():Int {
		
		var a =layerCoverageFlags;
		var bits = 0;
		for (i in 0...a.length) {
			bits |= a[i].value;
		}
		return bits;

	}
	
	@:computed function get_targetZoneFlags():Array<BitFlag> {
		var armor = this.armor;
		
		if (armor == null) return null;
		
		var body:BodyChar = this.bodyForArmor;
		var arr:Array<BitFlag> = [];
		//trace(body.targetZones);
		for (i in 0...body.thrustStartIndex) {
			var t = body.targetZones[i];
			arr.push({
				label: t.description != "" ? t.description + " to "+t.name :  t.name,
				value: (1 << i),
				index:i,
				id:"_"+i,
			});
		}
		return arr;
	}
	@:computed function get_targetZoneFlags2():Array<BitFlag> {
		var armor = this.armor;
		
		if (armor == null) return null;
		
		var body:BodyChar = this.bodyForArmor;
		var arr:Array<BitFlag> = [];
		//trace(body.targetZones);
		for (i in body.thrustStartIndex...body.targetZones.length) {
			var t = body.targetZones[i];
			arr.push({
				label: t.description != "" ? t.description + " to "+t.name :  t.name,
				value: (1 << i),
				index:i,
				id:"_"+i,
			});
		}
		return arr;
	}
	
	
	@:computed function get_modifyAllSwinging():Bool {
		var armor = this.armor;
		if (armor == null) return null;
		var body:BodyChar = this.bodyForArmor;
		return body.isSwingingAll( armor.special.hitModifier.targetZoneMask );
	}
	@:computed function get_modifyAllThrusting():Bool {
		var armor = this.armor;
		if (armor == null) return null;
		var body:BodyChar = this.bodyForArmor;
		return body.isThrustingAll( armor.special.hitModifier.targetZoneMask ); 
	}

	@:computed function get_swingMask():Int {
		var armor = this.armor;
		if (armor == null) return 0;
		var body:BodyChar = this.bodyForArmor;
		return  body.swingMask;
	}
	
	@:computed function get_thrustMask():Int {
		var armor = this.armor;
		if (armor == null) return 0;
		var body:BodyChar = this.bodyForArmor;
		return  body.thrustMask;
	}
	
	/*
	@:watch function watch_armorSpecialLayer(newValue:Int):Void {
		var armor = this.armor;
		if (armor.special != null) {
			if (newValue <=0) { // sync?
				armor.special.layerCoverage = 0; 
				
			}
		}
	}
	*/

	
	function sortCoverageFlag(a:BitFlag, b:BitFlag):Int {
		if (a.value < b.value) return -1;
		else if (a.value > b.value) return 1;
		return 0;
	}
	
//	*/
/*
	function getLayerLabelFor(ider:String):Void {
		var body = bodyForArmor;
		LibUtil.field(body.hitLocationHash, ider);
	}
	*/
	
	@:computed inline function get_bodyForArmor():BodyChar { // only call this if armor!=null!
		return armor.special != null &&  armor.special.otherBodyType != null ? armor.special.otherBodyType : BodyChar.getInstance();
	}
	
	@:computed function get_hitLocationIds():Array<String> {
		return Reflect.fields( this.bodyForArmor.hitLocationHash );
	}

	@:computed function get_hitLocationDummy():Dynamic<Int> {	// lazy instantation of hit body model dummy to store UI av modifiers
		//if (this.armor == null) return null;
		var hitIds:Array<String> = this.hitLocationIds;
		

		var crushAVMods:Dynamic<Int>  = currentArmorCustomise.hitLocationAllAVModifiers;

		var dyn:Dynamic<Int> = {};
		for (i in 0...hitIds.length) {
			var f = hitIds[i];
			LibUtil.setField(dyn, f, (crushAVMods != null && LibUtil.field(crushAVMods, f) != null ? LibUtil.field(crushAVMods, f) : 0 ) );
		}
		return dyn;
	}
	

	function crushAVInputHandler(input:InputElement, li:BitFlag):Void {
		//li.id;
		var armorCustomise = currentArmorCustomise;
		var result:Int = Std.int( input.valueAsNumber );
		
		if (result == null || Math.isNaN(result) ) {
			input.valueAsNumber =  LibUtil.field(hitLocationDummy, li.id);
			return;
		}

		if ( result != 0) {
			if (armorCustomise.hitLocationAllAVModifiers == null) {
				armorCustomise.hitLocationAllAVModifiers = {};
			}
			Vue.set(armorCustomise.hitLocationAllAVModifiers, li.id, result);
		}
		else  {
			if (armorCustomise.hitLocationAllAVModifiers == null) return;
			if (LibUtil.field(armorCustomise.hitLocationAllAVModifiers, li.id) != null) Vue.delete(armorCustomise.hitLocationAllAVModifiers, li.id);
		}
		
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
	
	
	
	
	function onArmorSpecialCheck(cb:InputElement) {
		var armor = this.armor;
		if ( cb.checked ) {
			
			armor.special = armor.special != null ? armor.special : armorSpecialCache != null ? armorSpecialCache  : new ArmorSpecial();
		
		}
		else {
			armorSpecialCache = armor.special;
			armor.special = null;
		}
	}
	
	
	function onArmorLocationSpecificSpecialCheck(cb:InputElement) {
		// we assume armor is available and armor.special != null
		var armor = this.armor;
			if ( cb.checked ) {
			
			armor.special.hitModifier = armor.special.hitModifier != null ? armor.special.hitModifier : armorSpecialHitModifierCache != null ? armorSpecialHitModifierCache  : new HitModifier();
		
		
		}
		else {
			armorSpecialHitModifierCache = armor.special.hitModifier;
			armor.special.hitModifier = null;
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
	
	function checkboxMaskHandler(checkbox:InputElement, mask:Int, targetObj:Dynamic, targetProp:String):Void {
		if (checkbox.checked) {
			untyped targetObj[targetProp] |= mask;
		}
		else {
			untyped targetObj[targetProp] &= ~mask;
		}
	}
	
}

typedef WTagsData = {
	var meleeSpecialCache:MeleeSpecial;
	var missileSpecialCache:MissileSpecial;
	
	var armorSpecialCache:ArmorSpecial;
	var armorSpecialHitModifierCache:HitModifier;
	
	var customise:WeaponCustomise;
	var customiseArmor:ArmorCustomise;
	
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

typedef BitFlag = {
	var label:String;
	var value:Int;
	var index:Int;
	var id:String;
}

