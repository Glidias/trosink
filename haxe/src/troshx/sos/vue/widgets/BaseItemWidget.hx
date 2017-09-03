package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.core.Inventory.ReadyAssign;
import troshx.sos.core.Item;

/**
 * ...
 * @author Glidias
 */
class BaseItemWidget extends VComponent<NoneT, BaseItemWidgetProps>
{

	public function new() 
	{
		super();
	}
	
	override public function Template() {
		return '<div>'+Type.getClassName(Type.getClass(this)).split(".").pop()+'</div>';
	}
	
	@:computed function get_itemLabel():String {
		return this.item.label;
	}
	
}

typedef BaseItemWidgetProps =
{
	@:prop({required:false}) @:optional var entryIndex:Int;
	@:prop({required:true}) var item:Item;
	@:prop({required:true}) var entry:ReadyAssign;
	@:prop({required:false})  @:optional var parentAttr:Dynamic;
	
}