package troshx.sos;
import troshx.components.Bout;
import troshx.components.FightState;
import troshx.core.ManueverStack;
import troshx.core.BoutMessage;
import troshx.core.IBoutController;
import troshx.util.DiceRoller;
import troshx.util.LibUtil;

/**
 * A localized bout controller class using Song of Swords rules
 * @author Glidias
 */
class BoutController implements IBoutController
{

	 var model:BoutModel;
	

	// Song of Swords implementation
	public static inline var STEP_ORIENTATION_OR_RESOLVE:Int = 0;
	public static inline var STEP_TARGET_SELECTION:Int = 1;
	public static inline var STEP_DECLARATION:Int = 2;
	public static inline var TOTAL_STEPS:Int = 3;
			
	public function waitForPlayer():FightState {
		return null;
	}
	
	
	
	public function new(model:BoutModel) 
	{
		this.model = model;
		DiceRoller;
		
		var namespaceVal:String = Math.random() > 0  ? Math.random() + "aaw" : "arawb";
		namespaceVal += "BBB";
		testInlineConstantOptimization2("HelloWorld", true, namespaceVal);
		
	}
	
	public inline function testInlineConstantOptimization(value:String, namespace:String = null):String {
		if (namespace != null) {
			//handleCurrentStep();
			return doThis(namespace + "specialthing");
		}
		else {
			//step();
			return doThis("specialthing");
		}
	}
	
		
	public inline function testInlineConstantOptimization2(value:String, usenameSpace:Bool=false, namespace:String = ""):String {
		if ( usenameSpace) {
			//handleCurrentStep();
			return doThis(namespace + "specialthing");
		}
		else {
			//step();
			return doThis("specialthing");
		}
	}
	
	public function doThis(str:String):String {
		return str;
	}
	
	public  function step():Void {
		model.bout.state.step(model.bout.state.s == (TOTAL_STEPS - 1));
		for (f in model.bout.combatants) {
			f.fight.matchScheduleWith(model.bout.state);
		}
	}
	
	public function handleCurrentStep():Bool
	{
		var step:Int = model.bout.state.s;
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