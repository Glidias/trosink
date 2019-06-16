package troshx.util.layout;

/**
 * This provides a constraint somewhat similar objective to using Anchors to clamp layout borders to some edge, 
 * but doing so selectively along a given k dimension (either horizontally along U or vertically along V),
 * with the  ability to set min/max relative scale margin range values. 
 * 
 * @author Glidias
 */
class BorderConstraint 
{
	
	public var side:Int;
	public static inline var SIDE_TOP:Int = 0;
	public static inline var SIDE_RIGHT:Int = 1;
	public static inline var SIDE_BOTTOM:Int = 2;
	public static inline var SIDE_LEFT:Int = 3;
	
	public static inline function isHorizontal(side:Int):Bool {
		return (side & 1) != 0;
	}
	
	public static inline function isMaximalSide(side:Int):Bool {
		return side == SIDE_RIGHT || side == SIDE_BOTTOM;
	}
	
	public var coord(default, null):Float;
	public var minScale(default, null):Float;
	public var maxScale(default, null):Float;

	function new() 
	{
		
	}
	
	public inline function solveCoord(value:Float, scale:Float):Float {
		var ratio:Float = findScaleRatio(scale);
		return coord + (value - coord) * ratio;
	}
	
	public function findScaleRatio(scale:Float):Float {
		
		/*
		if (scaleMax != null) {
			if (scaleX > 1 && scaleMax.x >= 1) result.x = 1 / scaleX * Math.min(scaleX, scaleMax.x);
			if (scaleY > 1 && scaleMax.y >= 1) result.y = 1 / scaleY * Math.min(scaleY, scaleMax.y);
		}
		if (scaleMin != null) {
			if (scaleX < 1 && scaleMin.x <= 1) result.x = 1 / scaleX * Math.max(scaleX, scaleMin.x);
			if (scaleY < 1 && scaleMin.y <= 1) result.y = 1 / scaleY * Math.max(scaleY, scaleMin.y);
		}
		*/
		
		var result:Float = 1;
		if (maxScale >=1) {
			if (scale > 1) result = 1 / scale * Math.min(scale, maxScale);
		}
		if (minScale <=1) {
			if (scale < 1) result = 1 / scale * Math.max(scale, minScale);
		}
		return result;
	}
	
	
	public static function createRelative(coord:Float, minScale:Float=2, maxScale:Float=0):BorderConstraint {
		var me = new BorderConstraint();
		me.coord = coord;
		me.minScale = minScale;
		me.maxScale = maxScale;
		return me;
	}
	
	
}