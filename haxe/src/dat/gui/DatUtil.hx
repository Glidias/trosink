package dat.gui ;
import dat.gui.DatUtil.FuncCallPacket;
import haxe.Constraints.Function;
import haxe.rtti.CType;
import haxe.rtti.Meta;
import haxe.rtti.Rtti;
import tjson.TJSON;
#if (js)
import dat.gui.GUI;	
#end

/**
 * Utility to generate field definitions/UI fields for DATGUI from Haxe classes using metadata.
 * 
 * By default, it'll only inspect variable fields with "@inspect" metadata attached to it. 
 * To remove this requirement, add to the options a field for "ignoreInspectMetadata:true".
 * 
 * 
 * @author Glenn Ko
 */

typedef FuncDependencies = {
	var fields:List<ClassField>;
	var meta : Dynamic<Dynamic<Array<Dynamic>>>;
	var instance :Dynamic;
}

typedef FuncCallPacket = {
	var name:String;
	var params:Dynamic;
	var func:FuncDependencies;
	var handler:Function;
	var guiGlue:Dynamic;
}

typedef FuncCallTrigger = {
	var name:String;
	var func:FuncDependencies;
	var handler:Function;
}

 
@:expose
class DatUtil
{
	public static var DEFAULT_FLOAT_STEP:Float = 0;
	
	private static function _concatDyn(a1:Array<Dynamic>, a2:Array<Dynamic>):Array<Dynamic> {
		return a1.concat(a2);
	}
	
