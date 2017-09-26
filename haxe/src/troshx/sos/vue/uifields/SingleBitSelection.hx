package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue.CreateElement;
import troshx.sos.vue.uifields.SingleSelection.SelectionProps;
import troshx.util.LibUtil;

/**
 * Higher order component for SingleSelection that links to external bitmask value to control option validities.
 * 
 * This is to be used under ArrayOfBits component as of now. Standalone not supported.
 * 
 * @author Glidias
 */
class SingleBitSelection extends VComponent<NoneT, SingleBitSelectionProps>
{
	public static inline var NAME:String = "SingleBitSelection";
	

	public function new() 
	{
		super();
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			"comp" => new SingleSelection()
		];
	}
	
	inline function shiftIndex(i:Int):Int {
		return (1 << i);
	}
	
	function isValidOptionAt(i:Int):Bool {
		var curBitmask = this.currentBitmask;
		
		var curValue:Int = bitList[index];
		
		return ((curBitmask&~curValue) & (1 << i)) == 0;
	}
	
	
	override function Template():String {
		return '<comp v-bind="$$attrs" :includeZeroOption="true" :labels="$$attrs.labels" :validateOptionFunc="isValidOptionAt" :valueAtIndexFunc="shiftIndex"></comp>';
	}
	
}

typedef SingleBitSelectionProps = {
//	>SelectionProps,
	@:prop({required:true}) var currentBitmask:Int; // current bitmask being clamped to bitList max process length
	@:prop({required:true}) var bitList:Array<Int>; // bit list values of each individual SingleSelection component (1 component = 1 bit)
	
	@:prop({required:true}) var index:Int;

}