CONST ZONE_VIII = 7

CONST MANUEVER_HAND_NONE = 0
CONST MANUEVER_HAND_MASTER = 1
CONST MANUEVER_HAND_SECONDARY = 2
CONST MANUEVER_HAND_BOTH = 3

CONST DAMAGE_TYPE_CUTTING =1
CONST DAMAGE_TYPE_PUNCTURING = 2 
CONST DAMAGE_TYPE_BLUDGEONING = 3
=== function getDamageTypeLabel(damageType) 
{ 
	- damageType == DAMAGE_TYPE_CUTTING: ~return "cutting"
	- damageType == DAMAGE_TYPE_PUNCTURING: ~return "puncturing"
	- damageType == DAMAGE_TYPE_BLUDGEONING: ~return "bludgeoning"
	-else:
	~elseResulted = 1
}
~return "none"

CONST ATTACK_TYPE_STRIKE = 1
CONST ATTACK_TYPE_THRUST = 2
=== function getAttackTypeLabel(attackType) 
{ 
	- attackType == ATTACK_TYPE_STRIKE: ~return "striking"
	- attackType == ATTACK_TYPE_THRUST: ~return "thrusting"
	-else:
	~elseResulted = 1
}
~return "none"



CONST MANUEVER_TYPE_MELEE = 0
CONST MANUEVER_TYPE_RANGED = 1
=== function getManueverTypeLabel(manueverType) 
{ 
	- manueverType == MANUEVER_TYPE_MELEE: ~return "melee"
	- manueverType == MANUEVER_TYPE_RANGED: ~return "ranged"
	-else:
	~elseResulted = 1
}
~return "none"


// return 9999999 cost if invalid against profeciency, to filter away
=== function getManueverCostWithProfeciency(profeciencyType, manueverType, hasShield)
// TODO
~ return 0


=== function isThrustingMotion(targetZone)
{
	- targetZone >= ZONE_VIII:
	~return 1
	- else:
	~return 0
}

=== function getManueverSelectReadonlyDependencies(charId,   ref initiative, ref profeciencyType, ref profeciencyLevel, ref diceAvailable, ref orientation, ref hasShield  ,   ref lastAttacked, ref DTN, ref DTNt, ref DTN_off, ref DTNt_off   ,   ref ATN, ref ATN2, ref ATN_off, ref ATN2_off, ref blunt,  ref hasShield, ref damage, ref damage2, ref damage3, ref damage_off, ref damage2_off, ref damage3_off, ref shieldLimit, ref weaponMainLabel, ref weaponOffhandLabel, ref twoHanded )
~temp x
{
///* player
- charId == charPersonName_id:
	// common to both attack/defense
	~initiative = charPersonName_fight_initiative
	~profeciencyType = charPersonName_usingProfeciency
	~profeciencyLevel = charPersonName_usingProfeciencyLevel
	~diceAvailable = charPersonName_cp
	~orientation = charPersonName_fight_orientation
	~lastAttacked = charPersonName_fight_lastAttacked
//getAllWeaponStats(weaponId, ref name, ref isShield, ref damage, ref damage2, ref damage3, ref attrBaseIndex,  ref dtn, ref dtnT, ref atn, ref atn2, ref blunt ,   ~ref shieldLimit  )
	{getAllWeaponStats(charPersonName_equipMasterhand, weaponMainLabel, hasShield,  damage, damage2, damage3,x,DTN, DTNt, ATN, ATN2, blunt, shieldLimit, twoHanded )}
	{getAllWeaponStats(charPersonName_equipOffhand, weaponOffhandLabel, hasShield, damage_off,damage2_off,damage3_off,x,DTN_off, DTNt_off, ATN_off, ATN2_off, blunt, shieldLimit, twoHanded )}

//*/
///* utest
- charId == charPersonName2_id:

	~initiative = charPersonName2_fight_initiative
	~profeciencyType = charPersonName2_usingProfeciency
	~profeciencyLevel = charPersonName2_usingProfeciencyLevel
	~diceAvailable = charPersonName2_cp
	~orientation = charPersonName2_fight_orientation
	~lastAttacked = charPersonName2_fight_lastAttacked
	{getAllWeaponStats(charPersonName2_equipMasterhand, weaponMainLabel, hasShield,  damage, damage2, damage3,x,DTN, DTNt, ATN, ATN2, blunt, shieldLimit, twoHanded )}
	{getAllWeaponStats(charPersonName2_equipOffhand, weaponOffhandLabel, hasShield, damage_off,damage2_off,damage3_off,x,DTN_off, DTNt_off, ATN_off, ATN2_off, blunt, shieldLimit, twoHanded )}
//*/
-else:
	~elseResulted = 1
}





=== function getManueverSelectReadonlyEnemyDependencies(charId, enemyId, ref enemyDiceRolled, ref enemyTargetZone, ref enemyManueverType)
~temp x
~temp target
~temp target2
{
///* player
- enemyId == charPersonName_id:
	{getTargetInitiativeStatesByCharId(enemyId, x, x, x, x, target, target2)}
	{
 	- target == charId: 
 		//  enemy targeting character
 		~enemyDiceRolled = charPersonName_manuever_rollAmount
 		~enemyTargetZone = charPersonName_manuever_targetZone
 		~enemyManueverType = charPersonName_manueverAttackType
 	- target2 == charId: 
 		//  enemy targeting character
 		~enemyDiceRolled = charPersonName_manuever2_rollAmount
 		~enemyTargetZone = charPersonName_manuever2_targetZone
 		~enemyManueverType = charPersonName_manuever2AttackType
 	- else: 
 		// enemy not targeting character but someone else
 		~enemyDiceRolled = 0
 		~enemyTargetZone = 0
 		~enemyManueverType = 0
 	}
//*/
///* utest
- enemyId == charPersonName2_id:
	{getTargetInitiativeStatesByCharId(enemyId, x, x, x, x, target, target2)}
	{	
	- target == charId: 
 		//  enemy targeting character
 		~enemyDiceRolled = charPersonName2_manuever_rollAmount
 		~enemyTargetZone = charPersonName2_manuever_targetZone
 		~enemyManueverType = charPersonName2_manueverAttackType
 	- target2 == charId: 
 		//  enemy targeting character
 		~enemyDiceRolled = charPersonName2_manuever2_rollAmount
 		~enemyTargetZone = charPersonName2_manuever2_targetZone
 		~enemyManueverType = charPersonName2_manuever2AttackType
 	- else:
 		~enemyDiceRolled = 0
 		~enemyTargetZone = 0
 		~enemyManueverType = 0
 	}
//*/
-else:
	~enemyDiceRolled = 0
	~enemyTargetZone = 0
	~enemyManueverType = 0
}


