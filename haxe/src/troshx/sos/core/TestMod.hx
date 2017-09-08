package troshx.sos.core;
#if macro
import haxe.macro.Expr;
#end

/**
 * ...
 * @author Glidias
 */
class TestMod 
{

	static public macro function something():Expr
	{
		return macro {};
	}
	
}