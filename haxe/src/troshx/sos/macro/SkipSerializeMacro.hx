package troshx.sos.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

/**
 * NOTE: This ain't working well atm.
 */

class SkipSerializeMacro {
    static function build():Array<Field> {
        var fields:Array<Field> = Context.getBuildFields();
        var pos = Context.currentPos();
        var serializeExprs = [];
        var unserializeExprs = [];
        for (field in fields) {
			
			
			if (field.access.indexOf(Access.AStatic) >= 0 || field.access.indexOf(Access.AMacro) >= 0) {
				continue;
			}
            if (MacroUtil.hasMetaTag(field.meta, ":skipSerialize") )
                continue;
			
			var fieldName = field.name;
			switch( field.kind) {
				case FieldType.FFun(_): continue;
			case FieldType.FProp(get, set): 
					if ( (get == "default" || get == "null") &&  (set == "default" || set == "null") ) {
						serializeExprs.push(macro s.serialize(this.$fieldName));
						unserializeExprs.push(macro this.$fieldName = u.unserialize());
					}
					//if (get == "get" && set == "set") continue;
					//if (get == "default" || get == "null") {
					//	serializeExprs.push(macro s.serialize(this.$fieldName));
					//}
					//if (set == "default" || set == "null") {
					//	unserializeExprs.push(macro this.$fieldName = u.unserialize());
					//}
				default:
					serializeExprs.push(macro s.serialize(this.$fieldName));
					unserializeExprs.push(macro this.$fieldName = u.unserialize());
			}
        }
        if (serializeExprs.length > 0) {
            fields.push({
                pos: pos,
                name: "hxSerialize",
                access: [APrivate],
                meta: [{name: ":keep", pos: pos}],
                kind: FFun({
                    ret: macro : Void,
                    args: [{name: "s", type: macro : haxe.Serializer}],
                    expr: macro $b{serializeExprs}
                })
            });
            fields.push({
                pos: pos,
                name: "hxUnserialize",
                access: [APrivate],
                meta: [{name: ":keep", pos: pos}],
                kind: FFun({
                    ret: macro : Void,
                    args: [{name: "u", type: macro : haxe.Unserializer}],
                    expr: macro $b{unserializeExprs}
                })
            });
        }
        return fields;
    }
}