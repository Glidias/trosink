package troshx.util.layout;
import hxGeomAlgo.HxPoint;

/**
 * Used as pivot scale constraint to define a local
 * transform origin for a layout region or anchoring/pinning reference point for that layout region's origin itself, 
 * It can also define min/max range relative scale values from given point.
 * @author Glidias
 */
class PointScaleConstraint 
{
	public var scaleMin(default, null):HxPoint;
	public var scaleMax(default, null):HxPoint;
	public var pt(default, null):HxPoint = new HxPoint();

	function new() 
	{
		
	}
	
	public function findScaleRatios(result:HxPoint, scaleX:Float, scaleY:Float):Void {
		result.x = 1;
		result.y = 1;
	
		if (scaleMax != null) {
			if (scaleX > 1 && scaleMax.x >= 1) result.x = 1 / scaleX * Math.min(scaleX, scaleMax.x);
			if (scaleY > 1 && scaleMax.y >= 1) result.y = 1 / scaleY * Math.min(scaleY, scaleMax.y);
		}
		if (scaleMin != null) {
			if (scaleX < 1 && scaleMin.x <= 1) result.x = 1 / scaleX * Math.max(scaleX, scaleMin.x);
			if (scaleY < 1 && scaleMin.y <= 1) result.y = 1 / scaleY * Math.max(scaleY, scaleMin.y);
		}
	}
	
	public function findScales(result:HxPoint, scaleX:Float, scaleY:Float):Void {
		findScaleRatios(result, scaleY, scaleX);
		result.x *= scaleX;
		result.y *= scaleY;
	}
	
	public function scaleMinRelative(x:Float=0, y:Float=0):PointScaleConstraint {
		if (scaleMin == null) {
			scaleMin = new HxPoint();
		}
		scaleMin.x = x;
		scaleMin.y = y;
		return this;
	}
	
	public function scaleMaxRelative(x:Float=0, y:Float=0):PointScaleConstraint {
		if (scaleMax == null) {
			scaleMax = new HxPoint();
		}
		scaleMax.x = x;
		scaleMax.y = y;
		return this;
		return this;
	}
	
	public static function createRelative(x:Float, y:Float):PointScaleConstraint {
		var me = new PointScaleConstraint();
		me.pt.x = x;
		me.pt.y = y;
		return me;
	}
	
	
	
}