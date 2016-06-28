CONST THRUST_INDEX = 8

CONST MANUEVER_HAND_NONE = 0
CONST MANUEVER_HAND_MASTER = 1
CONST MANUEVER_HAND_SECONDARY = 2
CONST MANUEVER_HAND_BOTH = 3


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
	- targetZone >= THRUST_INDEX:
	~return 1
	- else:
	~return 0
}

=== function getManueverSelectReadonlyDependencies(charId,   ref initiative, ref profeciencyType, ref profeciencyLevel, ref diceAvailable, ref orientation, ref hasShield  ,   ref lastAttacked, ref DTN, ref DTNt, ref DTN_off, ref DTNt_off   ,   ref ATN, ref ATN2, ref ATN_off, ref ATN2_off, ref blunt,  ref hasShield, ref damage, ref damage2, ref damage3, ref damage_off, ref damage2_off, ref damage3_off, ref shieldLimit, ref weaponMainLabel, ref weaponOffhandLabel, ref twoHanded )
~temp x
{
///* utest player
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
///* utest player
- enemyId == charPersonName_id:
	{getTargetInitiativeStatesByCharId(enemyId, x, x, x, x, target, target2)}
	{
 	- target == charId: 
 		//  enemy targeting character
 		~enemyDiceRolled = charPersonName_manuever_CP
 		~enemyTargetZone = charPersonName_manuever_targetZone
 		~enemyManueverType = charPersonName_manueverAttackType
 	- target2 == charId: 
 		//  enemy targeting character
 		~enemyDiceRolled = charPersonName_manuever2_CP
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
 		~enemyDiceRolled = charPersonName2_manuever_CP
 		~enemyTargetZone = charPersonName2_manuever_targetZone
 		~enemyManueverType = charPersonName2_manueverAttackType
 	- target2 == charId: 
 		//  enemy targeting character
 		~enemyDiceRolled = charPersonName2_manuever2_CP
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




=== function isAThreat(initiative, orientation, target)
// a "threat" must always have a target aquired, and a resolved initiative due to orientation (ie. if due to orientation resolution, it lacks initiative, often due to defensive vs defensive engagements  or some cautious vs cautious engagements, then it's deemed not a threat..). 
~return target && (initiative || orientation==ORIENTATION_NONE ) 


=== PrepareManueversForChar(charId, charTarget, charIsPlayer, charHasInitiative, ->callbackToMainLoop)
~temp opponentCount = 0
~temp charHasPrimaryTarget = 0
~temp redirectBack
~temp totalOpponentsLeft

///* utest all
{
	- (charPersonName_id == charTarget || charPersonName_fight_target == charId) && ( charHasInitiative || isAThreat(charPersonName_fight_initiative, charPersonName_fight_orientation, charPersonName_fight_target) ):
		~opponentCount = opponentCount+1
		{	
			-charPersonName_id == charTarget:
				~charHasPrimaryTarget = 1

		}
}
{
	- (charPersonName2_id == charTarget || charPersonName2_fight_target == charId) && ( charHasInitiative || isAThreat(charPersonName2_fight_initiative, charPersonName2_fight_orientation, charPersonName2_fight_target) ):
		~opponentCount = opponentCount+1
		{	
			-charPersonName2_id == charTarget:
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
~temp charNoMasterHand
~temp charNoOffHand

~inspectHandsFree(charId, secondarySlotIndex, charNoMasterHand, charNoOffHand)

{opponentCount > 1 && charIsPlayer && _confirming == 0: Pick an opponent to deal against:}
///* utest all declaration
{
	- (_confirming==0 || _confirming == charPersonName_id) && charPersonName_FIGHT && (charPersonName_id == charTarget || charPersonName_fight_target == charId):
		
		{
			- charHasPrimaryTarget && charPersonName_id == charTarget: 
				~useSlotIndex = 1
				~asPrimaryTarget = 1
			- else:
				~useSlotIndex = secondarySlotIndex
				Using secondary slot index! ID:{charId} Char has primary target:{charHasPrimaryTarget}
		}
		{
			- _confirming == 0 && charIsPlayer && opponentCount>1:
				+  [{charPersonName_label} {asPrimaryTarget:(Your target)}]
				-> ConsiderOpponents(charPersonName_id)
			- else:
				-> ProceedToActionAgainst(useSlotIndex, charId, charPersonName_id, charNoMasterHand, charNoOffHand, redirectBack)
		}
}
{
	- (_confirming==0 || _confirming == charPersonName2_id) && charPersonName2_FIGHT && (charPersonName2_id == charTarget || charPersonName2_fight_target == charId):
		
		{
			- charHasPrimaryTarget && charPersonName2_id == charTarget: 
				~useSlotIndex = 1
				~asPrimaryTarget = 1
			- else:
				~useSlotIndex = secondarySlotIndex
				Using secondary slot index! ID:{charId} Char has primary target:{charHasPrimaryTarget}
		}
		{
			- _confirming == 0 && charIsPlayer && opponentCount>1:
				+  [{charPersonName2_label} {asPrimaryTarget:(Your target)}]
				-> ConsiderOpponents(charPersonName2_id)
			- else:
				-> ProceedToActionAgainst(useSlotIndex, charId, charPersonName2_id, charNoMasterHand, charNoOffHand, redirectBack)
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
{
	///* utest player 
	-charId == charPersonName_id:
		~determineHandsFree(secSlotIndex, charNoMasterHand, charNoOffHand, charPersonName_manuever, charPersonName_manueverUsingHands, charPersonName_manuever2, charPersonName_manuever2UsingHands, charPersonName_manuever3, charPersonName_manuever3UsingHands)
	//*/
	///* utest  
	-charId == charPersonName2_id:
		~determineHandsFree(secSlotIndex, charNoMasterHand, charNoOffHand, charPersonName2_manuever, charPersonName2_manueverUsingHands, charPersonName2_manuever2, charPersonName_manuever2UsingHands, charPersonName2_manuever3, charPersonName2_manuever3UsingHands)
	//*/
	-else:
		~elseResulted = 1
}


=== ProceedToActionAgainst(slotIndex, charId, enemyId,  charNoMasterHand, charNoOffHand, ->doneCallbackThread) 
~temp x = 0
~temp y = 0
~temp z = 0
{
- slotIndex == 1:
	{	
	///* utest player 
	- charId == charPersonName_id: 
		->ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, charPersonName_cp, doneCallbackThread,  charPersonName_manuever,  charPersonName_manueverCost, charPersonName_manueverTN, charPersonName_manueverAttackType, charPersonName_manueverDamageType, charPersonName_manueverNeedBodyAim, charPersonName_manuever_attacking, charPersonName_manueverUsingHands, charPersonName_manuever_CP, charPersonName_manuever_targetZone )
	//*/
	///* utest  
	- charId == charPersonName2_id:
		->ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, charPersonName2_cp, doneCallbackThread,  charPersonName2_manuever,  charPersonName2_manueverCost, charPersonName2_manueverTN, charPersonName2_manueverAttackType, charPersonName2_manueverDamageType, charPersonName2_manueverNeedBodyAim, charPersonName2_manuever_attacking, charPersonName2_manueverUsingHands, charPersonName2_manuever_CP, charPersonName2_manuever_targetZone )
	//*/
	-else:
		~elseResulted = 1
	
	}
- slotIndex == 2:
	{	
	///* utest player 
	- charId == charPersonName_id: 
		~charPersonName_fight_target2 = enemyId
		->ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, charPersonName_cp, doneCallbackThread,  charPersonName_manuever2,  charPersonName_manuever2Cost, charPersonName_manuever2TN, charPersonName_manuever2AttackType, charPersonName_manuever2DamageType, charPersonName_manuever2NeedBodyAim, charPersonName_manuever2_attacking, charPersonName_manuever2UsingHands, charPersonName_manuever2_CP, charPersonName_manuever2_targetZone)
	//*/
	///* utest 
	- charId == charPersonName2_id:
		~charPersonName2_fight_target2 = enemyId
		->ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, charPersonName2_cp, doneCallbackThread,  charPersonName2_manuever2,  charPersonName2_manuever2Cost, charPersonName2_manuever2TN, charPersonName2_manuever2AttackType, charPersonName2_manuever2DamageType, charPersonName2_manuever2NeedBodyAim, charPersonName2_manuever2_attacking, charPersonName2_manuever2UsingHands, charPersonName2_manuever2_CP, charPersonName2_manuever2_targetZone )
	//*/
	-else:
		~elseResulted = 1
	}
- else:
	{
	///* utest player 
	- charId == charPersonName_id: 
		~charPersonName_fight_target3 = enemyId
		->ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, charPersonName_cp, doneCallbackThread,  charPersonName_manuever3,  charPersonName_manuever3Cost, charPersonName_manuever3TN, charPersonName_manuever3AttackType, charPersonName_manuever3DamageType, x, y, charPersonName_manuever3UsingHands, charPersonName_manuever3_CP, z )
	//*/
	///* utest 
	- charId == charPersonName2_id:
		~charPersonName2_fight_target3 = enemyId
		->ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, charPersonName2_cp, doneCallbackThread, charPersonName2_manuever3,  charPersonName2_manuever2Cost, charPersonName2_manuever3TN, charPersonName2_manuever3AttackType, charPersonName2_manuever3DamageType, x, y, charPersonName2_manuever3UsingHands, charPersonName2_manuever3_CP, z )
	//*/
	-else:
		~elseResulted = 1
	}
}