=== PrepareManueversForChar(charId, charTarget, charIsPlayer, ->callbackToMainLoop)
~temp opponentCount = 0
~temp charHasPrimaryTarget = 0
~temp redirectBack
~temp totalOpponentsLeft

///* utest all
{
	- charPersonName_FIGHT && (charPersonName_id == charTarget || charPersonName_fight_target == charId):
		~opponentCount = opponentCount+1
		{	charPersonName_id == charTarget:
			~charHasPrimaryTarget = 1
		}
}
{
	- charPersonName2_FIGHT && (charPersonName2_id == charTarget || charPersonName2_fight_target == charId):
		~opponentCount = opponentCount+1
		{	charPersonName_id == charTarget:
			~charHasPrimaryTarget = 1
		}
}
//*/
{
	- opponentCount > 1:
		~redirectBack = ->ConsiderNextOpponent
	-else:
		~redirectBack = callbackToMainLoop
}

~totalOpponentsLeft = opponentCount
{
	- opponentCount == 0:
		-> callbackToMainLoop
}
->ConsiderOpponents( 0)

= PrepareManueversForCharLooseEndError
PrepareManueversForCharLooseEndError detected. This should not happen!
->DONE


= ConsiderNextOpponent
~totalOpponentsLeft = totalOpponentsLeft - 1
{
	- totalOpponentsLeft:
		-> ConsiderOpponents(0)
	-else:
		->callbackToMainLoop
}
-> PrepareManueversForCharLooseEndError


= ConsiderOpponents(_confirming )
~temp useSlotIndex
~temp secondarySlotIndex
~temp asPrimaryTarget

// todo: for dealing with multiple opponents find a way and multiple attacks, find a way to determine secondarySlotIndex and persitant handmask 0 0 , 

{opponentCount > 1 && charIsPlayer && _confirming == 0: Pick an opponent to deal against:}
///* utest all resolution
{
	- (_confirming==0 || _confirming == charPersonName_id) && charPersonName_FIGHT && (charPersonName_id == charTarget || charPersonName_fight_target == charId):
		
		{
			- charHasPrimaryTarget && charPersonName_id == charTarget: 
				~useSlotIndex = 1
				asPrimaryTarget = 1
			- else:
				~useSlotIndex = secondarySlotIndex
		}
		{
			- _confirming == 0 && charIsPlayer && opponentCount>1:
				+  [{charPersonName_label} {asPrimaryTarget:(Your target)}]
				-> ConsiderOpponents(charPersonName_id)
			- else:
				-> ProceedToActionAgainst(useSlotIndex, charId, charPersonName_id, 0, 0, redirectBack)
		}
}
{
	- (_confirming==0 || _confirming == charPersonName2_id) && charPersonName2_FIGHT && (charPersonName2_id == charTarget || charPersonName2_fight_target == charId):
		
		{
			- charHasPrimaryTarget && charPersonName2_id == charTarget: 
				~useSlotIndex = 1
				asPrimaryTarget = 1
			- else:
				~useSlotIndex = secondarySlotIndex
		}
		{
			- _confirming == 0 && charIsPlayer && opponentCount>1:
				+  [{charPersonName2_label} {asPrimaryTarget:(Your target)}]
				-> ConsiderOpponents(charPersonName2_id)
			- else:
				-> ProceedToActionAgainst(useSlotIndex, charId, charPersonName2_id, 0, 0, redirectBack)
		}
}
//*/

/*
Run through the list of enemies in reverse reflex declaration order (highest reflex to lowest), 
and
List out any manuevers they might have declared previously.
If only 1 count of opponent, proceed immediately into ChooseManueverForChar for that opponent..
else...
else let Multiple opponents menu display, showing list of opponents to handle by generating the options instead

Player is free to able to address different targets as they see fit.,.but once they commit to a manuever against that opponent for that manuever slot, the opponent and manuever slot is no longer selectable.
slotIndex will be "1" for primary target always
slotIndex will either be "2" or "3", depending which is already used up.
*/
->PrepareManueversForCharLooseEndError

=== function determineHandsFree( ref secSlotIndex, ref charNoMasterHand, ref charNoOffHand, manuever, manueverUsingHands, manuever2, manuever2UsingHands, manuever3, manuever3UsingHands )
{
- manuever2 == "":
	~secSlotIndex = 2

-else:
	~secSlotIndex = 3
}
~temp handBitResult = 0
{
- (manuever == "")==0:
	~flag_OR_2Bits(handBitResult, manueverUsingHands)
}
{
- (manuever2 == "")==0:
	~flag_OR_2Bits(handBitResult, manuever2UsingHands)
}
{
- (manuever3 == "")==0:
	~flag_OR_2Bits(handBitResult, manuever3UsingHands)
}

