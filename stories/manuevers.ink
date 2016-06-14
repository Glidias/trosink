CONST ZONE_VIII = 7

CONST DAMAGE_TYPE_CUTTING =1
CONST DAMAGE_TYPE_PUNCTURING = 2 
CONST DAMAGE_TYPE_BLUDGEONING = 3
=== function getDamageTypeLabel(damageType) 
{ 
	- damageType == DAMAGE_TYPE_CUTTING: ~return "cutting"
	- damageType == DAMAGE_TYPE_PUNCTURING: ~return "puncturing"
	- damageType == DAMAGE_TYPE_BLUDGEONING: ~return "bludgeoning"
}
~return "none"

CONST ATTACK_TYPE_STRIKE = 1
CONST ATTACK_TYPE_THRUST = 2
=== function getAttackTypeLabel(attackType) 
{ 
	- attackType == ATTACK_TYPE_STRIKE: ~return "striking"
	- attackType == ATTACK_TYPE_THRUST: ~return "thrusting"
}
~return "none"

CONST DEFEND_TYPE_OFFHAND = 1
CONST DEFEND_TYPE_MASTERHAND = 2
=== function getDefendTypeLabel(defendType) 
{ 
	- defendType == DEFEND_TYPE_OFFHAND: ~return "off-hand"
	- defendType == DEFEND_TYPE_MASTERHAND: ~return "main-hand"
}
~return "none"

CONST MANUEVER_TYPE_MELEE = 0
CONST MANUEVER_TYPE_RANGED = 1
=== function getManueverTypeLabel(manueverType) 
{ 
	- manueverType == MANUEVER_TYPE_MELEE: ~return "melee"
	- manueverType == MANUEVER_TYPE_RANGED: ~return "ranged"
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

=== function getManueverSelectReadonlyDependencies(charId,   ref initiative, ref profeciencyType, ref profeciencyLevel, ref diceAvailable, ref orientation, ref hasShield  ,   ref lastAttacked, ref DTN, ref DTNt, ref DTN_off, ref DTNt_off   ,   ref ATN, ref ATN2, ref ATN_off, ref ATN2_off, ref blunt  )
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
	{getWeaponStatsForManueverFilter(charPersonName_equipMasterhand, x, DTN, DTNt, ATN, ATN2, blunt )}
	{getWeaponStatsForManueverFilter(charPersonName_equipOffhand, hasShield, DTN_off, DTNt_off, ATN_off, ATN2_off, x )}

//*/
///* utest
- charId == charPersonName2_id:

	~initiative = charPersonName2_fight_initiative
	~profeciencyType = charPersonName2_usingProfeciency
	~profeciencyLevel = charPersonName2_usingProfeciencyLevel
	~diceAvailable = charPersonName2_cp
	~orientation = charPersonName2_fight_orientation
	~lastAttacked = charPersonName2_fight_lastAttacked
	{getWeaponStatsForManueverFilter(charPersonName2_equipMasterhand, x, DTN, DTNt, ATN, ATN2, blunt )}
	{getWeaponStatsForManueverFilter(charPersonName2_equipOffhand, hasShield, DTN_off, DTNt_off, ATN_off, ATN2_off, x )}
//*/
}
=== function dummyTest( ref orientation) 
~orientation = 99999999




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
}


=== ChooseManueverForChar( charId, enemyId, ->doneCallbackThread, ref manuever, ref manueverCost, ref manueverTN, ref manueverAttackType, ref manueverDamageType, ref manueverNeedBodyAim)
// 
//, initiative, profeciencyType, profeciencyLevel, diceAvailable, orientation, hasShield  ,   lastAttacked, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off  ,  ATN, ATN2, ATN_off, ATN2_off, blunt  

// Read-only Dependencies for manuever selection/consideration to request by reference
~temp x
// common to both attack/defense
~temp _initiative
~temp _profeciencyType
~temp _profeciencyLevel
~temp _diceAvailable
~temp _orientation
~temp _hasShield     
// for defending only
~temp _lastAttacked
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
~temp _blunt  

