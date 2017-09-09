package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.BoonBane.BaneAssign;

/**
 * ...
 * @author Glidias
 */
class LastingPain extends Bane
{
	

	public function new() 
	{
		super("Lasting Pain", [4, 8]);
		flags = BoonBane.CANNOT_BE_REMOVED;
	}
	override function getEmptyAssignInstance():BaneAssign {
		return new LastingPainAssign();
	}
}

class LastingPainAssign extends BaneAssign {
	//public var hitLocationIndex:Int;
	public var hitLocationId:String = "";
	
	public function new() {
		super();
	}
	
	override public function isValid():Bool {
		return hitLocationId != null && hitLocationId != "";
	}
}


