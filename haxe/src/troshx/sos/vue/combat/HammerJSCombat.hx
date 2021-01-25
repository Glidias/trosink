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
import js.Browser;
import js.html.CanvasElement;
import js.html.DOMElement;
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
	
	public var pointerOffsetX:Float = 0;
	public var pointerOffsetY:Float = 0;
	
	
	public var DEFAULT_ACT_HOVER:UInteract = new UInteract(-1, UIInteraction.HOVER); // app specific set
	public var defaultAct:UInteract;
	public var requiredActs:Int = 0;	// enforce compulsory required events mask for callbacks
	
	var cursorDomRef:DOMElement;
	var cpTrayDom:DOMElement;
	inline function setCursorPos(x:Float, y:Float):Void {
		if (cursorDomRef != null) {
			cursorDomRef.style.transform = 'translate3d(${x}px, ${y}px, 0)';
		}
	}

	public function new(element:CanvasElement, imageMapData:ImageMapData, callback:Int->Int->Void=null, cursorDomRef:DOMElement=null) 
	{
		this.cursorDomRef = cursorDomRef;
		this.callback = callback != null ? callback : defaultCallback;
		this.imageMapData = imageMapData;
		
		hammer = new Manager(cast element);
		hammer.add(new Press());
		hammer.add(new Swipe());
		hammer.add(new Pan());
		hammer.add(new Tap({
			taps: 1
		}));
		
		this.cursorDomRef = cursorDomRef;

		defaultAct = DEFAULT_ACT_HOVER;
		
		// app specific set
		interactionList = UIInteraction.setupDollViewInteracts(imageMapData.layoutItemList, imageMapData.titleList, imageMapData.classList);
		hammer.on("hammer.input move panup pandown tap press swipeleft swiperight swipeup", handleUIGesture);
	}
	
	// app specific set
	public static inline var HIT_OFFSET_OBSERVE_Y:Int = -55; // note: hardcode to match with dollview.scss
	
	private function defaultCallback(index:Int, event:Int):Void {
		if (viewModel == null) {
			trace("Receiving event from:" + index + " ::" + event + " >" + currentGesture.type + " :" + currentGesture.eventType);
			return;
		}
		var tag = imageMapData.classList[index];
		var name = imageMapData.titleList[index];
		
		
		if (viewModel.actingState == CombatViewModel.ACTING_DOLL_DRAG_CP) {
			if (event == UIInteraction.MOVE) {
				//trace("Drag move detect");
				this.viewModel.setDraggedCP(this.viewModel.getDraggedCPAmountFromPos(currentGesture.center.x, currentGesture.center.y));
			}
			else if (event == UIInteraction.RELEASE) {
				// check if outside screen, ignore?
				viewModel.setActingState(CombatViewModel.ACTING_DOLL_DECLARE);
				defaultAct = DEFAULT_ACT_HOVER;
				requiredActs = 0;
				viewModel.setDraggedCP(0);
				viewModel.resetAdvFocusedIndex(); // todo: might be kept
				
				//trace("Drag move release");
			} else if (event == UIInteraction.CANCELED) {
				viewModel.setActingState(CombatViewModel.ACTING_DOLL_DECLARE);
				defaultAct = DEFAULT_ACT_HOVER;
				requiredActs = 0;
				
				viewModel.setDraggedCP(0);
				viewModel.resetAdvFocusedIndex(); // todo: might be kept
				//trace("Drag move canceled");
			}
			else {
				return;
			}
			
			return;
		}
		
		
		if (tag == "swing" || tag == "part" || name == "enemyHandLeft" || name == "enemyHandRight") {
			if ( (event & UIInteraction.MASK_HOVER)!=0 || index != viewModel.focusedIndex) {
				if (!viewModel.observeOpponent) {
					viewModel.setFocusedIndex(index);
					
				}
				else viewModel.setObserveIndex(index);
			} else {
				if (event == UIInteraction.DOWN && index == viewModel.focusedIndex) {
					if (name == "enemyHandLeft" || name == "enemyHandRight") {
						if (!viewModel.advInteract1.disabled) viewModel.setAdvFocusedIndex(0);
						else return;
					}
					else viewModel.resetAdvFocusedIndex(); 
					if (viewModel.currentPlayerIndex >= 0) startDragCP(name, tag,  viewModel.isFocusedEnemyLeftSide(), viewModel.isFocusedEnemyLower());
					else { // description writeup?
					
					}
				}
			}
			return;
		}
		
		
		if (name == "incomingManuevers") {
			if ( (event & UIInteraction.PAN) != 0) viewModel.showFocusedTag = false;
			else if ( (event & UIInteraction.MOVE) != 0) {
				setCursorPos(currentGesture.center.x, currentGesture.center.y);
			}
			else if ( (event & UIInteraction.MASK_CANCELED_OR_RELEASE) != 0 ) {
				if (viewModel.setObserveOpponent(false)) {
					onViewModelObservationChange(currentGesture);
				}
				viewModel.setIncomingHeldDown(false);
			} else if ( event & (UIInteraction.HOLD | UIInteraction.DOWN) != 0 ) {
				viewModel.setIncomingHeldDown(true);
			} else if ( (event & UIInteraction.ROLL_OUT) != 0 ){
				if (viewModel.setObserveOpponent(true)) {
					onViewModelObservationChange(currentGesture);
				}
			}
		} 
		else if (name == "vitals") {
			
		} 
		else if (name == "advManuever1" || name == "advManuever2" || name == "advManuever3" || name == "advManuever4") {
			if (event == UIInteraction.DOWN) {
				if (viewModel.currentPlayerIndex >= 0) {
					viewModel.setAdvFocusedIndex(Std.parseInt(name.substr(name.length - 1)) - 1);
					startDragCP(name, tag, true, name == "advManuever3" || name == "advManuever4");
				} else { // description writeup?
					
				}
			}
		} 
		else {
			trace("unhadnled:" + name + " ::"+event + " : "+currentGesture.type);
		}
	}
	
	function startDragCP(name:String, tag:String, flip:Bool, flipY:Bool):Void {
		viewModel.setDraggedCP(0);
		viewModel.showFocusedTag = true;
		viewModel.trayPosX = currentGesture.center.x;
		viewModel.trayPosY = currentGesture.center.y;
		calibrateDragCPTraySize();
		viewModel.trayPosFlip = flip;
		viewModel.trayPosFlipY = flipY;
		viewModel.setActingState(CombatViewModel.ACTING_DOLL_DRAG_CP);
		
		requiredActs = UIInteraction.MOVE | UIInteraction.CANCELED | UIInteraction.RELEASE;
		defaultAct = null;
	}
	
	static inline var MAX_GRID_SIZE:Float = 64;
	static inline var MIN_GRID_SIZE:Float = 36;
	function calibrateDragCPTraySize() {
		///viewModel.trayGridSizeX
		var canvasWidth:Float = Browser.window.innerWidth; // imageMapData.scaleX * imageMapData.refWidth;
		var canvasHeight:Float = Browser.window.innerHeight; // imageMapData.scaleY * imageMapData.refHeight;
		var valY = Math.min(canvasWidth / 2 / 5, canvasHeight / 2 / 6);
		if (valY > MAX_GRID_SIZE) valY = MAX_GRID_SIZE;
		if (valY < MIN_GRID_SIZE) valY  = MIN_GRID_SIZE;
		viewModel.trayGridSizeY = Math.floor(valY);
		viewModel.trayGridShelfSize = Math.floor(0.65 * valY);
		viewModel.trayGridSizeX = viewModel.trayGridSizeY;
		if (this.cpTrayDom == null) this.cpTrayDom = Browser.document.getElementById('cpTray');
		Browser.window.setTimeout(function() {
			viewModel.trayGridSizeX = cpTrayDom.clientWidth / CombatViewModel.TRAY_TOTAL_COLS;
			trace(viewModel.trayGridSizeX + ' , ' + viewModel.trayGridSizeX);
		});
		//viewModel.trayGridSizeX = Math.min(canvasWidth / 2 / 5, canvasHeight / 2 / 5);
	}
	
	public function onViewModelObservationChange(gesture:GestureInteractionData=null):Void {
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
		if (gesture != null) {
			var isTouchMode =  val && gesture.pointerType == "touch";
			pointerOffsetY = isTouchMode ? HIT_OFFSET_OBSERVE_Y : 0;
			setCursorPos(gesture.center.x, gesture.center.y);
			this.viewModel.isTouchDragMode = isTouchMode;
			
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
			u = (touch.pageX+pointerOffsetX) / canvasWidth;
			v = (touch.pageY+pointerOffsetY) / canvasHeight;
			
		} else {  // if (Std.is(pt, PointerEvent))
			pointer = pt;
			id = pointer.pointerId;
			u = (pointer.pageX+pointerOffsetX) / canvasWidth;
			v = (pointer.pageY+pointerOffsetY) / canvasHeight;
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
					if ( (e.deltaX != 0 || e.deltaY != 0) && (act.mask & (UIInteraction.MOVE | UIInteraction.MOVE_OVER | UIInteraction.MASK_HOVER) ) != 0 ) {
						if ((mask & UIInteraction.MOVE) != 0) callback(act.index, UIInteraction.MOVE);
						if ((act.mask & (UIInteraction.ROLL_OUT | UIInteraction.MOVE_OVER | UIInteraction.MASK_HOVER) != 0)) {
							var act2 = UIInteraction.findHit(u, v, imageMapData, interactionList);
							if (act2 != null) {
								if ( (act2.mask & UIInteraction.MOVE_OVER) != 0 && act2.index == act.index) {
									callback(act.index, UIInteraction.MOVE_OVER);
								} else if ( (act2.mask & UIInteraction.MASK_HOVER) != 0 && act2.index != act.index) {
									if ((act.mask & UIInteraction.ROLL_OUT) != 0) {
										callback(act.index, UIInteraction.ROLL_OUT);
									}
									
									if ((act.mask & UIInteraction.HOVER)!=0) callback(act2.index, UIInteraction.HOVER);
									if ((act.mask & UIInteraction.HOVER_SWITCH) != 0) {
										activeTouches.set(id, act2);
										callback(act2.index, UIInteraction.HOVER_SWITCH);
									}
								}
							} else {
								if ((act.mask & UIInteraction.ROLL_OUT) != 0) {
									callback(act.index, UIInteraction.ROLL_OUT);
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