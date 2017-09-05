package troshx.ds;
import troshx.core.IUid;

/**
 * A generic hashed array to support both adding and updating of items containing Uid and IUpdateWith interfaces.
 * 
 * This requires a unique immutable id assigned to each Uid instance at the moement the instance is added to the list,
 * or it may yield problems!
 * 
 * @author Glidias
 */
class HashedArray<T:(IUid,IUpdateWith<T>)> implements IMatchArray<T>
{
	public var list(default, null):Array<T> = [];
	public var hash:Dynamic<T> = {};
	
	// if no more modifications are to be made to the array, you can bake it to nullify the hash.
	public inline function bake():Void {
		hash = null;
	}
	
	public function new() 
	{
		
	}
	
	public function add(item:T):Void {
		var uid:String = item.uid;
		if (!hashContains(item)) {
			Reflect.setField(hash, uid, item);
			list.push(item);
		}
		else { 
			var fw:T = Reflect.field(hash, uid);
			fw.updateAgainst(item);
		}
	}
	
	public function delete(item:T):Void {
		var uid:String = item.uid;
		if (hashContains(item)) {
			Reflect.deleteField(hash, uid);
			
		}
		else { 
			trace("Warning: No item found to be removed for uid:" + item.uid);
		}
		
		var index:Int = list.indexOf(item);
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
	
	function hashContains(item:T):Bool {
		return Reflect.hasField(hash, item.uid);
	}
	
	function listContains(item:T):Bool {
		return list.indexOf(item) >= 0;
	}
	
	
}