package troshx.sos.vue.combat;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import troshx.components.Bout.FightNode;
import troshx.core.ManueverSpec;
import troshx.sos.combat.BoutModel;
import troshx.sos.core.BodyChar;
import troshx.sos.core.HitLocation;
import troshx.sos.core.Inventory;
import troshx.sos.core.Item;
import troshx.sos.core.Manuever;
import troshx.sos.core.Shield;
import troshx.sos.core.TargetZone;
import troshx.sos.core.Weapon;
import troshx.sos.core.Wound;
import troshx.sos.sheets.CharSheet;
import troshx.sos.vue.combat.UIInteraction.UInteract;
import troshx.util.AbsStringMap;
import troshx.util.LibUtil;

/**
 * Client-side Combat view model that works alongside other views
 *
 * @author Glidias
 */
class CombatViewModel
{
	//public var focusInvalidateCount(default, null):Int = 0;

	public var trayPosX:Float = 0;
	public var trayPosY:Float = 0;
	public var trayGridSizeX:Float = 10;
	public var trayGridSizeY:Float = 10;
	public var trayGridShelfSize:Float = 10;
	public var trayGridShelfX:Float = 8;
	public static inline var TRAY_TOTAL_COLS:Int = 5;

	public var trayPosFlip:Bool = false;
	public var trayPosFlipY:Bool = false;
	public function getDraggedCPAmountFromPos(mx:Int, my:Int):Int {
		var player = this.getCurrentPlayer();
		var maxAvailableCP = player.fight.cp;
		// any activation costs to be sbtracted

		var dx = trayPosFlip ? -1 : 1;
		var dy = trayPosFlipY ? -1 : 1;
		var x = trayPosX + trayGridShelfX * dx;
		var y = trayPosY + trayGridShelfSize*dy;
		var colIndex = Math.floor((mx - x) * dx / trayGridSizeX);
		var rowIndex = Math.floor((my - y) * dy / trayGridSizeY);
		if (rowIndex < 0 || colIndex < 0) {
			return 0;
		}
		var amt =  (rowIndex) * CombatViewModel.TRAY_TOTAL_COLS + (colIndex+1);
		if (amt > maxAvailableCP) amt = maxAvailableCP;
		return amt;
	}

	var manueverRepo:AbsStringMap<Manuever>;

	// atk and def manuevers, basic and adv
	var basicSwing:Manuever;
	var basicThrust:Manuever;
	var advSwingArr:Array<Manuever>;
	var advThrustArr:Array<Manuever>;
	
	var basicVoid:Manuever;
	var basicBlock:Manuever;
	var basicParry:Manuever;
	var advParryArr:Array<Manuever>;
	var advVoidArr:Array<Manuever>;
	var advBlockArr:Array<Manuever>;
	
	var advAntiWeapWithWeaponArr:Array<Manuever>;
	var advAntiShieldWithWeaponArr:Array<Manuever>;
	var advAntiHandWithShieldArr:Array<Manuever>;
	var advAntiHandUnarmedArr:Array<Manuever>;
	
	
	var basicHookPunch:Manuever;
	var basicStraightPunch:Manuever;
	var advPuglismThrustSwingArr:Array<Manuever>;
	var advPuglismHandlessArr:Array<Manuever>;
	
	var basicMeleeShoot:Manuever;
	var basicNetToss:Manuever;
	var advRangedArr:Array<Manuever>;
	
	public var playerManueverSpec(default, null):ManueverSpec = new ManueverSpec();
	
	// gameplay related manuevers
	public var mOneTwoPunch(default, null):Manuever;
	public var mDoNothing(default, null):Manuever;
	public var mMasterStrike(default, null):Manuever;
	public var mDoubleAttack(default, null):Manuever;
	public var mDoubleShot(default, null):Manuever;
	public var mStealInitiative(default, null):Manuever;
	public var mThreadNeedle(default, null):Manuever;
	public var mAllyDefense(default, null):Manuever;
	public var mQuickDefense(default, null):Manuever;
	public var mQuickDraw(default, null):Manuever;
	public var mRapidRise(default, null):Manuever;
	public var mGuardedAttack(default, null):Manuever;
	
