package troshx.sos.bnb;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.Modifier;
import troshx.sos.core.Modifier.SituationalCharModifier;
import troshx.sos.macro.MacroUtil;
import troshx.sos.sheets.CharSheet;
/**
 * ...
 * @author Glidias
 */
class Skinny extends Bane {
	public function new() {
		
		super("Skinny", [3]);
		var m; 
		MacroUtil.linkedListFromArray(m, [
			StaticModifier.create(Modifier.CAR_END, -1)
		]);
		staticModifiers = [m];
	}
}


