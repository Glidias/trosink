package troshx.util;
import haxe.ds.IntMap;
import haxe.rtti.Rtti;
import haxe.rtti.CType;
import haxe.rtti.Meta;

/**
 * Useful utility to reflect properties/methods, etc. of Haxe classes/instances to VueJS and other ViewModel/Model implementations
 * @author Glenn Ko
 */
@:expose
class ReflectUtil
{

	public static function setItemStaticMethodsTo<T>(c:Class<T>, to:Dynamic):Dynamic {
		return setItemMethodsTo(c, to, true);
	}
	public static function setItemInstanceMethodsTo<T>(c:Class<T>, to:Dynamic):Dynamic {
		return setItemMethodsTo(c, to, false);
	}
	
	public static function getMetaDataOfField(metaName:String, t:Dynamic, fieldName:Dynamic, isStatic:Bool=false):Dynamic {
		var meta = isStatic ? Meta.getStatics(t) : Meta.getFields(t);
		var fieldMeta = Reflect.field(meta, fieldName);
		if (Reflect.hasField(fieldMeta, metaName)) {
			return Reflect.field(fieldMeta, metaName);
		}
		return null;
	}
	
	public static function getEnumStrMapUnderscored(prefix:String, c:Class<Type>):IntMap<String> {
		var to:IntMap<String> = new IntMap<String>();
		var reference:Dynamic =  c;
		var rtti = Rtti.getRtti(c);
		for (f in ( rtti.statics ).iterator() ) {
			switch( f.type ) {
				case CType.CAbstract(args, ret):
					if (f.name.indexOf("_") >= 0 &&  f.name.split("_")[0] == prefix) {
						to.set(Reflect.field(reference, f.name ), f.name);
					}
				default:
			}
		}
		return to;
	}
	public static function getAllEnums(c:Class<Type>):Dynamic {
		var myMetaHash = {};
		var dyn:Dynamic = { };
		setItemFieldsTo(c, dyn, true, "enum");
		var meta = Meta.getStatics(c);
		
		for (p in Reflect.fields(dyn)) {
			
			var fieldMeta = Reflect.field(meta, p);
			var prefix:String  = Reflect.field(fieldMeta, "enum"); 
			var daMap;
			if (!Reflect.hasField(dyn, prefix)) {
				daMap = getEnumStrMapUnderscored(prefix, c);
				Reflect.setField(dyn, prefix, daMap );
			}
			else {
				daMap = Reflect.field(dyn, prefix);
			}
			Reflect.setField(myMetaHash, p, daMap );
		}
		Reflect.setField(dyn, "_meta", myMetaHash);
		return dyn;
	}
	
	
	
	
	public static function setItemFieldsTo<T>(c:Class<T>, to:Dynamic, isStatic:Bool=false, requireMeta:String=null):Dynamic {
		var rtti = Rtti.getRtti(c);
		var reference:Dynamic = isStatic ? c : Type.createEmptyInstance(c);
		var meta = isStatic ? Meta.getStatics(c) : Meta.getFields(c);
		for (f in (isStatic ? rtti.statics : rtti.fields ).iterator() ) {
			var fieldMeta = Reflect.field(meta, f.name);
			if (requireMeta == null || (fieldMeta != null && Reflect.hasField(fieldMeta, requireMeta)) ) {
				switch( f.type ) {
					case CType.CAbstract(args, ret):
						Reflect.setField(to, f.name, Reflect.field(reference, f.name) );
					case CType.CClass(args, ret):
						Reflect.setField(to, f.name, Reflect.field(reference, f.name) );
					default:
						
				}
			}
		}
		return to;
	}
	public static function setItemMethodsTo<T>(c:Class<T>, to:Dynamic, isStatic:Bool=false, requireMeta:String=null):Dynamic {
		var rtti = Rtti.getRtti(c);
		var reference:Dynamic = isStatic ? c : Type.createEmptyInstance(c);
		var meta = isStatic ? Meta.getStatics(c) : Meta.getFields(c);
		for (f in (isStatic ? rtti.statics : rtti.fields ).iterator() ) {
			var fieldMeta = Reflect.field(meta, f.name);
			if (requireMeta == null || (fieldMeta != null && Reflect.hasField(fieldMeta, requireMeta)) ) {
				switch( f.type ) {
					case CType.CFunction(args, ret):
						Reflect.setField(to, f.name, Reflect.field(reference, f.name) );
					default:
						
				}
			}
		}
		return to;
	}
	
}