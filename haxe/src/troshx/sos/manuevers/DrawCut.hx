package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.components.Bout.FightNode;
import troshx.core.ManueverSpec;
import troshx.sos.core.DamageType;
import troshx.sos.core.Manuever;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;
/**

 * ...
 * @author Glidias
 */
class DrawCut extends Manuever
{

	public function new() 
	{
		super("drawCut", "Deep Draw Cut");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON)._attackTypes(Manuever.ATTACK_TYPE_SWING);
	}
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var weapon:Weapon = spec.activeItem;
		return weapon.damageTypeS == DamageType.CUTTING && (weapon.meleeSpecial != null && weapon.meleeSpecial.draw > 0);
	}
	
}