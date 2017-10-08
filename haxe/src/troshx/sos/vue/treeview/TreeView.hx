package troshx.sos.vue.treeview;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import troshx.util.LibUtil;

/**
 * @author Alejandro Mostajo <http://about.me/amostajo>
 * @copyright 10Quality <http://www.10quality.com>
 * @license MIT
 * @version 1.0.2
 * 
 * Port to HaxeVx for >=Vue 2.3.0, with some additional props api to support custom icons/classnames per node.
 * Some key changes/improvements to get it to work proper and better with Vue 2.3.0:
 * - Replace component's "class" prop to "classname".
 * - $emit("update:value", value) instead  and  use bubbleValueHandler(value) handler method to deal with the single prop.sync on root level
 * - Replaced off some other old obsolete vue-1 related stuff (triple curly brace, etc.)
 * - v-for uses (node,index), instead of old outdated (index,node) syntax order.
 * - getNodeClass(node) method for :class to also support custom classname per node
 * 
 * Better UX:
 * - Only toggle open/close if item is already selected, or currently closed.
 * @author Glidias
 * 
 */
class TreeView extends VComponent<NoneT, TreeViewProps> 
{
	public static var UID_COUNT:Int = 0;
		
	// ICON STATES
	public static inline var ICON_CLOSED:Int = 0;
	public static inline var ICON_OPENED:Int = 1;
	public static inline var ICON_LEAF:Int = 2;
	
	public static inline var EVENT_CLICK:String = 'treeview_click';
	

	public function new() 
	{
		super();
		untyped this.name = "treeview";
	}
	
	
	function getNodeClass(node:Dynamic, index:Int):Dynamic {
		var dyn:Dynamic =  {'active': isSelected(index)};
		if ( getCustomClass != null ) {
			var clsName:Dynamic = getCustomClass(this.model[index]);
			if (clsName) LibUtil.setField(dyn, clsName, true );
		}
		return dyn;
	}
	
	function select(index:Int, value:Dynamic):Void
	{
		// Unselect from current level, children and parents
		if (!this.model[index].isOpened || isSelected(index) )  this.toggleOpen(index);
		
		_vEmit("update:value", value);
		
		// Call to event.
		_vEmit(EVENT_CLICK, this.model[index], this.parentNode );
	}
	
	function toggleOpen(index:Int):Void {
		  if (!this.validNodeHandler( LibUtil.field(this.model[index], this.children), this.model[index] ))
			return;
		// Init
		if (this.model[index].isOpened == null)
			_vSet(model[index], "isOpened", this.hasSelectedChild(index));
		// General
		_vSet(model[index], "isOpened", !this.model[index].isOpened);
	}
	
	function areValidNodes(nodes:Array<Dynamic>, node:Dynamic):Bool
	{
		return nodes != null && Std.is(nodes, Array) && nodes.length > 0;
	}
	
	@:computed function get_validNodeHandler():Array<Dynamic>->Dynamic->Bool {
		return areValidNodesHandler != null ? areValidNodesHandler : areValidNodes;
	}
	
	function hasSelected():Bool
	{
		// Check children
		for (i in 0...model.length) {
			if (this.isSelected(i) || this.hasSelectedChild(i))
				return true;
		}
		return false;
	}
	
	
	function hasSelectedChild(index:Int):Bool 
	{
		
		for (i in 0..._vChildren.length) {
			var r:Dynamic = _vChildren[i];
			if ( r.parent  == index &&  r.hasSelected() ) {
				return true;
			}
		}
		return false;
	}
	
	inline function isSelected(index:Int):Bool
	{
		return this.value!=null && LibUtil.field(this.model[index], this.valuename) == this.value;
	}
	
	function isOpened(index:Int):Bool
	{
		return (this.model[index].isOpened != null && this.model[index].isOpened)
			|| this.hasSelectedChild(index);
	}
	
	
	function bubbleValueHandler(value:Dynamic):Void {
		_vEmit("update:value", value);
	}
	function bubbleClickHandler(node:Dynamic, parentNode:Dynamic):Void {
		_vEmit(EVENT_CLICK, node, parentNode);
	}
	
	override function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}

}

typedef TreeViewProps = {
	

	
	@:prop({required:false}) @:optional var value:Dynamic; //value: [String, Number]  //selected value
	
	@:prop({required:true}) var model:Array<Dynamic>;
	@:prop({required:false, 'default':'nodes'}) @:optional var children:String;
	@:prop({required:false, 'default':'label'}) @:optional var labelname:String;
	@:prop({required:false, 'default':'value'}) @:optional var valuename:String;
	
	@:prop({required:false}) @:optional var classname:String;
	
	// extra API features (new props)
	
	/**
	 * Optional custom class name getter handler(node) for each tree node.
	 * @return (String) a specific node's class name string (if any). 
	 * @return FALSE, zero, or empty string to exclude custom class name.
	 */
	@:prop({required:false}) @:optional var getCustomClass:Dynamic->Dynamic;
	
	/**
	 * Optional custom icon getter handler(node, ICON_STATE) for each tree node.
	 * @return (String) string, empty or otherwise filled with textual content, to include any inner text content for icon span.custom-icon.
	 * @return FALSE to still use default icon.
	 */
	@:prop({required:false}) @:optional var getCustomIcon:Dynamic->Int->Dynamic;  
	
	/**
	 * Optional custom node filtering for each tree node. (2nd parameter is parent node reference)
	 * @return (Bool) true or false to determine if node is to be included in (show up in list) or not
	 */
	@:prop({required:false}) @:optional var filterNodeHandler:Dynamic->Dynamic->Bool;
	
	
	/**
	 * CUstom node chiildren validation overwrrite.
	 */
	@:prop({required:false}) @:optional var areValidNodesHandler:Array<Dynamic>->Dynamic->Bool;
	
	/**
	 * Optional custom label filtering for given label result from node[labelname]
	 * @return (String) filtered label result
	 */
	@:prop({required:false}) @:optional var customLabelHandler:String->String;
	
	
	// ************************
	// for internal use only
	@:prop({required:false}) @:optional var parent:Int;
	@:prop({required:false}) @:optional var parentNode:Dynamic;
	
	
	
}