	public function new(boutModel:BoutModel=null)
	{
		this.boutModel = boutModel != null ? boutModel : new BoutModel();
		manueverRepo = Manuever.getMap();
		
		basicSwing = manueverRepo.get('swing');
		basicThrust = manueverRepo.get('thrust');
		advSwingArr = ['drawCut', 'cleavingBlow', 'hook', 'feint'].map(manueverRepo.get);
		advThrustArr = ['pushCut', 'jointThrust', 'hook', 'feint'].map(manueverRepo.get);
	
		advAntiWeapWithWeaponArr = ['disarm', 'beat', 'break', ''].map(manueverRepo.get);
		advAntiShieldWithWeaponArr = ['hew', 'beat', 'hook', ''].map(manueverRepo.get);
		advAntiHandUnarmedArr = ['disarmUnarmedAtk'].map(manueverRepo.get);
		advAntiHandWithShieldArr = ['shieldBeat'].map(manueverRepo.get);
		
		basicHookPunch = manueverRepo.get('hookPunch');
		basicStraightPunch = manueverRepo.get('straightPunch');
		advPuglismHandlessArr = ['headbutt', 'elbow', 'knee', 'trip'].map(manueverRepo.get);
		advPuglismThrustSwingArr = ['oneTwoPunch', 'elbow', 'kick', 'trip'].map(manueverRepo.get);
		mOneTwoPunch = manueverRepo.get('oneTwoPunch');
		
		basicMeleeShoot = manueverRepo.get('meleeShoot');
		basicNetToss = manueverRepo.get('netToss');
		advRangedArr = ['', '', 'blindToss', 'weaponThrow'].map(manueverRepo.get);
		
		basicVoid = manueverRepo.get('void');
		basicParry = manueverRepo.get('parry');
		basicBlock = manueverRepo.get('block');
		advVoidArr =  ['hastyVoid', 'mobileVoid', '', 'flee'].map(manueverRepo.get);
		advParryArr =  ['disarmUnarmedDef', 'armParry', 'riposte', ''].map(manueverRepo.get);
		advBlockArr =  ['', 'shieldBind', '', 'totalBlock'].map(manueverRepo.get);
		
		mStealInitiative = manueverRepo.get('stealInitiative');
		
		mDoNothing = manueverRepo.get('doNothing');
		mMasterStrike = manueverRepo.get('masterStrike');
		mDoubleAttack = manueverRepo.get('doubleAttack');
		mDoubleShot = manueverRepo.get('mDoubleShot');
		
		mQuickDefense = manueverRepo.get('quickDefense');
		mQuickDraw = manueverRepo.get('quickDraw');
		mAllyDefense = manueverRepo.get('allyDefense');
		mThreadNeedle = manueverRepo.get('threadNeedle');
		mRapidRise = manueverRepo.get('rapidRise');
		mGuardedAttack = manueverRepo.get('guardedAttack');
		
		// later: alt mode swithching
		// steal initiative
	}
	
	public function activatePlayerItem(offhand:Bool = false):Void {
		var player = getCurrentPlayer();
		playerManueverSpec.activeItem = offhand ? player.charSheet.inventory.findOffHandItem() : player.charSheet.inventory.findMasterHandItem();
	}

	
	

	//public function filteredBodyParts(swing:B
	//return visiblity of doll elements
	//set disabled states of doll elements
	
	var MAP_LOWER_BODY_PARTS:StringMap<Bool> = [
		'SWING_LOWER_LEG'=> true,
		'SWING_UPPER_LEG'=> true,
		'KNEE'=> true,
		'LEG'=>	 true,
		'SHIN'=> true,
		'THIGH'=> true
	];

	public var isTouchDragMode:Bool = false;
	public var incomingHeldDown(default, null):Bool = false;
	public function setIncomingHeldDown(val:Bool):Void
	{
		incomingHeldDown = val;
	}

	public var observeOpponent(default, null):Bool = false;
	public function setObserveOpponent(val:Bool):Bool {
		var gotChange:Bool = observeOpponent != val;
		observeOpponent = val;
		return gotChange;
	}
	public var showFocusedTag:Bool = false;
	public var observeIndex(default, null):Int = -1;
	public var focusedIndex(default, null):Int = -1;
	public var advFocusedIndex(default, null):Int = -1;
	
