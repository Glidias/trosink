package troshx.sos.core;
import troshx.sos.core.Crossbow.SpanningTool;

/**
 * ...
 * @author Glidias
 */
class Crossbow
{

	public var span:Int = 0;
	@:flagInstances(SpanningTool) public var spanningTools:Int = 0;
	// support custom spanning tools?
	
	
	public function getSpanningToolsStrArr():Array<String> {
		var arr:Array<String> = Item.getLabelsOfArray(SpanningTool.getDefaultList(), span);
		//if (spanningToolsCustom != null) arr = spanningToolsCustom.concat(arr);
		return arr;
	}
	
	public function new() 
	{
		
	}
	
}

class SpanningTool extends Item
{
	public var spanBonus:Int;
	public var storeSpan:Bool;
	
	public function new(name:String = "", spanBonus:Int = 0, storeSpan:Bool = false, id:String="") {
		super(id, name);
		this.spanBonus = spanBonus;
		this.storeSpan = storeSpan;
	}
	
	public static inline var HAND:Int = 0;
	public static inline var LEVER:Int = 1;
	public static inline var SCREW:Int = 2;
	public static inline var STIRRUP:Int = 3;
	public static inline var WINDLASS:Int = 4;
	public static inline var WINCH:Int = 5;
	public static inline var CRANK:Int = 6;
	
	static var LIST:Array<SpanningTool>;  
	public static function getDefaultList():Array<SpanningTool> {
		return LIST != null ? LIST : (LIST=getNewDefaultList());
	}
	public static function getNewDefaultList():Array<SpanningTool> {
		var a:Array<SpanningTool> = [];
		a[HAND] = new SpanningTool("Hand", 0, false, "").setWeightCost(0, 0, Item.CP);
		a[LEVER] = new SpanningTool("Lever", 2, false, "").setWeightCost(0, 5, Item.CP);
		a[SCREW] = new SpanningTool("Screw", 0, true, "").setWeightCost(0, 1, Item.SP);
		a[STIRRUP] = new SpanningTool("Stirrup", 5, false, "").setWeightCost(1, 5, Item.CP);
		a[WINDLASS] = new SpanningTool("Windlass", 4, true, "").setWeightCost(1, 2, Item.SP);
		a[WINCH] = new SpanningTool("Winch", 6, true, "").setWeightCost(2, 3, Item.SP);
		a[CRANK] = new SpanningTool("Crank", 3, true, "").setWeightCost(0, 1, Item.SP);
		return a;
	}
	
	
	
	
	
}