package troshx.util;
import haxe.ds.StringMap;
import troshx.core.IUid;

/**
 * ...
 * @author Glidias
 */
class UidStringMapCreator 
{

	public static function createStrMapFromArray<T:IUid>(arr:Array<T>):StringMap<T> {
		var map = new StringMap<T>();
		for (i in 0...arr.length) {
			map.set(arr[i].uid, arr[i]);
		}
		
		return map;
	}
	
}