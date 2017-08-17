package troshx.sos.core;
import troshx.core.IUid;
import troshx.ds.HashedArray;
import troshx.ds.IDMatchArray;
import troshx.ds.IUpdateWith;
import troshx.sos.core.Inventory.ItemQty;
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
	
	public var wornArmor(default,never):Array<Armor> = [];	// any worn armor items
	
	public var equipedNonMeleeItems(default, never):Array<ItemAssign> = [];  // any readied/equiped non-melee items or pocketed items
	public var shields(default,never):Array<ShieldAssign> = [];	// melee shields carried or held
	public var weapons(default,never):Array<WeaponAssign> = [];  // melee weapons carried or held

	public static inline var HELD_OFF:Int = 1;
	public static inline var HELD_MASTER:Int = 2;
	public static inline var HELD_BOTH:Int = (1 | 2);
	
	public static inline var UNHELD_PACKED:Int = 1;
	public static inline var UNHELD_DROPPED:Int = 2;
	public static inline var UNHELD_EQUIPPED:Int = 4;
	
	public function holdItem(item:Item, holdSetting:Int=0):Void {
		
		if (item.twoHanded) holdSetting = HELD_BOTH;
		
		if (Std.is(item, Weapon)) {
			holdWeapon(LibUtil.as(item, Weapon), holdSetting != 0 ? holdSetting : HELD_MASTER);
		}
		else if (Std.is(item, Shield)) {
			holdShield(LibUtil.as(item, Shield), holdSetting != 0 ? holdSetting : HELD_OFF);
		}
		else if (Std.is(item, Armor)) {
			trace("You can't hold armor!! Equiping item instead!");
		}
		else {
			holdNonMeleeItem(item,  holdSetting != 0 ? holdSetting : HELD_MASTER);
		}
	}
	

	

	public function unholdItem(item:Item, preferedUnheld:Int = 0):Int {
		
		if (preferedUnheld == UNHELD_EQUIPPED) {
			equipItem(item);
			return 0;  
		}
		
		var spliceIndex:Int = -1;
		
		var spliceItem:ReadyAssign = null;
		var spliceArray:Array<ReadyAssign> = null;
		
		// check if item is being held within their respetive assignments, and treat them as existing held item and set held=0 for those items
		if (weaponOffhand == item || weaponHand == item) {
			if (weaponOffhand == item) {
				weaponOffhand = null;
			}
			if (weaponHand == item) {
				weaponHand = null;
			}
			//spliceIndex = weapons.indexOf(LibUtil.as(item, Weapon));
			spliceArray = weapons;
			//spliceIndex = -1;
			for (i in 0...weapons.length) {
				if (weapons[i].weapon == item) {
					weapons[i].held = 0;
					spliceIndex = i;
					spliceItem = spliceArray[i];
					break;
				}
			}
			
		}
		
		if (itemOffhand == item || itemHand == item) {
			if (itemHand == item) {
				itemHand = null;
			}
			if (itemOffhand == item) {
				itemOffhand = null;
			}
			spliceArray = equipedNonMeleeItems;
			//spliceIndex = -1;
			for (i in 0...equipedNonMeleeItems.length) {
				if (equipedNonMeleeItems[i].item == item) {
					equipedNonMeleeItems[i].held = 0;
					spliceIndex = i;
					spliceItem = spliceArray[i];
					break;
				}
			}
			
		}
		
		if (shieldOffhand == item || shieldHand == item) {
			if (shieldOffhand == item) {
				shieldOffhand = null;
			}
			if (shieldHand == item) {
				shieldHand = null;
			}
			spliceArray = shields;
			//spliceIndex = -1;
			for (i in 0...shields.length) {
				if (shields[i].shield == item) {
					shields[i].held = 0;
					spliceIndex = i;
					spliceItem = spliceArray[i];
					break;
				}
			}
			
		}
		
		if (preferedUnheld < 0) {  // if got existing item with unheld preference, do NOT add it back to respective array!
			return spliceItem != null ? spliceItem.unheld :  0; 
		}
	
		// Else continue to  re-add it back to prefered unheld for UNHELD_PACKED or UNHELD_DROPPED if required...
		
		//preferedUnheld = preferedUnehd != 0 ? preferedUnheld : if got existing equipped held item ? existinghelditem.unheld : 0;
		if (preferedUnheld > 0) {
			if (preferedUnheld != UNHELD_EQUIPPED) {  // would != the case of existingHeldItem.unheld already remain requipped
				if (preferedUnheld == UNHELD_PACKED) {
					packed.add( new ItemQty(item) );
					// if got existing held item, remove from existing held list
					if (spliceIndex >= 0) {
						spliceArray.splice(spliceIndex, 1);
					}
				}
				else if (preferedUnheld == UNHELD_DROPPED) {
					dropped.add( new ItemQty(item) );
					// if got existing held item, remove from existing held list
					if (spliceIndex >= 0) {
						spliceArray.splice(spliceIndex, 1);
					}
				}
				else {
					trace("Unaccounted prefered unheld case: " + preferedUnheld);
				}
			}
		}
		else {  // would be the case of existingHeldItem.unheld == 0
			// no unheld state saved, item completely demolished to the void
			if (spliceIndex >= 0) {
					spliceArray.splice(spliceIndex, 1);
				}
		}
		
		return spliceItem != null ? spliceItem.unheld :  0; 
	}
	
	public function packItem(item:Item):Void {
		unholdItem(item, UNHELD_PACKED);
	}
	
	public function dropItem(item:Item):Void {
		unholdItem(item, UNHELD_DROPPED);
	}
	
	public function equipItem(item:Item, unheldRemark:String = null) {
		var unheld:Int = 0;
		
		unheld = unholdItem(item, -1);  // always attempt to unhold any weapon before equiping them...
		if (unheld == UNHELD_EQUIPPED) {
			return;	// already equiped, don't need to add to list
		}
		
		if (Std.is(item, Weapon)) {
			
			weapons.push({weapon:LibUtil.as(item, Weapon), held:0, unheld:UNHELD_EQUIPPED, unheldRemark:unheldRemark});
		}
		else if (Std.is(item, Shield)) {
			
			shields.push({shield:LibUtil.as(item, Shield), held:0, unheld:UNHELD_EQUIPPED, unheldRemark:unheldRemark});
		}
		else if (Std.is(item, Armor)) {
			var a = LibUtil.as(item, Armor);
			if ( wornArmor.indexOf(a) < 0 ) {
				trace("Armor already equiped!");
				return;
			}
			wornArmor.push(a);
		}
		else {
			equipedNonMeleeItems.push({item:item, held:0, unheld:UNHELD_EQUIPPED, unheldRemark:unheldRemark});
		}
	}
	
	
	
	// imperative hold cache
	public var weaponHand(default, null):Weapon;
	public var weaponOffhand(default, null):Weapon; 
	function holdWeapon(weapon:Weapon, held:Int):Void {	// validate weilded weapon and shields

		var w;
		var lastHeld:Int;
		var alreadyEquiped:WeaponAssign = null;
		for (i in 0...weapons.length) {
			w = weapons[i];
			lastHeld = w.held;
			w.held &= ~held;
			if (lastHeld != w.held) {
				if ( (held & HELD_OFF) != 0 && weaponOffhand == weapon) {
					weaponOffhand = null;
				}
				if ( (held & HELD_MASTER) != 0 && weaponHand == weapon) {
					weaponHand = null;
				}
			}
			if (w.weapon == weapon) {
				alreadyEquiped = w;
			}
		}
		
		if (alreadyEquiped !=null) {
			alreadyEquiped.held = held;
		}
		else {
			var qtyItem:ItemQty = new ItemQty(weapon);
			weapons.push({weapon:weapon, held:held, unheld:packed.splicedAgainst(qtyItem) ? UNHELD_PACKED : dropped.splicedAgainst(qtyItem) ? UNHELD_DROPPED : 0 });
		}
		
		
	}
	
	// imperative hold cache
	public var shieldHand(default, null):Shield;
	public var shieldOffhand(default, null):Shield; 
	function holdShield(shield:Shield, held:Int):Void {	// validate weilded weapon and shields
		
		var w;
		var lastHeld:Int;
		var alreadyEquiped:ShieldAssign = null;
		for (i in 0...shields.length) {
			w = shields[i];
			lastHeld = w.held;
			w.held &= ~held;
			if (lastHeld != w.held) {
				if ( (held & HELD_OFF) != 0 && shieldOffhand == shield) {
					shieldOffhand = null;
				}
				if ( (held & HELD_MASTER) != 0 && shieldHand == shield) {
					shieldHand = null;
				}
			}
			if (w.shield == shield) {
				alreadyEquiped = w;
			}
		}
		
		if (alreadyEquiped !=null) {
			alreadyEquiped.held = held;
		}
		else {
			var qtyItem:ItemQty = new ItemQty(shield);
			shields.push({shield:shield, held:held, unheld:packed.splicedAgainst(qtyItem) ? UNHELD_PACKED : dropped.splicedAgainst(qtyItem) ? UNHELD_DROPPED : 0 });
		}
		
		
	}
	
	// imperative hold cache
	public var itemHand(default, null):Item;
	public var itemOffhand(default, null):Item; 
	function holdNonMeleeItem(item:Item, held:Int):Void {	
		var w;
		var lastHeld:Int;
		var alreadyEquiped:ItemAssign = null;
		for (i in 0...equipedNonMeleeItems.length) {
			w = equipedNonMeleeItems[i];
			lastHeld = w.held;
			w.held &= ~held;
			if (lastHeld != w.held) {
				if ( (held & HELD_OFF) != 0 && itemOffhand == item) {
					itemOffhand = null;
				}
				if ( (held & HELD_MASTER) != 0 && itemHand == item) {
					shieldHand = null;
				}
			}
			if (w.item == item) {
				alreadyEquiped = w;
			}
		}
		
		if (alreadyEquiped !=null) {
			alreadyEquiped.held = held;
		}
		else {
			var qtyItem:ItemQty = new ItemQty(item);
			equipedNonMeleeItems.push({item:item, held:held, unheld:packed.splicedAgainst(qtyItem) ? UNHELD_PACKED : dropped.splicedAgainst(qtyItem) ? UNHELD_DROPPED : 0 });
		}
	}
	
	
	public function new() 
	{
		
	}
	
}



class ItemQty implements IUid implements IUpdateWith<ItemQty> {
	public var item:Item = null;
	public var qty:Int ;
	public var uid(get, null):String;
	
	public function new(item:Item = null, qty:Int = 1):Void {
		this.item = item != null ? item : new Item();
		this.qty = qty;
	}
	
	public function updateAgainst(ref:ItemQty):Void {
		qty += ref.qty;
	}
	
	public function spliceAgainst(ref:ItemQty):Int {
		qty -= ref.qty;
		return qty;
	}
	
	function get_uid():String 
	{
		return item.uid;
	}
}

typedef ReadyAssign = {
	held:Int,
	unheld:Int,
	?unheldRemark:String
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


