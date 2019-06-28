package troshx.sos.vue.combat;
import haxe.ds.IntMap;
import hxGeomAlgo.Bayazit;
import hxGeomAlgo.HxPoint;
import hxGeomAlgo.PolyTools;
import troshx.sos.vue.combat.UIInteraction.UInteract;
import troshx.util.layout.LayoutItem;

/**
 * Yet another platform agnostic class to handle UI standard interactions
 * @author Glidias
 */
class UIInteraction 
{
	

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
	
	@:act public static inline var CANCELED:Int = (1 << 14);
	@:act public static inline var RELEASE:Int = (1 << 15);
	@:act public static inline var RELEASE_OVER:Int = (1 << 16);
	
	public static inline var MASK_CANCELED_OR_RELEASE:Int = CANCELED | RELEASE;
	
	public static inline function requiresConfirmHit(mask:Int):Bool {
		return (mask & (TAP|RELEASE_OVER))!=0;
	}
	
	public static inline function requiresTracking(mask:Int):Bool {
		return mask >= 2;
	}
	
	public static inline function requiresContinousHandling(mask:Int):Bool {
		return (mask & (PAN | MOVE_OVER | MOVE))!=0;
	}
	
	static function isValidPoly(poly:Poly):Bool {
		return poly.length >= 3;
	}
	
	static function weldPoly(poly:Poly, dupPoints:Array<Int>):Poly {
		var map:IntMap<Bool> = new IntMap<Bool>();
		for (i in 0...dupPoints.length) {
			map.set(dupPoints[i], true);
		}
		var newPoly:Poly = new Poly();
		for (i in 0...poly.length) {
			if (!map.exists(i)) newPoly.push( poly[i] );
		}
		return newPoly;
		
	}

	// app specific set
	public static function setupDollViewInteracts(layoutItems:Array<LayoutItem>, names:Array<String>, tags:Array<String>):Array<UInteract> {
		var arr:Array<UInteract> = new Array<UInteract>();
		for (i in 0...layoutItems.length) {
			var item:LayoutItem = layoutItems[i];
			var name:String = names[i];
			var tag:String = tags[i];
			
			// Polygon defaults
			if (item.shape == LayoutItem.SHAPE_POLYGON) {
				 // lazy-cleanup polygons due to crappy image map creators
				var dupPoints = PolyTools.findDuplicatePoints(item.uvs, true, true);
				if (dupPoints.length != 0 ) {
					item.setUVs( weldPoly(item.uvs, dupPoints) );
				}
				
				// make clockwise for hit detection convention
				PolyTools.makeCW(item.uvs);
				
				// decompose non-convex for hit detection
				if (!PolyTools.isConvex(item.uvs)) {
					item.hitDecomposition = Bayazit.decomposePoly(item.uvs);
					var lastLen:Int = item.hitDecomposition.length;
					item.hitDecomposition = item.hitDecomposition.filter(isValidPoly);
					if (item.hitDecomposition.length == 0 || item.hitDecomposition.length != lastLen) {
						trace("WARNING!! invalid decomposition occured: "+name + " : "+(item.hitDecomposition.length) + " / "+lastLen);
						item.hitDecomposition = null;
					}
				}
			}
			
			if (tag == "part" || tag == "swing") {	// assumption against refWidth/refHeight
				item.hitPadding = 5;
			}
			
			if (tag == "part" || tag == "swing" || name == "enemyHandLeft" || name == "enemyHandRight") {
				arr.push(new UInteract(i, DOWN | HOVER | RELEASE | CANCELED) );
				continue;
			}
			
			switch(name) {
				case "initRange": 
					arr.push(new UInteract(i, DOWN) );
				case "advManuever1", "advManuever2", "advManuever3", "advManuever4": 
					arr.push(new UInteract(i, DOWN) );
				case "btnBlock", "btnVoid", "btnParry": 
					item.hitPadding = 5;
					arr.push(new UInteract(i, DOWN | RELEASE | CANCELED) );
				case "incomingManuevers":
					arr.push(new UInteract(i, MASK_CANCELED_OR_RELEASE|DOWN| PAN_UP|PAN_DOWN));	
				case "opponentSwiper":
					arr.push(new UInteract(i, SWIPE_LEFT|SWIPE_RIGHT));	
				case "roundCount":
					//arr.push(new UInteract(i, HOLD);	
				case "vitals":
					arr.push(new UInteract(i, DOWN |  PAN_UP|PAN_DOWN));	
				case "cpMeter":
					
				case "cpText":
					
				case "handLeftAlt", "handRightAlt": 
						arr.push(new UInteract(i, TAP|HOLD|SWIPE_LEFT|SWIPE_RIGHT));	
				case "handLeftText", "handRightText": 
					
				
			}
		}
		return arr;
	}
	
	// General methods
	
