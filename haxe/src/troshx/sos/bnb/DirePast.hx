package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class DirePast extends Bane
{
	public static inline var BONUS_POINTS:Int = 10;
	
	public function new() 
	{
		super("Dire Past", [0]);
		// manual missing character creation only...
		flags = BoonBane.CHARACTER_CREATION_ONLY | BoonBane.CANNOT_BE_REMOVED;  
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BaneAssign {
		return new DirePastAssign(charSheet);
	}
}

class DirePastAssign extends BaneAssign {
	var char:CharSheet;
	
	@:ui({type:"textarea"}) public var notes:String = "";
	
	@:ui({type:"ButtonPermaPress", label:"Trigger", descriptionDone:"Done!", description:"Warning: For GM use only. Once you trigger Dire Past, all existing banes (assigned by GM based on your given 'story') are baked permanently and can no longer be canceled during character creation! However, you will gain 10 free points to spend on Boons.", callback:execute}) public var uiActivated:Bool;
	
	public function new(char:CharSheet) {
		super();
		this.char = char;
		uiActivated = this.char.direPast;
	}
	
	public function execute():Void {
		if (char.direPast) return;
		
		char.direPast = true;
		var baneAssigns:Array<BaneAssign> = char.banes.list;
		for (i in 0...baneAssigns.length) {
			var b = baneAssigns[i];
			b._forcePermanent = true; // or should just set min to existing rank only?
		}
	}
}