	/**
	 * Sets up inspectable parameters for guiGlue (glidias' fork) utility for DATGUI with a Haxe classes/instances/functions
	 * @param	instance	The instance to use, 
	 * @param	classe   The RTTI class to reference static functions and instance fields
	 * @param	options  Any additional options.
	 * @param   dotPath  Default empty string. Any dot path prefix to add
	 * @param	funcToInspect	A modifier to inspect a function instead
	 * @return	The guiGlue parameters
	 */
	public static function setup(instance:Dynamic, classe:Class<Dynamic>=null, options:Dynamic=null, dotPath:String="", funcToInspect:FuncDependencies=null):Dynamic 
	{
		var typeStr:String;
		if (classe == null) classe = Type.getClass(instance);
		if (options == null) options = { };
		
		var ignoreInspectMeta:Bool = Reflect.field( options, "ignoreInspectMeta");
		var useStatic:Bool = Reflect.field( options, "isStatic");
		var rtti = Rtti.getRtti(classe);
		var meta = funcToInspect != null ? funcToInspect.meta : (useStatic ? Meta.getStatics(classe) : Meta.getFields(classe) );
		
		if (funcToInspect != null) {  // overwrite instance reference in this case with the function dummy instance reference
			instance = funcToInspect.instance;
		}
		
		var fieldHash = { };
		var fields = funcToInspect!=null ? funcToInspect.fields :  (useStatic ? rtti.statics : rtti.fields);


		// @bitmask folders 
		// @choices combo list
		// @textarea  display:textarea
		// @range   display:range
		// @step	step:
		// @color   display:color
		
		var funcFolder:Dynamic = null;
		var cur:Dynamic;
		var curVal:Dynamic;
		var frStatics;
					var frParams:Array<Dynamic>;
				var frValue:Dynamic;
				var frPrefix:String = null;
				
				var frI:Int;
			
		//	cur = {display:"none", "_isLeaf":true, "value":0 };
		//	Reflect.setField(fieldHash, "DATUTIL", cur);
				
		for (f in fields.iterator() ) {
			var fieldMeta = Reflect.field(meta, f.name);
			
			var isVar = TypeApi.isVar(f.type);
			if (isVar && (!ignoreInspectMeta ?  fieldMeta!=null && Reflect.hasField( fieldMeta, "inspect") : true ) ) {
				
				cur = Reflect.field(fieldMeta, "inspect");
				
				if (cur == null) {
					cur = { };
				}
				else cur =  cur[0];
				if (cur == null) cur = { };
				curVal = Reflect.hasField(cur, "value") ? Reflect.field(cur, "value") : Reflect.getProperty(instance, f.name);
				typeStr = CTypeTools.toString(f.type);
				
	
				if (typeStr == "Int" || typeStr=="UInt" || typeStr == "Float") {
					
					if (curVal == null) { 
						curVal = 0;
					}
					Reflect.setField(cur, "value", curVal);
					
					if (typeStr == "Int" || typeStr == "UInt") {  // handle integer case
						
						if (Reflect.hasField(fieldMeta, "bitmask")) {
	
							var bitMaskFolder = { _classes: (Reflect.hasField(cur, "_classes") ? _concatDyn(["bitmask"], Reflect.field(cur, "_classes")) : ["bitmask"] ) }; //
							
							var gotBits = false;
							var bitFieldMeta = Reflect.field(fieldMeta, "bitmask")[0];
							
							if ( Std.is(bitFieldMeta, String)) {
								frValue = bitFieldMeta;
								frStatics = rtti.statics.iterator();
								for (f in frStatics) {
									frI = f.name.indexOf("_");
									if (frI >= 0) {
										gotBits = true;
										frPrefix = f.name.substring(0, frI);
										if (frPrefix == frValue) {	
											Reflect.setField(bitMaskFolder, f.name.substring(frI + 1),  {_bit:Reflect.field(classe, f.name), value:(curVal & Reflect.field(classe, f.name) )!=0 });
										}
									}
								}
							}
							else { // create default 32 bits
								for (i in 0...32) {
									Reflect.setField(bitMaskFolder, "b"+Std.string(i), {_bit:(1<<i), value:(curVal & (1<<i))!=0 });
								}
								gotBits = true;
							}
							
							if (gotBits) {
								Reflect.setField(fieldHash, f.name, bitMaskFolder);
								for ( p in Reflect.fields(cur) ) {
									if (p.charAt(0) != "_") continue;
									Reflect.setField(bitMaskFolder, p, Reflect.field(cur, p));
								}
								Reflect.setField(bitMaskFolder, "_subProxy", "bitmask");
								Reflect.setField(bitMaskFolder, "_value", curVal);  // subproxy default value
							}

							//Reflect.setField(fieldHash, f.name, cur);
							
						}
						else {  // regular numeric case for integer data type
							if (!Reflect.hasField(cur, "step") ) {
								Reflect.setField(cur, "step", 1);
							}
							
							if (typeStr == "UInt" && !Reflect.hasField(cur, "min") ) {
								Reflect.setField(cur, "min", 0);
							}
							
							Reflect.setField(fieldHash, f.name, cur);
							Reflect.setField(cur, "_isLeaf", true);
						}
						
					}
					else {  // handle generic number case
						if (DEFAULT_FLOAT_STEP > 0 && !Reflect.hasField(cur, "step")) {
							Reflect.setField(cur, "step", DEFAULT_FLOAT_STEP);
						}
						Reflect.setField(fieldHash, f.name, cur);
						Reflect.setField(cur, "_isLeaf", true);
					}
				}
				else if (typeStr == "String") {
					
					if (curVal == null) { 
						curVal = "";
					}
					Reflect.setField(cur, "value", curVal);
					
					
					Reflect.setField(fieldHash, f.name, cur);
					Reflect.setField(cur, "_isLeaf", true);
				}
				else if (typeStr == "Bool") {
					if (curVal == null) { 
						curVal = false;
					}
					Reflect.setField(cur, "value", curVal);
					
					Reflect.setField(fieldHash, f.name, cur);
					Reflect.setField(cur, "_isLeaf", true);
				}
				else {  // nested object case
					var tryInstance = Reflect.getProperty(instance, f.name);
					var instanceAvailable:Bool = true;
					
					if (tryInstance == null) {
						instanceAvailable = false;
						tryInstance = Type.createInstance( Type.resolveClass(typeStr), [] );  //Type.createEmptyInstance(Type.resolveClass(typeStr)); // 
					}
					var nested;
					
					Reflect.setField(fieldHash, f.name, nested = setup(tryInstance, Type.resolveClass(typeStr), f.type, (dotPath != "" ? dotPath + "." : "") + f.name) );
					for ( p in Reflect.fields(cur) ) {
						if (p.charAt(0) != "_") continue;
						Reflect.setField(nested, p, Reflect.field(cur, p));
					}
					
					Reflect.setField(nested, "_folded", instanceAvailable ? false : true );
					
					Reflect.setField(nested, "_classes", (Reflect.hasField(cur, "_classes") ? _concatDyn(["instance"], Reflect.field(cur, "_classes")) : ["instance"] ) );
					
					
				}
				//Reflect.setField(fieldHash, f.name, gui.add(instance, f.name));		
				
	
				
				if (Reflect.hasField(fieldMeta, "range")) {
					// check if choices[0] is a string static "string_" lookup, else woudl be either
					frParams = Reflect.field(fieldMeta, "range");
					
					
					if (frParams != null && frParams.length > 0) {
						frValue = frParams[0];
						
						if (Std.is(frValue, String)) {
							
							var frEnum:Dynamic = {  };
							// set min max based on static lookups
							var min = 1e20;	
							var max = -1e20;
							frStatics = rtti.statics.iterator();
							for (f in frStatics) {
								frI = f.name.indexOf("_");
								if (frI >= 0) {
									frPrefix = f.name.substring(0, frI);
									if (frPrefix == frValue) {
										var v:Float;
										v =  Reflect.field(classe, f.name);
										if (v > max) {
											max = v;
										}
										if (v < min) {
											min = v;
										}
										Reflect.setField(frEnum, f.name.substring(frI + 1), v);
									}
								}
							}
							Reflect.setField(cur, "enumeration", frEnum);
							Reflect.setField(cur, "min", min);
							Reflect.setField(cur, "max", max);
						}
						else {
							Reflect.setField(cur, "min", Reflect.hasField(frValue, "min") ? Reflect.field(frValue, "min") : 0 );
							Reflect.setField(cur, "max", Reflect.hasField(frValue, "max") ? Reflect.field(frValue, "max") : Reflect.field(frValue, "min")+1 );
						}
					}
					
		
				}
				if (Reflect.hasField(fieldMeta, "choices")) {
					// check if choices[0] is a string static "string_" lookup, else would be either assumed Object||Array
					frParams = Reflect.field(fieldMeta, "choices");
			
					if (frParams != null && frParams.length > 0) {
						frValue = frParams[0];
						if (Std.is(frValue, String)) {
							var frChoices:Dynamic = { };
							// set choices based on static lookups
							frStatics = rtti.statics.iterator();
							for (f in frStatics) {
								frI = f.name.indexOf("_");
								if (frI >= 0) {
									frPrefix = f.name.substring(0, frI);
									if (frPrefix == frValue) {
										//trace("SETTING:" + f.name);
										Reflect.setField(frChoices, f.name.substring(frI+1), Reflect.field(classe, f.name) );
									}
								}
							}
							Reflect.setField(cur, "choices", frChoices);
						}
						else {
							Reflect.setField(cur, "choices", frValue);
						}
					}
					
				}
			}
			else if (!isVar && fieldMeta!=null && Reflect.hasField( fieldMeta, "inspect")  ) {
				
				cur = Reflect.field(fieldMeta, "inspect");
				
				if (cur == null) {
					cur = [];
				}
				else {
					cur = cur[0];
					if (!Std.is(cur, Array)) {
						cur = [cur];
					}
				}
				
				
				//meta.sfs = [{}];
				
				
				switch( f.type ) {
					case CType.CFunction(args, ret):
						
						if (funcFolder == null) {
							funcFolder = {}   // hash keyStrings of FuncDependencies
							
						}
						var funcDep:FuncDependencies = {
							meta: { },
							instance: { },
							fields: new List<ClassField>()
						}
						//
					
						// { name : String, opt : Bool, t : CType, ?value:String }
						var count:Int = 0;
						for ( funcArg in args.iterator()) {
							funcDep.fields.add( getDummyClassFieldForFuncParam(funcArg.name, funcArg.t) );
							var paramsObj:Dynamic = count < cur.length ? cur[count] : { };
							var newObj:Dynamic = { inspect:null };
							for (r in Reflect.fields(paramsObj)) {
								Reflect.setField(newObj, r, [ Reflect.field(paramsObj, r) ]);
							}
							Reflect.setField(funcDep.meta, funcArg.name, newObj );
							
							Reflect.setField(funcDep.instance, funcArg.name, funcArg.opt ? parseStringParam(funcArg.value, CTypeTools.toString(funcArg.t), classe) : null);
							count++;
						}
						Reflect.setField(funcFolder, f.name, funcDep);
						//trace(f.name+" = " +typeStr, cur);
					default:
						
				}
			}
		}
		
		if (funcFolder != null) { 
			Reflect.setField(fieldHash, "_functions", funcFolder);
		}
		
		Reflect.setField(fieldHash, "_dotPath", dotPath);
		Reflect.setField(fieldHash, "_hxclass", Type.getClassName(classe) );
		
		
		return fieldHash;
	}
	
