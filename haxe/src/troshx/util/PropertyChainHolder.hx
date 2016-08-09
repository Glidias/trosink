package troshx.util;

/**
 * ...
 * @author 
 */
@:expose
class PropertyChainHolder {
	private var _src:Dynamic;
	
    @:isVar public var value(get, set):Float;
	public var propertyChain:Array<String>;
	
	public function new() {
		
		
		#if js
		untyped Object.defineProperty(this,"value",{
           get : get_value,
           set : set_value
        });
		#end
		
	}
	public  function setupProperty(src:Dynamic, property:Dynamic=null):Void {
		_src = src;
		
		if (property == null) {

			return;
		}
		if (Std.is(property, String)) {
			var str:String = property;
			propertyChain = str.split(".");
		}
		else { // assumed array
			propertyChain = property;
		}
	}
	
	private  function getPropertyChainValue():Dynamic {
		var len:Int = propertyChain.length;
		var cur = _src;
		
		for (i in 0...len) {
			var propToGet = propertyChain[i];
			cur = getPropertyOf(cur, propToGet );
			if (cur == null) {
				
				return null;
			}
		}
		return cur;
	}
	
	
	private  function setPropertyChainValue(val:Dynamic):Dynamic {
		
		if (_src == null) {
			_src = { };
		}
		var cur = _src;
		var len:Int = propertyChain.length;
		
		/*
		if (len == 1) {  // early out case
			Reflect.setProperty(_src, propertyChain[0], val);
			return val;
		}
		*/
		
		var propStack:Array<String> = [];
		for (i in 0...len) {
			var propToSet = propertyChain[i];
			propStack.push(propToSet);
			cur = setPropertyOf(cur, propToSet, val, i >= len -1, propStack);
			if (cur == null) {
			//	trace("EXITING null: " + val);
				return null;
			}
		}
		return cur;
	}
	
	private  function deletePropertyChainValue(val:Dynamic):Dynamic {
		
		if (_src == null) {
			return null;
		}
		var cur = _src;
		var len:Int = propertyChain.length;
		

		var propStack:Array<String> = [];
		for (i in 0...len) {
			var propToSet = propertyChain[i];
			propStack.push(propToSet);
			cur = deletePropertyOf(cur, propToSet, val, i >= len -1, propStack);
			if (cur == null) {
			//	trace("EXITING null: " + val);
				return null;
			}
		}
		return cur;
	}
	
	private function setPropertyOf(obj:Dynamic, prop:String, val:Dynamic,leaf:Bool, propStack:Array<String>):Dynamic {
		if (!leaf) {
			var reflectProp = val = Reflect.getProperty(obj, prop);
			if (reflectProp == null) {
				if (val == null) { // if value isn't significant, don't force it
					
					return null;  
				}
			//	trace("SORRY need to create!");
				Reflect.setProperty(obj, prop, (reflectProp={ }) );
			}
			val =  reflectProp;
		}
		Reflect.setProperty(obj, prop, val);
		return val;
	}
	
	
	private function deletePropertyOf(obj:Dynamic, prop:String, val:Dynamic,leaf:Bool, propStack:Array<String>):Dynamic {
		if (!leaf) {
			var reflectProp = val = Reflect.getProperty(obj, prop);
			if (reflectProp == null) {
				
				return null;
			}
			Reflect.setProperty(obj, prop, val);
			return val;
		}

		 Reflect.deleteField(obj, prop);
		 return val;
	}
	
	private  inline function getPropertyOf(obj:Dynamic, prop:String):Dynamic {


		return  Reflect.getProperty(obj, prop);
	}
	
	@:getter function get_value():Dynamic 
	{
		return propertyChain!= null && _src != null ? getPropertyChainValue() : null;
	}
	
	@:setter function set_value(v:Dynamic):Dynamic 
	{
		return propertyChain!= null ? setPropertyChainValue(v) : null;
	}
	
	
}