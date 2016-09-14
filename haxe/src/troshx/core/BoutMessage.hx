package troshx.core;

/**
 * ...
 * @author Glidias
 */
class BoutMessage
{
	public var text:String;
	public var type:Int;
	
	public static inline var TYPE_NONE:Int = 0;
	public static inline var TYPE_PLAYERS_TURN:Int = 1;
	public static inline var TYPE_RESOLVE_MANUEVER:Int = 2;

	
	public static function create(type:Int = 0, text:String = null):BoutMessage {
		var me:BoutMessage = new BoutMessage();
		me.type = type;
		me.text = text;
		return me;
	}

	public function new() 
	{
		
	}
	
}