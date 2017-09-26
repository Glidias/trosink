package troshx.sos.schools;

import troshx.sos.core.Money;
import troshx.sos.core.School;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class UnorthodoxFencer extends School
{

	public function new() 
	{
		super("Unorthodox Fencer", 6, 5);
		costMoney = Money.create(5, 0, 0);
	}
	
	override public function getSchoolBonuses(charSheet:CharSheet):SchoolBonuses {
		return new UnorthodoxFencerBonuses();
	}
	
}

class UnorthodoxFencerBonuses extends SchoolBonuses {
	public function new() {
		super();
	}
	
	override public function getTags():Array<String> {
		return ["The Meisterhau", "Treachery"];
	}
}