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
	
	public var damage:Int = 0;
	public var damageType:Int = DamageType.BLUDGEONING;
	
	// bob/ss house strap rules
	public var strapType:Int = 0;
	@:strap("Arm-Strap") public static inline var STRAP_ARM:Int = 0; // currently hardcoded in UI
	@:strap("Shoulder-Strap") public static inline var STRAP_SHOULDER:Int = 1;

	
	// Depreciated, refactor this to Shield special if really needed?
	//public var coverage:Dynamic<Int>;	// Using plain dynamic object to favor javascript object
	
	public static inline var POSITION_LOW:Int = 0;
	public static inline var POSITION_HIGH:Int = 1;
	
	// temp fix due to missing blockTN/bashTN/durability UIs in inventory sheet editor
	public function tempFixSpecsFromName():Void {
		var specSpl = name.split(":");
		damageType = DamageType.BLUDGEONING;
		
		if (specSpl.length > 1) {
			specSpl[0] = StringTools.trim(specSpl[0]);
			specSpl[1] = StringTools.trim(specSpl[1]);
			var specs = specSpl.pop();
			var duraSpl = specs.split(" ");
			
			if (duraSpl.length >= 2 ) {
				durability = Std.parseInt(duraSpl[1]);
			}
			var mainStats:String = duraSpl[0];

			var mainStatsSpl = mainStats.split("(");
			bashTN = Std.parseInt(mainStatsSpl[0]);
			if (mainStatsSpl.length >= 2 && mainStatsSpl[1].charAt(mainStatsSpl[1].length-1) == ")") {
				mainStats = mainStatsSpl[1];
				mainStats = mainStats.substr(0, mainStats.length - 1);
				damage = Std.parseInt(mainStats);
				mainStats = mainStats.charAt(mainStats.length - 1);
				if (mainStats == "c") {
					damageType = DamageType.CUTTING;
				} else if (mainStats == "p") {
					damageType = DamageType.PIERCING;
				}
				// okay, don't bother with other damage types for now
			} else {
				trace("Warning!! Could not find open/close bracket of:"+name);
			}
			
			if (Math.isNaN(bashTN)) {
				bashTN = 0;
				trace("Warning:: failed to parse bashTN of title:"+name);
			}
			if (Math.isNaN(damage)) {
				damage = 0;
				trace("Warning:: failed to parse damage of title:"+name);
			}
			if (Math.isNaN(durability)) {
				durability = 6;
				trace("Warning:: failed to parse durability of title:"+name);
			}
		}
		name = specSpl.join(":");
	}
	
	public static function getHighCoverage():Array<Dynamic<Bool>> {
		return [{
			// whole head
			"upperHead":true,
			"lowerHead":true,
			"face":true,
			
			"neck":true,
			"shoulder":true,
			
			// shield arm
			"upperArm":false,
			"elbow":false,
			"forearm":false,
			"hand":false
		},
		{
			// whole head
			"upperHead":true,
			"lowerHead":true,
			"face":true,
			
			"neck":true,
			"shoulder":true,
			
			// shield arm
			"upperArm":false,
			"elbow":false,
			"forearm":false,
			"hand":false,
			
			"chest":true	
			
		},
		{
			// whole head
			"upperHead":true,
			"lowerHead":true,
			"face":true,
			
			"neck":true,
			"shoulder":true,
			
			// arm
			"upperArm":true,
			"elbow":true,
			"forearm":true,
			"hand":true,
			
			"chest":true,
			"belly":true,
			"side":true,
		}
		];
	}
	
	public static function getLowCoverage():Array<Dynamic<Bool>> {
		return [{
			"chest":true,
			"belly":true,
			
			// shield arm
			"upperArm":false,
			"elbow":false,
			"forearm":false,
			"hand":false
		},
		{
			"chest":true,
			"belly":true,
			"side":true,
			"groin":true,
			"hip":true,
			
			// shield arm
			"upperArm":false,
			"elbow":false,
			"forearm":false,
			"hand":false,
			
			"thigh":true,
		},
		{	
			"chest":true, //manual missing this?
	
			"belly":true,
			"side":true,
			"groin":true,
			"hip":true,
			
			"neck":true,
			
			// shield arm
			"upperArm":false,
			"elbow":false,
			"forearm":false,
			"hand":false,
			
			"knee":true,
			"thigh":true,
		}
		];
	}
	
	
	
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