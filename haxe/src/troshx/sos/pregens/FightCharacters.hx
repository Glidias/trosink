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
			new CharSave("Commoner", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/commoner", "txt"), "0/8 S CP:5" ),
		
			new CharSave("Street Thug", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/street-thug", "txt"), "0.5/10 S CP:9" ),
			new CharSave("Street Thug Boss", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/street-thug-boss", "txt"), "0.5/10 S CP:12*"),
			new CharSave("Street Berserker", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/street-berserker", "txt"), "0.5/10 S CP:15*" ),
			
			
			new CharSave("Retiarius", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/retiarius", "txt"), "1/8 L CP:17" ),
			new CharSave("Dimachaerus-Light", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/dima-light", "txt"), "3/8 S CP:16" ),
			new CharSave("Dimachaerus-Medium", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/dima-med", "txt"), "6.5/10 S CP:15" ),
			
			new CharSave("Thracian", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/thracian", "txt"), "3/8 S CP:16" ),
			new CharSave("Provocator", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/provocator", "txt"), "8.5/11 S CP:15" ),
			new CharSave("Hoplomachus", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/hoplomachus", "txt"), "8.5/12 VL CP:14" ),
			
			new CharSave("Murmillo", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/murmillo", "txt"), "8.5/13 S CP:14" ),
			new CharSave("Secutor", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/secutor", "txt"), "8.5/13 VL CP:14" ),
			
			new CharSave("Anglian Huscarl", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/anglian-huscarl-grizzled", "txt"), "9.5/12 M CP:14*" ),
			
			new CharSave("Crupellarius", VHTMacros.getHTMLStringFromFile("src/troshx/sos/pregens/characters/crupellarius", "txt"), "19/14 S CP:12-" ),
		];
	}
	
}