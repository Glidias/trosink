package troshx.util.layout;

/**
 * Used as pivot scale constraint to define a local
 * transform origin for a layout region or anchoring/pinning reference point for that layout region's origin itself, 
 * It can also define min/max range relative scale values from given point.
 * @author Glidias
 */
class PointScaleConstraint 
{
	public var scaleMin:Vec2;
	public var scaleMax:Vec2;
	public var pt:Vec2 = new Vec2();

	public function new() 
	{
		
	}
	
}