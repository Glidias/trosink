package troshx.sos;
import troshx.components.Bout;
import troshx.components.FightState;
import troshx.core.BoutMessage;
import troshx.core.IBoutModel;
import troshx.core.ManueverStack;
import troshx.sos.BoutModel;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class BoutModel implements IBoutModel
{
	
	

	// bout model
	public var bout:Bout = new Bout();
	public function setBout(val:Bout):Void {
		bout = val;
	}
	
	// messaging model
	private var _messages:Array<BoutMessage>  = [];
	public function getMessages():Array<BoutMessage> {
		return _messages;
	}
	public function getMessagesCount():Int {
		return _messages.length;
	}
	public function clearMessages():Void {
		LibUtil.clearArray(_messages);
	}
	
	// manuevers within bout
	private var manueverStack:ManueverStack= new ManueverStack();
	private var defManueverStack:ManueverStack = new ManueverStack();
	
	public static function Get_something(state:Bout, getters:{bout:Bout, x:Float, y:Float, z:Float}, rootState:Bout, rootGetters) {
	
	}
	
	public function new() 
	{
		
	}
	
}