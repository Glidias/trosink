package troshx.util;
import troshx.core.IUid;

/**
 * ...
 * @author Glidias
 */
class UidStringMapCreator 
{

	public static function createStrMapFromArray<T:IUid>(arr:Array<T>):AbsStringMap<T> {
		var map = new AbsStringMap<T>();
		for (i in 0...arr.length) {
			map.set(arr[i].uid, arr[i]);
		}
		
		return map;
	}
	
}