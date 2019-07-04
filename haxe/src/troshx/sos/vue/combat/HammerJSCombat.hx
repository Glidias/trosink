package troshx.sos.vue.combat;
import hammer.GestureInteractionData;
import hammer.Hammer;
import hammer.Manager;
import hammer.recognizers.Pan;
import hammer.recognizers.Press;
import hammer.recognizers.Swipe;
import hammer.recognizers.Tap;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import js.html.CanvasElement;
import js.html.PointerEvent;
import js.html.Touch;
import troshx.sos.vue.combat.UIInteraction.UInteract;

/**
 * UI touch Setup controller for combat system via HammerJS
 * @author Glidias
 */
class HammerJSCombat 
{
	//var hammer:Hammer;
	var hammer:Manager;
	
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
	public var interactionList(default, null):Array<UInteract>;
	
	public var viewModel:CombatViewModel;
	
	public inline function setNewInteractionList(arr:Array<UInteract>):Void {
		interactionList = arr;
	}
	
	public var currentGesture(default, null):GestureInteractionData;
	
	var callback:Int->Int->Void;
	
	
	public var DEFAULT_ACT_HOVER:UInteract = new UInteract(-1, UIInteraction.HOVER); // app specific set
	public var defaultAct:UInteract;
	public var requiredActs:Int = 0;	// enforce compulsory required events mask for callbacks
	
	public function new(element:CanvasElement, imageMapData:ImageMapData, callback:Int->Int->Void=null) 
	{
		this.callback = callback != null ? callback : defaultCallback;
		this.imageMapData = imageMapData;
		
		hammer = new Manager(cast element);
		hammer.add(new Press());
		hammer.add(new Swipe());
		hammer.add(new Pan());
		hammer.add(new Tap({
			taps: 1
		}));

		defaultAct = DEFAULT_ACT_HOVER;
		
		// app specific set
		interactionList = UIInteraction.setupDollViewInteracts(imageMapData.layoutItemList, imageMapData.titleList, imageMapData.classList);
		hammer.on("hammer.input move panup pandown tap press swipeleft swiperight swipeup", handleUIGesture);
	}
	
	// app specific set
	private function defaultCallback(index:Int, event:Int):Void {
		if (viewModel == null) {
			trace("Receiving event from:" + index + " ::" + event + " >" + currentGesture.type + " :" + currentGesture.eventType);
			return;
		}
		
		if (viewModel.actingState == CombatViewModel.ACTING_DOLL_DRAG_CP) {
			if (event == UIInteraction.MOVE) {
				//trace("Drag move detect");
			}
			else if (event == UIInteraction.RELEASE) {
				// check if outside screen, ignore?
				viewModel.setActingState(CombatViewModel.ACTING_DOLL_DECLARE);
				defaultAct = DEFAULT_ACT_HOVER;
				requiredActs = 0;
				
				trace("Drag move release");
			} else if (event == UIInteraction.CANCELED) {
				viewModel.setActingState(CombatViewModel.ACTING_DOLL_DECLARE);
				defaultAct = DEFAULT_ACT_HOVER;
				requiredActs = 0;
				
				viewModel.setDraggedCP(0);
				trace("Drag move canceled");
			}
			else {
				return;
			}
			
			return;
		}
		
		var tag = imageMapData.classList[index];
		if (tag == "swing" || tag == "part") {
			if (event == UIInteraction.HOVER || index != viewModel.focusedIndex) {
				if (!viewModel.observeOpponent) viewModel.setFocusedIndex(index);
				else viewModel.setObserveIndex(index);
			} else {
				if (event == UIInteraction.DOWN && index == viewModel.focusedIndex) {
					viewModel.setDraggedCP(0);
					viewModel.showFocusedTag = true;
					viewModel.setActingState(CombatViewModel.ACTING_DOLL_DRAG_CP);
					requiredActs = UIInteraction.MOVE | UIInteraction.CANCELED | UIInteraction.RELEASE;
					defaultAct = null;
				}
			}
			return;
		}
		
		var name = imageMapData.titleList[index];
		if (name == "incomingManuevers") {
			if ( (event & UIInteraction.PAN) != 0) viewModel.showFocusedTag = false;
			else if ( (event & UIInteraction.MASK_CANCELED_OR_RELEASE) != 0 ) {
				if (viewModel.setObserveOpponent(false)) {
					onViewModelObservationChange();
				}
			} else if ( event & (UIInteraction.HOLD | UIInteraction.DOWN) != 0 ) {
				if (viewModel.setObserveOpponent(true)) {
					onViewModelObservationChange();
				}
			}
		} else if (name == "vitals") {
			
		} else {
			trace("unhadnled:" + name + " ::"+event + " : "+currentGesture.type);
		}
	}
	