{
	-handBitResult == MANUEVER_HAND_BOTH:
		~charNoMasterHand = 1
		~charNoOffHand =1
	-handBitResult == MANUEVER_HAND_MASTER:
		~charNoMasterHand = 1
	-handBitResult == MANUEVER_HAND_SECONDARY:
		~charNoOffHand = 1
	-else:
		~elseResulted = 1
}


=== function inspectHandsFree(charId, ref secSlotIndex, ref charNoMasterHand, ref charNoOffHand) 
///* utest all 
{
	-charId == charPersonName_id:
		~determineHandsFree(secSlotIndex, charNoMasterHand, charNoOffHand, charPersonName_manuever, charPersonName_manueverUsingHands, charPersonName_manuever2, charPersonName_manuever2UsingHands, charPersonName_manuever3, charPersonName_manuever3UsingHands)
	-charId == charPersonName2_id:
		~determineHandsFree(secSlotIndex, charNoMasterHand, charNoOffHand, charPersonName2_manuever, charPersonName2_manueverUsingHands, charPersonName2_manuever2, charPersonName_manuever2UsingHands, charPersonName2_manuever3, charPersonName2_manuever3UsingHands)
	-else:
		~elseResulted = 1
}
//*/


=== ProceedToActionAgainst(slotIndex, charId, enemyId,  charNoMasterHand, charNoOffHand, ->doneCallbackThread) 
{
- slotIndex == 1:
	{	
	///* utest all 
	- charId == charPersonName_id: 
		->ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, doneCallbackThread,  charPersonName_manuever,  charPersonName_manueverCost, charPersonName_manueverTN, charPersonName_manueverAttackType, charPersonName_manueverDamageType, charPersonName_manueverNeedBodyAim, charPersonName_manuever_attacking, charPersonName_manueverUsingHands )
	- charId == charPersonName2_id:
		->ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, doneCallbackThread,  charPersonName_manuever,  charPersonName2_manueverCost, charPersonName2_manueverTN, charPersonName2_manueverAttackType, charPersonName2_manueverDamageType, charPersonName2_manueverNeedBodyAim, charPersonName2_manuever_attacking, charPersonName2_manueverUsingHands )
	-else:
		~elseResulted = 1
	//*/
	}
- slotIndex == 2:
	{	
	///* utest all 
	- charId == charPersonName_id: 
		->ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, doneCallbackThread,  charPersonName_manuever2,  charPersonName_manuever2Cost, charPersonName_manuever2TN, charPersonName_manuever2AttackType, charPersonName_manuever2DamageType, charPersonName_manuever2NeedBodyAim, charPersonName_manuever2_attacking, charPersonName_manuever2UsingHands )
	- charId == charPersonName2_id:
		->ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, doneCallbackThread,  charPersonName2_manuever2,  charPersonName2_manuever2Cost, charPersonName2_manuever2TN, charPersonName2_manuever2AttackType, charPersonName2_manuever2DamageType, charPersonName2_manuever2NeedBodyAim, charPersonName2_manuever2_attacking, charPersonName2_manuever2UsingHands )
	-else:
		~elseResulted = 1
	//*/
	}
- else:
	{
	///* utest all 
	- charId == charPersonName_id: 
		->ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, doneCallbackThread,  charPersonName_manuever3,  charPersonName_manuever3Cost, charPersonName_manuever3TN, charPersonName_manuever3AttackType, charPersonName_manuever3DamageType, charPersonName_manuever3NeedBodyAim, charPersonName_manuever3_attacking, charPersonName_manuever3UsingHands )
	- charId == charPersonName2_id:
		->ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, doneCallbackThread, charPersonName2_manuever3,  charPersonName2_manuever2Cost, charPersonName2_manuever3TN, charPersonName2_manuever3AttackType, charPersonName2_manuever3DamageType, charPersonName2_manuever3NeedBodyAim, charPersonName2_manuever3_attacking, charPersonName2_manuever3UsingHands )
	-else:
		~elseResulted = 1
	//*/
	}
}

=== ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, ->doneCallbackThread, ref manuever, ref manueverCost, ref manueverTN, ref manueverAttackType, ref manueverDamageType, ref manueverNeedBodyAim, ref manueverIsAttacking, ref manueverUseHands)

// Read-only Dependencies for manuever selection/consideration to request by reference
// dummy variable to hold as unused referenced
~temp x

// common to both attack/defense
~temp _profeciencyType
~temp _profeciencyLevel
~temp _diceAvailable
~temp _orientation
~temp _hasShield     
// for defending only
~temp _lastAttacked
~temp _shieldLimit
// enemy specific
~temp _enemyDiceRolled
~temp _enemyTargetZone
~temp _enemyManueverType
// -----
~temp _DTN
~temp _DTNt
~temp _DTN_off
~temp _DTNt_off
// for attacking only
~temp _ATN 
~temp _ATN2
~temp _ATN_off
~temp _ATN2_off
~temp _equipMainHand
~temp _blunt  
~temp _damage
~temp _damage2
~temp _damage3
~temp _damage_off
~temp _damage2_off
~temp _damage3_off
~temp _equipOffhand
// target iniaitive states
~temp _initiative
~temp _charTarget
~temp _charTarget2
~temp _twoHanded

~temp preferOffhand = 0


// initaitive, orientation, ref t_paused, ref t_lastAttacked, ref t_target, ref t_target2
{getTargetInitiativeStatesByCharId(charId, _initiative, x, x, x,  _charTarget , _charTarget2 )}


~temp _isAI
 {getCharMetaInfo(charId, x, _isAI,x,x)}


~temp choiceCount = 0
~temp stipulateCost
~temp stipulateTN