=== ChooseManueverForChar(slotIndex, charId, enemyId, charNoMasterHand, charNoOffHand, ref charCombatPool, ->doneCallbackThread, ref manuever, ref manueverCost, ref manueverTN, ref manueverAttackType, ref manueverDamageType, ref manueverNeedBodyAim, ref manueverIsAttacking, ref manueverUseHands, ref manuever_CP, ref manuever_targetZone)

~manuever_targetZone = 0

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

~temp charCanAttack = _charTarget == enemyId && slotIndex != 3

// TOCHECK when dealing against multiple enemies
{
	- _initiative && _charTarget != enemyId:
		~_initiative = 0
		{	
			- slotIndex == 2 && currentlyBeingAttackedBy(charId, enemyId, 1) && (charNoMasterHand==0 || charNoOffHand==0): 
				~_initiative = 1
				~charCanAttack = 1
		}
}

{
- charNoMasterHand:
	~_DTN = 0
	~_DTNt = 0
	~_ATN = 0
	~_ATN2 = 0
}
{
- charNoOffHand:
	~_DTN_off = 0
	~_DTNt_off = 0
	~_ATN_off = 0
	~_ATN2_off = 0
}
{
	-preferOffhand:
	~_DTN = 0
	~_DTNt = 0
	~_ATN = 0
	~_ATN2 = 0
}

/*
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
*/

// all recorded attack action availabilities
~temp AVAIL_bash = 0
~temp AVAIL_spike = 0
~temp AVAIL_cut = 0
~temp AVAIL_thrust = 0
~temp AVAIL_beat = 0
~temp AVAIL_bindstrike = 0

// all recorded defend actoin availabilities
~temp AVAIL_block = 0
~temp AVAIL_parry = 0
~temp AVAIL_duckweave = 0
~temp AVAIL_partialevasion = 0
~temp AVAIL_fullevasion = 0
~temp AVAIL_blockopenstrike = 0
~temp AVAIL_counter = 0
~temp AVAIL_rota = 0
~temp AVAIL_expulsion = 0
~temp AVAIL_disarm = 0

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
	- _diceAvailable > 0:
	{
	- _initiative && charCanAttack:
		{_isAI==0:{" "}}
		{_isAI==0:Attack}
		-> ChooseManueverListAtk(0,altAction,divertTo )
	- else:
		{_isAI==0:{" "}}
		{_isAI==0:Defend}
		-> ChooseManueverListDef(0,altAction,divertTo)
	}
}
->divertTo


= AIManueverConfirmFailedErrorDef
AIManueverConfirmFailedErrorDef detected. This should not happen!
->DONE

= AIManueverConfirmFailedErrorAtk
AIManueverConfirmFailedErrorAtk detected. This should not happen!
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
{
	-_diceAvailable <= 0:
		{getDescribeLabelOfCharCapital(charId)} doesn't have any dice left in his combat pool to fight this exchange.
		->doneCallbackThread
}
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
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListAtk("bash", 1, ->AIManueverConfirmFailedErrorAtk) }
	}
	{
		-AVAIL_bash:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListAtk("bash", 1, ->AIManueverConfirmFailedErrorAtk) }
	}
	{
		-AVAIL_spike:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListAtk("spike", 1, ->AIManueverConfirmFailedErrorAtk) }
	}
	{
		-AVAIL_beat:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListAtk("beat", 1, ->AIManueverConfirmFailedErrorAtk) }
	}
