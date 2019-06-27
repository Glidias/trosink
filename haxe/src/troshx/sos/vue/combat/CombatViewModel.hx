package troshx.sos.vue.combat;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import troshx.components.Bout.FightNode;
import troshx.sos.combat.BoutModel;
import troshx.sos.core.BodyChar;
import troshx.sos.core.HitLocation;
import troshx.sos.core.TargetZone;
import troshx.sos.core.Wound;
import troshx.sos.sheets.CharSheet;
import troshx.sos.vue.combat.UIInteraction.UInteract;
import troshx.util.LibUtil;

/**
 * Client-side Combat view model 
 * 
 * @author Glidias
 */
class CombatViewModel 
{
	// initialize view flags
	public var observeOpponent:Bool = false;
	public var showFocusedTag:Bool = false;
	public var focusedIndex(default, null):Int = -1;
	public function setFocusedIndex(val:Int):Void { // layout index
		focusedIndex = val;
		showFocusedTag = val >=0;
	}
	public function getFocusedLabel():String {
		var i = focusedIndex;
		if (i < 0) return "";
		
		if (_swingMap.exists(i)) {
			return getDollSwingDescAt(_swingMap.get(i));
		} else if (_partMap.exists(i)) {
			return getDollPartThrustDescAt(_partMap.get(i));
		} else {
			return "todo/missing";
		}
	}

	
	public function getBodyPartLabel(i:Int=-1):String {
		if (i < 0) i = focusedIndex;
		if (i < 0) return "";
		if (_partMap.exists(i)) {
			var loc = getDollPartHitLocationAt(_partMap.get(i));
			return loc.name;
			
		} else {
			return null;
		}
		
	}
	
	public var draggedCP(default, null):Int = 0;
	public function setDraggedCP(val:Int):Void {
		draggedCP = val;
	}
	
	public var DOLL_PART_Slugs:Array<String> = [];
	public var DOLL_PART_Indices:Array<Int> = [];
	public var DOLL_PART_HitIndices:Array<Int> = [];
	public var DOLL_PART_IsRights:Int = 0;
	public function getDollPartThrustDescAt(index:Int):String {
		index = DOLL_PART_Indices[index];
		if (index < 0) return null;
		return _body.getDescLabelTargetZone(index);
	}
	public inline function getDollPartHitLocationAt(index:Int):HitLocation {
		return _body.hitLocations[DOLL_PART_HitIndices[index]];
	}
	public function getDollPartThrustZoneAt(index:Int):TargetZone {
		index = DOLL_PART_Indices[index];
		if (index < 0) return null;
		return _body.targetZones[index];
	}
	public inline function isDollPartThrustable(index:Int):Bool {
		return  DOLL_PART_Indices[index] >= 0;
	}
	
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
	public var DOLL_SWING_Indices:Array<Int> = [];
	public var DOLL_SWING_IsRights:Int = 0;
	public function getDollSwingDescAt(index:Int):String {
		return _body.getDescLabelTargetZone(DOLL_SWING_Indices[index]);
	}
	public function getDollSwingZoneAt(index:Int):TargetZone {
		return _body.targetZones[DOLL_SWING_Indices[index]];
	}
	
	public var boutModel(default, null):BoutModel; // server side synced data
	
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
	
	var defaultSwingAvailMask(default, null):Int = 0;
	var defaultThrustAvailMask(default, null):Int = 0;
	public var swingAvailabilityMask(default, null):Int = 0;
	public var thrustAvailabilityMask(default, null):Int = 0;
	function handleDisabledMask(val:Int, slugs:Array<String>):Void {
		var map = _interactionMaps[ACTING_DOLL_DECLARE];
		for (i in 0...slugs.length) {
			//trace(val + " : "+_dollImageMapData.titleList[map.get(_dollImageMapData.idIndices.get(slugs[i])).index] + " : "+((val & (1<<i)) == 0));
			map.get(_dollImageMapData.idIndices.get(slugs[i])).disabled = ((val & (1<<i)) == 0);
		}
	}
	function setDisabledAll(slugs:Array<String>, disabled:Bool=true):Void {
		var map = _interactionMaps[ACTING_DOLL_DECLARE];
		for (i in 0...slugs.length) {
			map.get(_dollImageMapData.idIndices.get(slugs[i])).disabled = disabled;
		}
	}
	function onThrustAvailabilityChange():Void {
		handleDisabledMask(thrustAvailabilityMask, DOLL_PART_Slugs);
	}
	function onSwingAvailabilityChange():Void {
		handleDisabledMask(swingAvailabilityMask, DOLL_SWING_Slugs);
	}
	
	public function partIndexAvailable(index:Int):Bool {
		return (thrustAvailabilityMask & (index << 1)) != 0;
	}

	public function swingArcAvailableBetween(slugs:Array<String>):Bool {
		return swingAvailabilityMask & (_dollImageMapData.idIndices.get(slugs[0]) | _dollImageMapData.idIndices.get(slugs[1]) ) != 0;
	}
	
	// Post initialize
	var _interactionStates:Array<Array<UInteract>>;
	var _interactionMaps:Array<IntMap<UInteract>>;
	var _dollImageMapData:ImageMapData;
	var _body:BodyChar;
	var _swingMap:IntMap<Int>;
	var _partMap:IntMap<Int>;
	
