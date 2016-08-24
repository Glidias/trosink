package troshx.tros;

/**
 * ...
 * @author Glidias
 */
@:expose
class ManueverSheet
{

	public function new() 
	{
		
	}
	public static function getManueverById(id:String):Manuever {
		return null;
		
	}
	
	static public function isDamagingManuever(ms:String) 
	{
		// todo: proper manuever parameter
		return ms == "cut" || ms == "spike" || ms == "thrust" || ms == "bash";
	}	
	
}