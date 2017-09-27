package troshx.sos.schools;
import troshx.sos.core.School;

/**
 * ...
 * @author Glidias
 */
class Schools
{
	static var LIST:Array<School>;
	public static function getList():Array<School> {
		return LIST != null ? LIST : (LIST = getNewList());
	}
	
	public static function getNewList():Array<School> {
		return  [
			new Scrapper(),
			new Soldier(),
			new Officer(),
			new Noble(),
			new TraditionalFencer(),
			new UnorthodoxFencer(),
			new EsotericSchool()
		];
	
	}

	
}

