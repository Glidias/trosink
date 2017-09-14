package troshx.sos.bnb;
import troshx.sos.bnb.ImpressiveVoice.ImpressiveVoiceAssign;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.BoonBane.BoonAssign;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */

class ImpressiveVoice extends Boon {
	
	public static inline var COST:Int = 2;

	public function new() {
		super("Impressive Voice", [COST]);
		
		multipleTimes = 3;
	}
	
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BoonAssign {
		return new ImpressiveVoiceAssign();
	}
}
class ImpressiveVoiceAssign extends BoonAssign {
	
	public static inline var POWERFUL:Int = (1 << 0);
	public static inline var GRATING:Int = (1 << 1);
	public static inline var SOOTHING:Int = (1 << 2);
	
	@:ui({type:"Bitmask", labels:["Powerful", "Grating", "Soothing"], validateOptionFunc:canBeToggled }) var voiceQualities:Int = 0;
	
	override public function isValid():Bool {
		return (voiceQualities & (POWERFUL | GRATING | SOOTHING)) != 0;
	}
	
	function canBeToggled(index:Int):Bool {
		return bitmaskIndexCanBeToggledAtCost(index, voiceQualities, ImpressiveVoice.COST);
	}
	
	override public function getQty():Int {
		var c:Int = 0;
		c += (voiceQualities & POWERFUL) != 0 ?  1: 0;
		c += (voiceQualities & GRATING) != 0 ? 1 : 0;
		c += (voiceQualities & SOOTHING) != 0 ? 1 : 0;
		return c;
	}
	
	override public function getCost(rank:Int):Int {
		return getQty() * ImpressiveVoice.COST;
	}
	
	public function new() {
		super();
	}
	
}