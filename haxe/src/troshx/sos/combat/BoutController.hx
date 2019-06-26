package troshx.sos.combat;
import troshx.components.Bout;
import troshx.components.FightState;
import troshx.core.ManueverStack;
import troshx.core.BoutMessage;
import troshx.core.IBoutController;
import troshx.util.DiceRoller;
import troshx.util.LibUtil;

/**
 * A localized bout controller class using Song of Swords rules.
 * convention: IBoutCOntroller classes should be instantitated as new instances afresh for every new bout
 * to handle initialization of bout
 * See IBoutController interface for conventions
 * @author Glidias
 */
class BoutController implements IBoutController
{
	var model:BoutModel;

	// Song of Swords implementation
	public static inline var STEP_ORIENTATION:Int = -2;
	public static inline var STEP_TARGET_SELECTION:Int = -1;
	public static inline var STEP_DECLARE:Int = 0;
	public static inline var STEP_RESOLVE:Int = 1;

			
	public function waitForPlayer():FightState {
		return null;
	}

	public function new(model:BoutModel) 
	{
		this.model = model;
		model.bout.s = STEP_ORIENTATION;
	}
	
	
	public  function step():Void {
		//model.bout.step(...);
	}
	
	public function handleCurrentStep():Int
	{
		var step:Int = model.bout.s;
		if (step == STEP_ORIENTATION) {
			//  resolve manuever  stacks
			
			// refresh combat pools if requided  (check blood lost and all..)
			
			// determine orientations if needed per combatant
			return -1;
			
		}
		else if (step == STEP_TARGET_SELECTION) {
			// determine targets if needed per combatant
			return -1;
		}
		else if (step == STEP_DECLARE) {
			// determine manuevers if needed per combatant
			
			return -1;
		}
		else if (step == STEP_RESOLVE) {
			return 0;
		}
		else {
			throw "Unhandled step:" + step;
			
		}
		return 0;
	}
	
	
	
	
	
	
	
	
}