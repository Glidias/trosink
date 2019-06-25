package troshx.sos.vue.combat;
import troshx.util.layout.LayoutItem;

/**
 * Yet another platform agnostic class to handle UI standard interactions
 * @author Glidias
 */
class UIInteraction 
{
	
	public static inline var COMPLETED:Int = 0;
	@:act public static inline var DOWN:Int = (1 << 0);
	@:act public static inline var MOVE:Int = (1 << 1);
	@:act public static inline var TAP:Int = (1 << 2);
	@:act public static inline var HOLD:Int = (1 << 3);
	@:act public static inline var SWIPE_UP:Int = (1 << 4);
	@:act public static inline var SWIPE_RIGHT:Int = (1 << 5);
	@:act public static inline var SWIPE_DOWN:Int = (1 << 6);
	@:act public static inline var SWIPE_LEFT:Int = (1 << 7);
	public static inline var SWIPE:Int = SWIPE_UP | SWIPE_DOWN | SWIPE_LEFT | SWIPE_RIGHT;
	@:act public static inline var PAN_UP:Int = (1 << 8);
	@:act public static inline var PAN_RIGHT:Int = (1 << 9);
	@:act public static inline var PAN_DOWN:Int = (1 << 10);
	@:act public static inline var PAN_LEFT:Int = (1 << 11);
	public static inline var PAN:Int = PAN_DOWN | PAN_UP | PAN_LEFT | PAN_RIGHT;
	
	@:act public static inline var HOVER:Int = (1 << 12);
	@:act public static inline var MOVE_OVER:Int = (1 << 13);
	
	public static inline var REQUIRE_CONFIRMATION:Int = TAP;
	
	public static inline function requiresTracking(mask:Int):Bool {
		return mask >= 2;
	}

	//public var dollViewElements:StringMap<
	public static function getDollViewInteracts(layoutItems:Array<LayoutItem>, names:Array<String>, tags:Array<String>):Array<UInteract> {
		var arr:Array<UInteract> = new Array<UInteract>();
		for (i in 0...layoutItems.length) {
			var item:LayoutItem = layoutItems[i];
			var name:String = names[i];
			var tag:String = tags[i];
			
			if (item.shape == LayoutItem.SHAPE_CIRCLE) {	// test circles
				item.hitPadding = 8;
				arr.push(new UInteract(i, DOWN ) );
				continue;
			}
			
			if (tag == "part" || tag == "swing") {	// assumption against refWidth/refHeight
				item.hitPadding = 8;
			}
			
			if (tag == "part" || tag == "swing" || name == "enemyHandLeft" || name == "enemyHandRight") {
				arr.push(new UInteract(i, DOWN | MOVE) );
				continue;
			}
			
			switch(name) {
				case "initRange": 
					arr.push(new UInteract(i, DOWN | MOVE) );
				case "advManuever1", "advManuever2", "advManuever3", "advManuever4": 
					
				case "btnBlock", "btnVoid", "btnParry": 
					arr.push(new UInteract(i, DOWN | MOVE) );
				case "opponentSwiper":
					
				case "roundCount":
					
				case "vitals":
						item.hitPadding = 8;
					arr.push(new UInteract(i, DOWN));
					
				case "cpMeter":
					
				case "cpText":
					
				case "handLeftAlt", "handRightAlt": 
					
				case "handLeftText", "handRightText": 
					
				
			}
		}
		return arr;
	}
	
