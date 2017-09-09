package troshx.sos.bnb;
import troshx.sos.bnb.ImpressiveVoice.ImpressiveVoiceAssign;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.BoonBane.BoonAssign;

/**
 * ...
 * @author Glidias
 */

class ImpressiveVoice extends Boon {
	

	public function new() {
		super("Impressive Voice", [2]);
		
		multipleTimes = 3;
	}
	
	
	override function getEmptyAssignInstance():BoonAssign {
		return new ImpressiveVoiceAssign();
	}
}
class ImpressiveVoiceAssign extends BoonAssign {
	
	public static inline var POWERFUL:Int = (1 << 0);
	public static inline var GRATING:Int = (1 << 1);
	public static inline var SOOTHING:Int = (1 << 2);
	
	var voiceQualities:Int = 0;
	
	
	public function new() {
		super();
	}
	
}