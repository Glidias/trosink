package troshx.sos.schools;

import troshx.sos.core.School;
import troshx.sos.sheets.CharSheet;

/**
 * ...
 * @author Glidias
 */
class Scrapper extends School
{

	public function new() 
	{
		super("Scrapper", 4, 0);
	}
	
	override public function getSchoolBonuses(charSheet:CharSheet):SchoolBonuses {
		return new ScrapperBonuses();
	}
	
}

class ScrapperBonuses extends SchoolBonuses {
	public function new() {
		super();
	}
	
	override public function getTags():Array<String> {
		return ["Dirty Trick", "Grapple"];
	}
}