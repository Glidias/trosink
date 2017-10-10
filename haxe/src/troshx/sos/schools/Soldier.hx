package troshx.sos.schools;
import troshx.sos.core.Modifier;
import troshx.sos.core.Modifier.StaticModifier;
import troshx.sos.sheets.CharSheet;
import troshx.sos.core.School;

/**
 * ...
 * @author Glidias
 */
class Soldier extends School
{

	public function new() 
	{
		super("Soldier", 10, 1);
		staticModifiers = StaticModifier.create(Modifier.STARTING_GRIT, 2);
	}
	
	override public function getSchoolBonuses(charSheet:CharSheet):SchoolBonuses {
		return new SoldierBonuses();
	}
	
}

class SoldierBonuses extends SchoolBonuses {
	public function new() {
		super();
	}
	
	override public function getTags():Array<String> {
		return ["Discipline", "Warrior's Grit"];
	}
	

}