	public inline function setFocusedIndex(val:Int):Void { // layout index
		//focusInvalidateCount++;
		focusedIndex = val;
		
		playerManueverSpec.activeEnemyZone = this.getTargetZoneIndexFromFocIndex(val);
		// playerManueverSpec.activeEnemyZone = val >=  ? val : -1;
		showFocusedTag = val >=0;
	}
	
	public inline function setAdvFocusedIndex(val:Int):Void {
		advFocusedIndex = val;
	}
	
	public inline function resetAdvFocusedIndex():Void {
		advFocusedIndex = -1;
	}
	

	public function getFocusManueverAtkType():Int {
		var i = focusedIndex;
		if (_swingMap.exists(i)) {
			return Manuever.ATTACK_TYPE_SWING;
		} else if (_partMap.exists(i)) {
			return Manuever.ATTACK_TYPE_THRUST;
		} else if (focusedIndex == _enemyHandLeftIdx) {
			return ManueverSpec.LEFT_HAND_ZONE;
		}
		else if (focusedIndex == _enemyHandRightIdx) {
			return ManueverSpec.RIGHT_HAND_ZONE;
		} else {
			return ManueverSpec.NO_ZONE;
		}
	}
	
	public function getTargetZoneIndexFromFocIndex(i:Int):Int {
		if (_swingMap.exists(i)) {
			return DOLL_SWING_Indices[_swingMap.get(i)];
		} else if (_partMap.exists(i)) {
			return DOLL_PART_Indices[_partMap.get(i)];
		} else if (focusedIndex == _enemyHandLeftIdx) {
			return ManueverSpec.LEFT_HAND_ZONE;
		}
		else if (focusedIndex == _enemyHandRightIdx) {
			return ManueverSpec.RIGHT_HAND_ZONE;
		} else {
			return ManueverSpec.NO_ZONE;
		}
	}

	public inline function setObserveIndex(val:Int):Void { // layout index
		observeIndex = val;
	}
	
	static var EMPTY_ARR:Array<Manuever> = [];
	public function getAdvancedManuevers(curPlayer:FightNode<CharSheet>=null, playerLeftItem:Item=null, playerRightItem:Item=null, curEnemy:FightNode<CharSheet>=null, enemyLeftItem:Item=null, enemyRightItem=null):Array<Manuever> {
		var manueverSpec:ManueverSpec = playerManueverSpec;
		var targetZone = manueverSpec.activeEnemyZone;
		var offhand = manueverSpec.usingLeftLimb;
		var focusIndex = this.focusedIndex;
		
		
		if (manueverSpec.activeEnemyBody==null) {
			return EMPTY_ARR;
		}

		if (curEnemy != null) {
			if (playerManueverSpec.activeEnemyZone < 0 && playerManueverSpec.activeEnemyZone != ManueverSpec.NO_ZONE) {
				if (playerManueverSpec.activeEnemyZone == ManueverSpec.LEFT_HAND_ZONE) {
					if (enemyLeftItem == null) enemyLeftItem = curEnemy.charSheet.inventory.findOffHandItem();
					playerManueverSpec.activeEnemyItem = enemyLeftItem;
				} else if (playerManueverSpec.activeEnemyZone == ManueverSpec.RIGHT_HAND_ZONE) {
					if (enemyRightItem == null) enemyRightItem = curEnemy.charSheet.inventory.findMasterHandItem();
					playerManueverSpec.activeEnemyItem = enemyRightItem;
				}
				else {
					playerManueverSpec.activeEnemyItem = null;
				}
			} else {
				playerManueverSpec.activeEnemyItem = null;
			}
		}
		
		if (curPlayer == null) {
			// todo: dummy catalog only without filtering player state
			return EMPTY_ARR;
		}
		
		if (targetZone >= 0) {
			if (manueverSpec.activeEnemyBody.isThrusting(targetZone)) {
				return advThrustArr;
			} else {
				return advSwingArr;
			}
		} else {
			if (focusIndex == _enemyHandLeftIdx || focusIndex == _enemyHandRightIdx) {

				if (Std.is(manueverSpec.activeItem, Weapon)) {
					return Std.is(manueverSpec.activeEnemyItem, Shield) ? advAntiShieldWithWeaponArr : advAntiWeapWithWeaponArr;
				} else if (Std.is(manueverSpec.activeItem, Shield)) {
					return advAntiHandWithShieldArr;
				}
				return advAntiHandUnarmedArr; 
				//advAntiHandUnarmedArr
				// advAntiHandWithShieldArr
			} 
		}
		return EMPTY_ARR;
	}


