package troshx.sos.sheets;

/**
 * ...
 * @author Glidias
 */
class FatiqueTable 
{

	static var TABLE:Array<FatiqueRow>;
	public static function getTable():Array<FatiqueRow> {
		return TABLE != null ? TABLE : (TABLE = getNewTable());
	}
	
	public static function getFatiqueLevel(fatique:Int, hlt:Int):Int {
		var f:Int = Math.ceil( (fatique-5-hlt) / 5);
		return f >= 0 ? f < 5 ? f : 4 : 0; 
	}
	public static function getNewTable():Array<FatiqueRow> {
		return [
			{ name:"Fresh", cp:0, mob:0, skill:0 },
			{ name:"Winded", cp:-1, mob:-1, skill:-1},
			{ name:"Tired", cp:-2, mob:-2, skill:-2 },
			{ name:"Very Tired",cp:-4, mob:-4, skill:-4 },
			{ name:"Exhausted",cp:-6, mob:-6, skill:-6 },
		//	{ name:"Beyond Exhausted!", cp:-6, mob:-6, skill:-6 }
		];
	}
}

typedef FatiqueRow = {
	var name:String;
	var cp:Int;
	var mob:Int;
	var skill:Int;
}