package troshx.util.layout;
import hxGeomAlgo.HxPoint;
import hxGeomAlgo.PolyTools.Poly;
/**
 * A basic layout item in screen space
 * @author Glidias
 */
class LayoutItem 
{
	// base dimensions
	public var u(default, null):Float;
	public var v(default, null):Float;
	public var uDim(default, null):Float;
	public var vDim(default, null):Float;
	
	public var uvs(default, null):Poly;	// local coordinate polygon uvs over base dimensions
	public inline function setUVs(uvs:Poly):Void {
		this.uvs = uvs;
	}
	
	public var shape(default, null):Int = 0;
	public static inline var SHAPE_RECT:Int = 0;
	public static inline var SHAPE_CIRCLE:Int = 1;
	public static inline var SHAPE_POLYGON:Int = 2;
	
	public var _pivot(default, null):PointScaleConstraint;	// pivot in local space
	public var _pin(default, null):PointScaleConstraint;	// constraint for pivot in parent space
	public var _borders(default, null):Array<BorderConstraint>;	// border constraints
	public var _aspect(default, null):AspectConstraint;		// relative aspect ratio constraint
	
	//static var PIN_FIXED:PointScaleConstraint = PointScaleConstraint.createRelative(0, 0).scaleMaxRelative(1,1).scaleMinRelative(1,1);

	static var SCRATCH:HxPoint = new HxPoint();
	
	public var hitDecomposition:Array<Poly>;
	public var hitPadding:Float = 0;

	function new() 
	{
		
	}
	
	public function solve(resultPosition:HxPoint, resultScale:HxPoint, scaleX:Float, scaleY:Float):Void {
		var pivotU:Float;
		var pivotV:Float;
		var scratch = SCRATCH;
		if (_pivot != null) {
			pivotU = u + _pivot.pt.x * uDim;
			pivotV = v + _pivot.pt.y * vDim;
		} else {
			pivotU = u;
			pivotV = v;
		}
			
		// determine scaling constraint of pivot position if needed via pin
		if (_pin != null) {
			_pin.findScaleRatios(scratch, scaleX, scaleY);
			if (_aspect != null && _aspect.preflight) {
				_aspect.findScales(resultScale, scaleX, scaleY);
				resultScale.x /= scaleX;
				resultScale.y /= scaleY;
				scratch.x = Math.min(resultScale.x, scratch.x);
				scratch.y = Math.min(resultScale.y, scratch.y);
			} 
			pivotU = _pin.pt.x + (pivotU - _pin.pt.x) * scratch.x;
			pivotV = _pin.pt.y + (pivotV - _pin.pt.y) * scratch.y;
		}
		
		// Now, let's determine scaling of shape
		if (_pivot != null) {
			// determine new top Left resultPosition
			_pivot.findScaleRatios(resultScale, scaleX, scaleY);
			resultPosition.x = pivotU - _pivot.pt.x * uDim * resultScale.x;
			resultPosition.y = pivotV - _pivot.pt.y * vDim * resultScale.y;
		} else {
			resultScale.x = 1;
			resultScale.y = 1;
			resultPosition.x = pivotU;
			resultPosition.y = pivotV;
		}
		
		var minU:Float = resultPosition.x;
		var minV:Float = resultPosition.y;
		
		var maxU:Float = minU + resultScale.x * uDim;
		var maxV:Float = minV + resultScale.y * vDim;
		
		// apply border constraint stretching/clamping if needed
		if (_borders != null) {
			var b:BorderConstraint;

			if (_borders[BorderConstraint.SIDE_TOP] != null) {
				b = _borders[BorderConstraint.SIDE_TOP];
				minV = b.solveCoord(v, scaleY); 
			}
			if (_borders[BorderConstraint.SIDE_RIGHT] != null) {
				b = _borders[BorderConstraint.SIDE_RIGHT];
				maxU = b.solveCoord(u+uDim, scaleX);
			}
			if (_borders[BorderConstraint.SIDE_BOTTOM] != null) {
				b = _borders[BorderConstraint.SIDE_BOTTOM];
				maxV = b.solveCoord(v+vDim, scaleY);
			}
			if (_borders[BorderConstraint.SIDE_LEFT] != null) {
				b = _borders[BorderConstraint.SIDE_LEFT];
				minU = b.solveCoord(u, scaleX);
			}
		}

		resultPosition.x = minU;
		resultPosition.y = minV;
		resultScale.x = maxU - minU;
		resultScale.y = maxV - minV;
		
		if (_aspect != null ) {
			_aspect.findScales(scratch, scaleX, scaleY);
			scratch.x /= scaleX;
			scratch.y /= scaleY;
			scratch.x *= uDim;
			scratch.y *= vDim;
			// the above is a dummy UV dimensional size reference that enforces aspect ratio 
			// in relation to current canvas scale
			
			// Now find aspect-ratio constrained scales in relation to that reference
			_aspect.findScales(resultScale, resultScale.x / scratch.x, resultScale.y / scratch.y);
			resultScale.x *= scratch.x;
			resultScale.y *= scratch.y;
			
			if (_pivot != null) { 
				resultPosition.x = pivotU - _pivot.pt.x * resultScale.x;
				resultPosition.y = pivotV - _pivot.pt.y * resultScale.y;
				// for border != null case,  _pivot.pt.x and y shouuld be re-intepreted against entire border-expanded AABB from pivotUV
				// (pivotU - minU)/resultScale.x,  (pivotV - minV)/resultScale.y
		
			} else {
				//resultPosition.x = pivotU;
				//resultPosition.y = pivotV;
				// for border != null case,  _pivot.pt.x and y should be re-interpreted against entire border-expanded AABB from pivotUV
			}
			
			//resultScale.x = Math.min(resultScale.x, scratch.x);
			//resultScale.y = Math.min(resultScale.y, scratch.y);
		} 
		
		
		
	}
	
