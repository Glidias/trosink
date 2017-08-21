package troshx.sos.core;


#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.VarAccess;
import haxe.macro.ComplexTypeTools;
import haxe.macro.MacroStringTools;
import haxe.macro.TypeTools;
#end

/**
 * Base Item class consisting of stuff relavant for all items/item-creations
 * @author Glidias
 */
class Item 
{
	public var weight:Float = 0;
	public var name:String;
	
	public var id(default,null):String;
	public var uid(get, never):String;
	public var label(get, never):String;

	static var UID_COUNT:Int = 0;
	
	public var flags:Int = 0;
	public static inline var FLAG_TWO_HANDED:Int = 1;
	public static inline var FLAG_STRAPPED:Int = 2;
	public static inline var MASK_HANDED:Int = 1 | 2;
	
	public var twoHanded(get, never):Bool;
	public var strapped(get, never):Bool;
	
	/**
	 * 
	 * @param	id	Empty string by default, which resolves to name dynamically if you wish. Set to explicit null to auto-generate a unique immutable id.
	 * @param	name	The name label of the item
	 */
	public function new(id:String= "", name:String = "") 
	{
		this.id = id != null ? id : "Item_" + UID_COUNT++;
		this.name = name;
		
	}
	
	public function getTypeLabel():String {
		return "MiscItem";
	}
	
	function get_uid():String 
	{
		return id != "" ? id : name;
	}
	
	function get_label():String {
		return name;
	}
	
	inline function get_twoHanded():Bool 
	{
		return (flags & FLAG_TWO_HANDED) != 0;
	}
	inline function get_strapped():Bool 
	{
		return (flags & FLAG_STRAPPED) != 0;
	}
	
	
	public static function labelizeAllCaps(name:String):String {
		var spl = name.split("_");
		for (i in 0...spl.length) {
			spl[i] =  spl[i].charAt(0).toUpperCase() + spl[i].substr(1).toLowerCase();
		}
		return spl.join(" ");
	}
	
	public static function labelizeCamelCase(name:String):String {
		var r = new EReg("([A-Z]+)", "g");
		var r2 = new EReg("([A-Z][a-z])", "g");
		name = r.replace(name, "$1");
		name = r2.replace(name, " $1");
		name = StringTools.trim(name);
		name = name.charAt(0).toUpperCase() + name.substr(1);
		//trace(name);
		return name;
	}
	
	public static function labelizeAllCapsArr(arr:Array<String>):Array<String> {
		var newArr:Array<String> = [];
		for (i in 0...arr.length) {
			newArr[i] = labelizeAllCaps(arr[i]);
		}
		return newArr;
	}
	
	public static function labelizeCamelCaseArr(arr:Array<String>):Array<String> {
		var newArr:Array<String> = [];
		for (i in 0...arr.length) {
			newArr[i] = labelizeCamelCase(arr[i]);
		}
		return newArr;
	}
	
	
	// Macros to be used
	
	public static macro function pushFlagLabelsToArr(labelize:Bool=true):Expr {
	
		var fields = Context.getLocalClass().get().statics.get();
		var block:Array<Expr> = [];
		
		var count:Int = 0;
		for ( i in 0...fields.length) {
			var f = fields[i];
			var fieldName:String = f.name;
			switch(f.kind) {
				case FVar(VarAccess.AccInline, VarAccess.AccNever):
					if (fieldName != "TOTAL_FLAGS") {
						if (labelize )  block.push( macro { if ( flags & (1 << $v{count}) != 0 )  arr.push($v{ labelizeAllCaps(fieldName) }); } );
						else block.push( macro {  arr.push($v{ fieldName }); } );
						count++;
					}
				default:
			}
			//trace(f.kind);
		}
		return macro $b{block};
	}
	
	
	public static macro function pushVarLabelsToArr(labelize:Bool=true):Expr {
		var fields = Context.getLocalClass().get().fields.get();
		var block:Array<Expr> = [];
		
		var count:Int = 0;

		var intTypeStr = ComplexTypeTools.toType( MacroStringTools.toComplex("Int") ) + "";
		

		for ( i in 0...fields.length) {
			var f = fields[i];
			var fieldName:String = f.name;
			switch(f.kind) {
				case FVar(VarAccess.AccNormal, VarAccess.AccNormal):
					var ct = haxe.macro.TypeTools.toComplexType(f.type);
					if (f.type+"" == intTypeStr) { // should be good enough to detect Int
						if (f.name.indexOf("_") >= 0) continue;
						if (labelize) block.push( macro { if (  instance.$fieldName != 0 )  arr.push($v{ labelizeCamelCase(fieldName) }); } );
						else block.push( macro {  arr.push($v{ fieldName }); } );
					}
					
				default:
			}
			
		}
		return macro $b{block};
	}
	
	

	

	
	
}


