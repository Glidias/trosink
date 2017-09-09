package troshx.sos.core;

#if macro
import haxe.ds.StringMap;
import haxe.macro.ExprTools;
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
	@:flags("Two-Handed") public static inline var FLAG_TWO_HANDED:Int = (1<<0);
	@:flags("Strapped") public static inline var FLAG_STRAPPED:Int = (1<<1);
	@:flags("Eye-Corrective") public static inline var EYE_CORRECTIVE:Int = (1 << 2);
	@:flags("Crutch") public static inline var CRUTCH:Int = (1 << 3);
	
	public static inline var MASK_HANDED:Int = 1 | 2;
	
	public var twoHanded(get, never):Bool;
	public var strapped(get, never):Bool;

	public var cost:Int = 0;
	public var costCurrency:Int = 0;
	public static inline var CP:Int = 0;
	public static inline var SP:Int = 1;
	public static inline var GP:Int = 2;
	public var unit:Int = 1;
	
	public function setWeightCost<T>(weight:Float, cost:Int, costCurrency:Int):T {
		this.weight = weight;
		this.cost = cost;
		this.costCurrency = costCurrency;
		
		return cast this;
	}
	
	public function setUnit<T>(unit:Int):T {
		this.unit = unit;
		return cast this;
	}
	
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
	
	public function addTagsToStrArr(arr:Array<String>):Void {
		if ( (flags & FLAG_STRAPPED) != 0  ) {
			arr.push("Strapped");
		}
		if (Type.getClass(this) != Weapon && (flags & FLAG_TWO_HANDED) != 0  ) {
			arr.push("Two-Handed");
		}
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
	
	
	public static function getLabelsOfArray<T:Item>(a:Array<T>, mask:Int):Array<String> {	
		var arr:Array<String> = [];
		for (i in 0...a.length) {
			if ( (mask & (1 << i )) != 0 ) {
				arr.push(a[i].name);
 			}
		}
		return arr;
	}
	
	public static inline function sign(i:Int):String {
		return (i >= 0 ? "+" : "");
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
	
	public static macro function getInstanceFlagsOf(classe:Expr, flags:Expr):Expr {
		var cp = Context.currentPos();
		
		var classeStr:String;
		switch( classe.expr) {
			case EConst(CIdent(s)):
				classeStr = s;
				
			default:
				
		}

		var exprBuild:Expr = macro (1 << Item.FLAG_STRAPPED) | ( 1 << Item.FLAG_TWO_HANDED) | ( 1 << Item.MASK_HANDED);
		var fieldList:Array<Expr> = [];
		
		switch (flags.expr) {
			case EArrayDecl(values):
				for (i in 0...values.length) {
					var v = values[i];
					switch( v.expr ) {
						case EConst(CIdent(s)):
							fieldList.push( { expr:EParenthesis(
								{ expr:EBinop(Binop.OpShl,  {expr:EConst(CInt("1")), pos:cp }, { expr:EField( { expr:EConst(CIdent(classeStr)), pos:v.pos }, s), pos:classe.pos } ), pos:cp }	
						), pos:cp } );
						default:
					}
				}
				
				if (values.length == 0) {
					return macro 0;
				}
				if (values.length == 1) {
					return fieldList[0];
				}
			case EConst(CIdent(s)):
				return  { expr:EParenthesis(
								{ expr:EBinop(Binop.OpShl,  {expr:EConst(CInt("1")), pos:cp }, { expr:EField( { expr:EConst(CIdent(classeStr)), pos:flags.pos }, s), pos:classe.pos } ), pos:cp }	
						), pos:cp };
			default:
				Context.error("Unresolved case for parameter. Either CArray or single CIdent", flags.pos);
		}
		
		var combineOr:Expr = null;
		for (i in 1...fieldList.length) {
			combineOr = { expr:EBinop(Binop.OpOr, (combineOr != null ? combineOr : fieldList[i-1]), fieldList[i]), pos:cp };
		}
		return combineOr;
	}
	
	public static macro function pushFlagLabelsToArr(labelize:Bool=true, moduleStr:String=null, noLabelizeCapitalCase:Bool=false, metadataLbl:String=null, prefix:String=""):Expr {  // todo when needed: metadata support
	
		var fields = null;
		if (moduleStr != null) {
			fields = getFieldsFromModule(moduleStr, true);
		}
		if (fields == null) fields =   Context.getLocalClass().get().statics.get();
		
		var block:Array<Expr> = [];
	
		var count:Int = 0;
		for ( i in 0...fields.length) {
			var f = fields[i];
			if (metadataLbl!=null && !hasMetaTag(f.meta.get(), metadataLbl))  {
				continue;
			}
			var metaLabel:String = null;
			
			if (metadataLbl != null) {
				var m = getMetaTagEntry(f.meta.get(), metadataLbl);
				if (m != null) {
					if (m.params == null || m.params.length == 0) {
						//Context.error("Please specify string as parameter.", f.pos);
						metaLabel = labelizeAllCaps(f.name);
					}
					else {
						var mp = m.params[0].expr;
						switch( mp ) {
							case EConst(CString(s)):
								metaLabel = s;
							default:
							Context.error("Please specify string literal as parameter.", f.pos);
						}
					}
				}	
			}
			var fieldName:String = f.name;
			switch(f.kind) {
				case FVar(VarAccess.AccInline, VarAccess.AccNever):
					if (fieldName != "TOTAL_FLAGS") {
						if (labelize )  block.push( macro { if ( flags & (1 << $v{count}) != 0 )  arr.push($v{ metaLabel != null ? prefix+metaLabel : prefix+labelizeAllCaps(fieldName) }); } );
						else block.push( macro {  arr.push($v{ metaLabel!=null ? prefix+metaLabel : (noLabelizeCapitalCase ? prefix+labelizeAllCaps(fieldName) : prefix+fieldName )  }); } );
						count++;
					}
				default:
			}
			//trace(f.kind);
		}
		return macro $b{block};
	}
	
	
	
	public static macro function pushFlagAbbrToArr(labelize:Bool = true, capitalize:Bool = false, moduleStr:String = null):Expr {
		var fields = null;
		if (moduleStr != null) {
			fields =  getFieldsFromModule(moduleStr, true);
		}
		if (fields == null) fields =   Context.getLocalClass().get().statics.get();
		var block:Array<Expr> = [];
		var count:Int = 0;

		for ( i in 0...fields.length) {
			var f = fields[i];
			var fieldName:String = f.name;
			switch(f.kind) {
				case FVar(VarAccess.AccInline, VarAccess.AccNever):
					if (fieldName != "TOTAL_FLAGS") {
						var defaultValue:String; 
						
						var m = getMetaTagEntry(f.meta.get(), ":abbr");
						if (m != null) {
							if (m.params == null || m.params.length == 0) {
								Context.error("Please specify abbreviation string as parameter.", f.pos);
							}
							var mp = m.params[0].expr;
							switch( mp ) {
								case EConst(CString(s)):
									defaultValue = s;
								default:
								Context.error("Please specify abbreviation string literal as parameter.", f.pos);
							}
						}
						else  {
							defaultValue = fieldName.charAt(0);
							if (capitalize) defaultValue.toUpperCase();
							else defaultValue.toLowerCase();
						}
						
						
						if (labelize )  block.push( macro { if ( flags & (1 << $v{count}) != 0 )  arr.push($v{ defaultValue }); } );
						else block.push( macro {  arr.push($v{ defaultValue  }); } );
						
						count++;
					}
				default:
			}
			//trace(f.kind);
		}
		return macro $b{block};
	}
	
	
	
	public static macro function pushVarLabelsToArr(labelize:Bool=true, moduleStr:String=null,  metadataLbl:String=null,  prefix:String=""):Expr {  // todo when needed: metadata support
		var fields = null;
		
		
		
		if (moduleStr != null) {
			fields = getFieldsFromModule(moduleStr, false);
		}
		if (fields == null) fields =   Context.getLocalClass().get().fields.get();
		var block:Array<Expr> = [];
		
		var count:Int = 0;

		var intTypeStr = ComplexTypeTools.toType( MacroStringTools.toComplex("Int") ) + "";
		

		for ( i in 0...fields.length) {
			var f = fields[i];
			if (metadataLbl!=null && !hasMetaTag(f.meta.get(), metadataLbl))  {
				continue;
			}
			var metaLabel:String = null;
			
			if (metadataLbl != null) {
				var m = getMetaTagEntry(f.meta.get(), metadataLbl);
				if (m != null) {
					if (m.params == null || m.params.length == 0) {
						//Context.error("Please specify string as parameter.", f.pos);
						metaLabel = labelizeAllCaps(f.name);
					}
					else {
						var mp = m.params[0].expr;
						switch( mp ) {
							case EConst(CString(s)):
								metaLabel = s;
							default:
							Context.error("Please specify string literal as parameter.", f.pos);
						}
					}
				}	
			}
			var fieldName:String = f.name;
			switch(f.kind) {
				case FVar(VarAccess.AccNormal, VarAccess.AccNormal):
					var ct = haxe.macro.TypeTools.toComplexType(f.type);
					if (f.type+"" == intTypeStr) { // should be good enough to detect Int
						if (f.name.indexOf("_") >= 0) continue;
						if (labelize) block.push( macro { if (  instance.$fieldName != 0 )  arr.push($v{ prefix+labelizeCamelCase(fieldName)  }+ " " + instance.$fieldName); } );
						else block.push( macro {  arr.push($v{ prefix+fieldName }); } );
					}
					
				default:
			}
			
		}
		return macro $b{block};
	}
	
	
	
	// misc macro helpers
	#if macro
	static private function hasMetaTag(metaData:Metadata, tag:String):Bool {
		for ( m in metaData) {
			if (m.name == tag) return true;
		}
		return false;
	}
	
	static private function getFieldsFromModule(moduleStr:String, statics:Bool) {
		var fields = null;
		var subModule = null;
		var baseModuleStr:String;
		
		if (moduleStr.indexOf(":") >= 0) {
			var moduleSplit = moduleStr.split(":");
			var baseMod = moduleSplit[0].split(".");
			baseMod.pop();
			baseModuleStr = baseMod.join(".");
			moduleStr = moduleSplit[0];
			subModule = moduleSplit[1];
		}
		var cm;
		
		if (subModule == null) {
			cm = Context.getModule(moduleStr)[0];
		}
		else {
			var moduleArr = Context.getModule(moduleStr);
			for (i in 0...moduleArr.length) {
				
				switch( moduleArr[i]) {
					case TInst(t, _): 
						// hopefully, this toString() hack is future proof in haxe...yikes..a better way later?
						if (t.toString() == baseModuleStr + "."+ subModule ) {
							cm = moduleArr[i];
							break;
						}
					default:
						Context.error("Failed to resolve subModuleStr:" + moduleStr+":"+subModule, Context.currentPos());
				}
			}
		}
		switch(cm) {
			case TInst(t, _):
			fields = statics ? t.get().statics.get() : t.get().fields.get();
			default:	
			Context.error("Failed to resolve moduleString:" + moduleStr, Context.currentPos());
		} 
		return fields;
	}
	
	
	static private function getMetaTagEntry(metaData:Metadata, tag:String):MetadataEntry {
		if (metaData == null) return null;
		
		for ( m in metaData) {
			if (m.name == tag) return m;
		}
		return null;
	}
	
	
	
	static private function hasMetaTags(metaData:Metadata, tags:StringMap<Bool>):Bool {
		for ( m in metaData) {
			if (tags.exists(m.name)) return true;
		}
		return false;
	}
	#end
	

	

	
	
}


