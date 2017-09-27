package troshx.sos.schools;

import troshx.sos.core.Money;
import troshx.sos.core.School;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class TraditionalFencer extends School
{

	public function new() 
	{
		super("Traditional Fencer", 4, 5);
		costMoney = Money.create(10, 0, 0);
	}
	
	override public function getSchoolBonuses(charSheet:CharSheet):SchoolBonuses {
		return new TraditionalFencerBonuses();
	}
	
}

class TraditionalFencerBonuses extends SchoolBonuses {
	
	
	public function new() {
		super();
	}
	
	override public function getTags():Array<String> {
		return ["Extreme Repetition", "Centered"];
	}
}