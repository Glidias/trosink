package haxevx.vuex.util;

/**
 * ...
 * @author Glidias
 */
class MutatorFactory
{
	
	static var store(get, null):Dynamic;
	static inline function get_store():Dynamic 
	{
		return untyped __js__("this.$store");
	}
	
	public static function getMutatorCommit(type:String, context:Dynamic = null):Void->Void {
		// to test: possible to precompute context out of here??
		return function() {		
			(context != null ? context : store).commit(type);
		};
	}
	
	
}