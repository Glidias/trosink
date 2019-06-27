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
import troshx.sos.combat.BoutController;
import troshx.sos.vue.combat.components.LayoutItemView;
import troshx.util.layout.LayoutItem;

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
	
	override function Data():DollViewData {
		return {
			mapData: getBlankImageMapData(),
			viewModel: new CombatViewModel()
		}
	}
	
	function getPartPropsOf(name:String):LayoutItemViewProps {
		var p = layoutViewPropsOf(name);
		var d = mapData;
		var i:Int = d.idIndices.get(name);
		p.showShape = i == viewModel.focusedIndex;
		return p;
	}
	
	function getSwingPropsOf(name:String):LayoutItemViewProps {
		var p = layoutViewPropsOf(name);
		var d = mapData;
		var i:Int = d.idIndices.get(name);
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
		// //:title="titleList[i]" :class="classList[i]" :key="i" :x="positionList[i].x*refWidth*scaleX" :y="positionList[i].y*refHeight*scaleY" :width="scaleList[i].x*refWidth*scaleX" :height="scaleList[i].y*refHeight*scaleY" :item="li"
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
			zone: new LayoutItemView()
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
	
}