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
	
	var _inputActCache:UInteract;
	var activeTouches:IntMap<UInteract> = new IntMap<UInteract>();
	
	var imageMapData:ImageMapData;
	var interactionList:Array<UInteract>;
	
	public function setNewInteractionList(arr:Array<UInteract>):Void {
		interactionList = arr;
	}
	
	public var currentGesture(default, null):GestureInteractionData;
	
	var callback:Int->Int->Void;
	
	public var defaultAct:UInteract = new UInteract(-1, UIInteraction.HOVER); // app specific set
	
	public function new(element:CanvasElement, imageMapData:ImageMapData, callback:Int->Int->Void=null) 
	{
		this.callback = callback != null ? callback : dummyCallback;
		this.imageMapData = imageMapData;

		hammer = new Hammer(element);
		
		// app specific set
		interactionList = UIInteraction.setupDollViewInteracts(imageMapData.layoutItemList, imageMapData.titleList, imageMapData.classList);
		
		hammer.on("hammer.input move panup pandown tap press swipeleft swiperight swipeup", handleUIGesture);
	}
	
	private function dummyCallback(index:Int, event:Int):Void {
		trace("Receiving event from:" + index + " ::"+event + " >"+currentGesture.type + " :"+currentGesture.eventType);
	}
	
	
	
	function handleUIGesture(e:GestureInteractionData):Void {
		currentGesture = e;
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
			u = touch.pageX / canvasWidth;
			v = touch.pageY / canvasHeight;
			
		} else {  // if (Std.is(pt, PointerEvent))
			pointer = pt;
			id = pointer.pointerId;
			u = pointer.pageX / canvasWidth;
			v = pointer.pageY / canvasHeight;
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
				// resolve if needed
				
				if ( (act.mask & UIInteraction.DOWN)!=0 ) callback(act.index, UIInteraction.DOWN);
				
				if (UIInteraction.requiresTracking(act.mask)) {
					activeTouches.set(id, act);
					//trace("Added id:" + id);
				}
				
			} else {
				// hover body part hit area check if not focused yet
				if (defaultAct != null) {
					activeTouches.set(id, defaultAct);
					//trace("Added hover checking id:" + id);
				}
			}
		} else {
			if ( !activeTouches.exists(id) ) return;
			act = activeTouches.get(id);
			if (act == null) {	// lazy defered removal
				act = _inputActCache;
				activeTouches.remove(id);
				_inputActCache = null;
				if (act == null) return;
			}
	
			if (e.type == "hammer.input") { // Respond to further raw hammer input
	
				// check for Hammer.INPUT..  move, end or cancel
				if (e.eventType == Hammer.INPUT_MOVE) {
					if ( (e.deltaX!= 0 || e.deltaY!=0) && (act.mask & (UIInteraction.MOVE | UIInteraction.MOVE_OVER | UIInteraction.HOVER) )!=0 ) {
						//trace("Move/MoveOver/Hover detected");
						if ((act.mask & UIInteraction.MOVE) != 0) callback(act.index, UIInteraction.MOVE);
						if ((act.mask & (UIInteraction.MOVE_OVER | UIInteraction.HOVER) != 0)) {
							var act2 = UIInteraction.findHit(u, v, imageMapData, interactionList);
							if (act2 != null) {
								if ( (act2.mask & UIInteraction.MOVE_OVER) != 0 && act2.index == act.index) {
									callback(act.index, UIInteraction.MOVE_OVER);
								} else if ( (act2.mask & UIInteraction.HOVER) != 0 && act2.index != act.index) {
									activeTouches.set(id, act2);
									callback(act2.index, UIInteraction.HOVER);
								}
							}
						}
					}	
				} else if (e.eventType == Hammer.INPUT_END || e.eventType == Hammer.INPUT_CANCEL) {
					_inputActCache = act;
					activeTouches.set(id, null);
					//trace("Removed-l id:" + id);
					
				} else {
					throw "Could not resolve event type:" + e.eventType;
				}
				return;
			}
			
			
			// Respond to hammerJS event gesture
			var interactType:Int = hammerEventMap.get(e.type);
			if ( (act.mask & interactType) != 0) {
				if ( !UIInteraction.requiresConfirmHit(interactType) || UIInteraction.checkHit(u, v, imageMapData, act)>=0 ) {
					callback(act.index, interactType);
				} 
				if (!UIInteraction.requiresContinousHandling(interactType)) {
					activeTouches.remove(id);
					//trace("Removedx id:" + id + " for :"+e.type);
				}
			}
			
			
		}
	}
}