	public function resolvePolygon(resultUVs:Array<Float>, position:HxPoint, scale:HxPoint):Void {
		var c:Int = 0;
		for (i in 0...uvs.length) {
			resultUVs[c++] = position.x + uvs[i].x * scale.x;
			resultUVs[c++] = position.y + uvs[i].y * scale.y;
		}
	}
	
	public static function createRectWIthUVs(u:Float, v:Float, uDim:Float, vDim:Float):LayoutItem {
		var me = new LayoutItem();
		me.u = u;
		me.v = v;
		me.uDim = uDim;
		me.vDim = vDim;
		return me;
	}
	
	public static function createRect(scrnWidth:Float, scrnHeight:Float, x:Float, y:Float, width:Float, height:Float):LayoutItem {
		return createRectWIthUVs(x/scrnWidth, y/scrnHeight, width/scrnWidth, height/scrnHeight);
	}
	public static function createCircle(scrnWidth:Float, scrnHeight:Float, x:Float, y:Float, radius:Float):LayoutItem {
		var me =  createRectWIthUVs((x-radius) / scrnWidth, (y-radius) / scrnHeight, radius*2 / scrnWidth, radius*2 / scrnHeight);
		me.shape = SHAPE_CIRCLE;
		return me;
	}
	public static function createPolygon(scrnWidth:Float, scrnHeight:Float, coords:Array<Float>):LayoutItem {
		var minX:Float = 2147483647;
		var minY:Float = 2147483647;
		var maxX:Float = 0;
		var maxY:Float = 0;
		var me = new LayoutItem();
		me.shape = SHAPE_POLYGON;
		var i:Int = 0;
		var len:Int = coords.length;
		me.uvs = [];
		var v:HxPoint;
		while ( i < len) {
			v = new HxPoint(coords[i], coords[i + 1]);
			me.uvs.push(v);
			if (v.x < minX) minX = v.x;
			if (v.y < minY) minY = v.y;
			if (v.x > maxX) maxX = v.x;
			if (v.y > maxY) maxY = v.y;
			i += 2;
		}
		me.u = minX / scrnWidth;
		me.v = minY / scrnHeight;
		me.uDim = maxX / scrnWidth;
		me.vDim = maxY / scrnHeight;
		me.uDim -= me.u;
		me.vDim -= me.v;
		
		for (i in 0...me.uvs.length) {
			v = me.uvs[i];
			v.x = (v.x / scrnWidth - me.u) / me.uDim;
			v.y = (v.y / scrnHeight - me.v) / me.vDim;
		}
		return me;

	}
	
	public function pivot(val:PointScaleConstraint):LayoutItem {
		_pivot = val;
		return this;
	}
	public function pin(val:PointScaleConstraint):LayoutItem {
		_pin = val;
		return this;
	}
	public function aspect(val:AspectConstraint):LayoutItem {
		_aspect = val;
		return this;
	}
	
	public function border(side:Int, scaleMin:Float, scaleMax:Float, coord:Float=-1):LayoutItem {
		if (_borders == null) {
			_borders = [null, null, null, null];
		}
		if (coord < 0) {
			coord = BorderConstraint.isMaximalSide(side) ? 1 : 0;
		} else {
			if (BorderConstraint.isMaximalSide(side)) {
				if (BorderConstraint.isHorizontal(side)) {
					if (coord < u + uDim) coord = u + uDim;
				} else {
					if (coord < v + vDim) coord = v + vDim;
				}
			} else {
				if (BorderConstraint.isHorizontal(side)) {
					if (coord > u) coord = u;
				} else {
					if (coord > v) coord = v;
				}
			}
		}
		_borders[side] = BorderConstraint.createRelative(coord, scaleMin, scaleMax);
		return this;
	}
	
	public static function fromHTMLImageMapArea(mapWidth:Int, mapHeight:Int, shape:String, coords:String):LayoutItem {
		var coords:Array<Float> = coords.split(", ").map(function(str){return Std.parseFloat(str); });
		if (shape == "rect") {
			 return LayoutItem.createRect(mapWidth, mapHeight, coords[0], coords[1], coords[2] - coords[0], coords[3] - coords[1]);
		} else if (shape == "circle") {
			return LayoutItem.createCircle(mapWidth, mapHeight, coords[0], coords[1], coords[2]);
		} else { // polygon
			return LayoutItem.createPolygon(mapWidth, mapHeight, coords);
		}
		
	}

	
}