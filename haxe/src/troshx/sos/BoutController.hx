package troshx.sos;
import troshx.components.Bout;
import troshx.components.FightState;
import troshx.components.ManueverStack;
import troshx.core.BoutMessage;
import troshx.core.IBoutController;

/**
 * A localized bout controller class using Song of Swords rules
 * @author Glidias
 */
class BoutController implements IBoutController
{
	// IBoutController boilerplate
	private var bout:Bout = new Bout();
	public function setBout(val:Bout):Void {
		bout = val;
	}
	
	public function waitForPlayer():FightState {
		return null;
	}
	
	public function getMessages():Array<BoutMessage> {
		return _messages;
	}
	public function getMessagesCount():Int {
		return _messages.length;
	}
	
	private var _messages:Array<BoutMessage>  = [];
	
	// Song of Swords implementation
	
	public static inline var STEP_ORIENTATION_OR_RESOLVE:Int = 0;
	public static inline var STEP_TARGET_SELECTION:Int = 1;
	public static inline var STEP_DECLARATION:Int = 2;
	public static inline var TOTAL_STEPS:Int = 3;
			
	private var manueverStack:ManueverStack= new ManueverStack();
	private var defManueverStack:ManueverStack = new ManueverStack();
	
	public function new() 
	{
		
	}
	
	public  function step():Void {
		bout.state.step(bout.state.s == (TOTAL_STEPS - 1));
		for (f in bout.combatants) {
			f.fight.matchScheduleWith(bout.state);
		}
	}
	
	public function handleCurrentStep():Bool
	{
		
		var step:Int = bout.state.s;
		if (step == STEP_ORIENTATION_OR_RESOLVE) {
			//  resolve manuever  stacks
			
			// refresh combat pools if requided  (check blood lost and all..)
			
			// determine orientations if needed per combatant
			return true;
			
		}
		else if (step == STEP_TARGET_SELECTION) {
			// determine targets if needed per combatant
			return true;
		}
		else if (step == STEP_DECLARATION) {
			// determine manuevers if needed per combatant
			
			return true;
		}
		else {
			throw "Unhandled step:" + step;
			
		}
		return false;
	}
	
	
	
	
	
	
	
	
}