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
import troshx.sos.manuevers.NetManuevers.NetItems;
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
	var basicShieldBash:Manuever;
	var advSwingArr:Array<Manuever>;
	var advThrustArr:Array<Manuever>;
	var advShieldAttackArr:Array<Manuever>;
	
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
	var basicWeaponThrow:Manuever;
	var advRangedArr:Array<Manuever>;
	
	static inline var B_ATTACK_1H:Int = 1;
	static inline var B_ATTACK_SHIELD:Int = 2;
	static inline var B_ATTACK_2H:Int = 3;
	static inline var B_ATTACK_UNARMED:Int = 0;
	static inline var B_ATTACK_UNARMED_2:Int = 3|4;
	//var browseAttackManueverList(default, null):Array<Int> = [B_ATTACK_1H, B_ATTACK_2H, B_ATTACK_UNARMED, B_ATTACK_UNARMED_2]; 
	//var browseAttackManueverList2(default, null):Array<Int> = [B_ATTACK_1H, B_ATTACK_SHIELD, B_ATTACK_UNARMED];
	
	var browseAttackManueverList3(default, null):Array<Int> = [B_ATTACK_1H, B_ATTACK_2H, B_ATTACK_1H, B_ATTACK_SHIELD, B_ATTACK_UNARMED, B_ATTACK_UNARMED_2];
	var browseAttackManueverList3i(default, null):Array<Bool> = [false, false, true, true, false, false];
	
	var browseManueverIndex:Int = 0;
	public function cycleAttackManueverMode(leftLimb:Bool = false):Void {
		/*
		if (playerManueverSpec.usingLeftLimb != leftLimb) {
			playerManueverSpec.usingLeftLimb = leftLimb;
			browseManueverIndex = 0;
		}
		var tarArr =getTarArr();
		browseManueverIndex++;
		if (browseManueverIndex >= tarArr.length) {
			browseManueverIndex = 0;
		}
		*/
		var tarArr =getTarArr();
		if (leftLimb) {
			browseManueverIndex--;
			if (browseManueverIndex < 0) {
				browseManueverIndex = tarArr.length - 1;
			}
		} else {
			browseManueverIndex++;
			if (browseManueverIndex >= tarArr.length) {
				browseManueverIndex = 0;
			}
		}
		playerManueverSpec.usingLeftLimb = browseAttackManueverList3i[browseManueverIndex];
	}
	public inline function getTarArr():Array<Int> {
		return browseAttackManueverList3;
		//return (playerManueverSpec.usingLeftLimb ? browseAttackManueverList2 : browseAttackManueverList);
	}
	public inline function getBrowseAttackMode():Int {
		return getTarArr()[browseManueverIndex];
	}
	public function getBrowseAttackModeLabel(alsoLeft:Bool):String {
		var tarArr = getTarArr(); // playerManueverSpec.usingLeftLimb && alsoLeft ? browseAttackManueverList2 : browseAttackManueverList;
		var val = tarArr[browseManueverIndex];
		switch (val) {
			case B_ATTACK_1H, B_ATTACK_2H: return "Weapon";
			case B_ATTACK_UNARMED, B_ATTACK_UNARMED_2: return "Unarmed";
			case B_ATTACK_SHIELD: return alsoLeft ? "Shield" : "Weapon";
		}
		return "unfound";
	}
	public function isBrowseHighlightLeft():Bool {
		var tarArr = getTarArr();
		return (playerManueverSpec.usingLeftLimb && tarArr[browseManueverIndex] ==B_ATTACK_1H) || (tarArr[browseManueverIndex] & 2) != 0;
	}
	public function isBrowseHighlightRight():Bool {
		var tarArr =  getTarArr();
		return (tarArr[browseManueverIndex] & 1) != 0;
	}
	
	static var TARGETING_LABELS_MELEE:Array<String> = ["Thrust at", "Swing at"];
	static var TARGETING_LABELS_SHOOT:Array<String> = ["Shoot at", null];
	static var TARGETING_LABELS_THROW:Array<String> = ["Throw at", null];
	static var TARGETING_LABELS_THROW_NET:Array<String> = ["Throw net at", null];
	static var TARGETING_LABELS_SHIELD:Array<String> = ["Shield bash at", null];
	static var TARGETING_LABELS_UNARMED:Array<String> = ["Straight punch at", "Hook punch to", "Downward hook to", "Upward hook to"];
	
	public function getBasicTargetingLabels(?usingNet:Bool):Array<String> {
		var activeItem = playerManueverSpec.activeItem;
		var gotPlayer = this.getCurrentPlayer() != null;
		var b = getBrowseAttackMode();
		
		if (gotPlayer) {
			var weap:Weapon = LibUtil.as(activeItem, Weapon);
			var shield:Shield = LibUtil.as(activeItem, Shield);
			if (weap != null) {
				if (!weap.isRangedWeap()) {
					return TARGETING_LABELS_MELEE;
				} else {
					if (!weap.isThrowing()) {
						return TARGETING_LABELS_SHOOT;
					} else {
						if (usingNet == null) usingNet = isUsingNet();
						return usingNet ? TARGETING_LABELS_THROW_NET : TARGETING_LABELS_THROW;
					}
				}
			}  
			else if (shield != null) {
				return TARGETING_LABELS_SHIELD;
			}
			else {
				return TARGETING_LABELS_UNARMED;
			}
		} else {
			switch (b) {
				case B_ATTACK_1H, B_ATTACK_2H: return TARGETING_LABELS_MELEE;
				case B_ATTACK_SHIELD: return TARGETING_LABELS_SHIELD;
				case B_ATTACK_UNARMED, B_ATTACK_UNARMED_2: return TARGETING_LABELS_UNARMED;
			}
		}
		return TARGETING_LABELS_MELEE;
	}
	
	public function getBasicManuever(?usingNet:Bool):Manuever {
		var spec = playerManueverSpec;
		var activeItem = spec.activeItem;
		var gotPlayer = this.getCurrentPlayer() != null;
		var b = getBrowseAttackMode();
		var enemyBody =  spec.activeEnemyBody;
		var enemyZone = spec.activeEnemyZone;
		
		var f = focusedIndex;
		if (_swingMap.exists(f) || _partMap.exists(f) || f == _enemyHandLeftIdx || f == _enemyHandRightIdx) {
			if (gotPlayer) {
				var weap:Weapon = LibUtil.as(activeItem, Weapon);
				var shield:Shield = LibUtil.as(activeItem, Shield);
				if (weap != null) {
					if (!weap.isRangedWeap()) {
						return enemyBody.isThrusting(spec.activeEnemyZone) ? basicThrust : basicSwing;
					} else {
						if (!weap.isThrowing()) {
							return basicMeleeShoot;
						} else {
							if (usingNet == null) usingNet = isUsingNet();
							return usingNet ? basicNetToss : basicWeaponThrow;
						}
					}
				}  
				else if (shield != null) {
					return basicShieldBash;
				}
				else {
					return enemyBody.isThrusting(enemyZone) ? basicStraightPunch : basicHookPunch;
				}
			} else {
				switch (b) {
					case B_ATTACK_1H, B_ATTACK_2H: return enemyBody.isThrusting(enemyZone) ? basicThrust : basicSwing;
					case B_ATTACK_SHIELD: return basicShieldBash;
					case B_ATTACK_UNARMED, B_ATTACK_UNARMED_2: return enemyBody.isThrusting(enemyZone) ? basicStraightPunch : basicHookPunch;
				}
			}
		} else {
			if (f == btnVoidInteract.index) {
				return basicVoid;
			} else if (f == btnParryInteract.index) {
				return basicParry;
			} else if (f == btnBlockInteract.index ){
				return basicBlock;
			}
			return null;
		}
		return null;
	}
	
	
	public function updateSwingThrustAvails():Void {
		var activeItem = playerManueverSpec.activeItem;
		var gotPlayer = this.getCurrentPlayer() != null;

		if (gotPlayer) {
			var weap:Weapon = LibUtil.as(activeItem, Weapon);
			var shield:Shield = LibUtil.as(activeItem, Shield);
			if (weap != null) {
				if (!weap.isRangedWeap()) {
					thrustAvailabilityMask = defaultThrustAvailMask;
					swingAvailabilityMask = defaultSwingAvailMask;
				} else {
					if (!weap.isThrowing()) {
						thrustAvailabilityMask = defaultThrustAvailMask;
						swingAvailabilityMask = 0;
					} else {
						thrustAvailabilityMask = defaultThrustAvailMask;
						swingAvailabilityMask = 0;
					}
				}
			}  
			else if (shield != null) {
				thrustAvailabilityMask = defaultThrustAvailMask;
				swingAvailabilityMask = 0;
			}
			else {
				thrustAvailabilityMask = defaultThrustAvailMask;
				swingAvailabilityMask = defaultSwingAvailMask;
			}
		} else {
			thrustAvailabilityMask = defaultThrustAvailMask;
			swingAvailabilityMask = defaultSwingAvailMask;
		}
	}
	
	public function onThrustAvailabilityChange():Void {
		handleDisabledMask(thrustAvailabilityMask, DOLL_PART_Slugs);
		var i = focusedIndex;
		if (_partMap.exists(i)) {
			//if (thrustAvailabilityMask == 0) focusedIndex = 0;
			//map.get(_dollImageMapData.idIndices.get(slugs[i]))
			if ((thrustAvailabilityMask & (1 << _partMap.get(i)) == 0)) {
				focusedIndex = -1;
			}
		}
	}
	public function onSwingAvailabilityChange():Void {
		handleDisabledMask(swingAvailabilityMask, DOLL_SWING_Slugs);
		var i = focusedIndex;
		if (_swingMap.exists(i)) {
			//if (swingAvailabilityMask == 0) focusedIndex = 0;
			if ((swingAvailabilityMask & (1 << _swingMap.get(i)) == 0)) {
				focusedIndex = -1;
			}
		}
	}
	
	public function togglePlayerMasterhandSlot():Void {
		var pl = getCurrentPlayer();
		lastToggleMasterSlot = true;
		
		var weaponAssign:WeaponAssign = pl.charSheet.inventory.getMasterWeaponAssign();
		var weapon:Weapon = Inventory.weaponFromAssign(weaponAssign);
		playerManueverSpec.usingLeftLimb = false;
		if (weaponAssign != null) {
			if (playerManueverSpec.activeItem != null && weapon == playerManueverSpec.activeItem) {
				if (weaponAssign.held == Inventory.HELD_BOTH && (!weapon.twoHanded || Weapon.isTwoHandedOff(weapon)) && weapon.variant !=null ) {
					weapon = weapon.variant;
					weaponAssign.holding1H = true;
					weaponAssign.held = Inventory.HELD_MASTER;
					playerManueverSpec.activeItem = weapon;
				} else {
					playerManueverSpec.activeItem = null;
					pl.charSheet.inventory.holdBackWeaponNormalise(weaponAssign);
				}
			} else {
				pl.charSheet.inventory.holdBackWeaponNormalise(weaponAssign);
				playerManueverSpec.activeItem = weapon;
			}
			return;
		}

		// for simplficiation in combat, all items assumed to not need two-handed carries
		var item:Item = pl.charSheet.inventory.findMasterHandItem();
		 if (playerManueverSpec.activeItem != null && item ==  playerManueverSpec.activeItem) {
			playerManueverSpec.activeItem = null;
		} else {
			playerManueverSpec.activeItem = item;
		}
	}
	public function togglePlayerOffhandSlot():Void {
		var pl = getCurrentPlayer();
		lastToggleMasterSlot = false;
	
		var item:Item = pl.charSheet.inventory.findOffHandItem();
		 if (item ==  playerManueverSpec.activeItem) {
			playerManueverSpec.activeItem = null;
			playerManueverSpec.usingLeftLimb = false;
		} else {
			playerManueverSpec.activeItem = item;
			playerManueverSpec.usingLeftLimb = true;
		}
	}
	
	
	
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
		
		// todo: netFeint
		
		basicSwing = manueverRepo.get('swing');
		basicThrust = manueverRepo.get('thrust');
		basicShieldBash = manueverRepo.get("shieldBash");
		basicMeleeShoot = manueverRepo.get("meleeShoot");
		basicWeaponThrow = manueverRepo.get("weaponThrow");
		
		advSwingArr = ['drawCut', 'cleavingBlow', 'hook', 'feint'].map(manueverRepo.get);
		advThrustArr = ['pushCut', 'jointThrust', 'hook', 'feint'].map(manueverRepo.get);
		advShieldAttackArr = ['', '', '', 'shieldFeint'].map(manueverRepo.get);
		
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
		basicWeaponThrow = manueverRepo.get("weaponThrow"); // if optional training weapon
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
	
	public function isDefBtnBlockAllowed():Bool {
		var pl = this.getCurrentPlayer();
		if (pl==null) return false;
		return pl.charSheet.inventory.findHeldShieldAssign() != null;
	}
	public function isDefBtnParryAllowed():Bool {
		var pl = this.getCurrentPlayer();
		var offhandPrefer = this.playerManueverSpec.usingLeftLimb;
		if (pl == null) return false;
		var w = offhandPrefer ? pl.charSheet.inventory.getOffhandWeapon() : pl.charSheet.inventory.getMasterWeapon();
		if (w != null) {
			return w.dtn >= 1;
		}
		return false;
	}
	
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
	
	public function isUsingNet():Bool {
		var weap:Weapon = LibUtil.as(playerManueverSpec.activeItem, Weapon);
		if (weap != null) {
			var throwing = weap.isThrowing();
			return throwing && NetItems.STUFF.indexOf(weap.name) >= 0;
		}
		return false;
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
	public function getAdvancedManuevers(curPlayer:FightNode<CharSheet>=null, playerLeftItem:Item=null, playerRightItem:Item=null, curEnemy:FightNode<CharSheet>=null, enemyLeftItem:Item=null, enemyRightItem=null, preferOneTwoPunch:Bool=false):Array<Manuever> {
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
		/*
		if (curPlayer == null) {
			// todo: dummy catalog only without filtering player state
			return EMPTY_ARR;
		}
		*/
		
		if (targetZone >= 0) {
			if (curPlayer == null) {
				var mode:Int = getBrowseAttackMode();
				if (mode == CombatViewModel.B_ATTACK_1H || mode == CombatViewModel.B_ATTACK_2H) {
					return manueverSpec.activeEnemyBody.isThrusting(targetZone) ? advThrustArr : advSwingArr; // todo: makeshift, 3 types..
				} else if (mode == CombatViewModel.B_ATTACK_UNARMED_2 || mode == CombatViewModel.B_ATTACK_UNARMED) {
					return mode == CombatViewModel.B_ATTACK_UNARMED_2 ? advPuglismThrustSwingArr : advPuglismHandlessArr;
				} else if (mode == CombatViewModel.B_ATTACK_SHIELD) {
					return advShieldAttackArr;
				}
			}  else if (manueverSpec.activeItem == null) {
				return preferOneTwoPunch ? advPuglismThrustSwingArr : advPuglismHandlessArr;
			}
			
			if (manueverSpec.activeEnemyBody.isThrusting(targetZone)) {
				return advThrustArr;
			} else {
				return advSwingArr;
			}
		} else {
			if (focusIndex == _enemyHandLeftIdx || focusIndex == _enemyHandRightIdx) {
				if (curPlayer == null) {
					var mode:Int = getBrowseAttackMode();
					if (mode == CombatViewModel.B_ATTACK_1H || mode == CombatViewModel.B_ATTACK_2H) {
						return Std.is(manueverSpec.activeEnemyItem, Shield) ? advAntiShieldWithWeaponArr : advAntiWeapWithWeaponArr; // todo: makeshift, 3 types..
					} else if (mode == CombatViewModel.B_ATTACK_UNARMED_2 || mode == CombatViewModel.B_ATTACK_UNARMED) {
						return Std.is(manueverSpec.activeEnemyItem, Shield) ? EMPTY_ARR : advAntiHandUnarmedArr;
					} else if (mode == CombatViewModel.B_ATTACK_SHIELD) {
						return Std.is(manueverSpec.activeEnemyItem, Shield) ? EMPTY_ARR : advAntiHandWithShieldArr;
					}
				}
				else if (Std.is(manueverSpec.activeItem, Weapon)) {
					return Std.is(manueverSpec.activeEnemyItem, Shield) ? advAntiShieldWithWeaponArr : advAntiWeapWithWeaponArr;
				} else if (Std.is(manueverSpec.activeItem, Shield)) {
					return advAntiHandWithShieldArr;
				}
				return advAntiHandUnarmedArr; 
				//advAntiHandUnarmedArr
				// advAntiHandWithShieldArr
			} else if (isDefensiveFocusIndex(focusIndex)) {
				return focusIndex == btnBlockInteract.index ? advBlockArr : focusIndex == btnParryInteract.index ? advParryArr : focusIndex == btnVoidInteract.index ? advVoidArr : EMPTY_ARR;
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


	public function getFocusedLabel(enemyLeftItem:Item, enemyRightItem:Item, lblDescs:Array<String>=null):String {
		var i = focusedIndex;
		if (i < 0) return "";
		
		if (_swingMap.exists(i)) {
			return lblDescs!= null ? _body.getDescLabelTargetZone(DOLL_SWING_Indices[_swingMap.get(i)], lblDescs[0], lblDescs[1], lblDescs.length >= 3 ? lblDescs.slice(2) : null) : getDollSwingDescAt(_swingMap.get(i));
		} else if (_partMap.exists(i)) {
			return lblDescs!=null ? _body.getDescLabelTargetZone(DOLL_PART_Indices[_partMap.get(i)], lblDescs[0], lblDescs[1]) : getDollPartThrustDescAt(_partMap.get(i));
		} else if (i == _enemyHandLeftIdx || i == _enemyHandRightIdx) {
			if (i != _enemyHandRightIdx) {
				return enemyLeftItem != null ? enemyLeftItem.name : "enemy's left-hand item";
			} else {
				return enemyRightItem != null ? enemyRightItem.name : "enemy's right-hand item";
			}
		} else  {
			return DOLL_GENERAL_FOCUS_DESC.exists(i) ? DOLL_GENERAL_FOCUS_DESC.get(i) : "todo/missing";
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
	
	public var DOLL_GENERAL_FOCUS_DESC:IntMap<String> = new IntMap<String>();
	
	public function getGeneralFocusDescAt(index:Int):String {
		return DOLL_GENERAL_FOCUS_DESC.get(index);
	}
	
	public inline function isDefensiveFocusIndex(index:Int):Bool {
		return index == btnBlockInteract.index || index == btnParryInteract.index || index == btnVoidInteract.index;
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
		playerManueverSpec.resetPlayer();
		lastToggleMasterSlot = true;
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
	
	public var lastToggleMasterSlot(default, null):Bool = true;
	
	public var advInteract1(default, null):UInteract;
	public var advInteract2(default, null):UInteract;
	public var advInteract3(default, null):UInteract;
	public var advInteract4(default, null):UInteract;
	
	public var btnBlockInteract(default, null):UInteract;
	public var btnVoidInteract(default, null):UInteract;
	public var btnParryInteract(default, null):UInteract;
	
	/*
	 * todo:
	Low priority: Blind Toss items
	*/

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
		(advInteract4 = _interactionMaps[ACTING_DOLL_DECLARE].get(_dollImageMapData.idIndices.get('advManuever4'))).disabled = false;
		
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
		
		(btnBlockInteract = _interactionMaps[ACTING_DOLL_DECLARE].get(_dollImageMapData.idIndices.get('btnBlock'))).disabled = true;
		(btnVoidInteract=_interactionMaps[ACTING_DOLL_DECLARE].get(_dollImageMapData.idIndices.get('btnVoid'))); //.disabled = true
		(btnParryInteract = _interactionMaps[ACTING_DOLL_DECLARE].get(_dollImageMapData.idIndices.get('btnParry'))).disabled = true;
		DOLL_GENERAL_FOCUS_DESC.set(btnBlockInteract.index, basicBlock.name);
		DOLL_GENERAL_FOCUS_DESC.set(btnVoidInteract.index, basicVoid.name);
		DOLL_GENERAL_FOCUS_DESC.set(btnParryInteract.index, basicParry.name);
	}

	

}