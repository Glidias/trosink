package haxevx.vuex.util;

/**
 * ...
 * @author Glidias
 */
class ActionFactory
{
	// inlining macro to allow for dollar sign 
	static var store(get, null):Dynamic;
	static inline function get_store():Dynamic 
	{
		return untyped __js__("this.$store");
	}
	
	public static function getActionDispatch(type:String, context:Dynamic=null):?Dynamic->Void {
		return function(payload:Dynamic=null) {		
			(context != null ? context : store).dispatch(type, payload);
		};
	}
	
	
}

