package troshx.sos.core;
import troshx.core.IUid;
import troshx.ds.HashedArray;
import troshx.ds.IDMatchArray;
import troshx.ds.IUpdateWith;
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

	public static inline var HELD_LEFT:Int = 1;
	public static inline var HELD_RIGHT:Int = 2;
	public static inline var HELD_BOTH:Int = (1 | 2);
	
	public static inline var UNHELD_PACKED:Int = 1;
	public static inline var UNHELD_DROPPED:Int = 2;
	public static inline var UNHELD_EQUIPPED:Int = 4;
	
	public function holdItem(item:Item, preferOffhand:Bool=false):Void {
		
		
		if (Std.is(item, Weapon)) {
			holdWeapon(LibUtil.as(item, Weapon), preferOffhand);
		}
		else if (Std.is(item, Shield)) {
			holdShield(LibUtil.as(item, Shield), true);
		}
		else if (Std.is(item, Armor)) {
			trace("You can't hold armor!! Equiping item instead!");
		}
		else {
			holdNonMeleeItem(item, preferOffhand);
		}
	}
	

	public function unholdItem(item:Item, preferedUnheld:Int = 0):Int {
		
		if (preferedUnheld == UNHELD_EQUIPPED) {
			equipItem(item);
			return;
		}
		
		// check if item is being held within their respetive assignments, and treat them as existing held item and set held=0 for those items
		
		if (preferedUnheld < 0) {  // if got existing item with unheld preference, do NOT add it back to respective array!
			// return unheld state of existing item
		}
	
		// Else continue to  re-add it back to prefered unheld for UNHELD_PACKED or UNHELD_DROPPED if required...
		
		//preferedUnheld = preferedUnehd != 0 ? preferedUnheld : if got existing equipped held item ? existinghelditem.unheld : 0;
		if (preferedUnheld > 0) {
			if (preferedUnheld != UNHELD_EQUIPPED) {  // would be the case of existingHeldItem.unheld already remain requipped
				if (preferedUnheld == UNHELD_PACKED) {
					packed.add(item);
					// if got existing held item, remove from existing held list
				}
				else if (preferedUnheld == UNHELD_DROPPED) {
					dropped.add(item);
					// if got existing held item, remove from existing held list
				}
				else {
					trace("Unaccounted prefered unheld case: " + preferedUnheld);
				}
			}
		}
		
		return 0; // return unheld state of existing item (if any)
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
	function holdWeapon(weapon:Weapon, preferOffhand:Bool):Void {	// validate weilded weapon and shields
		// may exist in: 'dropped' or 'packed'  or under 'weapons'
		
		var held:Int = weapon.twoHanded ? HELD_BOTH :  preferOffhand ? HELD_LEFT : HELD_RIGHT;
		
		// assign to weapons with previous exist...
	}
	
	// imperative hold cache
	public var shieldHand(default, null):Shield;
	public var shieldOffhand(default, null):Shield; 
	function holdShield(shield:Shield, preferOffhand:Bool):Void {	// validate weilded weapon and shields
		// may exist in: 'dropped' or 'packed'  or under 'shields'
		
		var held:Int = shield.twoHanded ? HELD_BOTH :  preferOffhand ? HELD_LEFT : HELD_RIGHT;
		
		// assign to shield with previous exist...
		
	}
	
	// imperative hold cache
	public var itemHand(default, null):Item;
	public var itemOffhand(default, null):Item; 
	function holdNonMeleeItem(item:Item, preferOffhand:Bool):Void {	
		// may exist in: 'dropped' or 'packed'  or under 'equipedNonMeleeItems'
		
		var held:Int = item.twoHanded ? HELD_BOTH :  preferOffhand ? HELD_LEFT : HELD_RIGHT;
		
		// assign to items with previous exist
		
	}
	
	
	public function new() 
	{
		
	}
	
}



class ItemQty implements IUid implements IUpdateWith<ItemQty> {
	public var item:Item = null;
	public var qty:Int ;
	public var uid(get, null):String;
	
	public function ItemQty(item:Item = null, qty:Int = 1):Void {
		this.item = item != null ? item : new Item();
		this.qty = qty;
	}
	
	public function updateAgainst(ref:ItemQty):Void {
		qty += ref.qty;
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


