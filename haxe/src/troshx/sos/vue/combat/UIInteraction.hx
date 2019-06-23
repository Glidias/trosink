package troshx.sos.vue.combat;
import haxe.ds.StringMap;
import troshx.util.layout.LayoutItem;

/**
 * Yet another platform agnostic class to handle UI standard interactions
 * @author Glidias
 */
class UIInteraction 
{
	public static inline var COMPLETED:Int = 0;
	public static inline var DOWN:Int = (1 << 0);
	public static inline var MOVE:Int = (1 << 1);
	public static inline var TAP:Int = (1 << 2);
	public static inline var HOLD:Int = (1 << 3);
	public static inline var SWIPE_UP:Int = (1 << 4);
	public static inline var SWIPE_RIGHT:Int = (1 << 5);
	public static inline var SWIPE_DOWN:Int = (1 << 6);
	public static inline var SWIPE_LEFT:Int = (1 << 7);
	public static inline var SWIPE:Int = SWIPE_UP | SWIPE_DOWN | SWIPE_LEFT | SWIPE_RIGHT;
	public static inline var PAN_UP:Int = (1 << 8);
	public static inline var PAN_RIGHT:Int = (1 << 9);
	public static inline var PAN_DOWN:Int = (1 << 10);
	public static inline var PAN_LEFT:Int = (1 << 11);
	public static inline var PAN:Int = PAN_DOWN | PAN_UP | PAN_LEFT | PAN_RIGHT;
	
	public static inline var REQUIRE_CONFIRMATION:Int = TAP;
	
	public static inline function requiresTracking(mask:Int):Bool {
		return mask >= 2;
	}
	

	//public var dollViewElements:StringMap<
	public static function getDollViewInteracts(layoutItems:Array<LayoutItem>, names:Array<String>, tags:Array<String>):Array<UInteract> {
		var arr:Array<UInteract> = new Array<UInteract>();
		for (i in 0...layoutItems.length) {
			var item:LayoutItem = layoutItems[i];
			var name:String = names[i];
			var tag:String = tags[i];
			
			if (tag == "part" || tag == "swing") {	// assumption against refWidth/refHeight
				item.hitPadding = 8;
			}
			
			if (tag == "part" || tag == "swing" || name == "enemyHandLeft" || name == "enemyHandRight") {
				arr.push(new UInteract(i, DOWN | MOVE) );
				continue;
			}
			
			switch(name) {
				case "initRange": 
					arr.push(new UInteract(i, DOWN | MOVE) );
				case "advManuever1", "advManuever2", "advManuever3", "advManuever4": 
					
				case "btnBlock", "btnVoid", "btnParry": 
					arr.push(new UInteract(i, DOWN | MOVE) );
				case "opponentSwiper":
					
				case "roundCount":
					
				case "vitals":
					
				case "cpMeter":
					
				case "cpText":
					
				case "handLeftAlt", "handRightAlt": 
					
				case "handLeftText", "handRightText": 
					
				
			}
		}
		return arr;
	}
	
	public static function findHit(u:Float, v:Float, mapData:ImageMapData, interacts:Array<UInteract>):UInteract {
		var layoutList = mapData.layoutItemList;
		var positionList = mapData.positionList;
		var scaleList = mapData.scaleList;
		var closestHit:LayoutItem;
		var closestHitDist:Float;
		for (i in 0...interacts.length) {
			var act:UInteract = interacts[i];
			var layout:LayoutItem = layoutList[act.index];
			var padding:Float = layout.hitPadding;
			
			
			//layout.
			
		}
		return null;
	}
	
	public static function confirmHit(u:Float, v:Float, mapData:ImageMapData, act:UInteract):Bool {
		return false;
	}
	
}

class UInteract {
	public var index:Int;
	public var mask:Int;
	public function new(index:Int, mask:Int) {
		
		this.index = index;
		this.mask = mask;
		
	}
}