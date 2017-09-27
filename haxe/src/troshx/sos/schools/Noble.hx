package troshx.sos.schools;

import troshx.sos.core.Money;
import troshx.sos.core.School;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Noble extends School
{

	public function new() 
	{
		super("Noble", 3, 5);
		costMoney = Money.create(15, 0, 0);
	}
	
	override public function getSchoolBonuses(charSheet:CharSheet):SchoolBonuses {
		return new NobleBonuses();
	}
	
}

class NobleBonuses extends SchoolBonuses {
	public function new() {
		super();
	}
	
	override public function getTags():Array<String> {
		return ["Superior Instruction", "Confidence"];
	}
}