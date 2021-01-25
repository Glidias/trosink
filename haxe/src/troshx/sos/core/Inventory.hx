package troshx.sos.core;
import haxe.Serializer;
import haxe.Unserializer;

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
	public var dropped(default, null):IDMatchArray<ItemQty> = new IDMatchArray<ItemQty>(); // any items directly below one's feet
	public function setNewDroppedList(list:IDMatchArray<ItemQty>):Void {
		this.dropped = list;
	}
	
	public var packed(default, never):IDMatchArray<ItemQty> = new IDMatchArray<ItemQty>();	// any items packed in one's bag or something...
	public var dropPack:Bool = false;	// flag to indicate if pack is dropped at one's feet
	
	public var wornArmor(default,never):Array<ArmorAssign> = [];	// any worn armor items
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
	@:unheld("DISABLED") public static inline var UNHELD_FORCE_DISABLED:Int = 6;
	
	public static function getUnheldLabelsArray():Array<String> {
		var arr:Array<String> = [];
		Item.pushFlagLabelsToArr(false, "troshx.sos.core.Inventory", true, ":unheld");
		return arr;
	}
	
	public static inline var PREFER_UNHELD_PACKED:Int = 1;
	public static inline var PREFER_UNHELD_DROPPED:Int = 2;
	public static inline var PREFER_UNHELD_EQUIPPED:Int = 4;
	
	public static inline var WEAR_RIGHT:Int = 1;
	public static inline var WEAR_LEFT:Int = 2;
	public static inline var WEAR_WHOLE:Int = 4;
	
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
	
	@:skipSerialize var signaler:Signal1<InventorySignal>;
	public inline function getSignaler():Signal1<InventorySignal> {
		return (signaler != null ? signaler : signaler=createSignaler());
	}
	function createSignaler():Signal1<InventorySignal> {
		signaler = new Signal1<InventorySignal>();
		return signaler;
	}
	public function setSignaler(val:Signal1<InventorySignal>):Void {
		if (signaler != null && val != signaler) signaler.removeAll();
		signaler = val;
	}
	function dispatchSignal(signal:InventorySignal):Void {
		getSignaler().dispatch(signal);
	}
	
	/*
	public function getReach():Int {
		for (i in 0...weapons.length) {
		
		}
	}
	*/
	
	public function findOffHandItem():Item {
		for (i in 0...weapons.length) {
			if (weapons[i].held == HELD_OFF) {
				return weapons[i].weapon;
			}
		}
		for (i in 0...shields.length) {
			if (shields[i].held == HELD_OFF) {
				return shields[i].shield;
			}
		}
		for (i in 0...equipedNonMeleeItems.length) {
			if (equipedNonMeleeItems[i].held == HELD_OFF) {
				return equipedNonMeleeItems[i].item;
			}
		}
		return null;
	}
	
	public function findOffHandAssign():ReadyAssign {
		for (i in 0...weapons.length) {
			if (weapons[i].held == HELD_OFF) {
				return weapons[i];
			}
		}
		for (i in 0...shields.length) {
			if (shields[i].held == HELD_OFF) {
				return shields[i];
			}
		}
		for (i in 0...equipedNonMeleeItems.length) {
			if (equipedNonMeleeItems[i].held == HELD_OFF) {
				return equipedNonMeleeItems[i];
			}
		}
		return null;
	}
	
	public function findMasterHandItem():Item {
		for (i in 0...weapons.length) {
			if (( weapons[i].held & HELD_MASTER) != 0) {
				return weapons[i].weapon;
			}
		}
		for (i in 0...shields.length) {
			if (( shields[i].held & HELD_MASTER) != 0) {
				return shields[i].shield;
			}
		}
		for (i in 0...equipedNonMeleeItems.length) {
			if (( equipedNonMeleeItems[i].held & HELD_MASTER) != 0) {
				return equipedNonMeleeItems[i].item;
			}
		}
		return null;
	}
	
	public function findMasterHandAssign():ReadyAssign {
		for (i in 0...weapons.length) {
			if (( weapons[i].held & HELD_MASTER) != 0) {
				return weapons[i];
			}
		}
		for (i in 0...shields.length) {
			if (( shields[i].held & HELD_MASTER) != 0) {
				return shields[i];
			}
		}
		for (i in 0...equipedNonMeleeItems.length) {
			if (( equipedNonMeleeItems[i].held & HELD_MASTER) != 0) {
				return equipedNonMeleeItems[i];
			}
		}
		return null;
	}
	
	public function getOffhandWeaponAssign():WeaponAssign {
		for (i in 0...weapons.length) {
			if (weapons[i].held == HELD_OFF) {
				return weapons[i];
			}
		}
		return null;
	}
	public function getMasterWeaponAssign():WeaponAssign {
		for (i in 0...weapons.length) {
			if (( weapons[i].held & HELD_MASTER) != 0) {
				return weapons[i];
			}
		}
		return null;
	}
	
	public function getOffhandWeapon():Weapon {
		for (i in 0...weapons.length) {
			if (weapons[i].held == HELD_OFF) {
				var w = weapons[i];
				return (!w.holding1H || w.weapon.variant == null) ? w.weapon : w.weapon.variant;
			}
		}
		return null;
	}
	public function getMasterWeapon():Weapon {
		for (i in 0...weapons.length) {
			if (( weapons[i].held & HELD_MASTER) != 0) {
				var w = weapons[i];
				return (!w.holding1H || w.weapon.variant == null) ? w.weapon : w.weapon.variant;
			}
		}
		return null;
	}
	
	public function getReach():Int {
		return getReachBetween(getMasterWeapon(), getOffhandWeapon());
	}
	
	public static inline function getReachBetween(w:Weapon, w2:Weapon):Int {
		return LibUtil.maxI(w != null ? w.reach : 1, w2 != null ? w2.reach : 1);
	}
	
	public function findHeldShieldAssign():ShieldAssign 
	{
		for (i in 0...shields.length) {
			if ( shields[i].held == HELD_OFF ) {
				return shields[i];
			}
		}
		for (i in 0...shields.length) {
			if (shields[i].held != 0) {
				return shields[i];
			}
		}
		return null;
	}
	
	
	public function findHeldShield():Shield 
	{
		var assign = findHeldShieldAssign();
		return assign != null ? assign.shield : null;
	}
	
	public var shieldPosition:Int = Shield.POSITION_LOW;
	
	public function getSortedWeapons(ranged:Bool, ?profs:Int, reverse:Bool=false, unheld:Bool=false):Array<SortedWeapon> {
		var weaps = getWeildableWeaponsTypeFiltered(ranged, profs, unheld);
		var arr:Array<SortedWeapon> = [];
		var w:WeaponAssign;
		for (i in 0...weaps.length) {
			w = weaps[i];
			arr[i] = {
				assign:w,
				sortVal: ranged ? w.weapon.atnM : (10 - w.weapon.reach) + ((w.weapon.atnS/10 + w.weapon.atnT/10 + w.weapon.dtn/10) / 3)
			};
		}
		arr.sort(reverse ? sortBetweenSortedReversed : sortBetweenSorted);
		return arr;
	}
	
	public function getSortedShields(reverse:Bool = false, unheld:Bool = false):Array<SortedShield> {
		var arr:Array<SortedShield> = [];
		var s:ShieldAssign;
		for (i in 0...shields.length) {
			s = shields[i];
			if (unheld && s.unheld!=0) continue;
			arr.push({
				assign:s,
				sortVal: (10- s.shield.size) + s.shield.blockTN/10
			});
		}
		arr.sort(reverse ? sortBetweenSortedReversed : sortBetweenSorted);
		return arr;
	}
	
	public function getWeildableWeaponsTypeFiltered(ranged:Bool, ?profs:Int, unheld:Bool=false):Array<WeaponAssign> {
		var arr = [];
		for (i in 0...weapons.length) {
			var wp = weapons[i];
			if (unheld && wp.held != 0) continue;
			var w = wp.weapon;
			var c =  w.matchesTypes(ranged, profs);
			if ( !w.isAmmunition() && c && !w.isAttachment()) {
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
	
	function compareItemsEq(a:Item, b:Item):Bool {
		var as:Serializer = new Serializer();
		var bs:Serializer = new Serializer();
		as.serialize(a);
		bs.serialize(b);
		/*
		var astr = as.toString();
		var bstr = bs.toString();
		if (astr != bstr) {
			trace(astr);
			trace(bstr);
		}
		
		return astr == bstr;
		*/
		return(as.toString() == bs.toString());
	}

	/**
	 * 
	 * @param	item
	 * @param	preferedUnheld  0 - Auto, >0 any prefered unheld value,  -1: ignore internal for equippng item,  -2 destroy internal
	 * @return
	 */
	function _shiftItem(item:Item, preferedUnheld:Int, qty:Int=1, attachments:Array<Item>=null):ItemQty {
		
		if (qty <= 0) qty = 1;
		
		// Else continue to  re-add it back to prefered unheld for UNHELD_PACKED or UNHELD_DROPPED if required...
		//preferedUnheld = preferedUnehd != 0 ? preferedUnheld : if got existing equipped held item ? existinghelditem.unheld : 0;
		if (preferedUnheld > 0) {
			if (preferedUnheld != PREFER_UNHELD_EQUIPPED) {  // would != the case of existingHeldItem.unheld already remain requipped
				var q:ItemQty;
				var m:ItemQty;
				if (preferedUnheld == PREFER_UNHELD_PACKED) {
					q = new ItemQty(item, qty);
					q.attachments = attachments;
					if ( (m = packed.getMatchingItem(q)) != null && m.item != q.item && !compareItemsEq(m.item.normalize(), q.item.normalize()) ) {
						
						
						return q;
					}
					packed.add( q );
					return null;
					
				}
				else if (preferedUnheld == PREFER_UNHELD_DROPPED) {
					q = new ItemQty(item, qty);
					q.attachments = attachments;
					if ( (m=dropped.getMatchingItem(q))!=null && m.item != q.item && !compareItemsEq(m.item.normalize(), q.item.normalize()) ) {
						
						return q;
					}
					dropped.add( q );
					return null;
				}
				else {
					trace("Unaccounted prefered unheld case: " + preferedUnheld);
					return null;
				}
			}
			return null;
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
			return null;
		}
		return null;
	}

	
	// imperative case functions
	public function packItemEntryFromGround(itemQ:ItemQty, qty:Int=0):ItemQty {
		if (qty == 0) qty = itemQ.qty;
		else itemQ = itemQ.getQtyCopy(qty);
		
		var s:ItemQty = _shiftItem(itemQ.item, PREFER_UNHELD_PACKED, qty);
		if (s !=null) {
			return s;
		}
		dropped.splicedAgainst(itemQ);
		dispatchSignal(InventorySignal.PackItem);
		return null;
	}
	
	public function dropItemEntryFromPack(itemQ:ItemQty, qty:Int=0):ItemQty {
		if (qty == 0) qty = itemQ.qty;
		else itemQ = itemQ.getQtyCopy(qty);
		
		var s:ItemQty = _shiftItem(itemQ.item, PREFER_UNHELD_DROPPED, qty);
		if (s !=null) {
			return s;
		}
		packed.splicedAgainst(itemQ);
		dispatchSignal(InventorySignal.DropItem);
		return null;
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
	
	public function getPerceptionPenalty():Int {
		var val = 0;
		for (i in 0...wornArmor.length) {
			val += wornArmor[i].armor.pp;
		}
		return val;
	}
	
	public function calculateTotalWeight(forceIncludePacked:Bool=false, forceIncludeDropped:Bool=false):Float {
		var w:Float = 0;
		
		if (forceIncludeDropped) {
			for (i in 0...dropped.length) {
				w += dropped.list[i].item.weight * dropped.list[i].qty;
			}
		}
		if (!dropPack || forceIncludePacked ) {
			for (i in 0...packed.length) {
				w += packed.list[i].item.weight * packed.list[i].qty;
			}
		}
		
		for (i in 0...wornArmor.length) {
			w += wornArmor[i].armor.weight;
		}
		for (i in 0...equipedNonMeleeItems.length) {
			w += equipedNonMeleeItems[i].item.weight;
		}
		for (i in 0...shields.length) {
			w += shields[i].shield.weight;
		}
		for (i in 0...weapons.length) {
			w += weapons[i].held == 0 ? weapons[i].weapon.weight : 0;
		}
	
		return w;
	}
	
	public function normalizeDroppedItems():Void {
		for (i in 0...dropped.length) {
			dropped.list[i].item.normalize();
		}
	}
	
	public function normalizeAllItems():Void {
		for (i in 0...dropped.length) {
			dropped.list[i].item.normalize();
		}
		for (i in 0...packed.length) {
			packed.list[i].item.normalize();
		}
		
		for (i in 0...wornArmor.length) {
			wornArmor[i].armor.normalize();
		}
		for (i in 0...equipedNonMeleeItems.length) {
			equipedNonMeleeItems[i].item.normalize();
		}
		for (i in 0...shields.length) {
			shields[i].shield.normalize();
		}
		for (i in 0...weapons.length) {
			weapons[i].weapon.normalize();
		}
	}
	
	static var MONEY_CALC_CACHE:Array<Int> = [0,0,0];
	static var MONEY_REF:Money = new Money();
	
	public function calculateTotalCost(forceIncludeDropped:Bool = false):Money {
		var item:Item;
		var qtyAssign:ItemQty;
		var calcCache:Array<Int> = MONEY_CALC_CACHE;
		calcCache[Item.CP] = 0;
		calcCache[Item.SP] = 0;
		calcCache[Item.GP] = 0;
		
		
		if (forceIncludeDropped) {
			for (i in 0...dropped.length) {
				qtyAssign = dropped.list[i];
				calcCache[qtyAssign.item.costCurrency] += qtyAssign.item.cost * qtyAssign.qty;
			}
		}
		for (i in 0...packed.length) {
			qtyAssign = packed.list[i];
			calcCache[qtyAssign.item.costCurrency] += qtyAssign.item.cost * qtyAssign.qty;
		}
		
		for (i in 0...wornArmor.length) {
			item = wornArmor[i].armor;
			calcCache[item.costCurrency] += item.cost;
		}
		for (i in 0...equipedNonMeleeItems.length) {
			item = equipedNonMeleeItems[i].item;
			calcCache[item.costCurrency] += item.cost;
		}
		for (i in 0...shields.length) {
			item = shields[i].shield;
			calcCache[item.costCurrency] += item.cost;
		}
		for (i in 0...weapons.length) {
			item = weapons[i].weapon;
			calcCache[item.costCurrency] += item.cost;
		}
		
		var moneyRef:Money = MONEY_REF;
		
		
		moneyRef.matchWithValues(calcCache[Item.GP], calcCache[Item.SP], calcCache[Item.CP]);
		return moneyRef.changeToHighest();
	}
	
	public static function sortBetweenAttachmentItems(ao:Item, bo:Item):Int
	{
		var a = ao.label.toLowerCase();
		var b = bo.label.toLowerCase();
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
	
	public static function sortBetweenSorted(ao:Sorted, bo:Sorted):Int
	{
		var a = ao.sortVal;
		var b = bo.sortVal;
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
	
	public static function sortBetweenSortedReversed(ao:Sorted, bo:Sorted):Int
	{
		var a = ao.sortVal;
		var b = bo.sortVal;
		if (a < b) return 1;
		if (a > b) return -1;
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
	
	// re-runs through list of ArmorAssign name labels and refresh half markers
	public static inline var LEFT_HALF_SUFFIX:String = "_";
	
	public function cleanupShieldLabels():Void {
		for (i in 0...shields.length) {
			shields[i].shield.tempFixSpecsFromName();
		}
	}
	
	public function refreshHalfArmorLabels():Void {
		for (i in 0...wornArmor.length) {
			var assign = wornArmor[i];
			var name = assign.armor.name;
			if (name.charAt(0) != "(") {
				assign.half = WEAR_WHOLE;
				continue;
			}
			var ni = name.indexOf(" ");
			var actualArmorName:String = name.substr(ni);
			name = name.substr(0, ni);
			var leftSideSuffix:Bool = name.charAt(name.length - 1) == LEFT_HALF_SUFFIX;
			if (leftSideSuffix) {
				name = name.substr(0, name.length - 1);
			}
			if (name == "(Half)" || name == "(single)") {  // 2 conventions
				if (name == "(Half)"){  // old version label convert to "(single)" label
					name = "(single)";
					assign.armor.name = name + (leftSideSuffix ? LEFT_HALF_SUFFIX : "") + " " + actualArmorName;
				}
				assign.half = leftSideSuffix ? WEAR_LEFT : WEAR_RIGHT;
			} else {
				assign.half = WEAR_WHOLE;
			}
		}
	}
	
	// if not already carrying a weapon/shield, draws them from equipment list
	public function weildMeleeEquip(?profs:Int):Void {
		var masterItem:Item = findMasterHandItem();
		var secItem:Item = findOffHandItem();
		if (masterItem != null) {
			if (!isWeaponary(masterItem)) {
				masterItem = null;
			}
		}
		if (secItem != null) {
			if (!isWeaponary(secItem)) {
				secItem = null;
			}
		}
		
		var weaponPicks:Array<SortedWeapon> = null;
		var w:SortedWeapon;
		var shieldPicks:Array<SortedShield>;
		if (masterItem == null) {
			if (weaponPicks == null) weaponPicks = getSortedWeapons(false, profs, true, true); 
			if (weaponPicks.length > 0) {
				w = weaponPicks.pop();
				holdEquiped(w.assign, w.assign.weapon.twoHanded ? HELD_BOTH : HELD_MASTER);
				if (w.assign.weapon.twoHanded) return;
			}
		}
		
		if (secItem == null) {
			shieldPicks = getSortedShields(true, true);
			if (shieldPicks.length > 0) {
				holdEquiped(shieldPicks.pop().assign, HELD_OFF);
				return;
			}
			
			if (weaponPicks == null) weaponPicks = getSortedWeapons(false, profs, true, true);
			while (weaponPicks.length > 0) {
				w = weaponPicks.pop();
				if (!w.assign.weapon.twoHanded) {
					holdEquiped(w.assign, HELD_OFF);
					return;
				}
			}
		}
	}
	
	public function dropEquipedShield(alreadyEquiped:ShieldAssign, doDestroy:Bool = false):ItemQty {  // Not applicable for shield
		var ind:Int= shields.indexOf(alreadyEquiped);
		if (!doDestroy) {
			var s:ItemQty = _shiftItem(alreadyEquiped.shield, PREFER_UNHELD_DROPPED, 1);
			if (s!=null) {
				return s;
			}
		}
		shields.splice(ind , 1 );
		dispatchSignal(doDestroy ? InventorySignal.DeleteItem : InventorySignal.DropItem);
		return null;
	}
	public function dropMiscItem(alreadyEquiped:ItemAssign, doDestroy:Bool = false):ItemQty {
		var ind:Int = equipedNonMeleeItems.indexOf(alreadyEquiped);
		if (!doDestroy) {
			var s:ItemQty = _shiftItem(alreadyEquiped.item, PREFER_UNHELD_DROPPED, 1, getAttachmentArray(equipedNonMeleeItems, ind, "item"));
			if (s!=null ) {
				return s;
			}
		}
		equipedNonMeleeItems.splice( ind, 1 );
		dispatchSignal(doDestroy ? InventorySignal.DeleteItem : InventorySignal.DropItem);
		return null;
	}
	public function dropEquipedWeapon(alreadyEquiped:WeaponAssign, doDestroy:Bool = false):ItemQty {
		var ind:Int = weapons.indexOf(alreadyEquiped);
		if (!doDestroy) {
			var s:ItemQty = _shiftItem(alreadyEquiped.weapon, PREFER_UNHELD_DROPPED, 1, getAttachmentArray(weapons, ind, "weapon"));
			if ( s!=null) {
				return s;
			}
		}
		weapons.splice( ind, 1 );
		dispatchSignal(doDestroy ? InventorySignal.DeleteItem : InventorySignal.DropItem);
		return null;
	}
	
	public function dropWornArmor(alreadyEquiped:ArmorAssign, doDestroy:Bool = false):ItemQty {
		var ind:Int = wornArmor.indexOf(alreadyEquiped);
		if (!doDestroy) {
			var s:ItemQty = _shiftItem(alreadyEquiped.armor, PREFER_UNHELD_DROPPED, 1, getAttachmentArray(wornArmor, ind, "armor") );
			if ( s!=null ) {
				return s;
			}
		}
		wornArmor.splice(ind, 1);
		dispatchSignal(doDestroy ? InventorySignal.DeleteItem : InventorySignal.DropItem);
		return null;
	}
	
	public function packEquipedShield(alreadyEquiped:ShieldAssign):ItemQty {
		var ind:Int = shields.indexOf(alreadyEquiped);
		var s:ItemQty = _shiftItem(alreadyEquiped.shield, PREFER_UNHELD_PACKED, 1);
		if (s!=null) {
			return s;
		}
		shields.splice( ind, 1 );
		dispatchSignal(InventorySignal.PackItem);
		return null;
	}
	
	public function packMiscItem(alreadyEquiped:ItemAssign):ItemQty {
		var ind:Int = equipedNonMeleeItems.indexOf(alreadyEquiped);
		var s:ItemQty = _shiftItem(alreadyEquiped.item, PREFER_UNHELD_PACKED,  1, getAttachmentArray(equipedNonMeleeItems, ind, "item"));
		if (s!=null) {
			return s;
		}
		equipedNonMeleeItems.splice( ind , 1  );
		dispatchSignal(InventorySignal.PackItem);
		return null;
	}
	public function packEquipedWeapon(alreadyEquiped:WeaponAssign):ItemQty {
		var ind:Int = weapons.indexOf(alreadyEquiped);
		var s:ItemQty = _shiftItem(alreadyEquiped.weapon, PREFER_UNHELD_PACKED, 1, getAttachmentArray(weapons, ind, "weapon"));
		if (s!=null) {
			return s;
		}
		weapons.splice( ind, 1 );
		dispatchSignal(InventorySignal.PackItem);
		return null;
	}
	
	public function packWornArmor(alreadyEquiped:ArmorAssign):ItemQty {
		var ind:Int =  wornArmor.indexOf(alreadyEquiped);
		var s:ItemQty = _shiftItem(alreadyEquiped.armor, PREFER_UNHELD_PACKED, 1, getAttachmentArray(wornArmor, ind, "armor"));
		if (s!=null) {
			return s;
		}
		wornArmor.splice(ind , 1);
		dispatchSignal(InventorySignal.PackItem);
		return null;
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
	
	public static inline function isWeaponary(item:Item):Bool {
		return Std.is(item, Weapon) || Std.is(item, Shield);
	}
	
	
	public function layeredWearingMaskWith(a:Armor, name:String, body:BodyChar):Int
	{
		for (i in 0...wornArmor.length) {
			var ar = wornArmor[i].armor;
			if (ar.name == name) {
				
				return (a.getCoverageMask(body) & ar.getCoverageMask(body));
			}
		}
		return 0;
	}
	
	function equipItem(item:Item, unheldRemark:String = null):Dynamic {
		var unheld:Int = 0;
		var readyAssign:Dynamic = null;
		var weaponAssign:WeaponAssign;
		var shieldAssign:ShieldAssign;
		var itemAssign:ItemAssign;
		var armorAssign:ArmorAssign;
		
		if (Std.is(item, Weapon)) {
			
			weapons.push(readyAssign = weaponAssign = {attached:false,  key:UID_COUNT++, weapon:LibUtil.as(item, Weapon), held:0, unheld:UNHELD_UNSPECIFIED, unheldRemark:unheldRemark, holding1H:false});
		}
		else if (Std.is(item, Shield)) {
			
			shields.push(readyAssign = shieldAssign = {key:UID_COUNT++, attached:false, shield:LibUtil.as(item, Shield), held:0, unheld:UNHELD_UNSPECIFIED, unheldRemark:unheldRemark});
		}
		else if (Std.is(item, Armor)) {

			wornArmor.push( readyAssign =  armorAssign = {key:UID_COUNT++, attached:false, armor:LibUtil.as(item, Armor), held:0, unheld:UNHELD_UNSPECIFIED, unheldRemark:unheldRemark});
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
		else if (type == "armor") {
			return wornArmor;
		}
		else {
			return equipedNonMeleeItems;
		}
	}
	
	public static function getReadyAssignOf(item:Item):Dynamic {
		var weaponAssign:WeaponAssign;
		var shieldAssign:ShieldAssign;
		var itemAssign:ItemAssign;
		var armorAssign:ArmorAssign;
		
		if (Std.is(item, Weapon)) {
			return weaponAssign = {
				weapon:cast item,
				held:0, unheld:0, unheldRemark:"",
				key:UID_COUNT++,
				attached:false,
				holding1H:false,
			};
		}
		else if (Std.is(item, Shield)) {
			return shieldAssign= {
				shield:cast item,
				attached:false,
				held:0, unheld:0, unheldRemark:"",
				key:UID_COUNT++
			};
		}
		else if (Std.is(item, Armor)) {
			return armorAssign  = {
				armor:cast item,
				attached:false,
				held:0, unheld:0, unheldRemark:"",
				key:UID_COUNT++	
			}
		}
		else {
			return itemAssign = {
				item:item,
				attached:false,
				held:0, unheld:0, unheldRemark:"",
				key:UID_COUNT++
			};
		}
	}
	
	public static function getEmptyReadyAssign(type:String):Dynamic {  // Dynamic no choice??, these types is a real pain sometimes
		var weaponAssign:WeaponAssign;
		var shieldAssign:ShieldAssign;
		var itemAssign:ItemAssign;
		var armorAssign:ArmorAssign;
		
		if (type == "weapon") {
			return weaponAssign = {
				weapon:new Weapon(),
				held:0, unheld:0, unheldRemark:"",
				key:UID_COUNT++,
				holding1H:false,
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
		else if (type == "armor") {
			return armorAssign  = {
				armor:Armor.createEmptyInstance(),
				attached:false,
				held:0, unheld:0, unheldRemark:"",
				key:UID_COUNT++	
			}
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
	
	public function cleanupBeforeSerialize():Void
	{	
		setSignaler(null); 
	}
	
	
	var version:Int = 3;
	public function postSerialization():Void
	{
		postSerialize_2();
		postSerialize_3();
	}
	@:postSerialize function postSerialize_2():Bool {	// warning: ingame ONLY!
		if (version == null || version < 2) version = 2
		else return false;
		
		/*
		for (i in 0...weapons.length) {
			if ( weapons[i].weapon.burdinadin == null) {
				weapons[i].weapon.burdinadin = null;
			}
		}
		*/
		for (i in 0...wornArmor.length) {
			if ( wornArmor[i].armor.burdinadin == null) {
				wornArmor[i].armor.burdinadin = null;
			}
		}
		
		var armor:Armor;
		var weap:Weapon;
		for (i in 0...dropped.list.length) {
			var item = dropped.list[i].item;
			armor = LibUtil.as(item , Armor);
			weap = LibUtil.as(item , Weapon);
			if (armor != null) {
				if (armor.burdinadin == null) armor.burdinadin = null;
			}
			//if (weap != null) {
				//if (weap.burdinadin == null) weap.burdinadin = null;
			//}
		}
		
		for (i in 0...packed.list.length) {
			var item = packed.list[i].item;
			armor = LibUtil.as(item , Armor);
			weap = LibUtil.as(item , Weapon);
			if (armor != null) {
				if (armor.burdinadin == null) armor.burdinadin = null;
			}
			//if (weap != null) {
				//if (weap.burdinadin == null) weap.burdinadin = null;
			//}
			
		}
		

		return true;
	
	}
	@:postSerialize function postSerialize_3():Bool {
		if (version == null || version < 3) version = 3
		else return false;
		
		for (i in 0...weapons.length) {
			if (weapons[i].holding1H == null) {
				weapons[i].holding1H = false;
			}
		}
		return true;
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
	holding1H:Bool,
}

typedef ArmorAssign = {
	> ReadyAssign,
	armor:Armor,
	?half:Int
}

typedef ShieldAssign = {
	> ReadyAssign,
	shield:Shield
}

typedef Sorted = {
	sortVal:Float
}

typedef SortedWeapon = {
	> Sorted,
	assign:WeaponAssign
}

typedef SortedShield = {
	> Sorted,
	assign:ShieldAssign
}