	public static function findHit(u:Float, v:Float, mapData:ImageMapData, interacts:Array<UInteract>):UInteract {
		var closestHit:UInteract = null;
		var closestHitDist:Float = 999999999999;
		for (i in 0...interacts.length) {
			var act:UInteract = interacts[i];
			if (act.disabled) continue;
			
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
	
	static var SAMPLE_PT:HxPoint = new HxPoint();
	static var SAMPLE_PT2:HxPoint = new HxPoint();
	
	static var SAMPLE_PT_A:HxPoint = new HxPoint();
	static var SAMPLE_PT_B:HxPoint = new HxPoint();
	
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
		var d2:Float;
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
			
			d2 = dx * dx + dy * dy;
			
			// method by scaled local displacement
			r = paddX < paddY ? paddY : paddX;
			dx *= r / paddX;
			dy *= r / paddY;
			d = dx*dx + dy*dy;
			if ( d <= r * r ) {
				//trace("PADD box:" + Math.sqrt(d2));
				return d2;
			}
			
			return -1;
		}
			
		if (layout.shape == LayoutItem.SHAPE_CIRCLE) {
			dx = (maxX-minX) * 0.5;
			dy = (maxY-minY) * 0.5;
			cx = minX + dx;
			cy = minY + dy;

			r = dx < dy ? dy : dx;
			var sx:Float = 1;
			var sy:Float  = 1;
			
			if (layout.hitPadding > 0) {
				sx = r / dx;
				sy = r / dy;
			}
			
			dx = x - cx;
			dy = y - cy;
			dx *= sx;
			dy *= sy;
			
			d = dx * dx + dy * dy;
			
			if ( d <= r * r ) {	// check if inside ellipsoid
				return 0;
			}
			
			d2 = d;
			
			// check if inside padding rim and return squared distance to circle
			dx += (dx < 0 ? 1 : -1)*paddX*sx;
			dy += (dy < 0 ? 1 : -1)*paddY*sy;
				
			d = dx * dx + dy * dy;
			if ( d <= r * r ) {	// check if inside ellipsoid
				d = Math.sqrt(d2) - r;
				//trace("PADD circle:" + d);
				return d*d;
			}
			
		} else {	// POLYGON
			var pt:HxPoint = SAMPLE_PT;
			pt.x = x;
			pt.y = y;
			if (layout.hitDecomposition == null) {
				r = checkHitPolygon(pt, layout.uvs, paddX, paddY, pos, scale, sw, sh);
				//if (r > 0) trace("PADD poly: "+paddX + " , "+paddY + " VS:"+( (scale.x * sw) + " :: " + (scale.y * sh)));
				return r;
			} else {
				r = 99999999999;
				var gotPaddHit:Bool = false;
				for (p in 0...layout.hitDecomposition.length) {
					dx = checkHitPolygon(pt, layout.hitDecomposition[p], paddX, paddY, pos, scale, sw, sh);
					if (dx == 0) return 0;
					if (dx > 0 && dx < r) {
						gotPaddHit = true;
						r = dx;
					}	
				}
				return gotPaddHit ? r : -1;
			}
		}
		return -1;
	}
	
	static function checkHitPolygon(pt:HxPoint, poly:Poly, paddX:Float, paddY:Float, pos:HxPoint, scale:HxPoint, sw:Float, sh:Float):Float {
		var len = poly.length;
		var p:HxPoint;
		var p2:HxPoint;
		var side:Bool;
		var shortestDist:Float = 99999999999;
		var gotPaddHit:Bool = false;

		var x:Float = pos.x * sw;
		var y:Float = pos.y * sh;
		var width:Float = scale.x * sw;
		var height:Float = scale.y * sh;
		
		var a:HxPoint = SAMPLE_PT_A;
		var b:HxPoint = SAMPLE_PT_B;
		
		//lastSide = side;
		
		var noPadding = paddX == 0 && paddY == 0;
		
		var r = paddX < paddY ? paddY : paddX;
		var sx = noPadding ? 1 : r / paddX;
		var sy = noPadding ? 1 : r / paddY;
		
		r *= r;

		var i = 0;
		while (i < len) {
			p = poly[i];
			p2 = i < len - 1 ? poly[i + 1] : poly[0];
			a.x = x + p.x * width;
			b.x = x + p2.x * width;
			a.y = y + p.y * height;
			b.y = y + p2.y * height;
			side = PolyTools.isLeft(pt, a, b);
			if (!side) {
				if (noPadding) return -1;
				if ( distanceToSegmentSquaredPaddScaled(pt, a, b, sx, sy) <= r) {
					var d:Float = PolyTools.distanceToSegmentSquared(pt, a, b);
					//trace("dist padd:"+ Math.sqrt(d) +" RECEIVED vs:"+r);
					return d;
				}
				return -1;
			};
			i++;
		}
		
		return !gotPaddHit ? 0 : shortestDist;
	}

	// Squared distance from `v` to `w`.
	inline static public function distanceSquaredPaddScaled(v:HxPoint, w:HxPoint, sx:Float, sy:Float):Float { return PolyTools.sqr((v.x - w.x)*sx) + PolyTools.sqr((v.y - w.y)*sy); }

	// Squared perpendicular distance from `p` to line segment `v`-`w`. 
	static public function distanceToSegmentSquaredPaddScaled(p:HxPoint, v:HxPoint, w:HxPoint, sx:Float, sy:Float):Float {
		var l2:Float = PolyTools.distanceSquared(v, w);
		if (l2 == 0) return distanceSquaredPaddScaled(p, v, sx, sy);
		var t = ((p.x - v.x) * (w.x - v.x) + (p.y - v.y) * (w.y - v.y)) / l2;
		if (t < 0) return distanceSquaredPaddScaled(p, v, sx, sy);
		if (t > 1) return distanceSquaredPaddScaled(p, w, sx, sy);
		SAMPLE_PT2.setTo(v.x + t * (w.x - v.x), v.y + t * (w.y - v.y));
		return distanceSquaredPaddScaled(p, SAMPLE_PT2, sx, sy);
	}
	
	

}

class UInteract {
	public var index:Int;
	public var mask:Int;
	public var disabled:Bool;
	
	public function new(index:Int, mask:Int) {
		
		this.index = index;
		this.mask = mask;
		this.disabled = false;
	}
	
	public static function getIndexMapOfArray(arr:Array<UInteract>):IntMap<UInteract> {
		var map:IntMap<UInteract> = new IntMap<UInteract>();
		for (i in 0...arr.length) {
			map.set(arr[i].index, arr[i]);
		}
		return map;
	}
}