// kiv: some overlap below with getTargetInitiativeStatesByCharId() by above, can consider re-factoring later? bah nvm..
{getManueverSelectReadonlyDependencies(charId, x, _profeciencyType, _profeciencyLevel, _diceAvailable, _orientation, _hasShield  ,   _lastAttacked,    _DTN, _DTNt, _DTN_off, _DTNt_off   ,    _ATN, _ATN2,  _ATN_off, _ATN2_off, _blunt,   _hasShield,   _damage, _damage2, _damage3, _damage_off, _damage2_off, _damage3_off, _shieldLimit, _equipMainHand, _equipOffhand, _twoHanded)}
{getManueverSelectReadonlyEnemyDependencies(charId, enemyId, _enemyDiceRolled, _enemyTargetZone, _enemyManueverType)}


// TOCHECK when dealing against multiple enemies
{
	- _initiative && _charTarget != enemyId:
		~_initiative = 0
		{	
			- slotIndex == 2 && currentlyBeingAttackedBy(charId, enemyId, 1) && (charNoMasterHand==0 || charNoOffHand==0): 
				~_initiative = 1
		}
}

{
- charNoMasterHand:
	_DTN = 0
	_DTNt = 0
	_ATN = 0
	_ATN2 = 0
}
{
- charNoOffHand:
	_DTN_off = 0
	_DTNt_off = 0
	_ATN_off = 0
	_ATN2_off = 0
}
{
	-preferOffhand:
	_DTN = 0
	_DTNt = 0
	_ATN = 0
	_ATN2 = 0
}

initiative:{_initiative} 
CP: {_diceAvailable} 
Hands available: Rt:{charNoMasterHand:0|1} lt:{charNoOffHand:0|1} 
ATNS: {_ATN} {_ATN2} 
ATNS offhand: {_ATN_off} {_ATN2_off}
DTNs: {_DTN} {_DTNt}
DTNS offhand: {_DTN_off} {_DTNt_off}
Prof: {_profeciencyType}
ProfLevel: {_profeciencyLevel}
HasShield: {_hasShield}
Last Attacked: {_lastAttacked}
Blunt Weapon: {_blunt}
isAI?:{_isAI}

// all recorded attack action availabilities
~temp AVAIL_bash = 0
~temp AVAIL_spike = 0
~temp AVAIL_cut = 0
~temp AVAIL_thrust = 0
~temp AVAIL_beat = 0
~temp AVAIL_bindstrike = 0

// all recorded defend actoin availabilities
~temp AVAIL_block = 1
~temp AVAIL_parry = 1
~temp AVAIL_duckweave =1
~temp AVAIL_partialevasion = 1
~temp AVAIL_fullevasion = 1
~temp AVAIL_blockopenstrike = 1
~temp AVAIL_counter = 1
~temp AVAIL_rota = 1
~temp AVAIL_expulsion = 1
~temp AVAIL_disarm = 1

~temp altAction
~temp divertTo
~temp aiFavCount

~temp theConfirmedManuever

{
	- _isAI: 
	~altAction = 1
	~divertTo = ->AIManueverDecision
	- else:
	~altAction = 0
	~divertTo = ->ChooseManueverMenu
}

{
	- _initiative:
		Attack
		-> ChooseManueverListAtk(0,altAction,divertTo )
	- else:
		Defend
		-> ChooseManueverListDef(0,altAction,divertTo)
}
->ChooseManueverMenu


= AIManueverConfirmFailedError
AIManueverConfirmFailedError detected. This should not happen!
->DONE

= AILooseEndError
AILooseEndError :: AI decision loose-end reached.
->DONE



= AIManueverDecision
{
	- _initiative:
		-> AIManueverDecision_MakeRandomChoiceFavAtk(0, ->AIManueverMakeFavDecisionNow)
	- else:
		-> AIManueverDecision_MakeRandomChoiceFavDef(0, ->AIManueverMakeFavDecisionNow)
}
->AILooseEndError



= AIManueverMakeFavDecisionNow
~temp rollChoice
{
	- aiFavCount > 1:
		~rollChoice = rollNSided(aiFavCount)
	- aiFavCount == 1 :
		~rollChoice = 1
	- aiFavCount ==0 :
		->AICannotMakeFavDecision
	-else:
		~elseResulted = 1
}
{
	- _initiative:
		-> AIManueverDecision_MakeRandomChoiceFavAtk(rollChoice, ->AICannotMakeFavDecision)
	- else:
		-> AIManueverDecision_MakeRandomChoiceFavDef(rollChoice, ->AICannotMakeFavDecision)
}
->AILooseEndError



= AICannotMakeFavDecision
AI cannot make default decision from favourites. Handler todo:...
Choice count..any choices? {choiceCount}
For now, he will Do Nothing.
->doneCallbackThread


// How it works?
// set parameter confirmDiceCHoice =0, if no finalised roll is made, but just need to consider numDice to roll based off aiFavCount
// then re-call the same function with an N-sided dice roll to pick one of 'em'
// Same trick applies to other AI menu selection routines

