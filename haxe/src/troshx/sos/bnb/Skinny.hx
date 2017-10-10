package troshx.sos.bnb;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.Modifier;
import troshx.sos.core.Modifier.SituationalCharModifier;
import troshx.sos.sheets.CharSheet;
/**
 * ...
 * @author Glidias
 */
class Skinny extends Bane {
	public function new() {
		
		super("Skinny", [3]);
		staticModifiers = [
			StaticModifier.create(Modifier.CAR_END, -1)
			//StaticModifier.create(Modifier.FATIQUE_END, -1)
		];
	}
}