- else:
	{
		-AVAIL_cut:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListAtk("cut", 1, ->AIManueverConfirmFailedErrorAtk) }
	}
	{
		-AVAIL_thrust:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListAtk("thrust", 1, ->AIManueverConfirmFailedErrorAtk) }
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
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("block", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_block:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("block", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_block:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("block", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_block:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("block", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_blockopenstrike:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("blockopenstrike", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_blockopenstrike:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("blockopenstrike", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_blockopenstrike:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("blockopenstrike", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_expulsion:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("expulsion", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_fullevasion:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("fullevasion", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_partialevasion:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("partialevasion", 1, ->AIManueverConfirmFailedErrorDef) }
	}
- else:
	{
		-AVAIL_parry:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("parry", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_parry:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("parry", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_parry:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("parry", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_counter:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("counter", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_counter:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("parry", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_rota:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("rota", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_expulsion:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("expulsion",1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_disarm:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("disarm", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_fullevasion:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("fullevasion", 1, ->AIManueverConfirmFailedErrorDef) }
	}
	{
		-AVAIL_partialevasion:
		~aiFavCount = aiFavCount + 1
		{ confirmDiceChoice == aiFavCount: ->ChooseManueverListDef("partialevasion", 1, ->AIManueverConfirmFailedErrorDef) }
	}
}
->noDecisionMadeYetCallback


= ToggleOffHandOnly
{
	- preferOffhand:
		~preferOffhand  = 0
	-else:
		~preferOffhand = 1
}
{
	-preferOffhand:
		//You switched to your off-hand weapon. 
		.....
		{
		- preferOffhand:
			~_DTN = 0
			~_DTNt = 0
			~_ATN = 0
			~_ATN2 = 0
		}
	-else:
		//You switched back to your main hand weapon.
		{
		- charNoMasterHand == 0:
			~getManueverSelectReadonlyDependencies(charId, x, x, x, x, x, x  ,   x,    _DTN, _DTNt, _DTN_off, _DTNt_off   ,    _ATN, _ATN2,  _ATN_off, _ATN2_off, x,   x,   x, x, x, x, x, x, x, x, x, x)
		}
}
-> ChooseManueverMenu


//Read more: http://opaque.freeforums.net/thread/22/combat-simulator#ixzz4BUQY0dl5
// todo kiv other action types, buy initiative espe
= ChooseManueverMenu
{ _isAI: AI should not be here}
{
	- _diceAvailable > 0:
		Choose the nature of your action {preferOffhand: (off-hand)}
	-else:
		You have no more dice left in your combat pool.
}
+  {_diceAvailable>0 && _initiative && charCanAttack}  Attack
	-> ChooseManueverListAtk(0,0,->ChooseManueverMenu )
+ {_diceAvailable>0 && _initiative==0}  Defend 
	-> ChooseManueverListDef(0,0,->ChooseManueverMenu )
+ {_diceAvailable>0 && _initiative && _orientation!=ORIENTATION_AGGRESSIVE}  Defend (with initiative)   // Quick Defense falls under here
	-> ChooseManueverListDef(0,0,->ChooseManueverMenu )
+ {_diceAvailable>0 && _initiative==0 && _charTarget == enemyId && _orientation!= ORIENTATION_DEFENSIVE && charCanAttack} Attack (buy initiative)
	-> ChooseManueverListAtk(0,0,->ChooseManueverMenu )
+ {_diceAvailable>0 && _initiative==0 && _charTarget==enemyId && _orientation!= ORIENTATION_DEFENSIVE && charCanAttack} Attack (no initiative) 
//+ {_initiative==0 && _orientation!= ORIENTATION_DEFENSIVE } Attack (seize initiative)  // TODO, if not being engaged by offenseive manuever from target
	-> ChooseManueverListAtk(0,0,->ChooseManueverMenu )
//+ Change target  (no initiative)// kiv, allows for switching target, but will lose current initiative (if any)
//+ Change target  (buy initiative)// kiv, allows for switching target, and will buy  initiative 
+ { _diceAvailable > 0 &&  charNoOffHand == 0 && _twoHanded==0 && (_equipOffhand=="")==0 && _hasShield==0 && (_equipMainHand=="")==0 && charNoMasterHand==0  } [{preferOffhand == 0:Switch to off-hand|Switch back to main-hand}]
	-> ToggleOffHandOnly
+ {_orientation!=ORIENTATION_AGGRESSIVE || choiceCount==0} [(Do Nothing)]
->doneCallbackThread

= AssignCombatPool
{
-_isAI ==0:
	// kiv todo: change copy to suit multiple PC characters in party
	How much dice in your combat pool do you wish to roll for this manuever?
	+ { boutExchange == 2 } [All remaining {_diceAvailable} dice]
		->ConfirmCombatPool(_diceAvailable)
	+ {_diceAvailable >= 1  } [1 dice]
		->ConfirmCombatPool(1)
	+ {_diceAvailable >= 2  } [2 dice]
		->ConfirmCombatPool(2)
	+ {_diceAvailable >= 3  } [3 dice]
		->ConfirmCombatPool(3)
	+ {_diceAvailable >= 4  }[4 dice]
		->ConfirmCombatPool(4)
	+ {_diceAvailable >= 5  } [5 dice]
		->ConfirmCombatPool(5)
	+ {_diceAvailable >= 5  } [6 dice]
		->ConfirmCombatPool(6)
	+ {_diceAvailable >= 7  } [7 dice] 
		->ConfirmCombatPool(7)
	+ {_diceAvailable >= 8  } [8 dice]
		->ConfirmCombatPool(8)
	+ {_diceAvailable >= 9  } [9 dice]
		->ConfirmCombatPool(9)
	+ {_diceAvailable >= 10  } [10 dice]
		->ConfirmCombatPool(10)
	+ {_diceAvailable >= 11  } [11 dice]
		->ConfirmCombatPool(11)
	+ {_diceAvailable >= 12  } [12 dice]
		->ConfirmCombatPool(12)
	+ {_diceAvailable >= 13  } [13 dice]
		->ConfirmCombatPool(13)
	+ {_diceAvailable >= 14  } [14 dice]
		->ConfirmCombatPool(14)
	+ {_diceAvailable >= 15  } [15 dice]
		->ConfirmCombatPool(15)
	+ {_diceAvailable >= 16  } [16 dice]
		->ConfirmCombatPool(16)
	+ {_diceAvailable >= 17 } [17 dice]
		->ConfirmCombatPool(17)
	+ {_diceAvailable >= 18  } [18 dice]
		->ConfirmCombatPool(18)
	+ {_diceAvailable >= 19  } [19 dice]
		->ConfirmCombatPool(19)
	+ {_diceAvailable >= 20  } [20 dice]
		->ConfirmCombatPool(20)
	+ {_diceAvailable >= 21  } [21 dice]
		->ConfirmCombatPool(21)
	+ {_diceAvailable >= 22  } [22 dice]
		->ConfirmCombatPool(22)
	+ {_diceAvailable >= 23  } [23 dice]
		->ConfirmCombatPool(23)
	+ {_diceAvailable >= 24  } [24 dice]
		->ConfirmCombatPool(24)
	+ {_diceAvailable >= 25  } [25 dice]
		->ConfirmCombatPool(25)
	+ {_diceAvailable >= 26  } [26 dice]
		->ConfirmCombatPool(26)
	+ {_diceAvailable >= 27  } [27 dice]
		->ConfirmCombatPool(27)
	+ {_diceAvailable >= 28  } [28 dice]
		->ConfirmCombatPool(28)
	+ {_diceAvailable >= 29  } [29 dice]
		->ConfirmCombatPool(29)
	+ {_diceAvailable >= 30  } [30 dice]
		->ConfirmCombatPool(30)
-else:
	// todo: ai needs to determine how to divide his combat pool when up against multiple opponents, and other variations
	~temp aiDecidePool = _diceAvailable
	{
	- boutExchange == 1:
		~aiDecidePool = _diceAvailable/2
		{
		-aiDecidePool == 0:
			~aiDecidePool = 1
		}
	}
	->ConfirmCombatPool(aiDecidePool)
}
//-> AssignCombatPoolLooseEndError

= AssignCombatPoolLooseEndError
AssignCombatPoolLooseEndError detected. This should not happen!
->DONE

= ChoosingManuversLooseEndError
ChoosingManuversLooseEndError detected. This should not happen!
->DONE

= ConfirmManuever
{
	-_isAI:
	{ 
	-manueverIsAttacking:
		Enemy acts with...
		CharacterID: {charId}
		ManueverID: {manuever}
		TN: {manueverTN}
		AttackType: {getAttackTypeLabel(manueverAttackType)}
		DamageType: {getDamageTypeLabel(manueverDamageType)}
		TargetZone: {manuever_targetZone >= THRUST_INDEX: (thrust)|(swing)} {getTargetZoneLabelDir(manuever_targetZone)}
		//Need to Aim body zone: {manueverNeedBodyAim:Yes|No }
		Cost: {manueverCost}
		Rolling CP: {manuever_CP}
	-else:
		Enemy acts with...
		CharacterID: {charId}
		ManueverID: {manuever}
		TN: {manueverTN}
		Cost: {manueverCost}
		Rolling CP: {manuever_CP}
	}
}
~charCombatPool = charCombatPool - manueverCost - manuever_CP
//....
{" "}
->doneCallbackThread

= ConfirmCombatPool(amount)
{""}
~manuever_CP = amount
{ 
	-manueverNeedBodyAim:
		->AimTargetZone
	-else:
		->ConfirmManuever
}

= AimTargetZone
{
-_isAI ==0:
	{
	-manueverAttackType == ATTACK_TYPE_STRIKE:
	How do you wish to aim your swing?
	+ to the Lower Legs
		~manuever_targetZone = 1
		->ConfirmManuever 
	+ to the Upper Legs 
		~manuever_targetZone = 2
		->ConfirmManuever 
	+ Horizontal Swing
		~manuever_targetZone = 3
		->ConfirmManuever 
	+ Overhand Swing
		~manuever_targetZone = 4
		->ConfirmManuever 
	+ Downward Swing from Above
		~manuever_targetZone = 5
		->ConfirmManuever 
	+ Upward Swing from Below
		~manuever_targetZone = 6
		->ConfirmManuever 
	+ to the Arms
		~manuever_targetZone = 7
		->ConfirmManuever 
	-manueverAttackType == ATTACK_TYPE_THRUST:
	Where on your opponent do you wish to aim your thrust?
	+ to the Lower Legs
		~manuever_targetZone = 8
		->ConfirmManuever 
	+ to the Upper Legs
		~manuever_targetZone = 9
		->ConfirmManuever 
	+ to the Pelvis
		~manuever_targetZone = 10
		->ConfirmManuever
	+ to the Belly
		~manuever_targetZone = 11
	 	->ConfirmManuever
	+ to the Chest
		~manuever_targetZone = 12
		->ConfirmManuever 
	+ to the Head
		~manuever_targetZone = 13
		->ConfirmManuever 	
	+ to the Arm
		~manuever_targetZone = 14
		->ConfirmManuever 
	-else:
	How do you wish to aim your strike?
	///* #if TROS
	+ Swing to the Lower Legs
		~manuever_targetZone = 1
		->ConfirmManuever 
	+ Swing to the Upper Legs 
		~manuever_targetZone = 2
		->ConfirmManuever 
	+ Horizontal Swing
		~manuever_targetZone = 3
		->ConfirmManuever 
	+ Overhand Swing
		~manuever_targetZone = 4
		->ConfirmManuever 
	+ Downward Swing from Above
		~manuever_targetZone = 5
		->ConfirmManuever 
	+ Upward Swing from Below
		~manuever_targetZone = 6
		->ConfirmManuever 
	+ Swing to the Arms
		~manuever_targetZone = 7
		->ConfirmManuever 
	+ Thrust to the Lower Legs
		~manuever_targetZone = 8
		->ConfirmManuever 
	+ Thrust to the Upper Legs
		~manuever_targetZone = 9
		->ConfirmManuever 
	+ Thrust to the Pelvis
		~manuever_targetZone = 10
		->ConfirmManuever
	+ Thrust to the Belly
		~manuever_targetZone = 11
	 	->ConfirmManuever
	+ Thrust to the Chest
		~manuever_targetZone = 12
		->ConfirmManuever 
	+ Thrust to the Head
		~manuever_targetZone = 13
		->ConfirmManuever 	
	+ Thrust to the Arm
		~manuever_targetZone = 14
		->ConfirmManuever 
	}

//*/
-else:
	{
	-manueverAttackType == ATTACK_TYPE_STRIKE:
		{ shuffle:
		- ~manuever_targetZone = 1
		- ~manuever_targetZone = 2
		- ~manuever_targetZone = 2
		- ~manuever_targetZone = 3
		- ~manuever_targetZone = 3
		- ~manuever_targetZone = 3
		- ~manuever_targetZone = 4
		- ~manuever_targetZone = 5
		- ~manuever_targetZone = 5
		- ~manuever_targetZone = 5
		- ~manuever_targetZone = 6
		- ~manuever_targetZone = 7
		}
	-manueverAttackType == ATTACK_TYPE_THRUST:
		{ shuffle:
		- ~manuever_targetZone = 8
		- ~manuever_targetZone = 9
		- ~manuever_targetZone = 10
		- ~manuever_targetZone = 10
		- ~manuever_targetZone = 10
		- ~manuever_targetZone = 11
		- ~manuever_targetZone = 11
		- ~manuever_targetZone = 11
		- ~manuever_targetZone = 12
		- ~manuever_targetZone = 12
		- ~manuever_targetZone = 12
		- ~manuever_targetZone = 13
		- ~manuever_targetZone = 14
		}
	-else:
		{ shuffle:
		- ~manuever_targetZone = 1
		- ~manuever_targetZone = 2
		- ~manuever_targetZone = 2
		- ~manuever_targetZone = 3
		- ~manuever_targetZone = 3
		- ~manuever_targetZone = 3
		- ~manuever_targetZone = 4
		- ~manuever_targetZone = 5
		- ~manuever_targetZone = 5
		- ~manuever_targetZone = 5
		- ~manuever_targetZone = 6
		- ~manuever_targetZone = 7
		- ~manuever_targetZone = 8
		- ~manuever_targetZone = 9
		- ~manuever_targetZone = 10
		- ~manuever_targetZone = 10
		- ~manuever_targetZone = 10
		- ~manuever_targetZone = 11
		- ~manuever_targetZone = 11
		- ~manuever_targetZone = 11
		- ~manuever_targetZone = 12
		- ~manuever_targetZone = 12
		- ~manuever_targetZone = 12
		- ~manuever_targetZone = 13
		- ~manuever_targetZone = 14

		}
	}
	-> ConfirmManuever
}

= AimTargetZoneLooseEndError
AimTargetZoneLooseEndError detected. This should not happen!
->DONE

= ChooseManueverListAtk(_confirmSelection, _altAction, ->_callbackThread )
~choiceCount=0
~manueverUseHands = MANUEVER_HAND_NONE
~temp usingOffhand = 0
~manueverNeedBodyAim = 1
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
					+ Bash....[({stipulateCost})tn:{stipulateTN} {usingOffhand:(off-hand)}]
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
					+ Spike....[({stipulateCost})tn:{stipulateTN} {usingOffhand:(off-hand)}]
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
					+ Cut....[({stipulateCost})tn:{stipulateTN} {usingOffhand:(off-hand)}]
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
					+ Thrust....[({stipulateCost})tn:{stipulateTN} {usingOffhand:(off-hand)}]
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
~manueverIsAttacking = 1
~_diceAvailable = _diceAvailable -  manueverCost
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
->AssignCombatPool

= ChooseManueverListDef(_confirmSelection, _altAction, ->_callbackThread ) 
~choiceCount=0
~manueverUseHands = MANUEVER_HAND_NONE
~temp usingOffhand = 0
~manueverNeedBodyAim = 0
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
						+ Parry....[({stipulateCost})tn:{stipulateTN} {usingOffhand:(off-hand)}]
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
	- (_confirmSelection==0||_confirmSelection=="partialevasion") :
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
						+ Counter....[({stipulateCost})tn:{stipulateTN} {usingOffhand:(off-hand)}]
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
~manuever = theConfirmedManuever
~manueverIsAttacking = 0

~_diceAvailable = _diceAvailable -  manueverCost
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
/*
...
CharacterID: {charId}
ManueverID: {manuever}
Cost: {manueverCost}
TN: {manueverTN}
*/
->AssignCombatPool



=== ResolveAtkManuevers(attackerId, ref attackerInitiative, ref attackerPaused, ref attackerCP, ref atkManuever1, ref atkManuever1CP, ref atkManuever1Target, ref atkManuever2, ref atkManuever2CP, ref atkManuever2Target, ref attackerEquipMasterhand, ref attackerEquipOffhand, ->mainCallbackThread, ref reselectCharId, ref reselectCharIdNext)
~temp requiredSuccesses
~temp x
~temp zeroDefPool = 0
~temp _atk_targetZone
~temp _atk_tn
~temp _atk_cp
~temp _atk_attackType
~temp _atk_damageType
~temp _atk_needBodyAim
~temp _atk_usingHands
~temp _def_cp
~temp _def_usingHands
~temp _def_tn
~temp _def_cost
~temp noDefense = ""
~temp defenderCharId
~temp slotIndexBeingResolved
~temp simultaneousHitResulted = 0


// varialbes on actal resolve
~temp shockToInflict
~temp useDamageType
~temp usingWeapon
~temp usingWeaponName
~temp usingWeaponIsShield
~temp usingWeaponBlunt
~temp usingWeaponDamage
~temp usingWeaponDamage2
~temp usingWeaponDamage3
~temp usingWeaponAttrIndex
~temp _targetBodyPart
~temp _woundLevel
~temp _applyDestruction

// todo: handle double attack and mixed cases
// kiv todo: resolve all overwatching targeters on character
{	
	- (atkManuever1 == "")==0: 
	{ 
		- atkManuever1CP <= 0:
			{getDescribeLabelOfCharCapital(attackerId)} failed to attack due to shock.
			->ResolveComplete
		-else: 
			->ResolveAtkManuever(atkManuever1, atkManuever1CP, atkManuever1Target, 1)
	}
}

= ResolveAtkManuever(ref atkManuever, ref atkManueverCP, ref atkManueverTarget, slotIndex)
~requiredSuccesses = 0
~_atk_cp = atkManueverCP
~slotIndexBeingResolved = slotIndex
~getAllManueverDetailsForCharacter(attackerId, slotIndex, x, x,  _atk_targetZone, x, _atk_tn, _atk_attackType, _atk_damageType, _atk_needBodyAim, x, _atk_usingHands )
{
	///* utest player 
	-atkManueverTarget == charPersonName_id:
		->AttemptDefense(charPersonName_id, charPersonName_fight_initiative, charPersonName_fight_paused,  charPersonName_cp, charPersonName_fight_target, charPersonName_fight_target2, charPersonName_fight_target3, charPersonName_manuever, charPersonName_manuever2, charPersonName_manuever3, charPersonName_manuever_attacking, charPersonName_manuever2_attacking, charPersonName_manuever_CP, charPersonName_manuever2_CP, charPersonName_manuever3_CP)
	//*/
	///* utest 
	-atkManueverTarget == charPersonName2_id:
		->AttemptDefense(charPersonName2_id, charPersonName2_fight_initiative, charPersonName2_fight_paused, charPersonName2_cp, charPersonName2_fight_target, charPersonName2_fight_target2, charPersonName2_fight_target3, charPersonName2_manuever, charPersonName2_manuever2, charPersonName2_manuever3, charPersonName2_manuever_attacking, charPersonName2_manuever2_attacking, charPersonName2_manuever_CP, charPersonName2_manuever2_CP, charPersonName2_manuever3_CP)
	//*/
	-else:
		~elseResulted = 1
}

ResolveAtkManuever:: Couldn't find target exception found for ID: {atkManueverTarget}
-> ResolveComplete


= ResolveComplete
{	
	- (atkManuever1 == "")==0: 
		~atkManuever1 = ""
}
{	
	- (atkManuever2 == "")==0: 
		~atkManuever2= ""
}
-> mainCallbackThread


= AttemptDefense(defenderId, ref defenderInitiative, ref defenderPaused, ref defenderCP, ref defenderTarget, ref defenderTarget2, ref defenderTarget3, ref defManuever, ref defManuever2, ref defManuever3, ref defenderAttacking,  ref defenderAttacking2, ref defManueverCP, ref defManuever2CP, ref defManuever3CP  )
~zeroDefPool = 0
~defenderCharId = defenderId

~defenderPaused = 0 
{
	- (defenderTarget == attackerId && (defManuever=="")==0) || (defenderTarget2 == attackerId && (defManuever2=="")==0) || (defenderTarget3 == attackerId && (defManuever3=="")==0):
		{
			-(defenderTarget == attackerId && (defManuever=="")==0):
				->AttemptDefendersManuever(defenderId, defenderInitiative, defenderTarget, defenderPaused, defenderCP, defManuever, defenderAttacking, defManueverCP, 1)
			-(defenderTarget2 == attackerId && (defManuever2=="")==0):
				->AttemptDefendersManuever(defenderId, defenderInitiative, defenderTarget, defenderPaused, defenderCP, defManuever2, defenderAttacking2, defManuever2CP, 2)
			-(defenderTarget3 == attackerId && (defManuever3=="")==0):
				->AttemptDefendersManuever(defenderId, defenderInitiative, defenderTarget,  defenderPaused, defenderCP, defManuever3, 0, defManuever3CP, 3)
			-else:
				AttemptDefense else exception found :: Should NOT HAPPEN!!
		}
	-else:
		->AttemptAttackersManuever(zeroDefPool, defenderCP, 0, defenderInitiative, defenderTarget,  defenderPaused, noDefense)
}

AttemptDefense loose-ended exception found :: Should NOT HAPPEN but redirect!!
-> ResolveComplete



= AttemptDefendersManuever(defenderId, ref defenderInitiative, ref defenderTarget, ref defenderPaused, ref defenderCP, ref defManuever, defManueverAttacking, ref defManueverCP, slotIndex)  
~temp c1
~temp c2

~getAllManueverDetailsForCharacter(defenderId, slotIndex, x, _def_cp,  x, _def_cost, _def_tn, x, x, x, x, _def_usingHands )
{
	-defManueverAttacking: 
	// todo kiv: for simultatneous block/strike cases during red/red, MAY have defensive manuever on slot2!
	{
		-defenderInitiative && attackerInitiative:
			// will attempt contest due to both parties having initiative with attack manuever
			 ~temp atkReflex = getReflexByCharId(attackerId)
			 ~temp defReflex = getReflexByCharId(defenderId)

			 ~c1 = rollNumSuccesses(atkReflex,5,0)
			 ~c2 = rollNumSuccesses(defReflex,5,0)

			 // to test simulatneous
			// ~c1 = c2

			// reflex contest role results: D{atkReflex}:{c1} D{defReflex}:{c2}
			 {
			 	-c1 > c2:
			 		{getDescribeLabelOfCharCapital(attackerId)} won the initaitive contest
			 		~defenderInitiative = 0
			 		//testing: successive resolution of atk manuevers from target AFTER targeter
			 		~reselectCharId = defenderId
			 		~reselectCharIdNext = 0
			 		 ->AttemptAttackersManuever(defManueverCP, defenderCP, 0, defenderInitiative, defenderTarget, defenderPaused, noDefense)
			 	-c2 > c1:
				 	{getDescribeLabelOfCharCapital(defenderId)} won the initaitive contest
			 		~attackerInitiative  = 0
			 		//testing:   successive resolution of atk manuevers from target before targeter
			 		~reselectCharId = defenderId
			 		~reselectCharIdNext = attackerId
			 		-> mainCallbackThread
			 	- else:
				 	Neither party won the initaitive contest.
			 		~defenderInitiative = 0
			 		~attackerInitiative = 0
			 		
			 		~simultaneousHitResulted = 1
			 		~reselectCharId = defenderId
			 		~reselectCharIdNext = 0
			 		
			 		 ->AttemptAttackersManuever(zeroDefPool, defenderCP, 0, defenderInitiative, defenderTarget, defenderPaused, noDefense)
			 }
			 ->AttemptAttackersManuever(defManueverCP, defenderCP, 0, defenderInitiative,defenderTarget,  defenderPaused, noDefense)
		-else:
			{
				- attackerInitiative:
					->AttemptAttackersManuever(defManueverCP, defenderCP, 0, defenderInitiative, defenderTarget,  defenderPaused, noDefense)
				- else:
					// assumption made due to both defender and attacker not having initaitive, assumed simultatenous hit situation!
					->AttemptAttackersManuever(zeroDefPool, defenderCP, 0, defenderInitiative, defenderTarget,  defenderPaused, noDefense)
			}
			
	}
	-else:
		~requiredSuccesses = rollNumSuccesses(_def_cp, _def_tn, 0)
		->AttemptAttackersManuever(zeroDefPool, defenderCP, 1, defenderInitiative, defenderTarget,  defenderPaused, defManuever)

}
AttemptDefendersManuever loose-ended exception found :: Should NOT HAPPEN!!
-> ResolveComplete


= AttemptAttackersManuever(ref defenderManueverPool, ref defenderCP, gotDefense, ref defenderInitiative, ref defenderTarget,   ref defenderPaused, ref defManuever)
~temp totalAtkSuccess = rollNumSuccesses(_atk_cp, _atk_tn, 0)
~temp bonusSuccess = totalAtkSuccess - requiredSuccesses
~temp _weaponBonusDamage

{
	-_atk_usingHands == MANUEVER_HAND_MASTER || _atk_usingHands == MANUEVER_HAND_BOTH:
		~usingWeapon = attackerEquipMasterhand
	-_atk_usingHands == MANUEVER_HAND_SECONDARY:
		~usingWeapon = attackerEquipOffhand
	-else:
		~usingWeapon = ""
}


~shockToInflict = 0
~useDamageType = 0
~_weaponBonusDamage =0
~_woundLevel = 0
~_applyDestruction = 0

{
	-usingWeapon:
	/*ref name, ref isShield, ref damage, ref damage2, ref damage3, ref attrBaseIndex,  ref dtn, ref dtnT, ref atn, ref atn2, ref blunt ,  ref shieldLimit, ref twoHanded*/
		~getAllWeaponStats(usingWeapon, usingWeaponName, usingWeaponIsShield, usingWeaponDamage, usingWeaponDamage2, usingWeaponDamage3, usingWeaponAttrIndex, x,x, x,x, usingWeaponBlunt , x, x )
}


{
	- bonusSuccess >= 0:
		{
			- bonusSuccess == 0:
				~shockToInflict = 0
			- else:
			{
				- _atk_damageType:
					~useDamageType = _atk_damageType
				- _atk_targetZone == 0:
					// assumption made by convention... with manuever without neither damage Type or attack zone
					~useDamageType = 0
					~shockToInflict = 0
				- usingWeapon && usingWeaponBlunt:
					~useDamageType = DAMAGE_TYPE_BLUDGEONING
					~_weaponBonusDamage = usingWeaponDamage3
				- _atk_targetZone >= THRUST_INDEX:
					~useDamageType = DAMAGE_TYPE_PUNCTURING
					~_weaponBonusDamage = usingWeaponDamage2
				- else:
					~useDamageType = DAMAGE_TYPE_CUTTING
					~_weaponBonusDamage = usingWeaponDamage
			}
			{
				- _atk_targetZone:
					~_targetBodyPart = getTargetZoneBodyPart(_atk_targetZone, useDamageType)
					{
						// miss detected
						-_targetBodyPart=="":
							~useDamageType = 0
					}
			}
		}

		// kiv: determine if target location is armored and adjust woundLevel accordingly.
		// kiv: toughness consider using Flower of Battle/SOS rules after armor is included in.

		{
			-useDamageType:
				{
					// lazy-resolve weapon bonus damage if still at zero
					- _weaponBonusDamage==0:
						{
							- useDamageType == DAMAGE_TYPE_BLUDGEONING && usingWeaponDamage3:
								~_weaponBonusDamage = usingWeaponDamage3
							- useDamageType == DAMAGE_TYPE_PUNCTURING && usingWeaponDamage2:
								~_weaponBonusDamage = usingWeaponDamage2
							- useDamageType == DAMAGE_TYPE_CUTTING && usingWeaponDamage:
								~_weaponBonusDamage = usingWeaponDamage
							- else:
								~elseResulted = 1

						}
				}
				// todo: some damages might not be derived from weapons, but from the manuever itself!
				~_woundLevel = getWeaponDamageStrength(_weaponBonusDamage, usingWeaponAttrIndex, getStrengthByCharId(attackerId) ) + bonusSuccess -  0 - getToughnessByCharId(defenderCharId)
				{
					-_woundLevel < 0: 
						~_woundLevel = 0
					-_woundLevel > 5: 
						~_woundLevel = 5
					-else:
						~elseResulted = 1
				}
				{
					- _woundLevel:
						~resolveTargetBodyPart(_targetBodyPart, _woundLevel, _atk_targetZone, useDamageType)
						~inflictWoundOn(defenderCharId, getWillpowerByCharId(defenderCharId), _targetBodyPart, _woundLevel, useDamageType, shockToInflict, x,x, _applyDestruction)

				}
		}
		
		~defenderManueverPool = defenderManueverPool - shockToInflict
		{
			- defenderManueverPool < 0:
				~defenderCP =  defenderCP + defenderManueverPool
				~defenderManueverPool = 0
		}
		-> ResolveAttackManueverResultsWin(totalAtkSuccess, bonusSuccess, defenderCP, gotDefense, defenderInitiative, defenderTarget, defenderPaused, defManuever)
	- else:
		-> ResolveAttackManueverResultsFail(totalAtkSuccess, bonusSuccess, defenderCP, gotDefense, defenderInitiative, defenderTarget,  defenderPaused, defManuever)
}
AttemptAttackersManuever loose-ended exception found :: Should NOT HAPPEN!!
-> ResolveComplete

= ResolveAttackManueverResultsWin(totalSuccess, bonusSuccess, ref defenderCP, gotDefense, ref defenderInitiative,ref defenderTarget,  ref defenderPaused, ref defManuever)
...
~temp def_isAI
~temp def_isEnemy
~temp def_isYou
~temp atk_isAI
~temp atk_isEnemy
~temp atk_isYou
~getCharMetaInfo(defenderCharId, x, def_isAI, def_isEnemy, def_isYou)
~getCharMetaInfo(defenderCharId, x, atk_isAI, atk_isEnemy, atk_isYou)

{
	- bonusSuccess && (_targetBodyPart == "")==1: 
		{getDescribeLabelOfCharCapital(attackerId)} {def_isYou:miss|misses} a part on {def_isYou:the|his} target's body!
}

{getDescribeLabelOfCharCapital(attackerId)} attacked {bonusSuccess && (_targetBodyPart=="")==0:successfully} against {getDescribeLabelOfChar(defenderCharId)}{gotDefense:(defending)} with BS:{bonusSuccess} {_woundLevel:..dealing a Level {_woundLevel} {_applyDestruction == D_DEATH:fatal} wound to the {_targetBodyPart} {def_isYou && shockToInflict && shockToInflict != 999:({shockToInflict} shock)} } {simultaneousHitResulted: while...}.



{
	- _applyDestruction == D_DEATH:
	{
		- simultaneousHitResulted == 0:
			~killChar(defenderCharId, GAMEOVER_DEAD,0)
		-else:
			~killChar(defenderCharId, GAMEOVER_DEAD,1)
	}

}
{
	- shockToInflict == 999:
		{getDescribeLabelOfCharCapital(defenderCharId)} suffered maximum shock for this wound!
}

// do specific atkManuever resolution here
{
-gotDefense:
	~defManuever = ""
}
-> ResolveComplete

= ResolveAttackManueverResultsFail(totalSuccess, bonusSuccess, ref defenderCP, gotDefense, ref defenderInitiative, ref defenderTarget,  ref defenderPaused, ref defManuever)
...
~temp giveInitiativeToDefender = 1
~temp userPrompted = 0

{getDescribeLabelOfCharCapital(attackerId)} failed to attacked successfully against {getDescribeLabelOfChar(defenderCharId)}{gotDefense:(defending)} with BS:{bonusSuccess} {simultaneousHitResulted: while...}.

// do specific case defManuever resolution here..
{
	-defManuever == "fullevasion":
		~giveInitiativeToDefender = 0
		~defenderInitiative = 0
		{
			- slotIndexBeingResolved == 1:
				~defenderTarget = TARGET_NONE
				~atkManuever1Target = TARGET_NONE
				~attackerInitiative = 0
		}
	- defManuever == "partialevasion":
		~giveInitiativeToDefender = 0
		{
			-defenderCP >= 2 && defenderInitiative == 0:
				~temp isAI = 1
				~temp isYou = 0
				~getCharMetaInfo(defenderCharId, x, isAI, x, isYou)
				{
					- isAI==0:
						~userPrompted = 1
						{
							-isYou: 
								..
								Do you wish to seize initiative for 2 CP? (Will have {defenderCP-2} CP left.)
							-else:
								..
								Does {getDescribeLabelOfChar(defenderCharId)} wish to seize initiative for 2 CP? (Will have {defenderCP-2} CP left.)
						}
						+ [Yes]
							~defenderCP = defenderCP - 2
							~giveInitiativeToDefender = 1
							-> ResolveAttackManueverFailedDefault(giveInitiativeToDefender, defenderInitiative, gotDefense, defManuever)
						+ [No]
							-> ResolveAttackManueverFailedDefault(giveInitiativeToDefender, defenderInitiative, gotDefense, defManuever)
					-else:
						// kiv: better AI to decide if wish to take initiative or not
						~defenderCP = defenderCP - 2
						~giveInitiativeToDefender = 1
				}
		}
	- else:
		~elseResulted = 1 
}
{	userPrompted == 0:
	-> ResolveAttackManueverFailedDefault(giveInitiativeToDefender, defenderInitiative, gotDefense, defManuever)
}

= ResolveAttackManueverFailedDefault(giveInitiativeToDefender, ref defenderInitiative, gotDefense, ref defManuever)
{
- giveInitiativeToDefender:
	~defenderInitiative = 1
	~attackerInitiative = 0
}
{
-gotDefense:
	~defManuever = ""
}
-> ResolveComplete

=== function resolveUnusedDefManuever(defenderId, ref defenderStance, ref defenderCP, ref defManuever, ref defManueverCP, ref defManueverCost)
{
	-(defManuever == "fullevasion") == 0:
		~defenderStance = STANCE_NEUTRAL
}
~defManuever = ""

=== function getTargetZoneLabelDir(targetZone)
///* #if TROS
{
-targetZone == 1:
~return "to the Lower Legs"
-targetZone == 2:
~return "to the Upper Legs"
-targetZone == 3:
~return "for Horizontal Swing"
-targetZone == 4:
~return "for Overhand Swing"
-targetZone == 5:
~return "for Downward Swing from Above"
-targetZone == 6:
~return "for Upward Swing from Below"
-targetZone == 7:
~return "to the Arms"

-targetZone == 8:
~return "to the Lower Legs"
-targetZone == 9:
~return "to the Upper Legs"
-targetZone == 10:
~return "to the Pelvis"
-targetZone == 11:
~return "to the Belly"
-targetZone == 12:
~return "to the Chest"
-targetZone == 13:
~return "to the Head"
-targetZone == 14:
~return "to the Arm"
-else:
	~return ""
}
//*/


=== function getTargetZoneBodyPart(targetZone, damageType)
///* #if TROS
{
-targetZone == 1:
	{ shuffle:
		- ~return "foot"
		- ~return "shin_and_lower_leg"
		- ~return "shin_and_lower_leg"
		- ~return "shin_and_lower_leg"
		- ~return "knee_and_nearby_areas"
		- ~return "knee_and_nearby_areas"
	}
-targetZone == 2:
	{ shuffle:
		- ~return "knee_and_nearby_areas"
		- ~return "knee_and_nearby_areas"
		- ~return "thigh"
		- ~return "thigh"
		- ~return "thigh"
		- ~return "hip"
	}
-targetZone == 3:
	{ shuffle:
		- ~return "hip"
		- ~return "upper_abdomen"
		- ~return "lower_abdomen"
		- ~return "ribcage"
		- ~return "ribcage"
		- ~return "arms"
	}
-targetZone==4:
	{ shuffle:
		- ~return "upper_arm_and_shoulder"
		- ~return "upper_arm_and_shoulder"
		- ~return "chest"
		- ~return "neck"
		- ~return "lower_head"
		- ~return "upper_head"
	}	
-targetZone==5:
	{ shuffle:
		- ~return "upper_head"
		- ~return "upper_head"
		- ~return "upper_head"
		- ~return "lower_head"
		- ~return "shoulder"
		- ~return "shoulder"
	}	
-targetZone==6:
	{ shuffle:
		- ~return "inner_thigh"
		- ~return "inner_thigh"
		- ~return "inner_thigh"
		- ~return "groin"
		- ~return "abdomen"
		- ~return "chest"
	}	
-targetZone==7:
	{ shuffle:
		- ~return "hand"
		- ~return "forearm"
		- ~return "forearm"
		- ~return "elbow"
		- ~return "upper_arm_and_shoulder"
		- ~return "upper_arm_and_shoulder"
	}
-targetZone==8:
	{ shuffle:
		- ~return "foot"
		- ~return "shin_and_lower_leg"
		- ~return "shin_and_lower_leg"
		- ~return "shin_and_lower_leg"
		- ~return "knee_and_nearby_areas"
		- ~return ""
	}
-targetZone==9:
	{ shuffle:
		- ~return "knee_and_nearby_areas"
		- ~return "knee_and_nearby_areas"
		- ~return "thigh"
		- ~return "thigh"
		- ~return "thigh"
		- ~return "hip"
	}
-targetZone==10:
	{ shuffle:
		// note missing rules for male/female cases
		- ~return "hip"
		- ~return "hip"
		- ~return "groin"
		- ~return "groin"
		- ~return "lower_abdomen"
		- ~return "lower_abdomen"
	}	
-targetZone==11:
	{ 
	-damageType != DAMAGE_TYPE_BLUDGEONING:
		{ shuffle:
			- ~return "lower_abdomen"
			- ~return "lower_abdomen"
			- ~return "lower_abdomen"
			- ~return "lower_abdomen"
			- ~return "lower_abdomen"
			- ~return "flesh_to_the_side"
		}
	- else:
		~return "lower_abdomen"
	}
-targetZone==12:
	{ shuffle:
		- ~return "upper_abdomen"
		- ~return "upper_abdomen"
		- ~return "chest"
		- ~return "chest"
		- ~return "chest"
		- ~return "chest"
	}			
-targetZone==13:
	{ 
	-damageType != DAMAGE_TYPE_BLUDGEONING:
		{ shuffle:
			- ~return "collar_and_throat"
			- ~return "collar_and_throat"
			- ~return "face_or_head"
			- ~return "face_or_head"
			- ~return "face_or_head"
			- ~return "face_or_head"
		}
	- else:
		{ shuffle:
			- ~return "neck"
			- ~return "face_or_lower_head"
			- ~return "face_or_lower_head"
			- ~return "face_or_lower_head"
			- ~return "upper_head"
			- ~return "upper_head"
		}	
	}	
-targetZone==14:
	{ 
	-damageType != DAMAGE_TYPE_BLUDGEONING:
		{ shuffle:
			- ~return "hand"
			- ~return "forearm"
			- ~return "forearm"
			- ~return "elbow"
			- ~return "upper_arm"
			- ~return "upper_arm"
		}
	- else:
		{ shuffle:
			- ~return "hand"
			- ~return "forearm"
			- ~return "forearm"
			- ~return "elbow"
			- ~return "upper_arm_and_shoulder"
			- ~return "upper_arm_and_shoulder"
		}	
	}	

-else:
	Exception occured for target zone part search....{targetZone}
	~return ""
}
//*/

// handling of special cases for targeted body part
=== function resolveTargetBodyPart(ref targetBodyPart, ref woundLevel, targetZone, damageType)
///* #if TROS
{
-damageType == DAMAGE_TYPE_BLUDGEONING:
	{
		-targetZone==13 && targetBodyPart == "face_or_lower_head":
			{

				-woundLevel <= 1:
					~targetBodyPart = "face"
				-woundLevel == 2:
					~targetBodyPart = "face"
				-woundLevel == 3:
					~targetBodyPart = "face"
				-woundLevel == 4:
					~targetBodyPart = "lower_head"
				-woundLevel >=5:
					~targetBodyPart = "lower_head"
				-else:
					~elseResulted = 1
			}
		-else:
			~elseResulted = 1
	}
-else:
	{
	- targetBodyPart == "flesh_to_the_side":
		~woundLevel = 1
	-targetZone==13 && targetBodyPart == "face_or_head":
			{

				-woundLevel <= 1:
					~targetBodyPart = "face"
				-woundLevel == 2:
					~targetBodyPart = "face"
				-woundLevel == 3:
					~targetBodyPart = "face"
				-woundLevel == 4:
					~targetBodyPart = "head"
				-woundLevel >=5:
					~targetBodyPart = "head"
				-else:
					~elseResulted = 1
			}
		-else:
			~elseResulted = 1
	}
}
//*/