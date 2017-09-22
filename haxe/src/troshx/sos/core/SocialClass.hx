package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class SocialClass 
{
	public var wealth:Int;
	public var money:Money;
	public var name:String;
	
	// ingame use only
	public var classIndex:Int;
	public var wealthIndex:Int;
	
	public function new(name:String, money:Money, wealth:Int):Void {
		this.name = name;
		this.money = money;
		this.wealth = wealth;
	}
	
}