package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Bane;

/**
 * ...
 * @author Glidias
 */
class OldWound extends Bane
{

	public function new() 
	{
		super("Old Wound", [1]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		multipleTimes = BoonBane.TIMES_VARYING;  // varies based on body
	}
	
	override function getEmptyAssignInstance():OldWoundAssign {
		return new OldWoundAssign();
	}
	
}

class OldWoundAssign extends BaneAssign {
	@:hitLocationMask public var hitLocations:Int  = 0;
	//public var hitLocations:Array<String> = [];
	
	public function new() {
		super();
	}
	
	override public function isValid():Bool {
		return hitLocations != 0;
		//return hitLocations.length > 0;
	}
}