~temp choiceCount = 0
{getManueverSelectReadonlyDependencies(charId, _initiative, _profeciencyType, _profeciencyLevel, _diceAvailable, _orientation, _hasShield  ,   _lastAttacked,    _DTN, _DTNt, _DTN_off, _DTNt_off   ,    _ATN, _ATN2,  _ATN_off, _ATN2_off, _blunt)}
{getManueverSelectReadonlyEnemyDependencies(charId, enemyId, _enemyDiceRolled, _enemyTargetZone, _enemyManueverType)}
initiative:{_initiative} {charPersonName_fight_initiative}
CP: {_diceAvailable} 
ATNS: {_ATN} {_ATN2} 
ATNS offhand: {_ATN_off} {_ATN2_off}
DTNs: {_DTN} {_DTNt}
DTNS offhand: {_DTN_off} {_DTNt_off}
Prof: {_profeciencyType}
ProfLevel: {_profeciencyLevel}
HasShield: {_hasShield}
Last Attacked: {_lastAttacked}
Blunt Weapon: {_blunt}

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

// todo..determine if NPC or PC is doing the selection
{
	- _initiative:
		Attack
		-> ChooseManueverListAtk(0,0,->ChooseManueverMenu )
	- else:
		Defend
		-> ChooseManueverListDef(0,0,->ChooseManueverMenu)
}
->ChooseManueverMenu
//Read more: http://opaque.freeforums.net/thread/22/combat-simulator#ixzz4BUQY0dl5

// todo kiv other action types
= ChooseManueverMenu
Choose the nature of your action
+  {_initiative}  Attack
	-> ChooseManueverListAtk(0,0,->ChooseManueverMenu )
+ {_initiative==0}  Defend 
	-> ChooseManueverListDef(0,0,->ChooseManueverMenu )
//+ {_initiative} Double Attack   // allows cross attacking into another enemy that is targeting you
//+ {_initiative==0 && orientation==ORIENTATION_NONE && } Quick Attack  // KIV
+ {_initiative}  Defend (with initiative)
	-> ChooseManueverListDef(0,0,->ChooseManueverMenu )
+ {_initiative==0} Attack (buy initiative)
	-> ChooseManueverListAtk(0,0,->ChooseManueverMenu )
+ {_initiative==0} Attack (no initiative) 
	-> ChooseManueverListAtk(0,0,->ChooseManueverMenu )
//+ Change target
//+ Change target (buy initiative)
+ [(Do Nothing)]
->DONE

= ConfirmManuever
To confirm manuever
->doneCallbackThread

= CommitCombatPool
Amount of CP to roll...
-> DONE

= AimTargetZone
Which target zone do you wish to aim at?
-> DONE


= ChooseManueverListAtk(_confirmSelection, _altAction, ->_callbackThread )

~temp stipulateCost
~temp stipulateTN
~choiceCount=0

