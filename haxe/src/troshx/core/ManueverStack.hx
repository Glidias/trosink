package troshx.core;
import haxe.ds.ArraySort;
import troshx.components.FightState.ManueverDeclare;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class ManueverStack
{

	public function new() 
	{
		
	}
	
	public var stack:Array<ManueverDeclare> = [];
	//public var stackIndex:int = 0;
	
	public inline function reset():Void {
		//stackIndex = 0;
		LibUtil.clearArray(stack);
	}
	
	public inline function reverseOrder():Void {
		 stack.reverse();
		//var referArr:Array<ManueverDeclare> = stack.reverse();
		//sortInto(referArr);
	}
	
	public inline function pushManuever(manueverObj:ManueverDeclare):Void {
		//stack[stackIndex++] = manueverObj;
		stack.push( manueverObj );
		
	}
	
	public inline function sortOnLowestToHighestReflex():Void {
		ArraySort.sort(stack, function(a:ManueverDeclare, b:ManueverDeclare) { return a.reflexScore != b.reflexScore  ? a.reflexScore > b.reflexScore ? 1 : -1 : 0;  } );
	//	stack.sortOn(property);
		
	}
	
	public inline function sortOnHighestToLowestReflex(property:String):Void {
		ArraySort.sort(stack, function(a:ManueverDeclare, b:ManueverDeclare) { return a.reflexScore != b.reflexScore  ? a.reflexScore > b.reflexScore ? -1 : 1 : 0;  } );
		//	stack.sortOn(property, Array.DESCENDING);
		
	}
	
	/*
	private function sortInto(referArr:Array<ManueverDeclare>):Void {

		for (i in 0...referArr.length) {
			stack[i] = referArr[i];
		}
	}
	*/
	
}