	private static function parseStringParam(str:String, type:String, classe:Dynamic):Dynamic {
		switch (type) {
			case "Int":
				return !Math.isNaN( Std.parseFloat(str) ) ?  Std.int(Std.parseFloat(str)) : Reflect.field(classe,str);
			case "UInt":
				return !Math.isNaN( Std.parseInt(str) ) ?  Std.parseInt(str) : Reflect.field(classe,str);
			case "Float":
				return !Math.isNaN( Std.parseFloat(str) ) ?  Std.parseFloat(str) : Reflect.field(classe,str);
			case "String":
				return (str.charAt(0) == '"' || str.charAt(0) == "'") ?  str.substring(1, str.length - 1) : Reflect.field(classe, str);
			case "Bool":
				return str == "true" ? true : str ==  "false" ? false : Reflect.field(classe, str);
			default:
				//trace("Could not resolve type: " + type);
				return type;
		}
	}
	
	private static inline function getDummyClassFieldForFuncParam(name:String, type:CType):ClassField {
		return {
			name:name,
			type:type,
			isPublic:true,
			isOverride:false,
			doc:null,
			get:null,
			set:null,
			params:null,
			platforms:null,
			meta:null,
			line:null,
			overloads:null,
			expr:null
		};
		/*
					 * typedef ClassField = {
					var name : String;
					var type : CType;
					var isPublic : Bool;
					var isOverride : Bool;
					var doc : Null<String>;
					var get : Rights;
					var set : Rights;
					var params : TypeParams;
					var platforms : Platforms;
					var meta : MetaData;
					var line : Null<Int>;
					var overloads : Null<List<ClassField>>;
					var expr : Null<String>;
				*/
				
	}
	
	
	public static function callMethod(scope:Dynamic, func:Function, params:Dynamic, funcDep:FuncDependencies):Dynamic {
		var arr = [];
		for (f in funcDep.fields) {
			arr.push( Reflect.field(params, f.name) );
		}
		return Reflect.callMethod(scope, func, arr);
	}
	
