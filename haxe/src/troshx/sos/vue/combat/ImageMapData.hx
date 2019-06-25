package troshx.sos.vue.combat;

import haxe.ds.StringMap;
import troshx.util.layout.LayoutItem;
import troshx.util.layout.Vec2;

/**
 * @author Glidias
 */
typedef ImageMapData = {
	var layoutItemList:Array<LayoutItem>;
	
	
	var positionList:Array<Vec2>;
	var scaleList:Array<Vec2>;
	var titleList:Array<String>;
	var classList:Array<String>;
	
	var refWidth:Float;
	var refHeight:Float;
	var scaleX:Float;
	var scaleY:Float;
	
	@:optional var idIndices:StringMap<Int>;
}