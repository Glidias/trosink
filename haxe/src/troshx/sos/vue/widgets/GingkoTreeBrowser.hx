package troshx.sos.vue.widgets;
import haxe.Http;
import haxe.Json;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import js.Browser;
import js.html.ButtonElement;
import js.html.InputElement;
import troshx.sos.vue.treeview.TreeView;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class GingkoTreeBrowser extends VComponent<GingkoTreeData, GingkoTreeProps>
{
	public static inline var EVENT_OPEN:String = "open";
	public static inline var EVENT_LOADED_DOMAIN:String = "loaded-domain";

	public function new() 
	{
		super();
	}
	
	static var SERIALIZE_PREFIXES:Dynamic<GingkoDataType> = {
		"troshx.sos.core.Inventory": {
			name: "Inventory",
			icon: "❐"
		}
	};
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>> {
		return {
			"treeview": new TreeView()
		}
	}
	
	override function Mounted():Void {
		
		
		loadDomain(defaultDomain);
	}
	
	function loadDomainClick():Void {
		loadDomain(requestedDomain);
	}
	
	function loadDomain(domainId:String):Void {
		requestEnteredDomain = domainId;
		isLoading = true;
		loadedDomain = "";
		
		var http:Http = new Http("https://effuse-church.000webhostapp.com/curlgink.php").setParameter("id", domainId);
		http.onData = onDataReceived;
		http.onError = onErrorLoad;
		http.request();
	}
	
	@:computed function get_requestedDomain():String {
		var dd = defaultDomain;
		return requestEnteredDomain != "" ? requestEnteredDomain : dd;
		
	}
	
	function onDataReceived(data:String):Void {
		isLoading = false;
	
		var gingkoData:Array<GingkoNode>;
		
		try{ 
			gingkoData = Json.parse(data);
		}
		catch (e:Dynamic) {
			Browser.alert("Sorry, failed to parse domain!");
			return;
		}
		
		loadedDomain = requestedDomain;
		for (i in 0...gingkoData.length) {
			cleanNode(gingkoData[i]);
		}
		this.model = gingkoData;
		_vEmit(EVENT_LOADED_DOMAIN, loadedDomain);
	}
	
	function nodeGotContent(node:GingkoNode):Bool {
		return node.content != "";
	}
	
	function cleanNode(node:GingkoNode):Void {
		
		if (node.children == null) return;
		if ( node.children.length > 0) {
			node.children = cleanNodes(node.children);
		}
		for (i in 0... node.children.length) {
			node.children[i].key = "_"+(valueKeyCounter++);
			cleanNode(node.children[i]);
		}
	}
	

	
	inline function cleanNodes(nodes:Array<GingkoNode>):Array<GingkoNode> {
		return nodes.filter(nodeGotContent);
	}
	
	inline function getFirstChild(arr:Array<GingkoNode>):GingkoNode {
		/*
		for (i in 0...arr.length) {
			if (arr[i].content != "") return arr[i];
		}
		*/
		return arr[0];
	}
	
	function onErrorLoad(data:String):Void {
		isLoading = false;
		Browser.alert("Failed to load domain!");
	}
	
	@:computed function get_curIsHeadingNode():Bool {
		return this.curSelectedNode != null && this.curSelectedNode.children != null && this.curSelectedNode.children.length != 0 && isSerializable( getFirstChild(this.curSelectedNode.children));
	}
	
	@:computed function get_curLandingNode():GingkoNode {
		return this.curSelectedNode != null ? this.curIsHeadingNode ?  getFirstChild(this.curSelectedNode.children) :  this.curSelectedNode : null;
	}
	
	@:computed function get_curLandingValue():String {
		return this.curLandingNode.content;
	}
	
	
	@:computed function get_curSerializable():Bool {
		var val:String = this.curSelectedNode != null ? this.curSelectedNode.content : null;
		return val!=null && isSerializableValue(val);
	}
	
	@:computed function get_curLandingSerializable():Bool {
		var val:GingkoNode = this.curLandingNode;
		return val!=null && isSerializable(this.curLandingNode);
	}
	
	
	@:computed function get_compiledMarkdown():String {
		var val:String = this.curSelectedNode != null ? this.curSelectedNode.content : null;
		return  val != null && !curSerializable ? MARKED(val, { sanitize:true }) : "";
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
		contents = StringTools.trim(contents);
		contents = new EReg("^#*", "").replace(contents, "");
		return contents.length < maxLabelLength ? contents :  contents.substr(0, maxLabelLength)+"...";
	}

	
	function onTreeViewClick(node:GingkoNode, parentNode:GingkoNode):Void {
		this.curSelectedNode = node;
		this.curSelectedParentNode = parentNode;
		
	}
	
	function isSerializable(node:GingkoNode):Bool {
		return new EReg("^cy[0-9]*:", "").match(node.content);
	}
	function isSerializableValue(content:String):Bool {
		return new EReg("^cy[0-9]*:", "").match(content);
	}
	
	function onOpenClick():Void {
		var curLandingNode = this.curLandingNode;
		if (curLandingNode == null) return;
		var targNodeNamer:GingkoNode = curLandingNode != this.curSelectedNode ? this.curSelectedNode : this.curSelectedParentNode;
		_vEmit(EVENT_OPEN, curLandingNode.content,  customLabelHandler(targNodeNamer.content), disableOpenButton );
	}
	
	
	function filterNodeHandler(node:GingkoNode, parentNode:GingkoNode):Bool {
		// 
		if (availableTypes == null) return true;
		
		var chkSerializable = isSerializable(node);
		if (chkSerializable && availableTypes != null && !LibUtil.field(availableTypes, getSerializeContentType(node.content) ) ) {
			return false;
		}
		if (node.children == null || node.children.length > 1) return true;
		var c = getFirstChild(node.children);
		chkSerializable = isSerializable(c);
	
		if (chkSerializable && availableTypes != null && !LibUtil.field(availableTypes, getSerializeContentType(c.content) ) ) {
			return false;
		}
		return return true;
	}
	
	function getCustomIcon(node:GingkoNode):Dynamic {
		return (node.children == null || node.children.length == 0) && isSerializable(node) ? getCustomIconForContent(node.content) : node.children != null && node.children.length == 1 && isSerializable(node.children[0]) ? getCustomIconForContent(node.children[0].content)  : false;// : false;
	}
	
	function areValidNodesHandler(nodes:Array<GingkoNode>, parentNode:GingkoNode):Bool {
		return nodes != null && Std.is(nodes, Array) && (nodes.length > 1 || (nodes.length == 1 && !isSerializable(nodes[0]) ) ) && !isSerializable(parentNode);
		
	}
	
	function disableOpenButton():Void {
		var button:ButtonElement = _vRefs.openButton;
		button.disabled = true;
		
	}
	
	function getCustomIconForContent(content:String):Dynamic {
		var colonIndex =  content.indexOf(":");
		var len:Int = Std.parseInt( content.substr(2, colonIndex) );
	
		var sp = SERIALIZE_PREFIXES;
		var s =LibUtil.field(sp,  content.substr(colonIndex + 1, len));
		return s != null ? s.icon : false;
	}
	
	@:computed function get_curSelectedType():String {
		if (curLandingNode == null) return "";
		
		var content:String =  curLandingNode.content;
		var colonIndex = content.indexOf(":");
		var len:Int = Std.parseInt( content.substr(2, colonIndex) );
	
		var sp = SERIALIZE_PREFIXES;
		var s =LibUtil.field(sp,  content.substr(colonIndex + 1, len));
		return s != null ? s.name : "";
	}
	
	function getSerializeContentType(content:String):String {
		var colonIndex = content.indexOf(":");
		var len:Int = Std.parseInt( content.substr(2, colonIndex) );
	

		return content.substr(colonIndex + 1, len);
	}
	
	function onInputDomain(inputField:InputElement):Void {
		if (inputField.value == "") return;
		this.requestEnteredDomain = inputField.value;
	}
	
	@:computed function get_treeviewStyle():Dynamic {
		return isLoading ? {'pointer-events':'none', 'opacity':0.4}: {};

	}
	
	function onInputDomainBlur(inputField:InputElement):Void {
		
	}
	
	static var MARKED(get, null):String->?Dynamic->String;
	static inline function get_MARKED():String->?Dynamic->String {
		return untyped __js__("marked");
	}
	
	override function Template():String {
		return '
			<div class="gingko-tree">
				<div><span v-show="loadedDomain!=\'\'" ><input type="text" style="display:inline-block;width:auto;max-width:80px;background-color:#f3f5f6" readonly :value="loadedDomain"></input> <i>loaded.</i></span><span style="margin-left:30px;display:inline-block"><input type="text" :disabled="isLoading" :value="requestedDomain" v-on:blur="onInputDomainBlur($$event.target)" @input="onInputDomain($$event.target)"></input><button v-on:click="loadDomainClick" :disabled="isLoading">Load Domain ID</button></span></div>
				<treeview :value.sync="curSelectedValue" v-on:treeview_click="onTreeViewClick" :disabled="isLoading" 
					:style="treeviewStyle"
					
					:model="model"
					class="form-control"
					labelname="content"
					valuename="key"
					children = "children" 
					:customLabelHandler = "customLabelHandler"
					:filterNodeHandler = "filterNodeHandler"
					:getCustomIcon = "getCustomIcon"
					
					:areValidNodesHandler = "areValidNodesHandler"
				/>
				<div class="markdown-view">
					<div v-html="compiledMarkdown" v-show="compiledMarkdown"></div>
					<div v-show="curLandingSerializable"><button v-on:click="onOpenClick" ref="openButton" :disabled="locked">Open {{curSelectedType}}</button></div>
				</div>
			</div>
			
		';
	}
	
	
	
	override function Data():GingkoTreeData 
	{
		return {
			requestEnteredDomain:"",
			curSelectedValue:null, // Binded to component.
			curSelectedNode:null,
			loadedDomain:"",
			isLoading:false,
			curSelectedParentNode:null,
			valueKeyCounter:0,
			model: [
				
			]
		}
	}
	
}

typedef GingkoNode = {
	var content:String;
	@:optional var key:String;
	@:optional var children:Array<GingkoNode>;
}

typedef GingkoTreeData = {
	var model:Array<GingkoNode>;
	var curSelectedValue:String;
	var curSelectedNode:GingkoNode;
	var curSelectedParentNode:GingkoNode;
	var requestEnteredDomain:String;	
	var loadedDomain:String;
	var isLoading:Bool;
	var valueKeyCounter:Int;
	
}


typedef GingkoDataType = {
	var name:String;
	var icon:String;
}
typedef GingkoTreeProps = {
	@:prop({required:false, 'default':32})  @:optional var maxLabelLength:Int;
	@:prop({required:false, 'default':"sos-weapons-and-armour"})  @:optional var defaultDomain:String;

	@:prop({required:false}) @:optional var availableTypes:Dynamic<Bool>;
	@:prop({required:false, 'default':false})  @:optional var locked:Bool;
}