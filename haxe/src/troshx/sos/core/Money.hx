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
	
	public static inline var SP_TO_GP:Float = (1 / 20);
	public static inline var GP_TO_SP:Int = 20;
	
	public static inline var CP_TO_SP:Float = (1 / 12);
	public static inline var SP_TO_CP:Int = 12;
	
	public static inline var CP_TO_GP:Float = CP_TO_SP * SP_TO_GP;
	public static inline var GP_TO_CP:Int = GP_TO_SP * SP_TO_CP;
	
	
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
	
	public function matchWith(other:Money):Money {
		gp = other.gp;
		sp = other.sp;
		cp = other.cp;
		return this;
	}
	public function matchWithValues(g:Int, s:Int, c:Int):Money {
		gp = g;
		sp = s;
		cp = c;
		return this;
	}
	
	
	inline public function isNegative():Bool {
		return cp < 0;  // assumed subtractAgainst/subtractValues methods is used only
	}
	

	// make pretty in highest possible GP/SP/CP format
	public function changeToHighest():Money {  		
		var q:Int;
		if (cp > SP_TO_CP) {  // convert excess CP TO SP if possible
			q = Std.int( cp * CP_TO_SP );
			sp += q;
			cp -= q * SP_TO_CP;
		}
		
		if (sp > GP_TO_SP) {  // convert excess SP TO GP if possible
			q = Std.int( sp * SP_TO_GP );
			gp += q;
			sp -= q * GP_TO_SP;
		}
		return this;
	}
	
	
	// Displays labels of 3 gp/sp/cp components
	
	public function getLabel():String {
		return (gp != 0 ? gp+ " gp" : "") + (sp != 0 ? (gp!=0? " " : "") +sp + " sp" : "") + (cp != 0 ? (sp!=0 || gp!=0 ? " " : "") +cp + " cp" : "");
	}
	
	public static function getLabelWith(gp:Int, sp:Int, cp:Int):String {
		return (gp != 0 ? gp+ " gp" : "") + (sp != 0 ? (gp!=0?" ":"") +sp + " sp" : "") + (cp != 0 ? (sp!=0 || gp!=0 ? " " : "") + cp + " cp" : "");
	}
	
	// CALCULATOR METHODS
	public static var ZERO:Money = new Money();
	
	// use this cache ONLY if you are ending the resolving calculated value that isn't required to be persistant
	static var TEMP:Money = new Money();
	public inline function tempCalc():Money {
		return TEMP.matchWith(this);
	}
	
	public function resetTo(money:Money):Money {
		money.matchWith(this);
		return money;
	}
	
	public function addValues(g:Int, s:Int, c:Int):Money {
		gp += g;
		sp += s;
		cp += c;
		return this;
	}
	
	public inline function getCPValue():Int {
		return gp * GP_TO_CP + sp * SP_TO_CP + cp;
	}
	
	public inline function getGoldValue():Float {
		return gp + sp * SP_TO_GP + cp * CP_TO_GP;
	}
	
	public inline function getSilverValue():Float {
		return gp*GP_TO_SP + sp  + cp * CP_TO_SP;
	}
	public function convertAllToCP():Money {
		var c = getCPValue();
		gp = 0;
		sp = 0;
		cp = c;
		return this;
	}
	
	public function addCP(c:Int):Money {
		cp += c;
		return this;
	}
	public function subtractCP(c:Int):Money {
		cp -= c;
		naiveChangeNegativeCP();
		return this;
	}
	
	public function addAgainst(against:Money):Money {
		gp += against.gp;
		sp += against.sp;
		cp += against.cp;
		return this;
	}
	
	public function subtractValues(g:Int, s:Int, c:Int):Money {
		gp -= g;
		if (gp < 0) {
			sp += gp * GP_TO_SP; 
			gp = 0;
		}
		
		sp -= s;
		if (sp < 0) {
			cp += sp * SP_TO_CP;
			sp = 0;
		}
		
		cp -= c;
		naiveChangeNegativeCP();
		return this;
	}
	
	  // Note: "idiotic" naive approach: convert entire bulk SP/GP to copper pieces if CP is negative.
	inline function naiveChangeNegativeCP():Void {
		if (cp < 0) {
			
			if (sp > 0) {  // naive change everything to CP (call change to changeToHighest() to make pretty)
				cp += sp * SP_TO_CP;
				sp = 0;
			}
			if (cp < 0 && gp > 0) {  // naive change everything to CP ( call changeToHighest() to make pretty)
				cp += gp * GP_TO_CP;
				gp = 0;
			}
		}
	}
	
	public function subtractAgainst(against:Money):Money {
		gp -= against.gp;
		if (gp < 0) {
			sp += gp * GP_TO_SP; 
			gp = 0;
		}
		sp -= against.sp;
		if (sp < 0) {
			cp += sp * SP_TO_CP;
			sp = 0;
		}
		cp -= against.cp;
		naiveChangeNegativeCP();
		
		return this;
	}

	
	
	
	
	
}