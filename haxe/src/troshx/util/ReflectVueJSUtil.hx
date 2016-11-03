package troshx.util;

/**
 * https://bitbucket.org/yar3333/haxe-jsprop
 * 
 * https://jsfiddle.net/2emwp5ms/3/
 * @author Glidias
 */
@:expose
class ReflectVueJSUtil
{

	public function new() 
	{
		
	}
	
	public static function setupClasses(arrOfClasses:Array<Class<Dynamic>>):Void {
			// app-specific initialization of referential classes for JS vue app targets 
		for ( i in 0...arrOfClasses.length) {
			untyped arrOfClasses[i].prototype.RefClassName = arrOfClasses[i].__name__.pop();
			
		}
	}
	
	public static function getRefObjGetter(refClassName:String, prop:String):Dynamic {
		return untyped __js__("function() {   return this[prop] != null ? _Ref[refClassName][this[prop]] : null } ");
	}
	public static function getRefObjSetter(refClassName:String, prop:String) {
		// todoL vuejs setter dynamic set
		return untyped  __js__("function(val) {  if (val == null) { this[prop] = null; return; }; if (!_Ref[refClassName][val._refid]) { _Ref[refClassName][val._refid] = val }; if (_Ref[refClassName][val._refid] != val) throw new Error('ERROR non-unique id for referential instance!'+val); this[prop] = val._refid; }");
		
	}
}