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
~ return 1


=== function isThrustingMotion(targetZone)
{
	- targetZone >= ZONE_VIII:
	~return 1
	- else:
	~return 0
}





=== ChooseManueverListAtk(profeciencyType, profeciencyLevel, diceAvailable, orientation,  ATN, ATN2, ATN_off, ATN2_off, blunt, hasShield, _confirmSelection, ->_callbackThread )
~temp manueverAttackType = 0
~temp manueverDamageType = 0
~temp manueverCost = 0
~temp manueverTN = 0
~temp manueverNeedBodyAim = 1

~temp stipulateCost
~temp stipulateTN

{ 	// Bash
	- (_confirmSelection==0||_confirmSelection=="bash") && blunt!=0 && ATN: 
	~stipulateCost= getManueverCostWithProfeciency(profeciencyType, "bash", hasShield)
	~stipulateTN = ATN
	{ 
		- diceAvailable >= stipulateCost: 
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_STRIKE
			~manueverDamageType = DAMAGE_TYPE_BLUDGEONING
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			-> ConfirmAtkManueverSelect
		- else:
			+ Bash....[({stipulateCost})tn:{stipulateTN}]
			-> ChooseManueverListAtk(profeciencyType, profeciencyLevel, diceAvailable, orientation,  ATN, ATN2, ATN_off, ATN2_off, blunt, hasShield, "bash", _callbackThread )
		}
	}
}
{	// Spike
	- (_confirmSelection==0||_confirmSelection=="spike") && blunt!=0 && ATN2: 
	~stipulateCost= getManueverCostWithProfeciency(profeciencyType, "spike", hasShield)
	~stipulateTN = ATN2
	{
		- diceAvailable >= stipulateCost: 
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_THRUST
			~manueverDamageType = DAMAGE_TYPE_BLUDGEONING
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			-> ConfirmAtkManueverSelect
		- else:
			+ Spike....[({stipulateCost})tn:{stipulateTN}]
			-> ChooseManueverListAtk(profeciencyType, profeciencyLevel, diceAvailable, orientation,  ATN, ATN2, ATN_off, ATN2_off, blunt, hasShield, "spike", _callbackThread )
		}
		
	}
}
{ 	// Cut
	- (_confirmSelection==0||_confirmSelection=="cut") && blunt==0 && ATN:
	~stipulateCost = getManueverCostWithProfeciency(profeciencyType, "cut", hasShield) 
	~stipulateTN = ATN
	{
		-diceAvailable >= stipulateCost: 
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_STRIKE
			~manueverDamageType = DAMAGE_TYPE_CUTTING
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			-> ConfirmAtkManueverSelect
		- else: 
			+ Cut....[({stipulateCost})tn:{stipulateTN}]
			-> ChooseManueverListAtk(profeciencyType, profeciencyLevel, diceAvailable, orientation,  ATN, ATN2, ATN_off, ATN2_off, blunt, hasShield, "cut", _callbackThread )
		}
		
	}
}
{ 	// Thrust
	- (_confirmSelection==0||_confirmSelection=="thrust") && blunt==0 && ATN2:
	~stipulateCost = getManueverCostWithProfeciency(profeciencyType, "thrust", hasShield) 
	~stipulateTN = ATN2
	{
		-diceAvailable >= stipulateCost: 
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_THRUST
			~manueverDamageType = DAMAGE_TYPE_PUNCTURING
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			-> ConfirmAtkManueverSelect
		-else :
			+ Thrust....[({stipulateCost})tn:{stipulateTN}]
			-> ChooseManueverListAtk(profeciencyType, profeciencyLevel, diceAvailable, orientation,  ATN, ATN2, ATN_off, ATN2_off, blunt, hasShield, "thrust", _callbackThread )
		}

		
	}
}
{ 	// Beat - Striking with the weapon at hand to knock an opponent's weapon or shield to the side
	- (_confirmSelection==0||_confirmSelection=="beat") && orientation == ORIENTATION_AGGRESSIVE && ATN && profeciencyLevel >=4:
	~stipulateCost =  getManueverCostWithProfeciency(profeciencyType, "beat", hasShield)
	~stipulateTN = ATN
	{
	- diceAvailable >= stipulateCost:
		{
		- _confirmSelection:
			~manueverAttackType = ATTACK_TYPE_STRIKE
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			~manueverNeedBodyAim = 0
			-> ConfirmAtkManueverSelect
		- else:
			+ Beat....[({stipulateCost})tn:{stipulateTN}]
			-> ChooseManueverListAtk(profeciencyType, profeciencyLevel, diceAvailable, orientation,  ATN, ATN2, ATN_off, ATN2_off, blunt, hasShield, "beat", _callbackThread )
		}	
	}
}
{	// Bind and Strike - Attacking with the offhand weapon to tie up an opponent's weapon.
	- (_confirmSelection==0||_confirmSelection=="bindstrike") && (ATN_off!=0 || ATN2_off!=0):
	~stipulateCost =  getManueverCostWithProfeciency(profeciencyType, "bindstrike", hasShield)
	{
		-ATN_off !=0 && ATN2_off !=0:
			~stipulateTN =  MathMin(ATN_off, ATN2_off)
		-else: { 
			- ATN_off!=0:
			~stipulateTN = ATN_off
			-else:
			~stipulateTN = ATN2_off
		}
	}
	{
	- diceAvailable >= stipulateCost:
		{
		- _confirmSelection:
			~manueverCost = stipulateCost
			~manueverTN = stipulateTN
			~manueverNeedBodyAim = 0
			-> ConfirmAtkManueverSelect
		- else:
			+ Bind and Strike....[({stipulateCost})tn:{stipulateTN}]
			-> ChooseManueverListAtk(profeciencyType, profeciencyLevel, diceAvailable, orientation,  ATN, ATN2, ATN_off, ATN2_off, blunt, hasShield, "bindstrike", _callbackThread )
		}

	
	}
}
{ 
- _confirmSelection == 0:
+ [(Continue)]
->_callbackThread
}


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

