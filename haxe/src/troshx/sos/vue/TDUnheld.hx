package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import haxevx.vuex.util.VHTMacros;
import js.html.InputElement;
import troshx.sos.core.Inventory;


/**
 * ...
 * @author Glidias
 */
class TDUnheld extends VComponent<TDUnheldData, TDUnheldProps>
{
	public static inline var NAME:String = "td-unheld";
	
	public function new() 
	{
		super();
	}
	
	override function Data():TDUnheldData {
		return {
			
			unheldLabels:Inventory.getUnheldLabelsArray()
		}
	}
	
	function shiftIndex(i:Int):Int {
		return (1 << i);
	}
	inline function emit(str:String):Void {
		_vEmit(str);
	}
	function onFocus(input:InputElement):Void {
		
	
		input.value = this.entry.unheldRemark;
		_vEmit('focus-in-row');
	}
	
	inline function setValidNameOfInput(inputElement:InputElement):Void {
		
		var tarName:String = StringTools.trim( inputElement.value);	
		
		this.entry.unheldRemark = tarName;
		
	}
	
	@:computed function get_unheld():Int {
		return this.entry.unheld;
	}
	
	@:watch function watch_unheld(newVal:Int, oldVal:Int):Void {
		//Vue.nextTick(refresh);
		refresh();
	}
	
	inline function refresh():Void {
		_vRefs.inputText.value = this.unheldLabel;
	}
	
	
	@:computed function get_unheldLabel():String {
		var pri:String = this.unheldLabels[this.entry.unheld];
		return pri + (pri!= "" && this.entry.unheldRemark != "" ? ": " : "") + this.entry.unheldRemark;
	}
	
	function onBlur(input:InputElement):Void {
		
		setValidNameOfInput(input);
		
		input.value = this.unheldLabel;
	
	
	}
	
	function requestCurWidgetButton(type:String, index:Int):Void {
		if (!this.showWidget) this.requestCurWidget(type, index);
		else this.requestCurWidget("", 0);
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	
}

typedef TDUnheldData = {
	
	var unheldLabels:Array<String>;
}

typedef TDUnheldProps = {

	@:prop({required:true}) var entry:ReadyAssign;
	
	@:prop({required:true}) var requestCurWidget:String->Int->Void;
	@:prop({required:true}) var index:Int;
	@:prop({required:true}) var showWidget:Bool;
}