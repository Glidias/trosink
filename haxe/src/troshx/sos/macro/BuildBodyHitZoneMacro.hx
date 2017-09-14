package troshx.sos.macro;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.MacroStringTools;

/**
 * ...
 * @author Glidias
 */
class BuildBodyHitZoneMacro 
{


	
	public static macro function buildBoilerplate(defaultOverride:Bool=false):Array<Field> {
		var fields = Context.getBuildFields(); 
		
		var targetZoneFields:Array<Field> = [];
		var targetZoneFieldParams:Array<Array<Expr>> = [];
		
		var hitLocationFields:Array<Field> = [];
		var hitLocationFieldsParams:Array<Array<Expr>> = [];
		
		var basicIntType:ComplexType = MacroStringTools.toComplex("Int");
		for (i in 0...fields.length) {
			var f = fields[i];
			var m;
			
			if ( (m=MacroUtil.getMetaTagEntry(f.meta, ":targetZone")) != null ) {
				if (f.access.indexOf(Access.AStatic) < 0 || f.access.indexOf(Access.AInline) < 0) {
					Context.error("Please use static inline var access for indice variables!", f.pos);
				}
				switch(f.kind) {
					
					case FieldType.FVar(basicIntType, e):
						var result = targetZoneFields.length;
						switch(e.expr) {
							case EConst(CInt(ind)):
								if ( Std.parseInt(ind) != targetZoneFields.length) Context.error("Please assign index values in proper order from 0", f.pos);
							default:
								Context.error("Please assign index values in proper order from 0", f.pos);
						}
					default:
						Context.error("Field needs to be of Int type", f.pos);
				}
				targetZoneFields.push(f);
				
				if (m.params == null || m.params.length == 0) {
					Context.error("Target zone @:targetZone requires at least 3 parameters (i think..)!", f.pos);
				}
				else {
					if (MacroUtil.extractValue(m.params[0]) == "") {
						m.params[0] = macro $v{MacroUtil.labelizeAllCaps(f.name)};
					}
				}

				targetZoneFieldParams.push(m.params);
			}
			else if ( (m = MacroUtil.getMetaTagEntry(f.meta, ":hitLocation")) != null ) {
			
				switch(f.kind) {
					case FieldType.FVar(basicIntType, e):
						var result = hitLocationFields.length;
						switch(e.expr) {
							case EConst(CInt(ind)):
								if ( Std.parseInt(ind) != hitLocationFields.length) Context.error("Please assign index values in proper order from 0", f.pos);
							default:
								Context.error("Please assign index values in proper order from 0", f.pos);
						}
					default:
						Context.error("Field needs to be of Int type", f.pos);
				}
				
				hitLocationFields.push(f);
		
				
				if (m.params == null || m.params.length == 0) {
					m.params = [];
					m.params[0] = macro $v{MacroUtil.labelizeAllCaps(f.name)};
					m.params[1] = macro $v{MacroUtil.slugifyAllCaps(f.name)};
					
				}
				else {
					if (MacroUtil.extractValue(m.params[0]) == "") {
						m.params[0] = macro $v{MacroUtil.labelizeAllCaps(f.name)};
					}
					if (m.params.length < 2 || MacroUtil.extractValue(m.params[1]) == "") {
						m.params[1] = macro $v{MacroUtil.slugifyAllCaps(f.name)};
					}
				}
				hitLocationFieldsParams.push(m.params);
			}
		}
		
	
		var corePackagePath:Array<String> = "troshx.sos.core".split(".");
		var cp = Context.getLocalClass().get().pos;
		var arrTargetZoneExpr:Array<Expr> = [];
		var arrHitLocationExpr:Array<Expr> = [];
		
		
		
		
		for (i in 0...targetZoneFields.length) {
			var f = fields[i];
			 
			arrTargetZoneExpr.push({expr:ECall( macro troshx.sos.core.TargetZone.create, targetZoneFieldParams[i]), pos:f.pos});
			
		}
		
		for (i in 0...hitLocationFields.length) {
			var f = fields[i];
			arrHitLocationExpr.push({expr:ExprDef.ENew({pack:corePackagePath, name:"HitLocation"}, hitLocationFieldsParams[i]), pos:f.pos});
		}
		
		var arrRetTypeTargetZone = MacroStringTools.toComplex("Array");
		switch(arrRetTypeTargetZone) {
			case TPath(p):
				//trace(p);
				
				p.params.push(TPType(MacroStringTools.toComplex("troshx.sos.core.TargetZone")));
			default:
				Context.error("Failed to resolve Array type for TargetZone", cp);
		}
		
		var arrRetTypeHitLocation = MacroStringTools.toComplex("Array");
		switch(arrRetTypeHitLocation) {
			case TPath(p):
				//trace(p);
				
				p.params.push(TPType(MacroStringTools.toComplex("troshx.sos.core.HitLocation")));
			default:
				Context.error("Failed to resolve Array type for HitLocation", cp);
		}
		
		
	
		fields.push({
			name:"getNewTargetZones",
			access: [Access.AStatic, Access.APublic],
			kind: FieldType.FFun( {
				args:[],
				expr:{ expr: EReturn({expr:EArrayDecl(arrTargetZoneExpr), pos:cp }) , pos:cp},
				ret: arrRetTypeTargetZone
				
			}),
			pos: cp	
		});
		
		fields.push({
			name:"getNewHitLocations",
			access: [Access.AStatic, Access.APublic],
			kind: FieldType.FFun( {
				args:[],
				expr:{ expr: EReturn({expr:EArrayDecl(arrHitLocationExpr), pos:cp }) , pos:cp},
				ret: arrRetTypeHitLocation
				
			}),
			pos: cp	
		});
		
	

		
		
		return fields;
	}
	
	
	
}