	public static function findHit(u:Float, v:Float, mapData:ImageMapData, interacts:Array<UInteract>):UInteract {
		var closestHit:UInteract = null;
		var closestHitDist:Float = 999999999999;
		
		for (i in 0...interacts.length) {
			var act:UInteract = interacts[i];
			var hitResult:Float = checkHit(u, v, mapData, act);
			if (hitResult >=0) {
				if (hitResult == 0) {
					return act;
				} else if (hitResult < closestHitDist) {
					closestHit = act;
					closestHitDist = hitResult; 
				}
			}
		}
		return closestHit;
	}
	
	
	// uv to Absolute screen coordinates calcalation, easier to visualise
	public static function checkHit(u:Float, v:Float, mapData:ImageMapData, act:UInteract):Float {

		var layout = mapData.layoutItemList[act.index];
		var pos = mapData.positionList[act.index];
		var scale = mapData.scaleList[act.index];
		
		var sw = mapData.scaleX * mapData.refWidth;
		var sh = mapData.scaleY * mapData.refHeight;
		var cx:Float;
		var cy:Float;
		var dx:Float;
		var dy:Float;
		var d:Float;
		var x:Float = u * sw;
		var y:Float = v * sh;
		var minX:Float = pos.x * sw;
		var minY:Float = pos.y * sh;
		var r:Float;
	
		var maxX:Float = minX + scale.x*sw;
		var maxY:Float = minY + scale.y*sh;
		var paddX:Float = layout.hitPadding *  mapData.scaleX * (scale.x/layout.uDim);
		var paddY:Float = layout.hitPadding * mapData.scaleY * (scale.y/layout.vDim);
		//trace([minU, minV, maxU, maxV, u, v]);
		// Bounding box check
		if (x >= minX && x <= maxX && y >= minY && y <= maxY) {
			if (layout.shape == LayoutItem.SHAPE_RECT) return 0;
		} else if (layout.shape == LayoutItem.SHAPE_RECT) {
			if (layout.hitPadding <= 0) return -1;
			// check padding hit case 
			
			dx = x > maxX ? x - maxX : x < minX ? x - minX : 0;
			dy = y > maxY ? y - maxY : y < minY ? y - minY : 0;
			
			// method by elimination
			/*
			d = du * du + dv * dv;
			du = du != 0 ? 1 : 0;
			dv = dv != 0 ? 1 : 0;
			if ( d <= paddU*paddU * du  + paddV * paddV * dv ) {
				trace("padding hit:" + paddU + ", "+paddV + " VS: "+du + ", "+dv + "= "+d);
				return d;
			}
			*/
			
			// method by scaled local displacement
			r = paddX < paddY ? paddY : paddX;
			dx *= r / paddX;
			dy *= r / paddY;
			d = dx*dx + dy*dy;
			if ( d <= r*r ) {
				trace("padding hit:" +  Math.sqrt(d));
				return d;
			}
			
			return -1;
		}
			
		if (layout.shape == LayoutItem.SHAPE_CIRCLE) {
			dx = (maxX-minX) * 0.5;
			dy = (maxY-minY) * 0.5;
			cx = minX + dx;
			cy = minY + dy;

			r = dx < dy ? dy : dx;
			var sx = r / dx;
			var sy = r / dy;
			
			dx = x - cx;
			dy = y - cy;
			dx *= sx;
			dy *= sy;
			
			d = dx * dx + dy * dy;
			
			if ( d <= r * r ) {	// check if inside ellipsoid
				return 0;
			}
			
			// check if inside padding rim and return squared distance to circle
			dx += (dx < 0 ? 1 : -1)*paddX*sx;
			dy += (dy < 0 ? 1 : -1)*paddY*sy;
				
			d = dx * dx + dy * dy;
			if ( d <= r * r ) {	// check if inside ellipsoid
				// TODO; correct square dist calculation to circle.
				dx = (cx + dx) - (cx +  r * (dx < 0 ? -1 : 1));
				dy = (cy + dy) - (cy +  r * (dy < 0 ? -1 : 1));
				trace("Padding hit:" +  Math.sqrt(dx*dx + dy*dy) + " :: "+r);
				return dx * dx + dy * dy;
			}

			
		} else {	// POLYGON
			
		}
		return -1;
	}

}

class UInteract {
	public var index:Int;
	public var mask:Int;
	public function new(index:Int, mask:Int) {
		
		this.index = index;
		this.mask = mask;
		
	}
}