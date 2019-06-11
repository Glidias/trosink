package troshx.sos.vue.combat;
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
class ImageMapTester extends VComponent<ImageMapTesterData, NoneT>
{

	public function new() 
	{
		super();
		DollView;
	}
	
	override function Data():ImageMapTesterData {
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
		}
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>> {
		return {
			zone: new LayoutItemView()
		}
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
		
		Browser.window.addEventListener("resize", onResize);
		onResize();
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

typedef ImageMapTesterData = {
	var layoutItemList:Array<LayoutItem>;
	var positionList:Array<Vec2>;
	var scaleList:Array<Vec2>;
	var titleList:Array<String>;
	var classList:Array<String>;
	
	var refWidth:Float;
	var refHeight:Float;
	var scaleX:Float;
	var scaleY:Float;
}