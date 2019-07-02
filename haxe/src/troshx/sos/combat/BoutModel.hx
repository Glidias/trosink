package troshx.sos.combat;
import troshx.components.Bout;
import troshx.core.BoutMessage;
import troshx.sos.sheets.CharSheet;
import troshx.core.IBoutModel;
import troshx.core.ManueverStack;
import troshx.util.LibUtil;

/**
 * Bout game model. Includes logging of messages support as well.
 * Suitable for both client and server-side use.
 * 
 * @author Glidias
 */
class BoutModel implements IBoutModel<CharSheet>
{
	
	// bout model
	public var bout:Bout<CharSheet> = null;
	public function setBout(val:Bout<CharSheet>):Void {
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
	
	// listed manuevers within bout
	private var manueverStack:ManueverStack= new ManueverStack();
	//private var defManueverStack:ManueverStack = new ManueverStack();
	
	public function new() 
	{
		
	}
	
}