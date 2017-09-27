package troshx.sos.schools;
import troshx.sos.core.Money;
import troshx.sos.sheets.CharSheet;
import troshx.sos.core.School;

/**
 * ...
 * @author Glidias
 */
class Officer extends School
{

	public function new() 
	{
		super("Officer", 4, 3);
		costMoney = Money.create(5, 0, 0);
	}
	
	override public function getSchoolBonuses(charSheet:CharSheet):SchoolBonuses {
		return new OfficerBonuses();
	}
	
}

class OfficerBonuses extends SchoolBonuses {
	
	public static inline var PROTECT_THE_BANNER:String = "Protect the Banner!";
	public static inline var RIDE_TO_RUIN:String = "Ride to Ruin!";
	
	@:ui({type:"SingleSelectionStr", label:"Choose Benefit #2", labels:[PROTECT_THE_BANNER, RIDE_TO_RUIN] }) public var choice2:String = PROTECT_THE_BANNER;
	
	public function new() {
		super();
		
	}
	
	override public function getTags():Array<String> {
		return ["By Example!", choice2];
	}
	

}