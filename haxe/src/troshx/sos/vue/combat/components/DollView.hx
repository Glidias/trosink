package troshx.sos.vue.combat.components;
import haxe.ds.StringMap;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import hxGeomAlgo.HxPoint;
import js.Browser;
import js.html.Element;
import js.html.HtmlElement;
import js.html.Image;
import troshx.components.Bout.FightNode;
import troshx.sos.combat.BoutController;
import troshx.sos.pregens.FightCharacters;
import troshx.sos.sheets.CharSheet;
import troshx.sos.vue.combat.components.LayoutItemView;
import troshx.util.layout.LayoutItem;

import troshx.sos.vue.pregen.PregenSelectView;

/**
 * Main doll view component
 * @author Glidias
 */
class DollView extends VComponent<DollViewData, NoneT>
{

	public function new() 
	{
		super();
	}
	
	static inline var PREGEN_SELECT_OPPONENT:Int = 4;
	static inline var PREGEN_SELECT_SELF:Int = 1;
	@:computed function get_pregenHeader():String 
	{
		return showPregens == PREGEN_SELECT_SELF ? "Select your character" : "Select your opponent"; 
	}
	
	
	override function Data():DollViewData {
		return {
			mapData: getRenderTrackedImageData(),
			viewModel: new CombatViewModel(),
			
			fightChars: new FightCharacters(),
			showPregens: PREGEN_SELECT_SELF
		}
	}
	
	function getPartPropsOf(name:String):LayoutItemViewProps {
		var p = layoutViewPropsOf(name);
		var d = mapData;
		var i:Int = d.idIndices.get(name);
		p.fillColor = "rgba(0,200,255,0.3)";
		p.strokeColor = "rgba(0,200,255,0.3)";
		p.strokeWidth = 4*(mapData.scaleX < mapData.scaleY ? mapData.scaleX : mapData.scaleY);
		p.showShape = i == viewModel.focusedIndex;
		return p;
	}
	
	function getSwingPropsOf(name:String):LayoutItemViewProps {
		var p = layoutViewPropsOf(name);
		var d = mapData;
		var i:Int = d.idIndices.get(name);
		p.fillColor = "rgba(0,255,255,0.3)";
		p.strokeColor = "rgba(0,255,255,0.3)";
		p.strokeWidth = 8*(mapData.scaleX < mapData.scaleY ? mapData.scaleX : mapData.scaleY);
		p.showShape = i == viewModel.focusedIndex;
		return p;
	}
	
	
	function layoutViewPropsOf(name:String):LayoutItemViewProps {
		var d = mapData;
		var i:Int = d.idIndices.get(name);
		return {
			title: d.titleList[i],
			x: d.positionList[i].x*d.refWidth*d.scaleX,
			y: d.positionList[i].y*d.refHeight*d.scaleY,
			width: d.scaleList[i].x*d.refWidth*d.scaleX,
			height: d.scaleList[i].y * d.refHeight * d.scaleY,
			item: d.layoutItemList[i]
		}
	}
	
	@:computed inline function get_focusedTextLbl():String 
	{
		var lbl = viewModel.getFocusedLabel();
		if (lbl == null) lbl = viewModel.getBodyPartLabel(viewModel.focusedIndex);
		return lbl;
	}
	
	@:computed inline function get_player():FightNode<CharSheet>
	{
		return viewModel.getCurrentPlayer();
	}
	
	@:computed inline function get_opponents():Array<FightNode<CharSheet>> 
	{
		return viewModel.getCurrentOpponents();
	}
	
	@:computed inline function get_dollScale():Float
	{
		var x = mapData.scaleX;
		var y = mapData.scaleY;
		var R = mapData.renderCount;
		return y < x ? y : x;
	}
	
	@:computed inline function get_gotPregens():Bool
	{
		return fightChars != null && showPregens !=0;
	}
	
	@:computed inline function get_thrustPointStyle():Dynamic
	{
		var scale = this.dollScale;
		var d = (scale * 9);
		return {
			//backgroundColor:
			width:  d + "px",
			height: d + "px"
		};
	}
	
	
	
