package troshx.sos.chargen;

/**
 * ...
 * @author Glidias
 */
typedef SkillPacket = {
	var name:String;
	var values:Dynamic<Int>;
	var qty:Int;
	@:optional var history:Array<Dynamic<String>>;
	@:optional var fields:Array<String>;
}