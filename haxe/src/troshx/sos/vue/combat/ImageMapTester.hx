package troshx.sos.vue.combat;
import hammer.GestureInteractionData;
import hammer.Hammer;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.util.VHTMacros;
import js.Browser;
import js.html.Element;
import js.html.HtmlElement;
import js.html.Image;
import troshx.sos.vue.combat.components.LayoutItemView;
import troshx.util.layout.LayoutItem;
import troshx.util.layout.Vec2;

/**
 * ...
 * @author Glidias
 */
class ImageMapTester extends VComponent<ImageMapData, NoneT>
{

	public function new() 
	{
		super();
	}
	
	override function Data():ImageMapData {
		return DollView.getBlankImageMapData();
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>> {
		return {
			zone: new LayoutItemView()
		}
	}
	
	
	
	function setupUIInteraction():Void {
		new HammerJSCombat(cast _vRefs.container, _vData);
		
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
		
		this.refWidth = img.width;
		this.refHeight = img.height;
		
		var arr:Array<LayoutItem> = [];
		while (c != null) {
			if (c.nodeName.toLowerCase() == "area") {
				//c.attributes.shape;
				//c.attributes.coord;
				var elem:HtmlElement = cast c;
				this.positionList.push( new Vec2());
				this.scaleList.push( new Vec2());
				this.classList.push(elem.getAttribute("alt"));
				this.titleList.push(elem.getAttribute("title"));
				arr.push(LayoutItem.fromHTMLImageMapArea(img.width, img.height, elem.getAttribute("shape"), elem.getAttribute("coords")));
			}
			c = c.nextSibling;
		}
		_vData.layoutItemList = arr;
		
		LayoutConstraints.applyDollView(arr, this.titleList, this.classList, this.refWidth, this.refHeight);
		
		Browser.window.addEventListener("resize", onResize);
		onResize();
		
		setupUIInteraction();
	}
	
	private function onResize():Void 
	{
		var container = _vRefs.container;
		var screenWidth = Std.parseFloat(container.clientWidth);
		var screenHeight = Std.parseFloat(container.clientHeight);
		this.scaleX = screenWidth / refWidth;
		this.scaleY  = screenHeight / refHeight;
		
		refreshLayout();
		
		
	}
	
	function refreshLayout():Void
	{
		for (i in 0...layoutItemList.length) {
			layoutItemList[i].solve(positionList[i], scaleList[i], scaleX, scaleY);
		}
	}
	
	override public function Template():String {
		return VHTMacros.getHTMLStringFromFile("", "html");
	}
	
}