	public function isFocusedEnemyLeftSide() {
		var i = focusedIndex;
		var str = null;
		if (_swingMap.exists(i)) {
			str = DOLL_SWING_Slugs[_swingMap.get(i)];
		} else if (_partMap.exists(i)) {
			str = DOLL_PART_Slugs[_partMap.get(i)];
		}
		return i == _enemyHandLeftIdx || (str != null && str.substr(str.length - 2) == "-l");
	}

	public function isFocusedEnemyLower() {
		var i = focusedIndex;
		var str = null;
		if (_swingMap.exists(i)) {
			str = DOLL_SWING_Slugs[_swingMap.get(i)];
		} else if (_partMap.exists(i)) {
			str = DOLL_PART_Slugs[_partMap.get(i)];
		}
		if (str != null) {
			str = str.split("-")[0];
		}
		return str != null && MAP_LOWER_BODY_PARTS.exists(str);
	}


	public function getFocusedLabel(enemyLeftItem:Item, enemyRightItem:Item):String {
		var i = focusedIndex;
		if (i < 0) return "";

		if (_swingMap.exists(i)) {
			return getDollSwingDescAt(_swingMap.get(i));
		} else if (_partMap.exists(i)) {
			return getDollPartThrustDescAt(_partMap.get(i));
		} else if (i == _enemyHandLeftIdx || i == _enemyHandRightIdx) {
			if (i != _enemyHandRightIdx) {
				return enemyLeftItem != null ? enemyLeftItem.name : "enemy's left-hand item";
			} else {
				return enemyRightItem != null ? enemyRightItem.name : "enemy's right-hand item";
			}
		} else {
			return "todo/missing";
		}
	}

	public inline function focusIndexEnemyHandSide(i:Int):Int {
		return (i == _enemyHandLeftIdx ? Inventory.WEAR_LEFT : i == _enemyHandRightIdx ? Inventory.WEAR_RIGHT : 0);
	}



