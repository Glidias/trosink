package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Boon;

/**
 * ...
 * @author Glidias
 */
class Literate extends Boon
{
	
	public function new() 
	{
		super("Literate", [1]);
		multipleTimes = BoonBane.TIMES_INFINITE;
	}
	
	override function getEmptyAssignInstance():BoonAssign {
		return new LiterateAssign();
	}
	
}

class LiterateAssign extends BoonAssign {
	public var scripts:Array<String> = [];
	
	public function new() {
		super();
	}

}