package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class BarrenOrSterility extends Bane {
	public function new() {
		super("Barren/Sterility", [1, 3]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		conditions = [null, new EunuchCondition() ];  // todo:Problems with serializations
	}
}

class EunuchCondition extends BoonBaneCondition {
	public function new() {
		super();
	}
	override function valid(char:CharSheet):Bool {
		return char.gender == CharSheet.GENDER_MALE;
	}
}