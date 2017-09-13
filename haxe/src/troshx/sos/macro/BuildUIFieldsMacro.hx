package troshx.sos.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import haxe.macro.MacroStringTools;


/**
 * ...
 * @author Glidias
 */

class BuildUIFieldsMacro 
{

	public static macro function buildUIFieldsInstanceMethod(defaultOverride:Bool=false):Array<Field> {
		var fields = Context.getBuildFields(); 
		
		for (i in 0...fields.length) {
			if ( fields[i].name == "getUIFields") {
			
				return fields;
				
			}
		}
		

	
		var collectedObjExpr:Array<Expr> = [];
		
		for (i in 0...fields.length) {
			var f = fields[i];
			
			if ( f.access.indexOf(Access.AStatic) >= 0 ) {
				continue;
			}
			
			var metaDataEntry = MacroUtil.getMetaTagEntry(f.meta, ":ui");
			var defaultValueManuallyEntered:Bool = false;
			if ( metaDataEntry != null ) {
				var fName:String = f.name;
				var resolvedType:String = null;
				var metaParam =  metaDataEntry.params[0];
				
				if (metaParam != null) {
					
					switch(metaParam.expr ) {
						case EConst(CString(s)):
							resolvedType = s;
							metaParam = { expr: EObjectDecl([{field:"type", expr:macro $v{s} }]), pos:metaDataEntry.pos};
						case EObjectDecl(fields):
							for (e in fields) {
								if (e.field == "type") {
									resolvedType = MacroUtil.extractValue(e.expr);
								}
								if (e.field == "defaultValue") {
									defaultValueManuallyEntered = true;
								}
							}
						default:
							Context.error("Metadata @:ui parameter format not supported at "+f.name, metaDataEntry.pos);
					}				
				}
			
				if (resolvedType == null) {
					switch (f.kind) {
						case FVar(t, _):
							switch (t) {
								case TPath(p):
									resolvedType = p.name;
									if (p.name == "Array") {
										if (p.params.length == 0) {
											Context.error("Array has no type parameter specified:" + p.params, f.pos);
										}
										var defaultingValue:Dynamic = null;
										var arrayOf:String = null;
										switch(p.params[0]) {
											
											case TPType(ComplexType.TPath({pack:pack, name:name})):
												arrayOf = name;
												
												if (name == "String") {
													defaultingValue = "";
												}
												else if (name == "Int" || name == "Float" || name == "UInt") {
													defaultingValue = 0;
												}
												else if (name == "Bool") {
													defaultingValue = false;
												}
												else {
													if (!defaultValueManuallyEntered) {
														Context.warning("Failed to resolve manually defaulting arrayed value for field:"+f.name+". Please manually specify." , f.pos);
													}
												}
											default:
												Context.error("Sorry, failed to resolve type parameter situation for Array at the moment:" + p.params, f.pos);
										}
										
										if (metaParam == null) {
											metaParam = { expr: EObjectDecl([{field:"type", expr:macro $v{resolvedType} }]), pos:f.pos};
										}
										metaParam = MacroUtil.combineObjDeclarations([ 
											metaParam, 
											{ expr: EObjectDecl([{field:"of", expr:macro $v{arrayOf} }]), pos:f.pos},
											{ expr: EObjectDecl([{field:"defaultValue", expr:macro $v{defaultingValue} }]), pos:f.pos}
										], f.pos);
										
									}
								default:
									Context.error("Metadata @:ui type path "+t.getName() +" not supported at "+f.name, f.pos);
							}
						default:
							Context.error("Metadata @:ui field type "+f.kind.getName() +" not supported at "+f.name, f.pos);
					}
				
					var typeObjDecl:Expr = { expr: EObjectDecl([{field:"type", expr:macro $v{resolvedType} }]), pos:f.pos};
					if (metaParam == null) {
						
						metaParam =  typeObjDecl;
					}
					else {
						metaParam = MacroUtil.combineObjDeclarations([metaParam, typeObjDecl],  f.pos);
					}
				}
			
				
				metaParam = MacroUtil.combineObjDeclarations([
					{ expr: EObjectDecl([{field:"prop", expr:macro $v{fName} }]), pos:metaDataEntry.pos},
					metaParam,
					{ expr: EObjectDecl([{field:"label", expr:macro $v{labelizeCamelCase(fName)} }]), pos:metaDataEntry.pos}
				],  f.pos);
				collectedObjExpr.push(metaParam);

			}
		}
	
		// create UI method to return collectedObjExpr 
		var localClasse = Context.getLocalClass().get();
		var cp = localClasse.pos;
		
	
		var accessing = [Access.APublic];
		
		var arrRetType = MacroStringTools.toComplex("Array");
		switch(arrRetType) {
			case TPath(p):
				//trace(p);
				
				p.params.push(TPType(MacroStringTools.toComplex("Dynamic")));
			default:
				Context.error("Failed to resolve dynamic Array type", cp);
		}
		
		
		if ( MacroUtil.hasMetaTag( localClasse.meta.get(), ":uiOverride") ) {
			var uiOverrideMeeta = MacroUtil.getMetaTagEntry(localClasse.meta.get(), ":uiOverride");
			if (uiOverrideMeeta.params != null && uiOverrideMeeta.params.length > 0) {
				switch( uiOverrideMeeta.params[0].expr) {
					case EConst(CIdent("true")):
						defaultOverride = true;
					case EConst(CIdent("false")):
						defaultOverride = false;
					default:
						Context.error("Parameter for :uiOverride must be Bool if specified", cp);
				}
			}
			else {
				defaultOverride = true;
			}
		}
		
		if (defaultOverride) {
			accessing.push(Access.AOverride);
		}
		

		fields.push({
			name:"getUIFields",
			access: accessing,
			kind: FieldType.FFun( {
				args:[],
				expr:{ expr: EReturn({expr:EArrayDecl(collectedObjExpr), pos:cp }) , pos:cp},
				ret: arrRetType
				
			}),
			pos: cp	
		});

		
		return fields;
	}
	
	#if macro
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
	
	#end
	
}