	public static inline function callInstanceMethodWithPacket(instance:Dynamic, funcCallPacket:FuncCallPacket):Dynamic {
		return callMethod(instance, Reflect.field(instance, funcCallPacket.name), funcCallPacket.params, funcCallPacket.func);
	}
	
	#if (js)
	
	public static inline function setupGUIForFunctionCall(folder:GUI, p:String, handler:Function, func:FuncDependencies, instance:Dynamic,  classe:Class<Dynamic> = null, options:Dynamic = null, ?guiOptions:GUIOptions):FuncCallPacket {
		var guiGlueMethod = untyped window.guiGlueRender;  // requires guiGlue.js
		var guiSetup = DatUtil.setup(instance, classe, options, "", func);
		var untypedGUI = guiGlueMethod(guiSetup, null, null, folder);

		var str = "";
		var i = func.fields.length;
		while (--i  > -1) {
			str += ".";
		}
			
		var packet:FuncCallPacket =  {handler:handler, params:untypedGUI._guiGlueParams, func:func, guiGlue:untypedGUI._guiGlue, name:p};
		folder.add(packet, "handler").name("Execute("+(str)+")");
		
		return null;
	}
	
	
	public static function createFunctionLibraryForGUI(gui:GUI, funcGuiMap:Dynamic<FuncDependencies>, instance:Dynamic, classe:Class<Dynamic>=null, options:Dynamic=null, ?guiOptions:GUIOptions):Dynamic {
		
		//function guiGlueRender(paramsGUI, optionsGUI, params, existingGUI)
		
		var funcMap = {};
		var handler = options != null &&  Reflect.hasField(options, "handler") ? Reflect.field(options, "handler") : emptyFunction;
		
		for (p in Reflect.fields(funcGuiMap)) {
			var func:FuncDependencies = Reflect.field(funcGuiMap, p);
			var folder:GUI = gui.addFolder(p);
			folder.close();
			var packet:FuncCallPacket = setupGUIForFunctionCall(folder, p, handler, func, instance, classe, options, guiOptions);
			Reflect.setField(funcMap, p, packet);
		}
		
		return funcMap;
	}
	
	
	public static function createFunctionButtonsForGUI(gui:GUI, funcGuiMap:Dynamic<FuncDependencies>, instance:Dynamic, classe:Class<Dynamic>=null, options:Dynamic=null, ?guiOptions:GUIOptions):Dynamic {
		var guiGlueMethod = untyped window.guiGlueRender;  // requires guiGlue.js
		//function guiGlueRender(paramsGUI, optionsGUI, params, existingGUI)
		
		var funcMap = {};
		var handler = options != null &&  Reflect.hasField(options, "handler") ? Reflect.field(options, "handler") : emptyFunction;
		
		for (p in Reflect.fields(funcGuiMap)) {
			var func:FuncDependencies = Reflect.field(funcGuiMap, p);
			var trigger:FuncCallTrigger= {handler:handler, func:func, name:p};
			Reflect.setField(funcMap, p, trigger);
			gui.add(trigger, "handler").name(p+"("+(func.fields.length > 0 ? "..." : "" )+")");
		}
		
		return funcMap;
	}
	
	private static function emptyFunction() {
		
	}
	
	
	
	
	
	#end 
	
	
}