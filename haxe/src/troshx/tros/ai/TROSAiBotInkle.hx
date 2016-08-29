package troshx.tros.ai;
//import ink.runtime.Story;
import haxe.rtti.Rtti;
import haxe.rtti.CType;
import haxe.rtti.Meta;

/**
 * ...
 * @author Glidias
 */
class TROSAiBotInkle
{

	public function new() 
	{
		
	}
	
	public static function staticVarSetter(varName:String, newValue:Dynamic):Void {
		
		Reflect.setField(TROSAiBot, varName, newValue);
		//trace("Variable set:" + varName + "=" + newValue);
	}
	
	
	// note: this function doesn't seem to work natively in C-sharp due to HAxe using their own Closure class...
	public static function bindWatchesForInk<T>(c:Class<T>, toStory:Dynamic, requireMeta:String = "watch"):Void {
		var rtti = Rtti.getRtti(c);
		var isStatic:Bool = true;
		var reference:Dynamic = isStatic ? c : Type.createEmptyInstance(c);
		var meta = isStatic ? Meta.getStatics(c) : Meta.getFields(c);
		//trace("bindWatchesForInk...");
		for (f in (isStatic ? rtti.statics : rtti.fields ).iterator() ) {
			var fieldMeta = Reflect.field(meta, f.name);
			if (requireMeta == null || (fieldMeta != null && Reflect.hasField(fieldMeta, requireMeta)) ) {
				switch( f.type ) {
					case CType.CAbstract(args, ret):
					//	trace("watching variable:" + f.name);
					
						
				//	case CType.CClass(args, ret):
				//		Reflect.setField(to, f.name, Reflect.field(reference, f.name) );
					default:
						
				}
			}
		}
		
	}
	
	
}


