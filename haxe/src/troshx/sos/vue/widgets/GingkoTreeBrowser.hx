package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.vue.treeview.TreeView;

/**
 * ...
 * @author Glidias
 */
class GingkoTreeBrowser extends VComponent<GingkoTreeData, GingkoTreeProps>
{

	public function new() 
	{
		super();
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>> {
		return {
			"treeview": new TreeView()
		}
	}
	
	override function Mounted():Void {
		
	}
	
	@:computed function get_compiledMarkdown():String {
		var val:String = this.curSelectedValue;
		return this.shouldShowMarkdown ? MARKED(val, { sanitize:true }) : "";
	}
	
	function customLabelHandler(contents:String):String {
		var lines = contents.split("\\n");
		var titleLineIndex :Int = 0;
		for (i in 0...lines.length) {
			if (StringTools.trim(lines[i]) != "") {
				break;
			}
			titleLineIndex = i;
		}
		contents = lines[titleLineIndex];
		return contents.length < 20 ? contents :  contents.substr(0, 20)+"...";
	}
	
	@:computed function get_shouldShowMarkdown():Bool {
		var val:String = this.curSelectedValue;
		//typeFilter == null ||
		return true;
	}
	
	function filterNodeHandler(node:GingkoNode):Bool {
		return node.content != "";
	}
	
	function getCustomIcon(node:GingkoNode):Dynamic {
		return false;
	}
	
	
	static var MARKED(get, null):String->?Dynamic->String;
	static inline function get_MARKED():String->?Dynamic->String {
		return untyped __js__("marked");
	}
	
	override function Template():String {
		return '
			<div class="gingko-tree">
				<treeview :value.sync="curSelectedValue"
					:model="model"
					class="form-control"
					labelname="content"
					valuename="content"
					children = "children" 
					:customLabelHandler = "customLabelHandler"
					:filterNodeHandler = "filterNodeHandler"
					:getCustomIcon = "getCustomIcon"
					/>
			</div>
		';
	}
	
	override function Data():GingkoTreeData 
	{
		return {
			curSelectedValue:null, // Binded to component.
			model: [
				
			]
		}
	}
	
}

typedef GingkoNode = {
	var content:String;
	@:optional var children:Array<GingkoNode>;
}

typedef GingkoTreeData = {
	var model:Array<GingkoNode>;
	var curSelectedValue:String;
	
}

typedef GingkoTreeProps = {
	@:prop({required:false}) var typeFilter:String;
}