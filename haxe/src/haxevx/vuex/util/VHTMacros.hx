package haxevx.vuex.util;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
#end 

/**
 * Some miscellenaous utilities that may be partially HTML-related or good for general use.
 * @author Glidias
 */
class VHTMacros
{
	/**
	 * StringMaps in array format `[ key=> value ]` are cool in Haxe because it supports inlinable dynamic key assignments!
	 * Call this macro in your code to return a dynamic object from stringmap syntax.
	 * @param	e	A StringMap expression in array format
	 * @return		A return expression of a particular string map declared as "_m_". 
	 */
	public static macro function return_stringMapToObj(e:Expr):Expr {
		 switch(e.expr) {
			case EArrayDecl(values):
				return convertStrMapToObjectSetup(values);
			default:
				Context.fatalError("Requires string map expression as EArrayDecl!", e.pos);
		}
		return macro ${e};
	}
	
	/**
	 * Extract text contents remotely from file to use as a string-based template expression in your Haxe codebase.
	 * The string-based expression, also supports string-based interpolation for strict-typed checking against your codebase. 
	 * @param	filePath	If left empty or undefined, will use current class file name and location.
	 * @param	fileExtension	"html" by default
	 * @return
	 */
	public static macro function getHTMLStringFromFile(filePath:String, fileExtension:String="html", escapeDollar:Bool=false):Expr {
		var canAutoCreateFile:Bool = false;
		if (filePath == null || filePath == "") {
	
			filePath =  Context.getPosInfos(Context.getLocalClass().get().pos).file;
			var filePathSplit:Array<String> = filePath.split("/");
			var fileName:String = filePathSplit.pop();
			fileName = fileName.split('.')[0];
			filePath = filePathSplit.join("/") +"/"+fileName;
			canAutoCreateFile = true;
			
		}
		
		var tarFile = Sys.getCwd() + filePath + "." + fileExtension;

		var fileExists:Bool =  FileSystem.exists(tarFile);
		
		
		var writtenContents:String = fileExists ?  sys.io.File.getContent(tarFile) : "";
		// For vue case, escape dollar signs in html file,
		//writtenContents = writtenContents.split("'").join("\\'");  // split single quote situations
		
		//if (escapeDollar) {
		//	writtenContents = writtenContents.split("$").join("\\$");
		//}
		
		
		//if (escapeDolalr) {
			//writtenContents.split("$"
		//}
		
		if (!fileExists) {
			if (canAutoCreateFile) {
				File.saveContent( tarFile, writtenContents );
			}
			else {
				Context.error("Failed to find file at:" + tarFile, Context.currentPos() );
			}
		}
		return  macro $v{writtenContents};
	}
	
	#if macro
	static function convertStrMapToObjectSetup(values:Array<Expr>):Expr {
	
		var myFields:Array<{field:ExprDef, exprDef:ExprDef, strField:String, keyPos:Position, valuePos:Position}> = [];
		for (i in 0...values.length) {
			switch( values[i].expr ) {
				case EBinop(OpArrow, {expr:key, pos:keyPos }, {expr:value, pos:valuePos}):
					//	trace(  Context.getPosInfos(keyPos) );
						
					switch( key ) {
						case EConst(CString(keyStr)):
							myFields.push({ field:key, exprDef:value, strField:keyStr, keyPos:keyPos, valuePos:valuePos});
						
						default:
							myFields.push({ field:key, exprDef:value, strField:null, keyPos:keyPos, valuePos:valuePos});
					}
				default:
					Context.fatalError("Couldn't resolve string map keys to ObjDecl! Please use OpArrow for String map!", values[i].pos );
			}	
		}
		
		var assignments = [for (f in myFields) {
			var val:Expr = {expr:f.exprDef, pos:f.valuePos};
			var keyer:Expr = {expr:f.field, pos:f.keyPos};
			if (f.strField != null) {
				var strField:String = f.strField;
				macro  haxevx.vuex.core.VxMacros.VxMacroUtil.dynamicSet(_m_, '$strField', ${val}); // _m_.awfawff =  ${val};    
			}
			else macro  haxevx.vuex.core.VxMacros.VxMacroUtil.dynamicSet(_m_, ${keyer}, ${val}); // _m_.awfawff =  ${val};    
		}];
		
		var retExpr:Expr = macro {
			var _m_:Dynamic = {};
			$b{assignments};
			return _m_;
		};
		return retExpr;
	}
	#end
	
	
}

