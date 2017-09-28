package troshx.ds;
import troshx.core.IUid;
import troshx.util.LibUtil;

/**
 * A generic hashed array to support both adding and updating of items containing Uid and IUpdateWith interfaces.
 * 
 * This requires a unique immutable id assigned to each Uid instance at the moement the instance is added to the list,
 * or it may yield problems! If any IDS change, you need to call rehash() on the HashedArray to update hash ids.
 * 
 * @author Glidias
 */
class HashedArray<T:(IUid,IUpdateWith<T>)> implements IMatchArray<T>
{
	public var list(default, null):Array<T> = [];
	public var hash:Dynamic<T> = {};
	
	// if no more modifications are to be made to the array, you can bake it to nullify the hash.
	/*
	public inline function bake():Void {
		hash = null;
	}
	*/
	
	public function new() 
	{
		
	}
	
	public function rehash():Void {
		hash = {};
		for (i in 0...list.length) {
			var item = list[i];
			LibUtil.setField(hash, item.uid, item);
		}
	}
	
	public function add(item:T):Void {
		var uid:String = item.uid;
		if (!hashContains(item)) {
			LibUtil.setField(hash, uid, item);
			list.push(item);
		}
		else { 
			var fw:T = LibUtil.field(hash, uid);
			fw.updateAgainst(item);
		}
	}
	
	/*
	public function replace(item:T):Bool {
		var uid:String = item.uid;
		if (hashContains(item)) {
			LibUtil.setField(hash, uid, item);
			var index:Int = indexOf(item);
			if (index >= 0) {
				list[index] = item;
			}
			return true;
		}
		return false;
	}
	*/
	
	public function indexOf(item:T):Int {
		for (i in 0...list.length) {
			if (list[i].uid == item.uid) return i;
		}
		return -1;
	}
	
	public function delete(item:T):Void {
		var uid:String = item.uid;
		if (hashContains(item)) {
			Reflect.deleteField(hash, uid);
			
		}
		else { 
			trace("Warning: No item found to be removed for uid:" + item.uid);
		}
		
		var index:Int = indexOf(item);
		if (index >= 0) {
			list.splice(index, 1);
		}
		else {
			trace("Warning: No item found to be removed for array index:" + index);
		}		
	}
	
	public function contains(item:T):Bool {
		return hashContains(item);
	}
	inline public function containsId(ider:String):Bool {
		return Reflect.hasField(hash, ider);
	}
	
	function hashContains(item:T):Bool {
		return Reflect.hasField(hash, item.uid);
	}
	
	public inline function findById(id:String):T {
		return Reflect.field(hash, id);
	}
	
	function listContains(item:T):Bool {
		return indexOf(item) >= 0;
	}
	
	
}