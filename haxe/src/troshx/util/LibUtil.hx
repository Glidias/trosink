package troshx.util;

/**
 * ...
 * @author Glidias
 */
class LibUtil
{


	
	public static inline function validInt(?val:Int):Bool {
		return val != null && !Math.isNaN(val);
	}
	public static inline function as<T>( obj:Dynamic, type:Class<T> ):T {
		return Std.is( obj, type ) ? cast obj : null;
	}
	public static  function asNoInline<T>( obj:Dynamic, type:Class<T> ):T {
		return Std.is( obj, type ) ? cast obj : null;
	}
	
	public static inline function tryParseFloat(val:Dynamic ):Dynamic {
		return Std.parseFloat(val);  // TOCHECK: across all platforms validity
	}
	public static inline function tryParseInt(val:Dynamic ):Dynamic {
		return Std.parseInt(val); // TOCHECK: across all platforms validity
	}
	
	public static function sortAlphabetically(aStr:String, bStr:String):Int
	{
		aStr = aStr.toLowerCase();
		bStr = bStr.toLowerCase();
		if (aStr < bStr) return -1;
		if (aStr > bStr) return 1;
		return 0;
	} 
		
	public static inline function setArrayLength<T>(of:Array<T>, len:Int):Void {
		//#if js
		//untyped of.length = len;
		//#else
		of.splice(len, of.length - len );
		//#end
	}
	
	public static inline function field<T>(of:Dynamic<T>, field:String):T {
		#if js
		return untyped of[field];
		#else
		return Reflect.field(of, field);
		#end
	}
	public static inline function setField<T>(of:Dynamic<T>, field:String, value:T):Void {
		#if js
		untyped of[field] = value;
		#else
		Reflect.setField(of, field, value);
		#end
	}
	
	public static function override2ndObjInto(into:Dynamic, obj2:Dynamic):Dynamic {
		for (p in Reflect.fields(obj2)) {
			LibUtil.setField(into, p, LibUtil.field(obj2, p));
		}
		return into;
	}
	public static function setFieldChain<T>(of:Dynamic<T>, field:String, value:T):T {
		setField(of, field, value);
		return value;
	}

	
	public static function arrayToList<T>(arr:Array<T>):List<T> {
		var list:List<T> = new List<T>();
		for (val in arr) {
			list.add(val);
		}
		return list;
	}
	
	public static inline function getArrayItemAtIndex<T>(arr:Array<T>, index:Int):T {
		return arr[index];
	}
	
	public static function getListItemAtIndex<T>(list:List<T>, index:Int):T {
		if (index < 0 || index >= list.length) return null;
		var iter = list.iterator();
		for (i in 0...index) {
			iter.next();
		}
		return iter.next();
	}
	
	public static inline function clearArray<T>(arr:Array<T>):Void {
		#if (js||flash)
		untyped arr.length = 0;
		#else
		arr.splice(0,arr.length);
		#end
	}
	
	public static inline function truncateArray<T>(arr:Array<T>, fromIndex:Int):Void {
		#if (js||flash)
		untyped arr.length = fromIndex;
		#else
		arr.splice(fromIndex, arr.length);
		#end
	}
	
	public static function findForList<T>(list:List<T>, f : T -> Bool ):T {
		for ( i in list) {
			if (f(i)) {
				return i;
			}
		}
		return null;
	}
	
	static public function minI(a:Int, b:Int):Int 
	{
		return (a < b ? a : b);
	}
	static public function maxI(a:Int, b:Int):Int 
	{
		return (a >= b ? a : b);
	}
	static public inline function minI_(a:Int, b:Int):Int 
	{
		return (a < b ? a : b);
	}
	static public inline function maxI_(a:Int, b:Int):Int 
	{
		return (a >= b ? a : b);
	}
	
	static public inline function removeArrayItemAtIndex<T>(arr:Array<T>, index:Int) 
	{
		arr.splice(index,1);
	}
	
	static public #if !cs inline #end function toFixed(value:Float, digits:Int):String
    {
        #if (js || flash)
        return untyped value.toFixed(digits);
        #elseif php
        return untyped __call__("number_format", value, digits, ".", "");
        #elseif java
        return untyped __java__("String.format({0}, {1})", '%.${digits}f', value);
        #elseif cs
        var separator:String = untyped __cs__('System.Globalization.CultureInfo.CurrentCulture.NumberFormat.NumberGroupSeparator');
        untyped __cs__('System.Globalization.CultureInfo.CurrentCulture.NumberFormat.NumberGroupSeparator = ""');
        var result = untyped value.ToString("N" + digits);
        untyped __cs__('System.Globalization.CultureInfo.CurrentCulture.NumberFormat.NumberGroupSeparator = separator');
        return result;
        #else
        throw "未実装";
        #end
    }
	
}