=== ChooseManueverListDef(profeciencyType, profeciencyLevel, diceAvailable, orientation, lastAttacked, hasShield, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off, _confirmSelection ) 
~temp manueverCost = 0
~temp manueverTN = 0

~temp stipulateCost
~temp stipulateTN

{  //Block (Defensive) - Deflecting an incoming attack with the shield.
	- (_confirmSelection==0||_confirmSelection=="block") && hasShield && DTN_off!=0:
	~stipulateCost = getManueverCostWithProfeciency(profeciencyType, "block", hasShield) 
	~stipulateTN = DTN_off
	{
		-diceAvailable >= stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				+ Block....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef(profeciencyType, profeciencyLevel, diceAvailable, orientation, lastAttacked, hasShield, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off, "block")
		}
	}
}
{	//Parry (Defensive) - Deflect an incoming attack with the weapon at hand.
	- (_confirmSelection==0||_confirmSelection=="parry") && DTN:
	~stipulateCost = getManueverCostWithProfeciency(profeciencyType, "parry", hasShield) 
	~stipulateTN = DTN
	{
		-diceAvailable >= stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				+ Parry....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef(profeciencyType, profeciencyLevel, diceAvailable, orientation, lastAttacked, hasShield, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off, "parry")
		}
	}
}
{	//Duck and Weave (Defensive) - Avoiding an incoming attack while moving in for a follow up.
	- (_confirmSelection==0||_confirmSelection=="duckweave") :
	~stipulateCost = 0
	~stipulateTN = 9
	{
		-diceAvailable >= stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				+ Duck and Weave....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef(profeciencyType, profeciencyLevel, diceAvailable, orientation, lastAttacked, hasShield, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off, "duckweave")
		}
	}
}
{	//Partial Evasion (Defensive) - Avoiding an incoming attack.
	- (_confirmSelection==0||_confirmSelection=="partialevade") :
	~stipulateCost = 0
	~stipulateTN = 7
	{
		-diceAvailable >= stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				+ Partial Evasion....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef(profeciencyType, profeciencyLevel, diceAvailable, orientation, lastAttacked, hasShield, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off, "partialevade")
		}
	}
}
{	//Full Evasion (Defensive) - Avoiding an incoming attack and exit the fight.
	- (_confirmSelection==0||_confirmSelection=="fullevasion") && (orientation == ORIENTATION_DEFENSIVE) || lastAttacked==0:
	~stipulateCost = 0
	~stipulateTN = 5
	{
		-diceAvailable >= stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				+ Full Evasion....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef(profeciencyType, profeciencyLevel, diceAvailable, orientation, lastAttacked, hasShield, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off, "fullevasion")
		}
	}
}
{	//Block Open and Strike - Deflecting an incoming attack with the offhand weapon to leave an opponent open for the next strike.
	- (_confirmSelection==0||_confirmSelection=="blockopenstrike") && DTN_off != 0 && profeciencyLevel>=6:
	~stipulateCost = getManueverCostWithProfeciency(profeciencyType, "blockopenstrike", hasShield) 
	~stipulateTN = DTN_off
	{
		-diceAvailable >= stipulateCost: 
		+ Block Open and Strike....[({stipulateCost})tn:{stipulateTN}]
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				+ Block Open and Strike....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef(profeciencyType, profeciencyLevel, diceAvailable, orientation, lastAttacked, hasShield, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off, "blockopenstrike")
		}
	}
}
{	//Counter - Deflecting an incoming attack with the weapon at hand while using an opponent's attack against them.
	- (_confirmSelection==0||_confirmSelection=="counter") && DTN != 0 && profeciencyLevel>=6:
	~stipulateCost = getManueverCostWithProfeciency(profeciencyType, "counter", hasShield) 
	~stipulateTN = DTN
	{
		-diceAvailable >= stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				+ Counter....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef(profeciencyType, profeciencyLevel, diceAvailable, orientation, lastAttacked, hasShield, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off, "counter")
		}
	}
}
{	//Rota - Deflect an incoming attack with the back of weapon at hand and countering with the front.
	- (_confirmSelection==0||_confirmSelection=="rota") && DTN && profeciencyLevel>=3 && enemyManueverType!=ATTACK_TYPE_THRUST && isThrustingMotion(enemyTargetZone)==0:
	~stipulateCost = getManueverCostWithProfeciency(profeciencyType, "rota", hasShield) 
	~stipulateTN = DTN
	{
		-diceAvailable >= stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				+ Rota....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef(profeciencyType, profeciencyLevel, diceAvailable, orientation, lastAttacked, hasShield, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off, "rota")
		}
	}
}
{	//Expulsion
	- (_confirmSelection==0||_confirmSelection=="expulsion") && DTN && profeciencyLevel>=5 && ( (enemyDiceRolled<=4) || (enemyManueverType == ATTACK_TYPE_THRUST || isThrustingMotion(enemyTargetZone)) ):
	~stipulateCost = getManueverCostWithProfeciency(profeciencyType, "expulsion", hasShield) 
	~stipulateTN = 9
	{
		-diceAvailable >= stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				+ Expulsion....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef(profeciencyType, profeciencyLevel, diceAvailable, orientation, lastAttacked, hasShield, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off, "expulsion")
		}
	}
}
{	//Disarm (Defensive) - Striking with the weapon at hand to remove an opponent's weapon from his control before he hits.
	- (_confirmSelection==0||_confirmSelection=="disarm") && DTN != 0 && profeciencyLevel>=4:
	~stipulateCost = getManueverCostWithProfeciency(profeciencyType, "counter", hasShield) 
	~stipulateTN = DTN
	{
		-diceAvailable >= stipulateCost: 
		{ 
			- _confirmSelection:
				~manueverCost = stipulateCost
				~manueverTN = stipulateTN	 
				->ConfirmDefManueverSelect
			- else: 
				+ Disarm....[({stipulateCost})tn:{stipulateTN}]
				->ChooseManueverListDef(profeciencyType, profeciencyLevel, diceAvailable, orientation, lastAttacked, hasShield, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off, "disarm")
		}
	}
}
+ [(Continue)]
->DONE


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