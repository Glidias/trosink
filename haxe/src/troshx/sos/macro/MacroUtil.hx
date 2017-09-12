package troshx.sos.macro;



#if macro
import haxe.macro.Expr.Metadata;
import haxe.macro.Expr.MetadataEntry;
import haxe.ds.StringMap;
import haxe.macro.Context;
import haxe.io.Path;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.Type;

#end

/**
 * ...
 * @author Glidias
 */
class MacroUtil 
{
#if macro
	inline static var QUOTED_FIELD_PREFIX = "@$__hx__";
 
	static public function hasMetaTag(metaData:Metadata, tag:String):Bool {
		for ( m in metaData) {
			if (m.name == tag) return true;
		}
		
		return false;
	}
	
	static public function getFieldsFromModule(moduleStr:String, statics:Bool) {
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
	
	
	static public function getMetaTagEntry(metaData:Metadata, tag:String):MetadataEntry {
		if (metaData == null) return null;
		
		for ( m in metaData) {
			if (m.name == tag) return m;
		}
		return null;
	}
	
	
	
	static public function hasMetaTags(metaData:Metadata, tags:StringMap<Bool>):Bool {
		for ( m in metaData) {
			
			if (tags.exists(m.name)) return true;
		}
		return false;
	}
	
	
    public static function extractValue(e:Expr):Dynamic
    {
        switch (e.expr)
        {
            case EConst(c):
                switch (c)
                {
                    case CInt(s):
                        var i = Std.parseInt(s);
                        return (i != null) ? i : Std.parseFloat(s); // if the number exceeds standard int return as float
                    case CFloat(s):
                        return Std.parseFloat(s);
                    case CString(s):
                        return s;
                    case CIdent("null"):
                        return null;
                    case CIdent("true"):
                        return true;
                    case CIdent("false"):
                        return false;
                    default:
                }
            case EBlock([]):
                return {};
            case EObjectDecl(fields):
                var object = {};
                for (field in fields)
                    Reflect.setField(object, unquoteField(field.field), extractValue(field.expr));
                return object;
            case EArrayDecl(exprs):
                return [for (e in exprs) extractValue(e)];
            default:
        }
        throw new Error("Invalid JSON expression: " + e, e.pos);
    }

	// see https://github.com/HaxeFoundation/haxe/issues/2642
	static function unquoteField(name:String):String
	{
		return (name.indexOf(QUOTED_FIELD_PREFIX) == 0) ? name.substr(QUOTED_FIELD_PREFIX.length) : name;
	}
	
	
	/**
	 * Combines an array of EObjectDecl expressions into a single new EObjectDecl instance.
	 * Prioritised keys in order of first-declared first, and will not replace existing ones.
	 * @param	objs
	 * @param	contextPos
	 * @return
	 */
	public static function combineObjDeclarations(objs:Array<Expr>, contextPos:Position): Expr {
		var collector;
		var newObjDecl = { expr: EObjectDecl(collector=[]), pos:contextPos};
		var receivedFields:StringMap<Bool> = new StringMap<Bool>();
		for (i in 0...objs.length) {
			var obj = objs[i];
			switch (obj.expr) {
				case EObjectDecl(fields):
					for ( f in fields) {
						if (!receivedFields.exists( f.field ) ) {
							collector.push(f);
							receivedFields.set(f.field, true);
						}
					}
				default:
					Context.error("Only EObjectDecl can be combined!::"+obj.expr.getName(), obj.pos);
			}
			
		}
		

		return newObjDecl;
	}
	
	public static function classTypeExtendsPath(type:ClassType, path:String):Bool {
		var sc = type.superClass;
		
		while (sc != null) {
			if (sc.t.toString() == path) {  // is this toString() match method future proof? hopefully..
				return true;
			}
			sc = sc.t.get().superClass;
		}
		return false;
	}
	
	static function pushToNewTypeExprToSortArrIfMatch(headerMod:Type, arr:Array<{ name:String, expr:Expr}>, extendingClassPath:String,  pos:Position):Void {
		
		switch(headerMod) {
			case TInst(t, params):
				if (( extendingClassPath == "" || extendingClassPath == null) || classTypeExtendsPath(t.get(), extendingClassPath)) {
					var tGet = t.get();
					arr.push({name:tGet.name, expr: {expr:ENew({pack:tGet.pack, name:tGet.name}, []), pos:pos} } );
				}
				//t.get().superClass
			default:
				//trace(headerMod);
		}
	}
	

#end



	// Publicily callable inlined expression generators
	
	public static macro function traceExpr(expr:Expr):Expr {
		trace(expr);
		return expr;
	}
	
	
	/**
	 * Gathers all classes to be instantiated under a given array expression `[...new GatheredClass()]`;
	 * Limitations: This method will only check for the first-listed header class under each Haxe file in current file's folder
	 * and all sub-module classes under the current file itself.
	 * @param	extendingClassPath	Must extend the given class path. Set to null or empty string to not have this condition.
	 * @return
	 */
	public static macro function getAllCurrentPackageInstancesInArray( extendingClassPath:String, doSort:Bool=true):Expr {
		var localClasse = Context.getLocalClass().get(); 
		
		
		var fromFile:String = Context.getPosInfos( localClasse.pos).file;
		var ff = fromFile.split("/");
		ff.pop();
		
		var sortStruct:Array<{ name:String, expr:Expr}>= [];
		
		var instancesForArr:Array<Expr> = [];
		var classGatherPrefix:String = localClasse.pack.join(".") + ".";
		
		var currentModuleClasses = Context.getModule(classGatherPrefix + localClasse.name);
		var cp = Context.currentPos();
		for (i in 0...currentModuleClasses.length) {
			pushToNewTypeExprToSortArrIfMatch( currentModuleClasses[i], sortStruct, extendingClassPath,   cp );
		}
		
		
		var mod;

		var directory:String = ff.join("/");
		if (sys.FileSystem.exists(directory)) {
		
		for (file in sys.FileSystem.readDirectory(directory)) {
		 // var path = haxe.io.Path.join([directory, file]);
		  //trace(path);
		 // trace(path);
		
			var fileSplit = file.split(".");
			var ext = fileSplit.pop();
			if (ext == "hx") {	
				//trace(   );
				mod = Context.getModule(classGatherPrefix + fileSplit[0]);
				pushToNewTypeExprToSortArrIfMatch( mod[0], sortStruct, extendingClassPath,  cp );
				
			}
		}
		} else {
			trace('"$directory" does not exists');
		}
	  
		if (doSort) {
			sortStruct.sort( function(a, b):Int
			{
				
				var av = a.name.toLowerCase();
				var bv = b.name.toLowerCase();
				if (av < bv) return -1;
				if (av > bv) return 1;
				return 0;
			} );
		}
	  
		for (i in 0...sortStruct.length) {
			instancesForArr[i] = sortStruct[i].expr;
		}
	
		return { expr:EArrayDecl(instancesForArr), pos:localClasse.pos };
	}
	
	
	
}