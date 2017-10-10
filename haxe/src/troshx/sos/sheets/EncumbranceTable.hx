package troshx.sos.sheets;

/**
 * ...
 * @author Glidias
 */
class EncumbranceTable
{

	static var TABLE:Array<EncumbranceRow>;
	public static function getTable():Array<EncumbranceRow> {
		return TABLE != null ? TABLE : (TABLE = getNewTable());
	}
	public static function getNewTable():Array<EncumbranceRow> {
		return [
			{ name:"Unencumbered", cp:0, mob:0, skill:0, exhaustion:1, recovery:1, cpMult:1, mobMult:1 },
			{ name:"Light", cp:-1, mob:-2, skill:1, exhaustion:1.5, recovery:1, cpMult:1, mobMult:1 },
			{ name:"Medium", cp:-2, mob:-4, skill:2, exhaustion:2, recovery:0.5, cpMult:1, mobMult:1 },
			{ name:"Heavy", cp:-3, mob:-6, skill:3, exhaustion:3, recovery:0.25, cpMult:1, mobMult:1 },
			{ name:"Overloaded", cp: -4, mob: -8, skill:4, exhaustion:3.5, recovery:0, cpMult:1, mobMult:1 },
			
			{ name:"Beyond Overloaded!", cp:-4, mob:-8, skill:4, exhaustion:3.5, recovery:0, cpMult:0, mobMult:0 }
		];
	}
}

typedef EncumbranceRow = {
	var name:String;
	var cp:Int;
	var mob:Int;
	var skill:Int;
	var exhaustion:Float;
	var recovery:Float;
	var cpMult:Int;
	var mobMult:Int;
}