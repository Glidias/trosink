package troshx.util.layout;
import troshx.util.layout.Vec2;

/**
 * ...
 * @author Glidias
 */
class AspectConstraint 
{
	public var min:Float = 1;
	public var max:Float = 1;
	public var aspect:Float;
	
	private function new() {
		
	}
	
	public function findScales(result:Vec2, scaleX:Float, scaleY:Float):Void {
		if (min > 0 && max > 0) {
			result.x = Math.min(scaleX, max * scaleY);
			//result.x = Math.max(scaleX, min * scaleY);
			//if (max > 0) result.y = Math.max(scaleY, scaleX / max);
			if (min > 0) result.y = Math.min(scaleY, scaleX / min);
		}
		else if (max > 0) {
			result.x = Math.min(scaleX, max * scaleY);
			result.y = result.x / aspect;
		} else if (min > 0) {
			result.y = Math.max(scaleY, scaleX / min);
			result.x = aspect * result.y;
		}
		
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