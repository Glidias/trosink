package troshx.ds;
import troshx.core.IUid;

/**
 * A generic list id matching array to support both adding and updating of items containing Uid and IUpdateWith interfaces.
 * This version allows for non-immutable ids at the cost of some linear iterative performance overhead.
 * 
 * @author Glidias
 */
class IDMatchArray<T:(IUid,IUpdateWith<T>)> implements IMatchArray<T>
{
	public var list(default, null):Array<T> = [];

	public function new() 
	{
		
	}
	
	public function add(item:T):Void {
		var uid:String = item.uid;
		
		var matchingItem:T = getMatchingItem(item);
		if (matchingItem == null) {
			list.push(matchingItem);
		}
		else {
			matchingItem.updateAgainst(item);
			var testIndex:Int;
			if ( item != matchingItem && (testIndex = list.indexOf(item)) >=0) {
				list.splice(testIndex, 1);
			}
		}
	}
	
	public function delete(item:T):Void {
		
		var uid:String = item.uid;
		if (contains(item)) {
			
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
		for (i in 0...list.length) {
			if (list[i].uid == item.uid) {
				return true;
			}
		}
		return false;
	}
	
	public function splicedAgainst(item:T):Bool {
		
		var spliceIndex:Int =-1;
		var spliceItem:T = null;
		
		for (i in 0...list.length) {
			var a = list[i];
			if (a.uid == item.uid) {
				spliceItem = a;
				spliceIndex = i;
				break;
			}
		}
		
		if (spliceItem != null) {
			if (  spliceItem.spliceAgainst(item) <= 0  ) {
				list.splice(spliceIndex, 1);
			}
			return true;
		}
		return false;
	}
	
	
	function getMatchingItem(item:T):T {
		for (i in 0...list.length) {
			var a = list[i];
			if (a.uid == item.uid) {
				return a;
			}
		}
		return null;
	}
	
	
	inline function listContains(item:T):Bool {
		return list.indexOf(item) >= 0;
	}
	
	
	
}