package troshx.sos.bnb;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.Modifier;
import troshx.sos.core.Modifier.StaticModifier;

/**
 * ...
 * @author Glidias
 */
class Fat extends Bane {
	public function new() {
		super("Fat", [5]);
		// -2 to endurance when determining fatque
		
		staticModifiers = [
			StaticModifier.create(Modifier.CMP_MOB, -2),
			StaticModifier.create(Modifier.FATIQUE_END, -2),
		];
	}
}