	public function onViewModelObservationChange():Void {
		var viewModel = this.viewModel;
		var val = viewModel.observeOpponent;
		if (val) {
			viewModel.setDisabledAll(viewModel.DOLL_PART_Slugs, false);
			viewModel.setDisabledAll(viewModel.DOLL_SWING_Slugs, true);
			viewModel.showFocusedTag = true;
		} else {
			viewModel.handleDisabledMask(viewModel.thrustAvailabilityMask, viewModel.DOLL_PART_Slugs);
			viewModel.handleDisabledMask(viewModel.swingAvailabilityMask, viewModel.DOLL_SWING_Slugs);
			viewModel.setObserveIndex( -1);
			viewModel.showFocusedTag = true;
		}
		
		
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
		var mask:Int = requiredActs;
		if (e.isFirst && e.type == "hammer.input") {
			// capture hit polygon (if any) on imageMapData, and place it into activeTouches
			// resolve down case if needed
			act = UIInteraction.findHit(u, v, imageMapData, interactionList);
			if (act != null ) {
				// resolve if needed
				mask |= act.mask;
				if ( (mask & UIInteraction.DOWN)!=0 ) callback(act.index, UIInteraction.DOWN);
				
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
			if ( !activeTouches.exists(id) ) {
				trace("OUT");
				return;
			}
			act = activeTouches.get(id);
			if (act == null) {	// lazy defered removal
				act = _inputActCache;
				mask |= act.mask;
				activeTouches.remove(id);
				_inputActCache = null;
				if (act == null) {
					
					return;
				}
			} else {
				mask |= act.mask;
			}
	
			if (e.type == "hammer.input") { // Respond to further raw hammer input
				// check for Hammer.INPUT..  move, end or cancel
				if (e.eventType == Hammer.INPUT_MOVE) {
					if ( (e.deltaX != 0 || e.deltaY != 0) && (act.mask & (UIInteraction.MOVE | UIInteraction.MOVE_OVER | UIInteraction.HOVER) ) != 0 ) {
						if ((mask & UIInteraction.MOVE) != 0) callback(act.index, UIInteraction.MOVE);
						if ((act.mask & (UIInteraction.MOVE_OVER | UIInteraction.HOVER) != 0)) {
							var act2 = UIInteraction.findHit(u, v, imageMapData, interactionList);
							if (act2 != null) {
								if ( (act2.mask & UIInteraction.MOVE_OVER) != 0 && act2.index == act.index) {
									callback(act.index, UIInteraction.MOVE_OVER);
								} else if ( (act2.mask & UIInteraction.HOVER) != 0 && act2.index != act.index) {
									//activeTouches.set(id, act2);
									callback(act2.index, UIInteraction.HOVER);
								}
							}
						}
					}	
				} else if (e.eventType == Hammer.INPUT_END || e.eventType == Hammer.INPUT_CANCEL) {
					_inputActCache = act;
					
					if ( e.eventType == Hammer.INPUT_END ) {
						if ( (mask & UIInteraction.RELEASE_OVER) != 0 && UIInteraction.checkHit(u, v, imageMapData, act) >= 0) {
							callback(act.index, UIInteraction.RELEASE_OVER);
						}
						if ((mask & UIInteraction.RELEASE) != 0) {
						
							callback(act.index, UIInteraction.RELEASE);
						}
					} else if ((mask & UIInteraction.CANCELED)!=0) { //Hammer.INPUT_CANCEL
						callback(act.index, UIInteraction.CANCELED);
					}
					
					activeTouches.set(id, null);
					trace("Removed-l id:" + id);
					
				} else {
					throw "Could not resolve event type:" + e.eventType;
				}
				return;
			}
			
			
			// Respond to hammerJS event gesture
			var interactType:Int = hammerEventMap.get(e.type);
			if ( (act.mask & interactType) != 0) {
				if ( !UIInteraction.requiresConfirmHit(interactType) || UIInteraction.checkHit(u, v, imageMapData, act)>=0 ) {
					if (!act.disabled) callback(act.index, interactType);
				} 
				//if (!UIInteraction.requiresContinousHandling(interactType)) {
					//activeTouches.remove(id);
					//trace("Removedx id:" + id + " for :"+e.type);
				//}
			}
			
			
		}
	}
}