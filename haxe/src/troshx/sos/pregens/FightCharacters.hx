package troshx.sos.pregens;
import haxevx.vuex.util.VHTMacros;
import troshx.core.CharSave;
import troshx.core.CharSheet;

/**
 * ...
 * @author Glidias
 */
class FightCharacters 
{
	var pool:Array<CharSave>;
	
	public function new() {
		pool = get();
	}
	
	public static function get():Array<CharSave> {
		return [
			new CharSave("Anglian Huscarl", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/anglian-huscarl-grizzled", "txt") ),
			
			new CharSave("Retiarius", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/retiarius", "txt") ),
			new CharSave("Secutor", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/secutor", "txt") ),
			new CharSave("Hoplomachus", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/hoplomachus", "txt") ),
			new CharSave("Crupellarius", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/crupellarius", "txt") ),
			
			new CharSave("Street Thug", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/street-thug", "txt") ),
			//new CharSave("Street Berserker", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/street-thug", "txt") ),
			new CharSave("Street Thug Boss", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/street-thug-boss", "txt") ),
		];
	}
	
}