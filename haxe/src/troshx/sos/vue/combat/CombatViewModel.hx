package troshx.sos.vue.combat;
import troshx.components.Bout.FightNode;
import troshx.sos.combat.BoutModel;
import troshx.sos.core.Wound;
import troshx.sos.sheets.CharSheet;
import troshx.sos.vue.combat.UIInteraction.UInteract;

/**
 * Combat view hud model for client  (platform agnostic)
 * 
 * @author Glidias
 */
class CombatViewModel 
{
	// initialize
	
	public var showFocusedTag:Bool = false;
	public var focusedIndex(default, null):Int = -1;
	public function setFocusedIndex(val:Int):Void {
		focusedIndex = val;
		showFocusedTag = val >=0;
	}
	public var draggedCP(default, null):Int = 0;
	public function setDraggedCP(val:Int):Void {
		draggedCP = val;
	}
	
	public var DOLL_PART_Slugs:Array<String> = [];
	public var DOLL_PART_Names:Array<String> = [];
	public function getDollPartArmorValues(result:Array<Int> = null):Array<Int> {
		if (result == null) result = [];
		return result;
	}
	public function getDollPartHighestWoundLevels(result:Array<Int> = null):Array<Int> {
		if (result == null) result = [];
		return result;
	}
	public function getDollHighestWounds(result:Array<Array<Wound>> = null):Array<Array<Wound>> {
		if (result == null) result = [];
		return result;
	}
	
	public var DOLL_SWING_Slugs:Array<String> = [];
	public var DOLL_SWING_Names:Array<String> = [];
	
	public var boutModel(default, null):BoutModel;
	
	public static inline var ACTING_DOLL_DECLARE:Int = 0;
	public static inline var ACTING_DOLL_DRAG_CP:Int = 1;
	public var actingState(default, null):Int = -1;
	public function setActingState(val:Int):Void {
		actingState = val;
	}

	var currentPlayerIndex:Int = -1;
	public var focusOpponentIndex:Int = 0;
	
	public inline function getCurrentPlayer():FightNode<CharSheet> {
		return currentPlayerIndex >= 0 ? boutModel.bout.combatants[currentPlayerIndex] : null;
	}
	public inline function getCurrentOpponents():Array<FightNode<CharSheet>> {
		var player = getCurrentPlayer();
		if (player == null) return null;
		return null;
	}
	public inline function getCurrentAllies():Array<FightNode<CharSheet>> {
		var player = getCurrentPlayer();
		if (player == null) return null;
		return null;
	}
	
	
	
	var defaultSwingAvailabilityMask(default, null):Int = 0;
	var defaultThrustAvailbilityMask(default, null):Int = 0;
	public var swingAvailabilityMask(default, null):Int = 0;
	public var thrustAvailabilityMask(default, null):Int = 0;
	function handleDisabledMask(val:Int, slugs:Array<String>):Void {
		var fullList:Array<UInteract> = _interactionStates[ACTING_DOLL_DECLARE];
		for (i in 0...slugs.length) {
			fullList[_dollImageMapData.idIndices.get(slugs[i])].disabled = (val & (i<<1)) == 0;
		}
	}
	function setDisabledAll(slugs:Array<String>, disabled:Bool=true):Void {
		var fullList:Array<UInteract> = _interactionStates[ACTING_DOLL_DECLARE];
		for (i in 0...slugs.length) {
			fullList[_dollImageMapData.idIndices.get(slugs[i])].disabled = disabled;
		}
	}
	function onThrustAvailabilityChange(val:Int):Void {
		handleDisabledMask(val, DOLL_PART_Slugs);
	}
	function onSwingAvailabilityChange(val:Int):Void {
		handleDisabledMask(val, DOLL_SWING_Slugs);
	}
	
	public function partIndexAvailable(index:Int):Bool {
		return (thrustAvailabilityMask & (index << 1)) != 0;
	}

	public function swingArcAvailableBetween(slugs:Array<String>):Bool {
		return swingAvailabilityMask & (_dollImageMapData.idIndices.get(slugs[0]) | _dollImageMapData.idIndices.get(slugs[1]) ) != 0;
	}
	
	// Post initialize
	var _interactionStates:Array<Array<UInteract>>;
	var _dollImageMapData:ImageMapData;
	
	public function setupDollInteraction(fullInteractList:Array<UInteract>, imageMapData:ImageMapData):Void {
		_interactionStates = [];
		_interactionStates[ACTING_DOLL_DECLARE] = fullInteractList;
		_interactionStates[ACTING_DOLL_DRAG_CP] = [];
		_dollImageMapData = imageMapData;
		
		for (i in 0...imageMapData.layoutItemList.length) {
			var tag = imageMapData.classList[i];
			if (tag == "part") {
				DOLL_PART_Slugs.push(imageMapData.titleList[i]);
				//DOLL_PART_Names.push();
			} else if (tag == "swing") {
				DOLL_SWING_Slugs.push(imageMapData.titleList[i]);
				//DOLL_SWING_Names.push();
			}
			
			// filter doll parts clikability based on of actual default swings vs thrusts

			
		}
	}
	
	
	
	//public function filteredBodyParts(swing:B
	
	// return visiblity of doll elements
	// set disabled states of doll elements
	
	public function new(boutModel:BoutModel=null) 
	{
		this.boutModel = boutModel!=null ? boutModel : new BoutModel();
	}
	
	
	
	
}