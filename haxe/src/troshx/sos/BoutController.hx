package troshx.sos;
import troshx.components.Bout;
import troshx.components.FightState;
import troshx.components.ManueverStack;

/**
 * A localized bout controller/manager class
 * @author Glidias
 */
class BoutController
{
	public static inline var STEP_ORIENTATION_OR_RESOLVE:Int = 0;
	public static inline var STEP_TARGET_SELECTION:Int = 1;
	public static inline var STEP_DECLARATION:Int = 2;
	public static inline var TOTAL_STEPS:Int = 3;
	
	private var bout:Bout;
		
	private var manueverStack:ManueverStack= new ManueverStack();
	private var defManueverStack:ManueverStack = new ManueverStack();
	
	public function new() 
	{
		
	}

	
	public function step():Void {
		bout.state.step(bout.state.s == (TOTAL_STEPS - 1));
		
	}
	
	public function updateFightState(fightState:FightState):Void {
		
		fightState.s = bout.state.s;
		fightState.e = bout.state.e;
		
		
		
	}
	
	
	
	
	
	
	
}