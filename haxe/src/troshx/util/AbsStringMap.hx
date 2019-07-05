package troshx.util;
#if js
#else
import haxe.ds.StringMap;
#end

/**
 * Cross platform StringMap implementation. For various Javascript/untyped targets that don't reflect types, just use plain old Dynamic object!
 * @author Glidias
 */
abstract AbsStringMap<T>(
#if js
Dynamic<T>
#else
StringMap<T>
#end
)
{

	inline public function new() 
	{
		#if js
		this = {};
		#else
		this = new StringMap<T>();
		#end
	}
	
	inline public function set(p:String, val:T):Void {
		#if js
		LibUtil.setField(this, p, val);
		#else
		this.set(p, val);
		#end
	}
	
	inline public function get(p:String):T {
		#if js
		return LibUtil.field(this, p);
		#else
		return this.get(p);
		#end
	}
	
	
}