	public function getHitLocationAtFocusIndex(i:Int):HitLocation {
		return getDollPartHitLocationAt(_partMap.get(i));
	}
	public function getDollIndexAtFocusIndex(i:Int):Int {
		return _partMap.get(i);
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
	public inline function setDraggedCP(val:Int):Void {
		draggedCP = val;
	}

	public function getRemainingDisplayCP():Int {
		var dcp = draggedCP;
		var pl = this.getCurrentPlayer();
		//if (pl == null) return 0;
		var cp = pl.fight.cp - dcp;
		return cp >= 0 ? cp : 0;
	}

	public var DOLL_PART_Slugs:Array<String> = [];
	public var DOLL_PART_Indices:Array<Int> = [];
	public var DOLL_PART_HitIndices:Array<Int> = [];
	public var DOLL_PART_IsLefts:Int = 0;
	public inline function isLeftPartAtDollIndex(i:Int):Bool {
		return (DOLL_PART_IsLefts & (1 << i)) != 0;
	}
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
	public var DOLL_SWING_IsLefts:Int = 0;
	public function getDollSwingDescAt(index:Int):String {
		return _body.getDescLabelTargetZone(DOLL_SWING_Indices[index]);
	}
	public function getDollSwingZoneAt(index:Int):TargetZone {
		return _body.targetZones[DOLL_SWING_Indices[index]];
	}

	public var boutModel(default, null):BoutModel; // server side synced data
	public inline function getDefaultPlayerSideIndex():Int {
		return 0;
	}

	public inline function getDefaultEnemySideIndex():Int {
		return 1;
	}

	public static inline var ACTING_DOLL_DECLARE:Int = 0;
	public static inline var ACTING_DOLL_DRAG_CP:Int = 1;
	public static inline var ACTING_NONE:Int = 2;

	public var actingState(default, null):Int = -1;
	public function setActingState(val:Int):Void {
		actingState = val;
	}

	public var currentPlayerIndex(default, set):Int = -1;
	inline function set_currentPlayerIndex(value:Int):Int 
	{
		playerManueverSpec.reset();
		//playerManueverSpec.activeItem = boutModel.bout.combatants[value].charSheet.inventory.findMasterHandItem();
		//trace(playerManueverSpec.activeItem);
		return currentPlayerIndex = value;
	}
	
	public var focusOpponentIndex(default, set):Int = 0;
	inline function set_focusOpponentIndex(value:Int):Int 
	{
		playerManueverSpec.setNewEnemy(boutModel.bout.combatants[value].charSheet.body);
		return focusOpponentIndex = value;
	}

	public inline function getCurrentPlayer():FightNode<CharSheet> {
		return currentPlayerIndex >= 0 ? boutModel.bout.combatants[currentPlayerIndex] : null;
	}

	public inline function getCurrentOpponents():Array<FightNode<CharSheet>> {
		var playerSideIndex = getDefaultPlayerSideIndex();
		if (boutModel.bout == null) return null;
		//trace(bout
		return boutModel.bout.combatants.filter(function(obj) {
			return obj.sideIndex != playerSideIndex;
		});
	}

	public inline function getCurrentActiveOpponents():Array<FightNode<CharSheet>> {
		var pl = this.getCurrentPlayer();
		if (boutModel.bout == null) return null;
		if (pl != null) {
			var r = this.boutModel.bout.linkUpdateCount;
			return this.boutModel.bout.findLinkedOpponents(pl);
		}
		return null;
	}

	public inline function getCurrentAllies():Array<FightNode<CharSheet>> {
		var playerSideIndex = getDefaultPlayerSideIndex();
		if (boutModel.bout == null) return null;
		return boutModel.bout.combatants.filter(function(obj) {
			return obj.sideIndex != playerSideIndex;
		});
	}

	var defaultSwingAvailMask(default, null):Int = 0;
	var defaultThrustAvailMask(default, null):Int = 0;
	public var swingAvailabilityMask(default, null):Int = 0;
	public var thrustAvailabilityMask(default, null):Int = 0;
	public function handleDisabledMask(val:Int, slugs:Array<String>):Void {
		var map = _interactionMaps[ACTING_DOLL_DECLARE];
		for (i in 0...slugs.length) {
			//trace(val + " : "+_dollImageMapData.titleList[map.get(_dollImageMapData.idIndices.get(slugs[i])).index] + " : "+((val & (1<<i)) == 0));
			map.get(_dollImageMapData.idIndices.get(slugs[i])).disabled = ((val & (1<<i)) == 0);
		}
	}
	public function setDisabledAll(slugs:Array<String>, disabled:Bool=true):Void {
		var map = _interactionMaps[ACTING_DOLL_DECLARE];
		for (i in 0...slugs.length) {
			map.get(_dollImageMapData.idIndices.get(slugs[i])).disabled = disabled;
		}
	}
	public function onThrustAvailabilityChange():Void {
		handleDisabledMask(thrustAvailabilityMask, DOLL_PART_Slugs);
	}
	public function onSwingAvailabilityChange():Void {
		handleDisabledMask(swingAvailabilityMask, DOLL_SWING_Slugs);
	}
	
	public function onAdvAvailabilityChange(mask:Int):Void {
		advInteract1.disabled = (mask & (1|16)) != 0;
		advInteract2.disabled = (mask & (2|32)) != 0;
		advInteract3.disabled = (mask & (4|64)) != 0;
		advInteract4.disabled = (mask & (8|128)) != 0;
	}

	public function partIndexAvailable(index:Int):Bool {
		return (thrustAvailabilityMask & (index << 1)) != 0;
	}

	public function swingArcAvailableBetween(slugs:Array<String>):Bool {
		return swingAvailabilityMask & (_dollImageMapData.idIndices.get(slugs[0]) | _dollImageMapData.idIndices.get(slugs[1]) ) != 0;
	}

	// Post initialize
	var _interactionStates:Array<Array<UInteract>>;
	public function getInteractionListByState(state:Int):Array<UInteract> {
		return _interactionStates[state];
	}

	var _interactionMaps:Array<IntMap<UInteract>>;
	var _dollImageMapData:ImageMapData;
	var _body:BodyChar;
	var _swingMap:IntMap<Int>;
	var _partMap:IntMap<Int>;
	var _enemyHandLeftIdx:Int;
	var _enemyHandRightIdx:Int;
	public var advInteract1(default, null):UInteract;
	public var advInteract2(default, null):UInteract;
	public var advInteract3(default, null):UInteract;
	public var advInteract4(default, null):UInteract;

	public function setupDollInteraction(fullInteractList:Array<UInteract>, imageMapData:ImageMapData):Void {
		_interactionMaps = [];
		_interactionStates = [];
		_interactionStates[ACTING_DOLL_DECLARE] = fullInteractList;
		_interactionMaps[ACTING_DOLL_DECLARE] = UInteract.getIndexMapOfArray(fullInteractList);
		_interactionStates[ACTING_DOLL_DRAG_CP] = [];
		_dollImageMapData = imageMapData;
		_interactionStates[ACTING_NONE] = [];
		
		(advInteract1=_interactionMaps[ACTING_DOLL_DECLARE].get(_dollImageMapData.idIndices.get('advManuever1'))).disabled = false;
		(advInteract2=_interactionMaps[ACTING_DOLL_DECLARE].get(_dollImageMapData.idIndices.get('advManuever2'))).disabled = false;
		(advInteract3=_interactionMaps[ACTING_DOLL_DECLARE].get(_dollImageMapData.idIndices.get('advManuever3'))).disabled = false;
		(advInteract4=_interactionMaps[ACTING_DOLL_DECLARE].get(_dollImageMapData.idIndices.get('advManuever4'))).disabled = false;
		

		var body = BodyChar.getInstance();
		_body = body;

		var needToLowercase:Bool;

		_swingMap = new IntMap<Int>();
		_partMap = new IntMap<Int>();

		for (i in 0...imageMapData.layoutItemList.length) {
			var tag = imageMapData.classList[i];
			var name = imageMapData.titleList[i];
			if (tag == "part") {
				_partMap.set(i, DOLL_PART_Slugs.length);
				DOLL_PART_Slugs.push(imageMapData.titleList[i]);

			} else if (tag == "swing") {
				_swingMap.set(i, DOLL_SWING_Slugs.length);
				DOLL_SWING_Slugs.push(imageMapData.titleList[i]);

			} else if (name == "enemyHandLeft") {
				_enemyHandLeftIdx = i;
			} else if (name == "enemyHandRight") {
				_enemyHandRightIdx = i;
			}

		}
		var targetZones = body.targetZones;

		var toUnderscoreCapital:EReg = new EReg(" ([A-Z])", "g");
		var toSlugifyCapital:EReg = new EReg("_([a-z])", "g");

		var mapTempSwings:AbsStringMap<Int> = new AbsStringMap<Int>();
		var mapTempThrusts:AbsStringMap<Int> = new AbsStringMap<Int>();
		var key:String;
		for (i in 0...body.thrustStartIndex) {
			key = toUnderscoreCapital.replace(targetZones[i].name, "_$1").toUpperCase();
			mapTempSwings.set("SWING_"+key, i);
			//trace(key);
		}
		//trace(" to thrusts...");
		for (i in body.thrustStartIndex...targetZones.length) {
			key = toUnderscoreCapital.replace(targetZones[i].name, "_$1").toUpperCase();
			mapTempThrusts.set(key, i);
			if (key == "LOWER_ARM") {	// exception consdieration for Target zone to PART harcodes
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

			DOLL_PART_IsLefts |= keySplit.length >= 2 && keySplit[keySplit.length - 1] == "l" ? (1 << i) : 0;
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

			DOLL_SWING_IsLefts |= keySplit.length >= 2 && keySplit[keySplit.length - 1] == "l" ? (1 << i) : 0;

			key = keySplit[0];
			if (key == "SWING_UPWARD_HEAD") {	// hardcodes exception case , ah well
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

	

}