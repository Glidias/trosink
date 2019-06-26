package troshx.sos.vue.combat;

import haxe.ds.StringMap;
import hxGeomAlgo.HxPoint;
import troshx.util.layout.LayoutItem;

/**
 * @author Glidias
 */
typedef ImageMapData = {
	var layoutItemList:Array<LayoutItem>;
	
	
	var positionList:Array<HxPoint>;
	var scaleList:Array<HxPoint>;
	var titleList:Array<String>;
	var classList:Array<String>;
	
	var refWidth:Float;
	var refHeight:Float;
	var scaleX:Float;
	var scaleY:Float;
	
	@:optional var idIndices:StringMap<Int>;
}