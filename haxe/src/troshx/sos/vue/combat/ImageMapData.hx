package troshx.sos.vue.combat;

import haxe.ds.StringMap;
import hxGeomAlgo.HxPoint;
import troshx.util.layout.LayoutItem;

/**
 * @author Glidias
 */
typedef ImageMapData = {
	@:optional var layoutItemList:Array<LayoutItem>;
	
	
	@:optional var positionList:Array<HxPoint>;
	@:optional var scaleList:Array<HxPoint>;
	@:optional var titleList:Array<String>;
	@:optional var classList:Array<String>;
	
	@:optional var refWidth:Float;
	@:optional var refHeight:Float;
	@:optional var scaleX:Float;
	@:optional var scaleY:Float;
	
	@:optional var renderCount:Int;
	
	@:optional var idIndices:StringMap<Int>;
}