	@:computed function get_clampedOpponentIndex():Int
	{
		var opponents = this.opponents;
		var focusIndex = viewModel.focusOpponentIndex;
		if (opponents == null || opponents.length == 0) return 0;
		return focusIndex < opponents.length ? focusIndex : opponents.length -1;
	}
	
	@:computed inline function get_currentOpponent():FightNode<CharSheet> 
	{
		return this.opponents[this.clampedOpponentIndex];
	}
	
	
	public static function getRenderTrackedImageData():ImageMapData {
		return {
			renderCount:0,
		};
	}
	
	public static function getBlankImageMapData():ImageMapData {
		return {
			layoutItemList: null,
			positionList: [],
			scaleList: [],
			titleList: [],
			classList: [],
			refWidth:0,
			refHeight:0,
			scaleX:1,
			scaleY:1
		};
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>> {
		return {
			zone: new LayoutItemView(),
			pregens: new PregenSelectView()
		}
	}
	
	function setupNewGame():Void {
		
	}
	
	
	function setupUIInteraction():Void {
		hammerUI = new HammerJSCombat(cast _vRefs.container, this.mapData);
		hammerUI.viewModel = this.viewModel;
		
		
		this.viewModel.setupDollInteraction(hammerUI.interactionList, this.mapData);
	}
	
	override public function Mounted():Void {
		var img:Image = _vRefs.image;
		if (img.width > 0) {
			handleImageMap(img);
			
		} else {
			img.onload= function() {
				handleImageMap(img);
			};
		}
	}
	
	//function resolve
	
	function handleImageMap(img:Image) 
	{
		var map:Element = _vRefs.map;
		var c = map.firstChild;
		
		var d = this.mapData;
		d.refWidth = img.width;
		d.refHeight = img.height;
		
		d.layoutItemList = [];
		d.positionList = [];
		d.scaleList = [];
		d.titleList = [];
		d.classList = [];
		
		
		var idIndices = new StringMap<Int>();
		
		var count:Int = 0;
		var arr:Array<LayoutItem> = [];
		while (c != null) {
			if (c.nodeName.toLowerCase() == "area") {
				//c.attributes.shape;
				//c.attributes.coord;
				var elem:HtmlElement = cast c;
				d.positionList.push( new HxPoint());
				d.scaleList.push( new HxPoint());
				d.classList.push(elem.getAttribute("alt"));
				var title = elem.getAttribute("title");
				d.titleList.push(title);
				idIndices.set(title, count++);
				
				arr.push(LayoutItem.fromHTMLImageMapArea(img.width, img.height, elem.getAttribute("shape"), elem.getAttribute("coords")));
			}
			c = c.nextSibling;
		}
		d.layoutItemList = arr;
		
		d.idIndices = idIndices;
		
		
		LayoutConstraints.applyDollView(arr, d.titleList, d.classList, d.refWidth, d.refHeight);
		
		Browser.window.addEventListener("resize", onResize);
		onResize();
		
		setupUIInteraction();
		
		
		setupNewGame();
	}
	
	private function onResize():Void 
	{
		var container = _vRefs.container;
		var screenWidth = Std.parseFloat(container.clientWidth);
		var screenHeight = Std.parseFloat(container.clientHeight);
		var d = this.mapData;
		d.scaleX = screenWidth / d.refWidth;
		d.scaleY  = screenHeight / d.refHeight;
		
		refreshLayout();
	}
	
	function refreshLayout():Void
	{
		var d = mapData;
		for (i in 0...d.layoutItemList.length) {
			d.layoutItemList[i].solve(d.positionList[i], d.scaleList[i], d.scaleX, d.scaleY);
		}
		d.renderCount++;
	}
	
	
	
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
	
	
}

typedef DollViewData = {
	var mapData: ImageMapData;
	var viewModel:CombatViewModel;
	
	// post initialize  below to prevent reactivity
	@:optional var hammerUI:HammerJSCombat;
	@:optional var boutController:BoutController;
	
	// pregens
	@:optional var fightChars:FightCharacters;
	@:optional var showPregens:Int;
	
}