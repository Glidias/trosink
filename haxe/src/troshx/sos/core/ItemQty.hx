package troshx.sos.core;
import troshx.core.IUid;
import troshx.ds.IUpdateWith;
import troshx.ds.IValidable;

/**
 * ...
 * @author Glidias
 */
class ItemQty implements IUid implements IUpdateWith<ItemQty> implements IValidable {
	public var item:Item;
	public var qty:Int;

	public var uid(get, never):String;
	
	public function isValid():Bool {	

		return qty  > 0 && item != null && item.name != null && item.name != "";
	}
	
	public function new(item:Item = null, qty:Int = 1):Void {
		this.item = item != null ? item : new Item();
		this.qty = qty;
	}
	
	public function updateAgainst(ref:ItemQty):Void {
		qty += ref.qty;
	}
	
	/*
	public function getTotalWeight():Int {
		return item.weight * qty;
	}
	*/
	
	public function spliceAgainst(ref:ItemQty):Int {
		qty -= ref.qty;
		return qty;
	}
	
	function get_uid():String 
	{
		return item.uid;
	}

	
}