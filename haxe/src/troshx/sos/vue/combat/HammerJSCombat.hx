package troshx.sos.vue.combat;
import hammer.GestureInteractionData;
import hammer.Hammer;
import hammer.Manager;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import js.html.CanvasElement;
import js.html.HtmlElement;
import js.html.PointerEvent;
import js.html.Touch;
import js.html.TouchEvent;
import troshx.sos.vue.combat.UIInteraction.UInteract;

/**
 * UI Setup for combat system via HammerJS
 * @author Glidias
 */
class HammerJSCombat 
{
	var hammer:Hammer;
	//var manager:Manager;
	
	var hammerEventMap:StringMap<Int> = [	// note: should contain everything for reusability
		"panup" => UIInteraction.PAN_UP,
		"pandown" => UIInteraction.PAN_DOWN,
		"tap" => UIInteraction.TAP,
		"press" => UIInteraction.HOLD,
		"swipeleft" => UIInteraction.SWIPE_LEFT,
		"swiperight" => UIInteraction.SWIPE_RIGHT,
		"swipeup" => UIInteraction.SWIPE_UP
	];
	
	var activeTouches:IntMap<UInteract> = new IntMap<UInteract>();
	
	var imageMapData:ImageMapData;
	var interactionList:Array<UInteract>;
	
	public function new(element:CanvasElement, imageMapData:ImageMapData) 
	{
		this.imageMapData = imageMapData;
		hammer = new Hammer(element);
		interactionList = UIInteraction.getDollViewInteracts(imageMapData.layoutItemList, imageMapData.titleList, imageMapData.classList);
		
		hammer.on("hammer.input move panup pandown tap press swipeleft swiperight swipeup", handleUIGesture);
	}
	
	var _hoverAct:UInteract = new UInteract( -1, UIInteraction.MOVE);
	
	function handleUIGesture(e:GestureInteractionData):Void {
		
		var pt:Dynamic = e.changedPointers[0];
		var id:Int;
		var touch:Touch = null;
		var pointer:PointerEvent = null;
		var u:Float;
		var v:Float;
				
		// warning assumption: full screen canvas HUD assumed
		var canvasWidth:Float = imageMapData.scaleX * imageMapData.refWidth;
		var canvasHeight:Float = imageMapData.scaleY * imageMapData.refHeight;
		if (Std.is(pt, Touch)) {
			touch = pt;
			id = touch.identifier;
			u = touch.screenX / canvasWidth;
			v = touch.screenY / canvasHeight;
			
		} else {  // if (Std.is(pt, PointerEvent))
			pointer = pt;
			id = pointer.pointerId;
			u = pointer.screenX / canvasWidth;
			v = pointer.screenY / canvasHeight;
		} 
		//else {
		//	return;
		//}
			
		var act:UInteract;
		
		if (e.isFirst && e.type == "hammer.input") {
			// capture hit polygon (if any) on imageMapData, and place it into activeTouches
			// resolve down case if needed
			act = UIInteraction.findHit(u, v, imageMapData, interactionList);
			if (act != null ) {
				if (UIInteraction.requiresTracking(act.mask)) {
					activeTouches.set(id, act);
					trace("Added id:" + id);
				}
				// resolve if needed
			} else {
				// hover body part hit area check if not focused yet
				activeTouches.set(id, _hoverAct);
				//trace("Added hover checking id:" + id);
			}
		} else {
			if ( !activeTouches.exists(id) ) return;
			act = activeTouches.get(id);
			
			if (e.type == "hammer.input") { // Respond to further raw hammer input
	
				// check for Hammer.INPUT..  move, end or cancel
				if (e.eventType == Hammer.INPUT_MOVE) {
					if ( (act.mask & UIInteraction.MOVE)!=0 ) {
						//trace("Hover detected");
						var act2 = UIInteraction.findHit(u, v, imageMapData, interactionList);
						if (act2 != null  ) {
							if (UIInteraction.requiresTracking(act2.mask)) {
								activeTouches.set(id, act2);
								trace("Added act2 id:" + id);
							}
							// resolve if needed
						}
					}	
				} else if (e.eventType == Hammer.INPUT_END || e.eventType == Hammer.INPUT_CANCEL) {
					activeTouches.remove(id);
					//trace("Removed id:" + id);
					
				} else {
					throw "Could not resolve event type:" + e.eventType;
				}
				return;
			}
			
			
			// Respond to hammerJS event gesture
			var interactType:Int = hammerEventMap.get(e.type);
			if ( (act.mask & interactType) != 0) {
				if ( (interactType & UIInteraction.REQUIRE_CONFIRMATION) == 0) {
					// resolve now
				} else { // check confirm first
					
				}
			}
		}
	}
}