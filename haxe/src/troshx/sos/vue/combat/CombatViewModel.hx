package troshx.sos.vue.combat;
import troshx.sos.combat.BoutModel;

/**
 * Combat view hud model for client 
 * 
 * @author Glidias
 */
class CombatViewModel 
{
	public var focusedIndex:Int = -1;
	public var draggedCP:Int = 0;
	
	public var boutModel(default, null):BoutModel;
	
	public function new(boutModel:BoutModel=null) 
	{
		this.boutModel = boutModel!=null ? boutModel : new BoutModel();
	}
	
	
}