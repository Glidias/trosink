package haxevx.vuex.util;

/**
 * ...
 * @author Glidias
 */
class ActionFactory
{
	
	static var store(get, null):Dynamic;
	static inline function get_store():Dynamic 
	{
		return untyped __js__("this.$store");
	}
	
	public static function getActionDispatch(type:String, context:Dynamic=null):Void->Void {
		return function() {		
			store.dispatch(type);
		};
	}
	
	
}