package troshx.sos.core;

/**
 * 
 * @author Glidias
 */
class Shield extends Item
{
	public var AV:Int = 1;
	
	public var size:Int = 0;
	@:size("Small") public static inline var SIZE_SMALL:Int = 0;	// currently hardcoded in UI
	@:size("Medium") public static inline var SIZE_MEDIUM:Int = 1;
	@:size("Large") public static inline var SIZE_LARGE:Int = 2;
	
	public var blockTN:Int = 7;
	public var bashTN:Int = 0;
	public var durability:Int = 6;
	
	
	// bob/ss house strap rules
	public var strapType:Int = 0;
	@:strap("Arm-Strap") public static inline var STRAP_ARM:Int = 0; // currently hardcoded in UI
	@:strap("Shoulder-Strap") public static inline var STRAP_SHOULDER:Int = 1;
	
	
	// Depreciated, refactor this to Shield special if really needed?
	//public var coverage:Dynamic<Int>;	// Using plain dynamic object to favor javascript object

	
	
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