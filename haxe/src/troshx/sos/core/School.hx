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

	public function new(name:String="", profLimit:Int=0, costArc:Int=0) 
	{
		this.name = name;
		this.profLimit = profLimit;
		this.costArc = costArc;
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