= AIManueverDecision_MakeRandomChoiceFavAtk(confirmDiceChoice, ->noDecisionMadeYetCallback)
~aiFavCount = 0
// kiv:  ai can check more factors to determine if each move should be considered as a "favourite", such as how worth it is the expenditure for certain manuevers and such, etc. whether lower TN to gain intiative is more crucial then analysed reward, etc.
{
- _blunt:
	{
		-AVAIL_bash:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListAtk("bash", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_bash:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListAtk("bash", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_spike:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListAtk("spike", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_beat:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListAtk("beat", 1, ->AIManueverConfirmFailedError) }
	}
- else:
	{
		-AVAIL_cut:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListAtk("cut", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_thrust:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListAtk("thrust", 1, ->AIManueverConfirmFailedError) }
	}
}
->noDecisionMadeYetCallback


= AIManueverDecision_MakeRandomChoiceFavDef(confirmDiceChoice, ->noDecisionMadeYetCallback)
~aiFavCount = 0
// kiv:  ai can check more factors to determine if each move should be considered as a "favourite", such as how worth it is the expenditure for certain manuevers and such, etc. Example, if he is low on CP, he'll not bother risking life and limb with more expensives moves, etc.
// . whether lower TN to gain intiative is more crucial then analysed reward, etc.
// especially: whether to run or not, or go for some form of evasion
{
- _hasShield:
	{
		-AVAIL_block:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("block", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_block:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("block", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_block:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("block", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_block:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("block", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_blockopenstrike:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("blockopenstrike", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_blockopenstrike:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("blockopenstrike", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_blockopenstrike:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("blockopenstrike", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_expulsion:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("expulsion", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_fullevasion:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("fullevasion", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_partialevasion:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("partialevasion", 1, ->AIManueverConfirmFailedError) }
	}
- else:
	{
		-AVAIL_parry:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("parry", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_parry:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("parry", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_parry:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("parry", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_counter:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("counter", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_counter:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("parry", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_rota:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("rota", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_expulsion:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("expulsion",1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_disarm:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("disarm", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_fullevasion:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("fullevasion", 1, ->AIManueverConfirmFailedError) }
	}
	{
		-AVAIL_partialevasion:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("partialevasion", 1, ->AIManueverConfirmFailedError) }
	}
}
->noDecisionMadeYetCallback


= ToggleOffHandOnly
{
	- preferOffhand:
		preferOffhand  = 0
	-else:
		preferOffhand = 1
}
{
	-preferOffhand:
		You switched to your off-hand. 
		.....
		{
		- preferOffhand:
			_DTN = 0
			_DTNt = 0
			_ATN = 0
			_ATN2 = 0
		}
	-else:
		You switched back to your main hand(s).
		{
		- charNoMasterHand == 0:
			getManueverSelectReadonlyDependencies(charId, x, x, x, x, x, x  ,   x,    _DTN, _DTNt, _DTN_off, _DTNt_off   ,    _ATN, _ATN2,  _ATN_off, _ATN2_off, x,   x,   x, x, x, x, x, x, x, x, x, x)
		}
}
-> ChooseManueverMenu


//Read more: http://opaque.freeforums.net/thread/22/combat-simulator#ixzz4BUQY0dl5
// todo kiv other action types
= ChooseManueverMenu
Choose the nature of your action {preferOffhand: (off-hand)}
+  {_initiative}  Attack
	-> ChooseManueverListAtk(0,0,->ChooseManueverMenu )
+ {_initiative==0}  Defend 
	-> ChooseManueverListDef(0,0,->ChooseManueverMenu )
//+ {_initiative} Double Attack   // kiv, allows for double attack on same target...
//+ {_initiative==0 && orientation==ORIENTATION_NONE && } Quick Attack  // KIV
+ {_initiative}  Defend (with initiative)
	-> ChooseManueverListDef(0,0,->ChooseManueverMenu )
+ {_initiative==0 && _charTarget == enemyId} Attack (buy initiative)
	-> ChooseManueverListAtk(0,0,->ChooseManueverMenu )
+ {_initiative==0 && _charTarget==enemyId} Attack (no initiative) 
	-> ChooseManueverListAtk(0,0,->ChooseManueverMenu )
//+ Change target  // kiv, allows for switching target, but will lose current initiative (if any)
+ { charNoOffHand == 0 && _twoHanded==0 && (_equipOffhand=="")==0 && _hasShield==0 } Switch Hands
	-> ToggleOffHandOnly
+ [(Do Nothing)]
->doneCallbackThread

= ConfirmManuever
->doneCallbackThread

= AssignCombatPool
Assign dice from combat pool to make to roll... TODO
-> DONE

= AimTargetZone
Which target zone do you wish to aim at? TODO
-> DONE


= ChooseManueverListAtk(_confirmSelection, _altAction, ->_callbackThread )
~choiceCount=0
~manueverUseHands = MANUEVER_HAND_NONE
~temp usingOffhand = 0
{	
	-_confirmSelection:
		~theConfirmedManuever = _confirmSelection
}
{ 	// Bash
	- (_confirmSelection==0||_confirmSelection=="bash") && _blunt!=0 && (_ATN || _ATN_off): 
	~stipulateCost= getManueverCostWithProfeciency(_profeciencyType, "bash", _hasShield)
	~stipulateTN = _ATN
	{ 
		-stipulateTN == 0: 
			~stipulateTN=_ATN_off
			~usingOffhand = 1
	}
	{ 
		- _diceAvailable > stipulateCost: 
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_STRIKE
			~manueverDamageType = DAMAGE_TYPE_BLUDGEONING
			~manueverCost = stipulateCost
			~manueverUseHands = MANUEVER_HAND_MASTER
			{ _ATN==0:
				~manueverUseHands = MANUEVER_HAND_SECONDARY
			}
			-> ConfirmAtkManueverSelect
		- else:
			~choiceCount=choiceCount+1
			~AVAIL_bash = 1
			{
				- _altAction <= 0:
					+ Bash....[({stipulateCost})tn:{stipulateTN}{usingOffhand:(off-hand)}]
					-> ChooseManueverListAtk("bash", _altAction, _callbackThread )
				//-else:
				//	->_callbackThread
			}
		}
	}
}
{	// Spike
	- (_confirmSelection==0||_confirmSelection=="spike") && _blunt!=0 && (_ATN2 || _ATN2_off): 
	~stipulateCost= getManueverCostWithProfeciency(_profeciencyType, "spike", _hasShield)
	~stipulateTN = _ATN2
	{ 
		-stipulateTN == 0: 
			~stipulateTN=_ATN2_off
			~usingOffhand = 1
	}
	{
		- _diceAvailable > stipulateCost: 
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_THRUST
			~manueverDamageType = DAMAGE_TYPE_BLUDGEONING
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			~manueverUseHands = MANUEVER_HAND_MASTER
			{ _ATN2==0:
				~manueverUseHands = MANUEVER_HAND_SECONDARY
			}
			-> ConfirmAtkManueverSelect
		- else:
			~choiceCount=choiceCount+1
			~AVAIL_spike = 1
			{
				- _altAction <= 0:
					+ Spike....[({stipulateCost})tn:{stipulateTN}{usingOffhand:(off-hand)}]
					-> ChooseManueverListAtk("spike", _altAction, _callbackThread )
				//-else:
				//	->_callbackThread
			}
		}
		
	}
}
{ 	// Cut
	- (_confirmSelection==0||_confirmSelection=="cut") && _blunt==0 && (_ATN || _ATN_off):
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "cut", _hasShield) 
	~stipulateTN = _ATN
	{ 
		-stipulateTN == 0: 
			~stipulateTN=_ATN_off
			~usingOffhand = 1
	}
	{
		-_diceAvailable > stipulateCost: 
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_STRIKE
			~manueverDamageType = DAMAGE_TYPE_CUTTING
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			~manueverUseHands = MANUEVER_HAND_MASTER
			{ _ATN==0:
				~manueverUseHands = MANUEVER_HAND_SECONDARY
			}
			-> ConfirmAtkManueverSelect
		- else: 
			~choiceCount=choiceCount+1
			~AVAIL_cut = 1
			{
				- _altAction <= 0:
					+ Cut....[({stipulateCost})tn:{stipulateTN}{usingOffhand:(off-hand)}]
					-> ChooseManueverListAtk("cut", _altAction, _callbackThread )
				//-else:
				//	->_callbackThread
			}
		}
		
	}
}
{ 	// Thrust
	- (_confirmSelection==0||_confirmSelection=="thrust") && _blunt==0 && (_ATN2||_ATN2_off):
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "thrust", _hasShield) 
	~stipulateTN = _ATN2
	{
		-stipulateTN == 0: 
			~stipulateTN=_ATN2_off
			~usingOffhand = 1
	}
	{
		-_diceAvailable > stipulateCost: 
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_THRUST
			~manueverDamageType = DAMAGE_TYPE_PUNCTURING
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			~manueverUseHands = MANUEVER_HAND_MASTER
			{ _ATN2==0:
				~manueverUseHands = MANUEVER_HAND_SECONDARY
			}
			-> ConfirmAtkManueverSelect
		-else :
			~choiceCount=choiceCount+1
			~AVAIL_thrust = 1
			{
				- _altAction <= 0:
					+ Thrust....[({stipulateCost})tn:{stipulateTN}{usingOffhand:(off-hand)}]
					-> ChooseManueverListAtk("thrust", _altAction, _callbackThread )
				//-else:
				//	->_callbackThread
			}
		}

		
	}
}
{ 	// Beat - Striking with the weapon at hand to knock an opponent's weapon or shield to the side
	- (_confirmSelection==0||_confirmSelection=="beat") && _orientation == ORIENTATION_AGGRESSIVE && _ATN && _profeciencyLevel >=4:
	~stipulateCost =  getManueverCostWithProfeciency(_profeciencyType, "beat", _hasShield)
	~stipulateTN = _ATN
	{
	- _diceAvailable > stipulateCost:
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_STRIKE
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			~manueverNeedBodyAim = 0
			~manueverUseHands = MANUEVER_HAND_MASTER
			-> ConfirmAtkManueverSelect
		- else:
			~choiceCount=choiceCount+1
			~AVAIL_beat = 1
			{
				- _altAction <= 0:
					+ Beat....[({stipulateCost})tn:{stipulateTN}]
					-> ChooseManueverListAtk("beat", _altAction, _callbackThread )
				//-else:
				//	->_callbackThread
			}
		}	
	}
}
{	// Bind and Strike - Attacking with the offhand weapon to tie up an opponent's weapon.
	- (_confirmSelection==0||_confirmSelection=="bindstrike") && (_ATN_off!=0 || _ATN2_off!=0):
	~stipulateCost =  getManueverCostWithProfeciency(_profeciencyType, "bindstrike", _hasShield)
	{
		-_ATN_off !=0 && _ATN2_off !=0:
			~stipulateTN =  MathMin(_ATN_off, _ATN2_off)
		-else: { 
			- _ATN_off!=0:
			~stipulateTN = _ATN_off
			-else:
			~stipulateTN = _ATN2_off
		}
	}
	{
	- _diceAvailable > stipulateCost:
		{
		- _confirmSelection:
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			~manueverNeedBodyAim = 0
			~manueverUseHands = MANUEVER_HAND_SECONDARY
			-> ConfirmAtkManueverSelect
		- else:
			~choiceCount=choiceCount+1
			~AVAIL_bindstrike = 1
			{
			- _altAction <= 0:
				+ Bind and Strike....[({stipulateCost})tn:{stipulateTN}]
				-> ChooseManueverListAtk("bindstrike", _altAction, 	_callbackThread )
			//- else:
			//	->_callbackThread
			}
		}

	
	}
}
{ 
	- _altAction <= 0:
		+ [(Try Something Else)]
		->_callbackThread
}
{CHOICE_COUNT() == 0: ->_callbackThread}


/*
//  Disarm (Offensive) - Striking with the weapon at hand to remove an opponent's weapon from his control.
+ Double Attack - Attacking with the weapon at hand and the offhand weapon simultaneously.
+ Simultaneous Block/Strike - Attacking with the weapon at hand and parrying or blocking with the offhand weapon.
+ Draw Cut - Striking with the weapon at hand to do a cutting attack and drawing the weapon along the body.
+ Evasive Attack - Striking with the weapon at hand to do a cutting attack while jumping back to avoid getting hit.
+ Feint-and-thrust - Striking with the weapon at hand to mislead an opponent and finishing with a thrust.
+ Feint-and-cut - Striking with the weapon at hand to mislead an opponent and finishing with a different strike location.
+ Grapple (Offensive) - Entering a clinch with an opponent.
+ Half Sword (Offensive) - Striking with the weapon at hand to do a cutting attack while re-gripping like a spear.
+ Head Butt - Striking with your head to do a bludgeoning attack.
+ Hook - Attacking with the weapon at hand to knock an opponent down.
+ Kick - Attacking with your foot or leg to do a bludgeoning attack.
+ Master Strike (Offensive) - Striking and parrying with the weapon at hand simultaneously.
+ Murder Stroke - Striking with the weapon at hand by gripping the blade and bashing an opponent with the pommel.
+ Pommel Bash - Attacking with the weapon at hand to do a bludgeoning attack by hitting an opponent with the pommel.
+ Punch - Attacking with your fist to do a bludgeoning attack.
+ Quick Draw (Offensive) - Striking with the weapon at hand to do a cutting attack at the same time you draw the weapon at hand.
+ Stop Short - Stomping or leaping at an opponent with the weapon at hand and then stopping suddenly.
+ Toss - Tossing a hat, sidearm, sand, or other object in an opponent's face.
+ Twitching - Striking with the weapon at hand to do a cutting attack, but if the attack is defended, striking to the other side for a follow-up attack.
*/


= ConfirmAtkManueverSelect 
.........
~manuever = theConfirmedManuever
~manueverIsAttacking = 0
{
	-manueverUseHands == MANUEVER_HAND_MASTER:
		~charNoMasterHand = 1
		{ _twoHanded:
			~charNoOffHand = 1
		}
	-manueverUseHands == MANUEVER_HAND_SECONDARY:
		~charNoOffHand = 1
	-manueverUseHands == MANUEVER_HAND_BOTH:
		~charNoMasterHand = 1
		~charNoOffHand = 1
	-else:
		~elseResulted = 1
}
ManueverID: {manuever}
AttackType: {getAttackTypeLabel(manueverAttackType)}
DamageType: {getDamageTypeLabel(manueverDamageType)}
Need to Aim body zone: {manueverNeedBodyAim:Yes|No }
Cost: {manueverCost}
TN: {manueverTN}
->DONE

= ChooseManueverListDef(_confirmSelection, _altAction, ->_callbackThread ) 
~choiceCount=0
~manueverUseHands = MANUEVER_HAND_NONE
~temp usingOffhand = 0
{	
	-_confirmSelection:
		~theConfirmedManuever = _confirmSelection
}
{  //Block (Defensive) - Deflecting an incoming attack with the shield.
	- (_confirmSelection==0||_confirmSelection=="block") && _hasShield && _DTN_off!=0:
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "block", _hasShield) 
	~stipulateTN = _DTN_off
	{
		- _diceAvailable > stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverUseHands = MANUEVER_HAND_SECONDARY
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_block = 1
				{
					- _altAction <= 0:
						+ Block....[({stipulateCost})tn:{stipulateTN}]
						-> ChooseManueverListDef("block", _altAction, _callbackThread )
					//-else:
					//	->_callbackThread
				}
		}
	}
}
{	//Parry (Defensive) - Deflect an incoming attack with the weapon at hand.
	- (_confirmSelection==0||_confirmSelection=="parry") && (_DTN||_DTN_off):
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "parry", _hasShield) 
	~stipulateTN = _DTN
	{
		-stipulateTN==0: 
		~stipulateTN=_DTN_off
		~usingOffhand = 1
	}
	{
		- _diceAvailable > stipulateCost: 
		{
			- _confirmSelection:
				~manueverUseHands = MANUEVER_HAND_MASTER
				{ _DTN==0: 
					~manueverUseHands = MANUEVER_HAND_SECONDARY
				}
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_parry  = 1
				{
					- _altAction <= 0:
						+ Parry....[({stipulateCost})tn:{stipulateTN}{usingOffhand:(off-hand)}]
						-> ChooseManueverListDef("parry", _altAction, _callbackThread )
					//-else:
					//	->_callbackThread
				}
		}
	}
}
{	//Duck and Weave (Defensive) - Avoiding an incoming attack while moving in for a follow up.
	- (_confirmSelection==0||_confirmSelection=="duckweave") :
	~stipulateCost = 0
	~stipulateTN = 9
	{
		- _diceAvailable > stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_duckweave = 1
				{
					- _altAction <= 0:
						+ Duck and Weave....[({stipulateCost})tn:{stipulateTN}]
						-> ChooseManueverListDef("duckweave", _altAction, _callbackThread )
					//-else:
					//	->_callbackThread
				}
		}
	}
}
{	//Partial Evasion (Defensive) - Avoiding an incoming attack.
	- (_confirmSelection==0||_confirmSelection=="partialevade") :
	~stipulateCost = 0
	~stipulateTN = 7
	{
		- _diceAvailable > stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_partialevasion = 1
				{
					- _altAction <= 0:
						+ Partial Evasion....[({stipulateCost})tn:{stipulateTN}]
						-> ChooseManueverListDef("partialevasion", _altAction, _callbackThread )
					//-else:
					//	->_callbackThread
				}
		}
	}
}
{	//Full Evasion (Defensive) - Avoiding an incoming attack and exit the fight.
	- (_confirmSelection==0||_confirmSelection=="fullevasion") && (_orientation == ORIENTATION_DEFENSIVE) || _lastAttacked==0:
	~stipulateCost = 0
	~stipulateTN = 5
	{
		- _diceAvailable > stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_fullevasion = 1
				{
					- _altAction <= 0:
						+ Full Evasion....[({stipulateCost})tn:{stipulateTN}]
						-> ChooseManueverListDef("fullevasion", _altAction, _callbackThread )
					//-else:
					//	->_callbackThread
				}
		}
	}
}
{	//Block Open and Strike - Deflecting an incoming attack with the offhand weapon to leave an opponent open for the next strike.
	- (_confirmSelection==0||_confirmSelection=="blockopenstrike") && _DTN_off != 0 && _profeciencyLevel>=6:
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "blockopenstrike", _hasShield) 
	~stipulateTN = _DTN_off
	{
		- _diceAvailable > stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN
				~manueverUseHands = MANUEVER_HAND_SECONDARY	 
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_blockopenstrike = 1
				{
					- _altAction <= 0:
						+ Block Open and Strike....[({stipulateCost})tn:{stipulateTN}]
						-> ChooseManueverListDef("blockopenstrike", _altAction, _callbackThread )
					//-else:
					//	->_callbackThread
				}
		}
	}
}
{	//Counter - Deflecting an incoming attack with the weapon at hand while using an opponent's attack against them.
	- (_confirmSelection==0||_confirmSelection=="counter") && (_DTN || _DTN_off) && _profeciencyLevel>=6:
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "counter", _hasShield) 
	~stipulateTN = _DTN
	{
		-stipulateTN==0: 
		~stipulateTN=_DTN_off
		~usingOffhand = 1
	}
	{
		- _diceAvailable > stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	
				~manueverUseHands = MANUEVER_HAND_MASTER
				{ _DTN:
					~manueverUseHands = MANUEVER_HAND_SECONDARY
				}
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_counter = 1
				{
					- _altAction <= 0:
						+ Counter....[({stipulateCost})tn:{stipulateTN}{usingOffhand:(off-hand)}]
						-> ChooseManueverListDef("counter", _altAction, _callbackThread )
					//-else:
					//	->_callbackThread
				}
		}
	}
}
{	//Rota - Deflect an incoming attack with the back of weapon at hand and countering with the front.
	- (_confirmSelection==0||_confirmSelection=="rota") && _DTN && _profeciencyLevel>=3 && _enemyManueverType!=ATTACK_TYPE_THRUST && isThrustingMotion(_enemyTargetZone)==0:
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "rota", _hasShield) 
	~stipulateTN = _DTN
	{
		- _diceAvailable > stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				~manueverUseHands = MANUEVER_HAND_MASTER
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_rota = 1
				{
					- _altAction <= 0:
						+ Rota....[({stipulateCost})tn:{stipulateTN}]
						-> ChooseManueverListDef("rota", _altAction, _callbackThread )
					//-else:
					//	->_callbackThread
				}
		}
	}
}
{	//Expulsion
	- (_confirmSelection==0||_confirmSelection=="expulsion") && _DTN && _profeciencyLevel>=5 && ( (_enemyDiceRolled<=4) || (_enemyManueverType == ATTACK_TYPE_THRUST || isThrustingMotion(_enemyTargetZone)) ):
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "expulsion", _hasShield) 
	~stipulateTN = 9
	{
		- _diceAvailable > stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				~manueverUseHands = MANUEVER_HAND_MASTER
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_expulsion = 1
				{
					- _altAction <= 0:
						+ Expulsion....[({stipulateCost})tn:{stipulateTN}]
						-> ChooseManueverListDef("expulsion", _altAction, _callbackThread )
					//-else:
					//	->_callbackThread
				}
		}
	}
}
{	//Disarm (Defensive) - Striking with the weapon at hand to remove an opponent's weapon from his control before he hits.
	- (_confirmSelection==0||_confirmSelection=="disarm") && _DTN != 0 && _profeciencyLevel>=4:
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "counter", _hasShield) 
	~stipulateTN = _DTN
	{
		- _diceAvailable > stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				~manueverUseHands = MANUEVER_HAND_MASTER
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_disarm = 1
				{
					- _altAction <= 0:
						+ Disarm....[({stipulateCost})tn:{stipulateTN}]
						-> ChooseManueverListDef("disarm", _altAction, _callbackThread )
					//-else:
					//	->_callbackThread
				}
		}
	}
}
{ 
	- _altAction <= 0:
		+ [(Try Something Else)]
		->_callbackThread
}
{CHOICE_COUNT() == 0: ->_callbackThread}


/*

SIMULATENOUS/special moves?
Overrun - Avoiding an incoming attack and striking with the weapon at hand simultaneously.
Quick Draw (Defensive) - Deflect an incoming attack with the weapon at hand at the same time you draw the weapon at hand.
Master Strike (Defensive) - Parrying and striking with the weapon at hand simultaneously.
Grapple (Defensive) - Entering a clinch with an opponent before he hits.
Half Sword (Defensive) - Deflect an incoming attack with the weapon at hand while re-gripping like a spear.
*/

= ConfirmDefManueverSelect()
.........
~manuever = theConfirmedManuever
~manueverIsAttacking = 1
{
	-manueverUseHands == MANUEVER_HAND_MASTER:
		~charNoMasterHand = 1
		{ _twoHanded:
			~charNoOffHand = 1
		}
	-manueverUseHands == MANUEVER_HAND_SECONDARY:
		~charNoOffHand = 1
	-manueverUseHands == MANUEVER_HAND_BOTH:
		~charNoMasterHand = 1
		~charNoOffHand = 1
	-else:
		~elseResulted = 1
}

ManueverID: {manuever}
Cost: {manueverCost}
TN: {manueverTN}
->DONE