{ 	// Bash
	- (_confirmSelection==0||_confirmSelection=="bash") && _blunt!=0 && _ATN: 
	~stipulateCost= getManueverCostWithProfeciency(_profeciencyType, "bash", _hasShield)
	~stipulateTN = _ATN
	{ 
		- _diceAvailable > stipulateCost: 
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_STRIKE
			~manueverDamageType = DAMAGE_TYPE_BLUDGEONING
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			-> ConfirmAtkManueverSelect
		- else:
			~choiceCount=choiceCount+1
			~AVAIL_bash = 1
			+ Bash....[({stipulateCost})tn:{stipulateTN}]
			-> ChooseManueverListAtk("bash", _altAction, _callbackThread )
		}
	}
}
{	// Spike
	- (_confirmSelection==0||_confirmSelection=="spike") && _blunt!=0 && _ATN2: 
	~stipulateCost= getManueverCostWithProfeciency(_profeciencyType, "spike", _hasShield)
	~stipulateTN = _ATN2
	{
		- _diceAvailable > stipulateCost: 
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_THRUST
			~manueverDamageType = DAMAGE_TYPE_BLUDGEONING
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			-> ConfirmAtkManueverSelect
		- else:
			~choiceCount=choiceCount+1
			~AVAIL_spike = 1
			+ Spike....[({stipulateCost})tn:{stipulateTN}]
			-> ChooseManueverListAtk("spike", _altAction, _callbackThread )
		}
		
	}
}
{ 	// Cut
	- (_confirmSelection==0||_confirmSelection=="cut") && _blunt==0 && _ATN:
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "cut", _hasShield) 
	~stipulateTN = _ATN
	{
		-_diceAvailable > stipulateCost: 
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_STRIKE
			~manueverDamageType = DAMAGE_TYPE_CUTTING
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			-> ConfirmAtkManueverSelect
		- else: 
			~choiceCount=choiceCount+1
			~AVAIL_cut = 1
			+ Cut....[({stipulateCost})tn:{stipulateTN}]
			-> ChooseManueverListAtk("cut", _altAction, _callbackThread )
		}
		
	}
}
{ 	// Thrust
	- (_confirmSelection==0||_confirmSelection=="thrust") && _blunt==0 && _ATN2:
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "thrust", _hasShield) 
	~stipulateTN = _ATN2
	{
		-_diceAvailable > stipulateCost: 
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_THRUST
			~manueverDamageType = DAMAGE_TYPE_PUNCTURING
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			-> ConfirmAtkManueverSelect
		-else :
			~choiceCount=choiceCount+1
			~AVAIL_thrust = 1
			+ Thrust....[({stipulateCost})tn:{stipulateTN}]
			-> ChooseManueverListAtk("thrust", _altAction, _callbackThread )
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
			-> ConfirmAtkManueverSelect
		- else:
			~choiceCount=choiceCount+1
			~AVAIL_beat = 1
			+ Beat....[({stipulateCost})tn:{stipulateTN}]
			-> ChooseManueverListAtk("beat", _altAction, _callbackThread )
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
			-> ConfirmAtkManueverSelect
		- else:
			~choiceCount=choiceCount+1
			~AVAIL_bindstrike = 1
			+ Bind and Strike....[({stipulateCost})tn:{stipulateTN}]
			-> ChooseManueverListAtk("bindstrike", _altAction, 	_callbackThread )
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
AttackType: {getAttackTypeLabel(manueverAttackType)}
DamageType: {getDamageTypeLabel(manueverDamageType)}
Need to Aim body zone: {manueverNeedBodyAim:Yes|No }
Cost: {manueverCost}
TN: {manueverTN}
->DONE

= ChooseManueverListDef(_confirmSelection, _altAction, ->_callbackThread ) 

~temp stipulateCost
~temp stipulateTN
~choiceCount=0

{  //Block (Defensive) - Deflecting an incoming attack with the shield.
	- (_confirmSelection==0||_confirmSelection=="block") && _hasShield && _DTN_off!=0:
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "block", _hasShield) 
	~stipulateTN = _DTN_off
	{
		- _diceAvailable > stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_block = 1
				+ Block....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef("block", _altAction, ->_callbackThread)
		}
	}
}
{	//Parry (Defensive) - Deflect an incoming attack with the weapon at hand.
	- (_confirmSelection==0||_confirmSelection=="parry") && _DTN:
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "parry", _hasShield) 
	~stipulateTN = _DTN
	{
		- _diceAvailable > stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_parry  = 1
				+ Parry....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef("parry", _altAction, ->_callbackThread)
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
				+ Duck and Weave....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef("duckweave", _altAction, ->_callbackThread)
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
				+ Partial Evasion....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef("partialevade", _altAction, ->_callbackThread)
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
				+ Full Evasion....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef("fullevasion", _altAction, ->_callbackThread)
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
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_blockopenstrike = 1
				+ Block Open and Strike....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef("blockopenstrike", _altAction, ->_callbackThread)
		}
	}
}
{	//Counter - Deflecting an incoming attack with the weapon at hand while using an opponent's attack against them.
	- (_confirmSelection==0||_confirmSelection=="counter") && _DTN != 0 && _profeciencyLevel>=6:
	~stipulateCost = getManueverCostWithProfeciency(_profeciencyType, "counter", _hasShield) 
	~stipulateTN = _DTN
	{
		- _diceAvailable > stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_counter = 1
				+ Counter....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef("counter", _altAction, ->_callbackThread)
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
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_rota = 1
				+ Rota....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef("rota", _altAction, ->_callbackThread)
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
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_expulsion = 1
				+ Expulsion....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef("expulsion", _altAction, ->_callbackThread)
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
				->ConfirmDefManueverSelect
			- else: 
				~choiceCount=choiceCount+1
				~AVAIL_disarm = 1
				+ Disarm....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef("disarm", _altAction, ->_callbackThread)
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

= ConfirmDefManueverSelect 
Cost: {manueverCost}
TN: {manueverTN}
->DONE


