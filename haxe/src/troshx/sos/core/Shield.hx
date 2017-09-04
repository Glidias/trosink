package troshx.sos.core;

/**
 * 
 * @author Glidias
 */
class Shield extends Item
{
	public var AV:Int = 1;
	public var coverage:Dynamic<HitLocation> = {};
	
	public var blockTN:Int = 7;
	public var bashTN:Int = 0;
	
	
	// bob/ss
	public var strapType:Int = 0;
	public static inline var STRAP_ARM:Int = 0;
	public static inline var STRAP_SHOULDER:Int = 1;

	
	public function new() 
	{
		super();
	}
	
	override public function addTagsToStrArr(arr:Array<String>):Void {
		super.addTagsToStrArr(arr);
		if (this.strapped) {
			arr.push(strapType == STRAP_ARM ? "Arm-strap" : "Shoulder-strap");
		}
	}
	
	override public function getTypeLabel():String {
		return "Shield";
	}
	
}