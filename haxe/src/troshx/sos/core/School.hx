package troshx.sos.core;
import troshx.sos.bnb.IBuildUIFields;
import troshx.sos.core.Modifier.EventModifierBinding;
import troshx.sos.core.Modifier.SituationalCharModifier;
import troshx.sos.core.Modifier.StaticModifier;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class School 
{
	public var name:String;
	public var profLimit:Int;
	
	public var costArc:Int;
	public var costMoney:Money = null;

	public var uid(get, never):String;
	
	public static inline var MAX_LEVELS:Int = 20;
	
	// truth tables for progression
	public static function getLevels():Array<Int> {
		return [1,1,1,1, 2,2,2,2,  3,3,3,3,3,  6,6,6,6,  8, 10,10];
	}
	
	public static function getTalentAdds():Array<Int> { //
		return [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0];  // like alternate 1s
	}
	public static function getSuperiorAdds():Array<Int> {  // like every 4th interval
		return [0,0,0,1,  0,0,0,1,  0,0,0,1,   0,0,0,1,  0,0,0,1];
	}

	// mastery adds assumed last level..
	public static inline var MASTERY_LEVEL:Int = 20;

	public function new(name:String="", profLimit:Int=0, costArc:Int=0) 
	{
		this.name = name;
		this.profLimit = profLimit;
		this.costArc = costArc;
	}
	
	public function canAffordWith(arcPoints:Int, money:Money = null):Bool {
		
		if (money != null && costMoney != null) { // todo:
			
		}
		
		return arcPoints >= costArc;
	}
	
	// overrided this to implement any custom requirements for character
	public function customRequire(charSheet:CharSheet):Bool {
		return true;
	}

	public function getSchoolBonuses(charSheet:CharSheet):SchoolBonuses {
		return null;
	}
	
	inline function get_uid():String 
	{
		return name;
	}
	
	// these modifiers are for returning a specific value for hardcoded cases
	public var staticModifiers(default, null):Array<StaticModifier>;
	public var situationalModifiers(default, null):Array<SituationalCharModifier>;
	
	// these modifiers are only triggered upon events
	public var eventBasedModifiers(default, null):Array<EventModifierBinding>;

}

class SchoolBonuses implements IBuildUIFields {

	
	public var situationalModifiers(default, null):Array<SituationalCharModifier>;
	
	// these modifiers are only triggered upon events
	public var eventBasedModifiers(default, null):Array<EventModifierBinding>;
	

	public function getUIFields():Array<Dynamic> {
		return null;
	}
	
	public function getTags():Array<String> {
		return [];
	}
	
	
	public function new() {
		
	}
}