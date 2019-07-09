package troshx.sos.manuevers;
import troshx.components.Bout;
import troshx.components.Bout.FightNode;
import troshx.core.ManueverSpec;
import troshx.sos.core.Manuever;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;
/**
 * ...
 * @author Glidias
 */

class NetItems {
	public static var STUFF:Array<String> = ["Net (Retiarius)"];
}

class NetFeint extends Manuever 
{
	public function new() 
	{
		super("netFeint", "Net Feint");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON | Manuever.REQ_STUFF, NetItems.STUFF)._costs(1, Manuever.DEFER_COST)._ranged(); 
	}
	
	
	override public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		var weapon:Weapon;
		var useRight:Bool = spec.usingLeftLimb;
		// Note todo: Master weapon might not tally with left handed characters?
		weapon = useRight ? node.charSheet.inventory.getMasterWeapon() : node.charSheet.inventory.getOffhandWeapon();
		return weapon != null && weapon.isMelee();
	}
}

class NetToss extends Manuever
{
	public function new()
	{
		super("netToss", "Net Toss");
		_types(Manuever.TYPE_OFFENSIVE)._requisite(Manuever.REQ_WEAPON | Manuever.REQ_STUFF)._ranged();
	}
}