package troshx.sos.core;

/**
 * ...
 * @author Glidias
 */
class Money 
{
	@:ui public var gp:Int = 0;	// Pounds
	@:ui public var sp:Int = 0;	// Shilling
	@:ui public var cp:Int = 0;	// Pence
	
	public function new() 
	{
		
	}
	
	public static function create(gp:Int, sp:Int, cp:Int):Money {
		var m = new Money();
		m.gp = gp;
		m.sp = sp;
		m.cp = cp;
		return m;
	}
	
	public inline function matchWith(other:Money):Void {
		gp = other.gp;
		sp = other.sp;
		cp = other.cp;
	}
	
	public inline function getLabel():String {
		return (gp != 0 ? gp+ " gp" : "") + (sp != 0 ? sp + " sp" : "") + (cp != 0 ? cp + " cp" : "");
	}
	
	public static inline function getLabelWith(gp:Int, sp:Int, cp:Int):String {
		return (gp != 0 ? gp+ " gp" : "") + (sp != 0 ? sp + " sp" : "") + (cp != 0 ? cp + " cp" : "");
	}
	
	// CALCULATOR METHODS
	
	static var TEMP:Money = new Money();
	
	public function tempCalc():Money {
		var calc = TEMP;
		calc.matchWith(this);
		return calc;
	}
	
	public function resetTo(money:Money):Money {
		money.matchWith(this);
		return money;
	}
	
	public function addValues(gp:Int, sp:Int, cp:Int):Money {
		this.gp += gp;
		this.sp += sp;
		this.cp += cp;
		return this;
	}
	public function subtractValues(gp:Int, sp:Int, cp:Int):Money {
		this.gp -= gp;
		this.sp -= sp;
		this.cp -= cp;
		return this;
	}

	
	/*	
	public function changeHighest():Void {
		
	}
	*/
	
	
	
	
	
}