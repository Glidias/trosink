package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Armor extends Item
{

	public var AVC:Int = 0;
	public var AVP:Int = 0;
	public var AVB:Int = 0;
	
	public var coverage:Dynamic<HitLocation> = {};
	public var tags:String = "";
	
	public function new() 
	{
		super();
	}
	
	override public function getTypeLabel():String {
		return "Armor";
	}
	
}