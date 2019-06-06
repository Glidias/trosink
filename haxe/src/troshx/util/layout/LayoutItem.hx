package troshx.util.layout;

/**
 * A basic layout item in screen space
 * @author Glidias
 */
class LayoutItem 
{
	// base dimensions
	var u:Float;
	var v:Float;
	var uDim:Float;
	var vDim:Float;
	
	var uvs:Array<Vec2>;	// local coordinate polygon uvs over base dimensions
	
	var shape:Int = 0;
	public static inline var SHAPE_RECT:Int = 0;
	public static inline var SHAPE_CIRCLE:Int = 1;
	public static inline var SHAPE_POLYGON:Int = 2;
	
	@:isVar public var _pivot(get, null):PointScaleConstraint;	// pivot in local space
	@:isVar public var _pin(get, null):PointScaleConstraint;	// constraint for pivot in parent space
	@:isVar public var _border(get, null):BorderConstraint;	// border constraints
	@:isVar public var _aspect(get, null):AspectConstraint;		// relative aspect ratio constraint

	static var SCRATCH:Vec2 = new Vec2();

	function new() 
	{
		
	}
	
	public function solve(resultPosition:Vec2, resultScale:Vec2, scaleX:Float, scaleY:Float):Void {
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
		
		// should this be a selective approach to resultScale?
		if (_aspect != null && _aspect.preflight) {
			_aspect.findScales(resultScale, scaleX, scaleY);
		} else {
			resultScale.x = scaleX;
			resultScale.y = scaleY;
		}
			
		// determine scaling constraint of pivot position if needed via pin
		if (_pin != null) {
			_pin.findScaleRatios(scratch, resultScale.x, resultScale.y);
			pivotU = _pin.pt.x + (pivotU - _pin.pt.x) * scratch.x;
			pivotV = _pin.pt.y + (pivotV - _pin.pt.y) * scratch.y;
		}
		
		// Now, let's determine scaling of shape
		if (_pivot != null) {
			// determine new top Left resultPosition
			resultScale.x = scaleX;
			resultScale.y = scaleY;
			_pivot.findScaleRatios(resultScale, resultScale.x, resultScale.y);
			resultPosition.x = pivotU + (u-pivotU) * resultScale.x;
			resultPosition.y = pivotV + (v-pivotV) * resultScale.y;
		} else {
			resultScale.x = 1;
			resultScale.y = 1;
			resultPosition.x = u;
			resultPosition.y = v;
		}
		
		
		var minU:Float = resultPosition.x;
		var minV:Float = resultPosition.y;
		var maxU:Float = resultPosition.x + resultScale.x * uDim;
		var maxV:Float = resultPosition.y + resultScale.y * vDim;
		
		// apply border constraint stretching/clamping if needed
		if (_border != null) {
			
		}
		
		// Finalise resultPosition/resultScale based on new bounds
		// resultScale refers to projected uDim and vDim
		// resultPosition refers to projected u and v
		
		if (_aspect != null) {
			
		}
		
		
		resultPosition.x = minU;
		resultPosition.y = minV;
		resultScale.x = maxU - minU;
		resultScale.y = maxV - minV;
		
	}
	
	public function resolvePolygon(resultUVs:Array<Vec2>, position:Vec2, scale:Vec2):Void {
		
	}
	
	public static function createRectWIthUVs(u:Float, v:Float, uDim:Float, vDim:Float):LayoutItem {
		var me = new LayoutItem();
		me.u = u;
		me.v = v;
		me.uDim = uDim;
		me.vDim = vDim;
		return me;
	}
	
	public static function createRectRelative(scrnWidth:Float, scrnHeight:Float, x:Float, y:Float, width:Float, height:Float):LayoutItem {
		return createRectWIthUVs(x/scrnWidth, y/scrnHeight, width/scrnWidth, height/scrnHeight);
	}
	
	public function pivot(val:PointScaleConstraint):LayoutItem {
		_pivot = val;
		return this;
	}
	public function pin(val:PointScaleConstraint):LayoutItem {
		_pin = val;
		return this;
	}
	public function aspect(val:AspectConstraintTest):LayoutItem {
		_aspect = val;
		return this;
	}
	

	
}