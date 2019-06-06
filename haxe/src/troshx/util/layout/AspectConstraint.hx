package troshx.util.layout;
import troshx.util.layout.Vec2;

/**
 * This provides a constraint for min/max relative aspect ratio (of width/height)
 * @author Glidias
 */
class AspectConstraint 
{
	public var min:Float = 1;
	public var max:Float = 1;
	public var aspect:Float;
	public var preflight:Bool = false;
	
	private function new() {
		
	}
	
	public function enablePreflight():AspectConstraint {
		preflight = true;
		return this;
	}
	
	public function findScales(result:Vec2, scaleX:Float, scaleY:Float):Void {
		result.x = Math.min(scaleX, max * scaleY);
		result.y = min > 0 ? Math.min(scaleY, scaleX / min) : scaleY;
		//result.x = scaleX;
		//result.y = scaleY;
	}
	
	public static function createRelative(width:Float, height:Float, ?limit1:Float=null, ?limit2:Float=null):AspectConstraint {
		var me = new AspectConstraint();
		me.aspect = width / height;
		
		if (limit1 != null) {
			if (limit1 > 1) {
				me.max = limit1;
			} else if (limit1 < 1) {
				me.min = limit1;
			}
		}
		
		if (limit2 != null) {
			if (limit2 > 1) {
				if (limit2 > me.max) me.max = limit2;
			} else if (limit2 < 1) {
				if (limit2 < me.min) me.min = limit2;
			}
		}
		
		return me;
	}
	
}