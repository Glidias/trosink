package troshx.util;

/**
 * ...
 * @author Glidias
 */
class StringHashId
{
	static var COUNT:Int = 0;
	
	public static function get():String {
		return "i" + (COUNT++);
	}


	
}