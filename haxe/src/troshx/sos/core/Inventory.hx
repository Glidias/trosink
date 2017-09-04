package troshx.sos.core;
import haxe.Serializer;
import haxe.Unserializer;
import js.html.svg.Number;
import msignal.Signal.Signal1;
import troshx.core.IUid;
import troshx.ds.HashedArray;
import troshx.ds.IDMatchArray;
import troshx.ds.IUpdateWith;
import troshx.ds.IValidable;
import troshx.sos.core.Inventory.WeaponAssign;

import troshx.sos.core.Weapon;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class Inventory 
{
	public var dropped(default, never):IDMatchArray<ItemQty> = new IDMatchArray<ItemQty>(); // any items directly below one's feet
	public var packed(default, never):IDMatchArray<ItemQty> = new IDMatchArray<ItemQty>();	// any items packed in one's bag or something...
	public var dropPack:Bool = false;	// flag to indicate if pack is dropped at one's feet
	
	// TODO: Armor should allow for both sides or multiples via ArmorAssign
	public var wornArmor(default,never):Array<Armor> = [];	// any worn armor items
	
	public var equipedNonMeleeItems(default, never):Array<ItemAssign> = [];  // any readied/equiped non-melee items or pocketed items
	public var shields(default,never):Array<ShieldAssign> = [];	// melee shields carried or held
	public var weapons(default,never):Array<WeaponAssign> = [];  // melee weapons carried or held

	public static inline var HELD_MASTER:Int = 1;
	public static inline var HELD_OFF:Int = 2;
	public static inline var HELD_BOTH:Int = (1 | 2);
	
	@:unheld("") public static inline var UNHELD_UNSPECIFIED:Int = 0;
	@:unheld("Sheath/Holster") public static inline var UNHELD_SHEATH_HOLSTER:Int = 1;
	@:unheld("Strapped-Arm") public static inline var UNHELD_STRAPPED_ARM:Int = 2;
	@:unheld("Strapped-Shoulder") public static inline var UNHELD_STRAPPED_SHOULDER:Int = 3;
	@:unheld("Back") public static inline var UNHELD_BACK:Int = 4;
	@:unheld("Concealed") public static inline var UNHELD_CONCEALED:Int = 5;
	public static function getUnheldLabelsArray():Array<String> {
		var arr:Array<String> = [];
		Item.pushFlagLabelsToArr(false, "troshx.sos.core.Inventory", false, ":unheld");
		return arr;
	}
	
	public static inline var PREFER_UNHELD_PACKED:Int = 1;
	public static inline var PREFER_UNHELD_DROPPED:Int = 2;
	public static inline var PREFER_UNHELD_EQUIPPED:Int = 4;
	
	public static var UID_COUNT:Int = 0;
	
	// todo: imperative weapon state equip caches
	/*
	public var weaponOffHand:Weapon = null;
	public var weaponHand:Weapon = null;
	
	public var shieldOffHand:Shield = null; //
	public var shield:Shield  = null;
	
	public var miscItemOffHand:Item = null;
	public var miscItemHand:Item = null;
	*/
	
	var signaler:Signal1<InventorySignal>;
	public inline function getSignaler():Signal1<InventorySignal> {
		return (signaler != null ? signaler : signaler=createSignaler());
	}
	function createSignaler():Signal1<InventorySignal> {
		signaler = new Signal1<InventorySignal>();
		return signaler;
	}
	public function setSignaler(val:Signal1<InventorySignal>):Void {
		signaler = val;
	}
	function dispatchSignal(signal:InventorySignal):Void {
		getSignaler().dispatch(signal);
	}
	
	
	public function getWeildableWeaponsTypeFiltered(ranged:Bool, ?profs:Int):Array<WeaponAssign> {
		var arr = [];
		for (i in 0...weapons.length) {
			var wp = weapons[i];
			var w = wp.weapon;
			var c =  w.matchesTypes(ranged, profs);
			if ( !w.isAmmunition() && c) {
				arr.push(wp);	
			}
		}
		return arr;
	}
	
	
	
	public var ammoFiltered(get, never):Array<WeaponAssign>;
	function get_ammoFiltered():Array<WeaponAssign> {
		var arr = [];
		for (i in 0...weapons.length) {
			var wp = weapons[i];
			var w = weapons[i].weapon;
			if (w.isAmmunition()) {
				arr.push(wp);
			}
		}
		return arr;
	}

	/**
	 * 
	 * @param	item
	 * @param	preferedUnheld  0 - Auto, >0 any prefered unheld value,  -1: ignore internal for equippng item,  -2 destroy internal
	 * @return
	 */
	function _shiftItem(item:Item, preferedUnheld:Int, qty:Int=1, attachments:Array<Item>=null):Void {
		
		if (qty <= 0) qty = 1;
		
		// Else continue to  re-add it back to prefered unheld for UNHELD_PACKED or UNHELD_DROPPED if required...
		//preferedUnheld = preferedUnehd != 0 ? preferedUnheld : if got existing equipped held item ? existinghelditem.unheld : 0;
		if (preferedUnheld > 0) {
			if (preferedUnheld != PREFER_UNHELD_EQUIPPED) {  // would != the case of existingHeldItem.unheld already remain requipped
				var q:ItemQty;
				if (preferedUnheld == PREFER_UNHELD_PACKED) {
					q = new ItemQty(item, qty);
					q.attachments = attachments;
					packed.add( q );
					
				}
				else if (preferedUnheld == PREFER_UNHELD_DROPPED) {
					q = new ItemQty(item, qty);
					q.attachments = attachments;
					dropped.add( q );
				}
				else {
					trace("Unaccounted prefered unheld case: " + preferedUnheld);
				}
			}
		}
		else if (preferedUnheld < 0) {  
			// no unheld state saved, item completely demolished to the void
			
			var delItem = new ItemQty(item);
			if (preferedUnheld == -2) {
				dropped.splicedAgainst(delItem);
			}
			else {
				packed.splicedAgainst( delItem );
			}
				//;
		}
	}

	
	// imperative case functions
	public function packItemEntryFromGround(itemQ:ItemQty):Void {
		var qty:Int = itemQ.qty;
		dropped.splicedAgainst(itemQ);
		dispatchSignal(InventorySignal.PackItem);
		_shiftItem(itemQ.item, PREFER_UNHELD_PACKED, qty);
		
	}
	
	/*
	public function holdItemEntryFromGround(itemQ:ItemQty, remark:String=""):Void {
		var itemReady = equipItemEntryFromGround(itemQ, remark);
		if (itemReady != null) {
			var weapon:Weapon = LibUtil.as(itemReady, Weapon);
			var shield:Shield = Std.is(itemReady, Shield);
		
			holdEquiped(itemReady, isShield ? (isShield HELD_OFF : weapon.twoHanded);
		}
	}
	*/
	
	public function dropItemEntryFromPack(itemQ:ItemQty):Void {
		var qty:Int = itemQ.qty;
		packed.splicedAgainst(itemQ);
		_shiftItem(itemQ.item, PREFER_UNHELD_DROPPED, qty);
		dispatchSignal(InventorySignal.DropItem);
	}
	
	public function equipItemEntryFromGround(itemQ:ItemQty, remark:String=""):ReadyAssign {
		dropped.splicedAgainst(new ItemQty(itemQ.item, 1));
		dispatchSignal(InventorySignal.EquipItem);
		return equipItem(itemQ.item, remark); 
	} 
	
	public function equipItemEntryFromPack(itemQ:ItemQty, remark:String=""):ReadyAssign {
		packed.splicedAgainst(new ItemQty(itemQ.item, 1));
		dispatchSignal(InventorySignal.EquipItem);
		return equipItem(itemQ.item, remark);  
	}

	
	public function holdEquiped(alreadyEquiped:ReadyAssign, held:Int):Void {
		
		_unholdAllItems(held, Reflect.hasField(alreadyEquiped, "shield") ); 
		alreadyEquiped.held = held;
		dispatchSignal(InventorySignal.HoldItem);
	}
	
	function sortBetweenAttachmentItems(ao:Item, bo:Item):Int
	{
		var a = ao.label.toLowerCase();
		var b = bo.label.toLowerCase();
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
	
	function getAttachmentArray(arr:Array<ReadyAssign>, fromI:Int, propName:String):Array<Item> {
		if (fromI < 0 || fromI + 1 >= arr.length || !arr[fromI + 1].attached ) return null;
		var newArr:Array<Item> = [];
		for (i in fromI...arr.length) {
			newArr.push(Reflect.field(arr[i], propName) );
			if (!arr[i].attached) break;
		}
		newArr.sort(sortBetweenAttachmentItems);
		return newArr;
	}
	
	public function dropEquipedShield(alreadyEquiped:ShieldAssign, doDestroy:Bool = false):Void {  // Not applicable for shield
		
		shields.splice( shields.indexOf(alreadyEquiped), 1 );
		if (!doDestroy) _shiftItem(alreadyEquiped.shield, PREFER_UNHELD_DROPPED, 1);
		dispatchSignal(doDestroy ? InventorySignal.DeleteItem : InventorySignal.DropItem);
	}
	public function dropMiscItem(alreadyEquiped:ItemAssign, doDestroy:Bool = false):Void {
		var ind:Int;
		equipedNonMeleeItems.splice( ind=equipedNonMeleeItems.indexOf(alreadyEquiped), 1 );
		if (!doDestroy) _shiftItem(alreadyEquiped.item, PREFER_UNHELD_DROPPED, 1, getAttachmentArray(equipedNonMeleeItems, ind, "item") );
		dispatchSignal(doDestroy ? InventorySignal.DeleteItem : InventorySignal.DropItem);
	}
	public function dropEquipedWeapon(alreadyEquiped:WeaponAssign, doDestroy:Bool = false):Void {
		var ind:Int;
		weapons.splice( ind=weapons.indexOf(alreadyEquiped), 1 );
		if (!doDestroy) _shiftItem(alreadyEquiped.weapon, PREFER_UNHELD_DROPPED, 1, getAttachmentArray(weapons, ind, "weapon"));
		dispatchSignal(doDestroy ? InventorySignal.DeleteItem : InventorySignal.DropItem);
	}
	
	public function dropWornArmor(armor:Armor, doDestroy:Bool=false):Void {
		wornArmor.splice(wornArmor.indexOf(armor), 1);
		if (!doDestroy) _shiftItem(armor, PREFER_UNHELD_DROPPED, 1);
		dispatchSignal(doDestroy ? InventorySignal.DeleteItem : InventorySignal.DropItem);
	}
	
	public function packEquipedShield(alreadyEquiped:ShieldAssign):Void {
		
		shields.splice( shields.indexOf(alreadyEquiped), 1 );
		_shiftItem(alreadyEquiped.shield, PREFER_UNHELD_PACKED, 1);
		dispatchSignal(InventorySignal.PackItem);
	}
	public function packMiscItem(alreadyEquiped:ItemAssign):Void {
		var ind:Int;
		equipedNonMeleeItems.splice( ind= equipedNonMeleeItems.indexOf(alreadyEquiped), 1  );
		_shiftItem(alreadyEquiped.item, PREFER_UNHELD_PACKED,  1, getAttachmentArray(equipedNonMeleeItems, ind, "item"));
		dispatchSignal(InventorySignal.PackItem);
	}
	public function packEquipedWeapon(alreadyEquiped:WeaponAssign):Void {
		var ind:Int;
		weapons.splice( ind= weapons.indexOf(alreadyEquiped), 1 );
		_shiftItem(alreadyEquiped.weapon, PREFER_UNHELD_PACKED, 1, getAttachmentArray(weapons, ind, "weapon"));
		dispatchSignal(InventorySignal.PackItem);
	}
	
	public function packWornArmor(armor:Armor):Void {
		wornArmor.splice(wornArmor.indexOf(armor), 1);
		_shiftItem(armor, PREFER_UNHELD_PACKED, 1);
		dispatchSignal(InventorySignal.PackItem);
	}

	public function deletePacked(itemQty:ItemQty):Void {
		packed.delete(itemQty);
		dispatchSignal(InventorySignal.DeleteItem);
	}
	
	public function deleteDropped(itemQty:ItemQty):Void {
		dropped.delete(itemQty);
		dispatchSignal(InventorySignal.DeleteItem);
	}
	
	function _unholdAllItems(held:Int, isForShield:Bool=false ):Void {
		var w;
		var s;
		var t;
		
		for (i in 0...weapons.length) {
			w = weapons[i];
			if (!w.weapon.strapped ) {  // For now, assumed no limit to amount of strapped weapons (assumed magic...)
				w.held &= ~held;
				if (w.weapon.twoHanded && w.held != HELD_BOTH) {
					w.held = 0;
				}
			}
		}
		
		for (i in 0...shields.length) {
			s = shields[i];
			s.held &= ~held;
			if (!s.shield.strapped || isForShield) {  // only 1 strapped shield is allowed with isForShield
				s.held &= ~held;
				if (s.shield.twoHanded && s.held != HELD_BOTH) {
					s.held = 0;
				}
			}
			
		}
		
		for (i in 0...equipedNonMeleeItems.length) {
			t = equipedNonMeleeItems[i];
			
			if (!t.item.strapped) {  // For now, assumed no limit to amount of strapped items (assumed magic..)
				t.held &= ~held;
				if (t.item.twoHanded && t.held != HELD_BOTH) {
					t.held = 0;
				}
			}
		}

	}
	
	function equipItem(item:Item, unheldRemark:String = null):Dynamic {
		var unheld:Int = 0;
		var readyAssign:Dynamic = null;
		var weaponAssign:WeaponAssign;
		var shieldAssign:ShieldAssign;
		var itemAssign:ItemAssign;
		var armorAssign:Armor;
		
		if (Std.is(item, Weapon)) {
			
			weapons.push(readyAssign = weaponAssign = {attached:false,  key:UID_COUNT++, weapon:LibUtil.as(item, Weapon), held:0, unheld:UNHELD_UNSPECIFIED, unheldRemark:unheldRemark});
		}
		else if (Std.is(item, Shield)) {
			
			shields.push(readyAssign = shieldAssign = {key:UID_COUNT++, attached:false, shield:LibUtil.as(item, Shield), held:0, unheld:UNHELD_UNSPECIFIED, unheldRemark:unheldRemark});
		}
		else if (Std.is(item, Armor)) {

			wornArmor.push( armorAssign = LibUtil.as(item, Armor) );
		}
		else {
			equipedNonMeleeItems.push(readyAssign =  itemAssign= {key:UID_COUNT++, attached:false,  item:item, held:0, unheld:UNHELD_UNSPECIFIED, unheldRemark:unheldRemark});
		}
		
		return readyAssign;
	}
	
	public function new() 
	{
		
	}
	
	public function getEquipedAssignList(type:String):Array<ReadyAssign> {
		if (type == "weapon") {
			return weapons;
		}
		else if (type == "shield") {
			return shields;
		}
		else {
			return equipedNonMeleeItems;
		}
	}
	
	public static function getEmptyReadyAssign(type:String):Dynamic {  // Dynamic no choice??, these types is a real pain sometimes
		var weaponAssign:WeaponAssign;
		var shieldAssign:ShieldAssign;
		var itemAssign:ItemAssign;

		if (type == "weapon") {
			return weaponAssign = {
				weapon:new Weapon(),
				held:0, unheld:0, unheldRemark:"",
				key:UID_COUNT++,
				attached:false
			};
		}
		else if (type == "shield") {
			return shieldAssign= {
				shield:new Shield(),
				attached:false,
				held:0, unheld:0, unheldRemark:"",
				key:UID_COUNT++
			};
		}
		else {
			return itemAssign = {
				item:new Item(),
				attached:false,
				held:0, unheld:0, unheldRemark:"",
				key:UID_COUNT++
			};
		}
	}
	
}

enum InventorySignal {
	DeleteItem;
	PackItem;
	DropItem;
	EquipItem;
	HoldItem;
}

typedef ReadyAssign = {
	held:Int,
	unheld:Int,
	unheldRemark:String,
	attached:Bool,
	key:Int
}


typedef ItemAssign = {
	> ReadyAssign,
	item:Item,
}

typedef WeaponAssign = {
	> ReadyAssign,
	weapon:Weapon,
	
}

typedef ShieldAssign = {
	> ReadyAssign,
	shield:Shield
}