	public function setupDollInteraction(fullInteractList:Array<UInteract>, imageMapData:ImageMapData):Void {
		_interactionMaps = [];
		_interactionStates = [];
		_interactionStates[ACTING_DOLL_DECLARE] = fullInteractList;
		_interactionMaps[ACTING_DOLL_DECLARE] = UInteract.getIndexMapOfArray(fullInteractList);
		
		_interactionStates[ACTING_DOLL_DRAG_CP] = [];
		_dollImageMapData = imageMapData;
		
		
		var body = BodyChar.getInstance();
		_body = body;
		
		var needToLowercase:Bool;
	
		_swingMap = new IntMap<Int>();
		_partMap = new IntMap<Int>();
	
		for (i in 0...imageMapData.layoutItemList.length) {
			var tag = imageMapData.classList[i];

			if (tag == "part") {
				_partMap.set(i, DOLL_PART_Slugs.length);
				DOLL_PART_Slugs.push(imageMapData.titleList[i]);
				
			} else if (tag == "swing") {
				_swingMap.set(i, DOLL_SWING_Slugs.length);
				DOLL_SWING_Slugs.push(imageMapData.titleList[i]);
				
			}

		}
		var targetZones = body.targetZones;
		
		var toUnderscoreCapital:EReg = new EReg(" ([A-Z])", "g");
		var toSlugifyCapital:EReg = new EReg("_([a-z])", "g");
		
		var mapTempSwings:StringMap<Int> = new StringMap<Int>();
		var mapTempThrusts:StringMap<Int> = new StringMap<Int>();
		var key:String;
		for (i in 0...body.thrustStartIndex) {
			//if (targetZones[i].description == "")  {
				key = toUnderscoreCapital.replace(targetZones[i].name, "_$1").toUpperCase();
				mapTempSwings.set("SWING_"+key, i);
				//trace(key);
			//} 
		}
		//trace(" to thrusts...");
		for (i in body.thrustStartIndex...targetZones.length) {
			key = toUnderscoreCapital.replace(targetZones[i].name, "_$1").toUpperCase();
			mapTempThrusts.set(key, i);
			if (key == "LOWER_ARM") {	// exception consdieration for Target zone to PART
				mapTempThrusts.set("FOREARM", i);
			} else if (key == "UPPER_LEG") {
				mapTempThrusts.set("THIGH", i);
			} else if (key == "HEAD") {
				mapTempThrusts.set("FACE", i);
			} else if (key == "LOWER_LEG") {
				mapTempThrusts.set("SHIN", i);
			} 
			//trace(key);
		}
		
		needToLowercase = DOLL_PART_Slugs[0].charAt(0).toLowerCase() != DOLL_PART_Slugs[0].charAt(0);
		var keySplit:Array<String>;
		
		var maskAccum:Int;
		
		maskAccum = 0;
		for (i in 0...DOLL_PART_Slugs.length) {
			keySplit = DOLL_PART_Slugs[i].split("-");
			key = keySplit[0];
			
			DOLL_PART_IsRights |= keySplit.length >= 2 && keySplit[keySplit.length - 1] == "r" ? (1<<i) : 0;
			
			if (mapTempThrusts.exists(key)) {
				DOLL_PART_Indices[i] = mapTempThrusts.get(key);
				//trace("Part thrust detected:" + key);
				maskAccum |= (1 << i);
			} else {
				DOLL_PART_Indices[i] = -1;
				//trace ("did not find target zone thrust index by key:"+key);
			}
			
			key = toSlugifyCapital.map(key.toLowerCase(), function(e):String { return e.matched(1).toUpperCase(); } );
			key = key.charAt(0).toLowerCase() + key.substr(1);
			if (Reflect.hasField(body.hitLocationHash, key)) {
				var hitLoc:HitLocation;
				DOLL_PART_HitIndices[i] = LibUtil.field(body.hitLocationHash, key);
			} else {
				throw ("FAILED TO FIND hit location index by key:"+key);
			}
		}
		thrustAvailabilityMask = maskAccum;
	
		maskAccum = 0;
		for (i in 0...DOLL_SWING_Slugs.length) {
			//DOLL_PART_Slugs[i].replace(
			keySplit = DOLL_SWING_Slugs[i].split("-");
			
			DOLL_SWING_IsRights |= keySplit.length >= 2 && keySplit[keySplit.length - 1] == "r" ? (i << 1) : 0;
			
			key = keySplit[0];
			if (key == "SWING_UPWARD_HEAD") {	// WARNINg hardcode case from Humanoid
				DOLL_SWING_Indices[i] = 1;
			} else if (key == "SWING_DOWNWARD_HEAD") {
				DOLL_SWING_Indices[i] = 0;
			} else {
				if (mapTempSwings.exists(key)) {
					DOLL_SWING_Indices[i] = mapTempSwings.get(key);
				} else {
					DOLL_SWING_Indices[i] = -1;
					throw ("FAILED TO FIND target zone index by key:"+key);
				}
			}
			maskAccum |= (1 << i);
		}
		swingAvailabilityMask = maskAccum;
		
		
		defaultSwingAvailMask = swingAvailabilityMask;
		defaultThrustAvailMask = thrustAvailabilityMask;
		onThrustAvailabilityChange();
		onSwingAvailabilityChange();
	}
	
	
	
	//public function filteredBodyParts(swing:B
	
	// return visiblity of doll elements
	// set disabled states of doll elements
	
	public function new(boutModel:BoutModel=null) 
	{
		this.boutModel = boutModel!=null ? boutModel : new BoutModel();
	}
	
	
	
	
}