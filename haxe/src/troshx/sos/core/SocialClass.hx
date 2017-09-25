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
	
	// as of character generation
	public var classIndex:Int = 0;
	public var wealthIndex:Int = 0;
	
	public function new(name:String, money:Money, wealth:Int):Void {
		this.name = name;
		this.money = money;
		this.wealth = wealth;
	}
	
}