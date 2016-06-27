// Common globals
CONST GOT_CONSOLE_NUMBERS = 0

VAR boutRounds=1	
VAR boutExchange=1
VAR boutStep=-1
VAR elseResulted = 0

// Common Functions  (usually stateful, game-specific)
VAR combatStatusStringCache = ""
=== function showCombatStatus()
~temp statusToShow = "Round "+boutRounds+" - Exchange: "+boutExchange+"/2"
{
	- (combatStatusStringCache == statusToShow)==0:
		~combatStatusStringCache = statusToShow
		~return statusToShow
}
~ return ""


// Static Functions (stateless)
=== function MathMax(v,v2)
{  
	- v > v2: 
		~ return v
	- else:
		~ return v2
}
=== function MathMin(v,v2)
{  
	- v < v2: 
		~ return v
	- else:
		~ return v2
}
=== function MathExp(base, power)
~return _MathExp(base,power, 1)

=== function _MathExp(base, power, v)
{
	-power == 0:
		~return v
}
~v = v*base
~power = power - 1
{
	-power: 
		~return _MathExp(base, power, v)
}
~return v

=== function XOR_2Bits(A, B) 
~temp evalue = (A + B*MathExp(-1,A)) % 4
// handle negative int results by swapping A/B and re-evaulating
{ evalue < 0:
	~evalue = (B + A*MathExp(-1,B)) % 4
}
~return evalue

=== function OR_2Bits(A, B) 
~return XOR_2Bits(A,B) + B

=== function flag_OR_2Bits(ref val, bits) 
~val = XOR_2Bits(val,bits) + bits

=== function check_2BitFlag(A,B)
~return XOR_2Bits(A,3) == B


=== function hasBit(mask, bit)
~return (mask mod (bit*2)) >= bit

=== function addBit(ref mask, bit)
{
	- hasBit(mask, bit) == 0:
		~mask = mask + bit
}


=== function rollNSided(nSides)
{
	-nSides==2:
		~return rollD2()
	-nSides==3:
		~return rollD3()
	-nSides==4:
		~return rollD4()
	-nSides==5:
		~return rollD5()
	-nSides==6:
		~return rollD6()
	-nSides==7:
		~return rollD7()
	-nSides==8:
		~return rollD8()
	-nSides==9:
		~return rollD9()
	-nSides==10:
		~return rollD10()
	-else:
		~elseResulted = 1
}
// will return max nSideCapped available by default.
~return rollD10   


=== function rollD2() 
{ shuffle:
 	- ~return 1
 	- ~return 2
}
=== function rollD3() 
{ shuffle:
 	- ~return 1
 	- ~return 2
 	- ~return 3
}
=== function rollD4() 
{ shuffle:
 	- ~return 1
 	- ~return 2
 	- ~return 3
 	- ~return 4
}
=== function rollD5() 
{ shuffle:
 	- ~return 1
 	- ~return 2
 	- ~return 3
 	- ~return 4
 	- ~return 5
}
=== function rollD6() 
{ shuffle:
 	- ~return 1
 	- ~return 2
 	- ~return 3
 	- ~return 4
 	- ~return 5
 	- ~return 6
}
=== function rollD7() 
{ shuffle:
 	- ~return 1
 	- ~return 2
 	- ~return 3
 	- ~return 4
 	- ~return 5
 	- ~return 6
 	- ~return 7
}
=== function rollD8() 
{ shuffle:
 	- ~return 1
 	- ~return 2
 	- ~return 3
 	- ~return 4
 	- ~return 5
 	- ~return 6
 	- ~return 7
 	- ~return 8
}
=== function rollD9() 
{ shuffle:
 	- ~return 1
 	- ~return 2
 	- ~return 3
 	- ~return 4
 	- ~return 5
 	- ~return 6
 	- ~return 7
 	- ~return 8
 	- ~return 9
}
=== function rollD10() 
{ shuffle:
 	- ~return 1
 	- ~return 2
 	- ~return 3
 	- ~return 4
 	- ~return 5
 	- ~return 6
 	- ~return 7
 	- ~return 8
 	- ~return 9
 	- ~return 10
}
=== function breakTie(result, result2)
//comparing {result} vs {result2}
{ 
	- result > result2:
		~return 1
	- result < result2:
		~return 0
	- else:
		{ shuffle:
			- ~return 0
			- ~return 1 
		}
}

=== function decrement(val)
~return val-1
=== function increment(val)
~return val+1
=== function incrementIfTrue(val, condition)
{ 
	- condition: 
		~return val+1
	-else:
		~return val
}


=== function rollNumSuccessesEcho(numDiceLeft, tn, curSuccesses) 
{	
	- numDiceLeft !=0:
	     ~ temp rolledVal = rollD10()
	    <> {rolledVal}
	     { 
		  - rolledVal>=tn: 
				~curSuccesses = curSuccesses+1
		}
	     ~numDiceLeft = numDiceLeft - 1
		 ~return rollNumSuccessesEcho(numDiceLeft, tn, curSuccesses)
	- else: 
		Roll Result:{curSuccesses}
		~return curSuccesses
}

=== function rollNumSuccesses(numDiceLeft, tn, curSuccesses) 
{	
	- numDiceLeft !=0:
		 { 
		 	- rollD10()>=tn: 
				~curSuccesses = curSuccesses+1
		}
	     ~numDiceLeft = numDiceLeft - 1
		~return  rollNumSuccesses(numDiceLeft, tn, curSuccesses)
	- else: 
		~return curSuccesses
}

=== function inCriticalCondition(health) 
{
	- health == 1:
		~return 1
	-else:
		~elseResulted = 1
}
~return 0

=== function refreshCombatPool(ref cp, profeciencyLevel, reflex, totalPain, carryOverShock, health)
~temp inCritical =  inCriticalCondition(health)
~temp useReflex = reflex
{inCritical: 
	~useReflex = 1
}
~temp result = profeciencyLevel + useReflex -MathMax(carryOverShock, totalPain)
{inCritical: 
	~result = result/2
}
{result < 0: 
	~result = 0
}

~cp = result


// FOR COMBAT... (scenerio specific)
VAR numEnemies = 1
VAR numCombatants = 2

// CharacterMetaData
// relative client metaData
///* utest player var
CONST charPersonName_AI = 0
CONST charPersonName_isENEMY = 0
CONST charPersonName_isYOU = 1
VAR charPersonName_visited = 0
VAR charPersonName_avail = 0
VAR charPersonName_picked = 0
//*/
///* utest
VAR charPersonName2_AI = 1
CONST charPersonName2_isENEMY = 1
CONST charPersonName2_isYOU = 0
VAR charPersonName2_visited = 0
VAR charPersonName2_avail = 0
VAR charPersonName2_picked = 0
//*/

// CharacterSheet 
// for each char (tag charPersonName)
///* utest player var
CONST charPersonName_id = 1
VAR charPersonName_label = "CharPersonName"
VAR charPersonName_strength = 4
VAR charPersonName_toughness = 4
VAR charPersonName_reflex = 4
VAR charPersonName_willpower = 4
VAR charPersonName_mobility = 6
CONST charPersonName_perception = 4
VAR charPersonName_usingProfeciency ="swordandshield"
VAR charPersonName_usingProfeciencyLevel = 8
VAR charPersonName_carryOverShock = 0
VAR charPersonName_cp = 0
VAR charPersonName_totalPain = 0
VAR charPersonName_health = 4
VAR charPersonName_equipOffhand = "gladius"
VAR charPersonName_equipMasterhand = "gladius"
//*/
///* utest var
CONST charPersonName2_id = 2
VAR charPersonName2_label = "CharPersonName2"
VAR charPersonName2_strength = 4
VAR charPersonName2_toughness = 4
VAR charPersonName2_reflex = 4
VAR charPersonName2_willpower = 4
VAR charPersonName2_mobility = 6
VAR charPersonName2_perception = 4
VAR charPersonName2_usingProfeciency = "massweapons"
VAR charPersonName2_usingProfeciencyLevel = 8
VAR charPersonName2_carryOverShock = 0
VAR charPersonName2_cp = 0
VAR charPersonName2_totalPain = 0
VAR charPersonName2_health = 4
VAR charPersonName2_equipOffhand = "shield"
VAR charPersonName2_equipMasterhand = "mace"
//*/


// Fight
// targeting
CONST TARGET_NONE = 0
// stance
CONST STANCE_RESET = -1
CONST STANCE_NEUTRAL = 0
CONST STANCE_DEFENSIVE = 1
CONST STANCE_OFFENSIVE = 2
=== function getStanceLabel(stance)
{ 
    - stance==STANCE_NEUTRAL:  ~return "Neutral"
    - stance==STANCE_DEFENSIVE:  ~return "Defensive"
    - stance==STANCE_OFFENSIVE:  ~return "Offensive"
    - stance==STANCE_RESET: ~return "Resetted"
    -else:
		~elseResulted = 1
}
// combat orientation intent
CONST ORIENTATION_NONE = 0
CONST ORIENTATION_DEFENSIVE = 1
CONST ORIENTATION_CAUTIOUS = 2
CONST ORIENTATION_AGGRESSIVE = 3
=== function getOrientationLabel(orientation)
{ 
    - orientation==ORIENTATION_AGGRESSIVE:  ~return "Aggressive"
    - orientation==ORIENTATION_DEFENSIVE:  ~return "Defensive"
    - orientation==ORIENTATION_CAUTIOUS:  ~return "Cautious"
    - orientation==ORIENTATION_NONE: ~return "In the Midst of Fighting"
    -else:
		~elseResulted = 1
}

// initiative state reflection
CONST GOT_INITIATIVE = 2
CONST CONTESTING_INITIATIVE = 1 
CONST NO_INITIATIVE = 0
CONST REROLL_INITIATIVE = -1
CONST UNCERTAIN_INITATIVE = -2

// for each char (tag charPersonName)
VAR charPersonName_FIGHT = 1
VAR charPersonName_fight_side = 1
VAR charPersonName_fight_initiative = 1
VAR charPersonName_fight_stance = STANCE_RESET
VAR charPersonName_fight_orientation = ORIENTATION_NONE
VAR charPersonName_fight_shock = 0
VAR charPersonName_fight_target = TARGET_NONE
VAR charPersonName_fight_target2 = TARGET_NONE
VAR charPersonName_fight_target3 = TARGET_NONE
VAR charPersonName_fight_cautiousLock = 0
VAR charPersonName_fight_lastAttacked = 0
VAR charPersonName_manuever = ""
VAR charPersonName_manuever_CP = 0
VAR charPersonName_manuever_targetZone = 0
VAR charPersonName_manueverCost= 0
VAR charPersonName_manueverTN= 0
VAR charPersonName_manueverAttackType= 0
VAR charPersonName_manueverDamageType= 0
VAR charPersonName_manueverNeedBodyAim= 0
VAR charPersonName_manuever_attacking = 0
VAR charPersonName_manueverUsingHands = 0
VAR charPersonName_manuever2 = ""
VAR charPersonName_manuever2_CP = 0
VAR charPersonName_manuever2_targetZone = 0
VAR charPersonName_manuever2Cost= 0
VAR charPersonName_manuever2TN= 0
VAR charPersonName_manuever2AttackType= 0
VAR charPersonName_manuever2DamageType= 0
VAR charPersonName_manuever2NeedBodyAim= 0
VAR charPersonName_manuever2_attacking = 0
VAR charPersonName_manuever2UsingHands = 0
VAR charPersonName_manuever3 = ""
VAR charPersonName_manuever3_CP = 0
VAR charPersonName_manuever3Cost= 0
VAR charPersonName_manuever3TN= 0
VAR charPersonName_manuever3AttackType= 0
VAR charPersonName_manuever3DamageType= 0
VAR charPersonName_manuever3NeedBodyAim= 0
VAR charPersonName_manuever3UsingHands = 0
VAR charPersonName_fight_paused = 1
///* utest 
VAR charPersonName2_FIGHT = 1
VAR charPersonName2_fight_side = 2
VAR charPersonName2_fight_initiative = 1
VAR charPersonName2_fight_stance = STANCE_RESET
VAR charPersonName2_fight_orientation = ORIENTATION_NONE
VAR charPersonName2_fight_shock = 0
VAR charPersonName2_fight_target = TARGET_NONE
VAR charPersonName2_fight_target2 = TARGET_NONE
VAR charPersonName2_fight_target3 = TARGET_NONE
VAR charPersonName2_fight_cautiousLock = 0
VAR charPersonName2_fight_lastAttacked = 0
VAR charPersonName2_manuever = ""
VAR charPersonName2_manuever_CP = 0
VAR charPersonName2_manuever_targetZone = 0
VAR charPersonName2_manueverCost= 0
VAR charPersonName2_manueverTN= 0
VAR charPersonName2_manueverAttackType= 0
VAR charPersonName2_manueverDamageType= 0
VAR charPersonName2_manueverNeedBodyAim= 0
VAR charPersonName2_manuever_attacking = 0
VAR charPersonName2_manueverUsingHands = 0
VAR charPersonName2_manuever2 = ""
VAR charPersonName2_manuever2_CP = 0
VAR charPersonName2_manuever2_targetZone = 0
VAR charPersonName2_manuever2Cost= 0
VAR charPersonName2_manuever2TN= 0
VAR charPersonName2_manuever2AttackType= 0
VAR charPersonName2_manuever2DamageType= 0
VAR charPersonName2_manuever2NeedBodyAim= 0
VAR charPersonName2_manuever2_attacking = 0
VAR charPersonName2_manuever2UsingHands = 0
VAR charPersonName2_manuever3 = ""
VAR charPersonName2_manuever3_CP = 0
VAR charPersonName2_manuever3Cost= 0
VAR charPersonName2_manuever3TN= 0
VAR charPersonName2_manuever3AttackType= 0
VAR charPersonName2_manuever3DamageType= 0
VAR charPersonName2_manuever3NeedBodyAim= 0
VAR charPersonName2_manuever3UsingHands = 0
VAR charPersonName2_fight_paused = 1
//*/

// for each char (advanced) TBC
VAR shortRangeAdvantage = 0
//VAR lastHadInitiative

CONST RESOLVED_LOCKED = -1


// Current combat functions
=== function getAllManueverDetailsForCharacter(charId, manueverSlot, ref manuever, ref manuever_CP, ref manuever_targetZone, ref manueverCost, ref manueverTN, ref manueverAttackType, ref manueverDamageType, ref manueverNeedBodyAim, ref manuever_attacking, ref manueverUsingHands)
{
///* utest player
- charId == charPersonName_id: 
	{
	-manueverSlot==1:
		~manuever= charPersonName_manuever
		~manuever_CP = charPersonName_manuever_CP
		~manuever_targetZone = charPersonName_manuever_targetZone
		~manueverCost = charPersonName_manueverCost
		~manueverTN = charPersonName_manueverTN
		~manueverAttackType = charPersonName_manueverAttackType
		~manueverDamageType = charPersonName_manueverDamageType
		~manueverNeedBodyAim = charPersonName_manueverNeedBodyAim
		~manuever_attacking = charPersonName_manuever_attacking
		~manueverUsingHands= charPersonName_manueverUsingHands
	-manueverSlot==2:
		~manuever= charPersonName_manuever2
		~manuever_CP = charPersonName_manuever2_CP
		~manuever_targetZone = charPersonName_manuever2_targetZone
		~manueverCost = charPersonName_manuever2Cost
		~manueverTN = charPersonName_manuever2TN
		~manueverAttackType = charPersonName_manuever2AttackType
		~manueverDamageType = charPersonName_manuever2DamageType
		~manueverNeedBodyAim = charPersonName_manuever2NeedBodyAim
		~manuever_attacking = charPersonName_manuever2_attacking
		~manueverUsingHands= charPersonName_manuever2UsingHands
	-else:
		~manuever= charPersonName_manuever3
		~manuever_CP = charPersonName_manuever3_CP
		~manuever_targetZone = 0
		~manueverCost = charPersonName_manuever3Cost
		~manueverTN = charPersonName_manuever3TN
		~manueverAttackType = charPersonName_manuever3AttackType
		~manueverDamageType = charPersonName_manuever3DamageType
		~manueverNeedBodyAim = charPersonName_manuever3NeedBodyAim
		~manuever_attacking = 0
		~manueverUsingHands= charPersonName_manuever3UsingHands
	}
//*/
///* utest
- charId == charPersonName2_id:
	{
	-manueverSlot==1:
		~manuever= charPersonName2_manuever
		~manuever_CP = charPersonName2_manuever_CP
		~manuever_targetZone = charPersonName2_manuever_targetZone
		~manueverCost = charPersonName2_manueverCost
		~manueverTN = charPersonName2_manueverTN
		~manueverAttackType = charPersonName2_manueverAttackType
		~manueverDamageType = charPersonName2_manueverDamageType
		~manueverNeedBodyAim = charPersonName2_manueverNeedBodyAim
		~manuever_attacking = charPersonName2_manuever_attacking
		~manueverUsingHands= charPersonName2_manueverUsingHands
	-manueverSlot==2:
		~manuever= charPersonName2_manuever2
		~manuever_CP = charPersonName2_manuever2_CP
		~manuever_targetZone = charPersonName2_manuever2_targetZone
		~manueverCost = charPersonName2_manuever2Cost
		~manueverTN = charPersonName2_manuever2TN
		~manueverAttackType = charPersonName2_manuever2AttackType
		~manueverDamageType = charPersonName2_manuever2DamageType
		~manueverNeedBodyAim = charPersonName2_manuever2NeedBodyAim
		~manuever_attacking = charPersonName2_manuever2_attacking
		~manueverUsingHands= charPersonName2_manuever2UsingHands
	-else:
		~manuever= charPersonName2_manuever3
		~manuever_CP = charPersonName2_manuever3_CP
		~manuever_targetZone = 0
		~manueverCost = charPersonName2_manuever3Cost
		~manueverTN = charPersonName2_manuever3TN
		~manueverAttackType = charPersonName2_manuever3AttackType
		~manueverDamageType = charPersonName2_manuever3DamageType
		~manueverNeedBodyAim = charPersonName2_manuever3NeedBodyAim
		~manuever_attacking = 0
		~manueverUsingHands= charPersonName2_manuever3UsingHands
	}
//*/
}


=== function showPlayerInitiativeState()
///* utest player
{ charPersonName_fight_target==TARGET_NONE:{~return} }
~temp mutual =  getTargetByCharId(charPersonName_fight_target) == charPersonName_id
~temp mutualOrientation
Target{mutual:{" Opponent"}}: {getDescribeLabelOfCharCapital(charPersonName_fight_target)}{"   "}<>
{
	- charPersonName_fight_orientation == ORIENTATION_NONE || boutStep ==3:  // assumed initiative values are resolved by then...
	 {
	 	- mutual:
	 		{ 
	 			- charPersonName_fight_initiative:
	 			{ getInitiativeByCharId(charPersonName_fight_target): Contesting for initiative.|You have initiative. }
	 			- else:
	 			{ getInitiativeByCharId(charPersonName_fight_target): Target has initiative.|Both without initiative. }
	 		}
	 	 - else:
	 	 	{ charPersonName_fight_initiative: You have initiative.(target isn't aiming you) }
	 }
	- else:
	 {
	 	- mutual:
	 		~mutualOrientation = getOrientationByCharId(charPersonName_fight_target)
	 		{
	 			-charPersonName_fight_orientation == ORIENTATION_AGGRESSIVE && mutualOrientation == ORIENTATION_AGGRESSIVE:  
	 			  Contesting for initiative 
	 			-else:
	 			{
	 			- charPersonName_fight_orientation != ORIENTATION_DEFENSIVE:
	 				{ charPersonName_fight_orientation >  mutualOrientation: You have initiative.|Uncertain initiative }
	 			- else:
	 				{ mutualOrientation ==  ORIENTATION_DEFENSIVE: Both parties lack initiative.|Target has initiative. }
	 				
	 			}
	 		}
	 	
	 	 - else:
	 	 	{ charPersonName_fight_orientation != ORIENTATION_DEFENSIVE : You have initiative.(target isn't aiming you)|Without initiative and target isn't aiming you. }
	 }
}
//*/



// need to consider AI awareness of environment, situational aspects...
=== function getAIOrientation(charId, charStance)  
// default behaviour
{ shuffle:
 	-   ~return ORIENTATION_DEFENSIVE
    -   ~return ORIENTATION_CAUTIOUS
    -   ~return ORIENTATION_AGGRESSIVE
}

=== function getAIStance(charId)  
// default behaviour
{ shuffle:
    -   ~return STANCE_NEUTRAL
    -   ~return STANCE_NEUTRAL
    -   ~return STANCE_NEUTRAL
    -   ~return STANCE_NEUTRAL
    -   ~return STANCE_OFFENSIVE
    -   ~return STANCE_DEFENSIVE
}

=== function currentlyBeingAttackedBy(attacker, charIdToCheck, mustBePrimaryTarget)
~temp considerSecondaryManuever = (mustBePrimaryTarget==0)
{ 
	///* utest player
- attacker == charPersonName_id: 
	{
		- (charPersonName_fight_target == charIdToCheck && charPersonName_manuever_attacking) || (considerSecondaryManuever && charPersonName_fight_target2 == charIdToCheck && charPersonName_manuever2_attacking):
			~return 1
	}
	//*/
	///* utest
- attacker == charPersonName2_id:
	{
		- (charPersonName2_fight_target == charIdToCheck && charPersonName2_manuever_attacking) || (considerSecondaryManuever && charPersonName2_fight_target2 == charIdToCheck && charPersonName2_manuever2_attacking):
			~return 1
	}
	//*/
-else:
	~elseResulted = 1
}
~return 0






=== function getCharMetaInfo(charId, ref label, ref isAI, ref isEnemy, ref isYou) 
{
///* utest player
- charId == charPersonName_id: 
	~label = charPersonName_label
	~isAI = charPersonName_AI
	~isEnemy = charPersonName_isENEMY
	~isYou = charPersonName_isYOU
	//*/
	///* utest
- charId == charPersonName2_id:
	~label = charPersonName2_label
	~isAI = charPersonName2_AI
	~isEnemy = charPersonName2_isENEMY
	~isYou = charPersonName2_isYOU
	//*/
-else:
	~elseResulted = 1
}



=== function getMobilityByCharId(charId)
{
	///* utest player
- charId == charPersonName_id: 
	~return charPersonName_mobility
	//*/
	///* utest
- charId == charPersonName2_id:
	~return charPersonName2_mobility
	//*/
-else:
	~elseResulted = 1
}

=== function getReflexByCharId(charId)
{
	///* utest player
- charId == charPersonName_id: 
	~return charPersonName_reflex
	//*/
	///* utest
- charId == charPersonName2_id:
	~return charPersonName2_reflex
	//*/
-else:
	~elseResulted = 1
}

=== function getWillpowerByCharId(charId)
{
	///* utest player
- charId == charPersonName_id: 
	~return charPersonName_reflex
	//*/
	///* utest
- charId == charPersonName2_id:
	~return charPersonName2_reflex
	//*/
-else:
	~elseResulted = 1
}

=== function getStrengthByCharId(charId)
{
	///* utest player
- charId == charPersonName_id: 
	~return charPersonName_strength
	//*/
	///* utest
- charId == charPersonName2_id:
	~return charPersonName2_strength
	//*/
-else:
	~elseResulted = 1
}

=== function getToughnessByCharId(charId)
{
	///* utest player
- charId == charPersonName_id: 
	~return charPersonName_toughness
	//*/
	///* utest
- charId == charPersonName2_id:
	~return charPersonName2_toughness
	//*/
-else:
	~elseResulted = 1
}

// note: this method might depciiate
=== function getOrientationByCharId(charId)
{
	///* utest player
- charId == charPersonName_id: 
	~return charPersonName_fight_orientation
	//*/
	///* utest
- charId == charPersonName2_id:
	~return charPersonName2_fight_orientation
	//*/
-else:
	~elseResulted = 1
}

// note: this method might depciiate
=== function getInitiativeByCharId(charId)
{
	///* utest player
- charId == charPersonName_id: 
	~return charPersonName_fight_initiative
	//*/
	///* utest
- charId == charPersonName2_id:
	~return charPersonName2_fight_initiative
	//*/
-else:
	~elseResulted = 1
}

// temporary fix with to prevent naming conflicts with knot 't_' prefix...
=== function getTargetInitiativeStatesByCharId(charId, ref t_initiative, ref t_orientation, ref t_paused, ref t_lastAttacked, ref t_target, ref t_target2)
{
	///* utest player	
- charId == charPersonName_id: 
	~t_initiative = charPersonName_fight_initiative
	~t_orientation = charPersonName_fight_orientation
	~t_target = charPersonName_fight_target
	~t_target2 = charPersonName_fight_target2
	~t_lastAttacked = charPersonName_fight_lastAttacked
	//*/
	///* utest
- charId == charPersonName2_id:
	~t_initiative = charPersonName2_fight_initiative
	~t_orientation = charPersonName2_fight_orientation
	~t_target = charPersonName2_fight_target
	~t_target2 = charPersonName2_fight_target2
	~t_lastAttacked = charPersonName2_fight_lastAttacked
	//*/
-else:
	~elseResulted = 1
}



// NOTE, this method might depreciate
=== function getTargetByCharId(charId)
{
	///* utest player	
- charId == charPersonName_id: 
	~return charPersonName_fight_target
	//*/
	///* utest	
- charId == charPersonName2_id:
	~return charPersonName2_fight_target
	//*/
-else:
	~return TARGET_NONE
}

// NOTE, this method might depreciate
=== function getTarget2ByCharId(charId)
{
	///* utest player	
- charId == charPersonName_id: 
	~return charPersonName_fight_target2
	//*/
	///* utest	
- charId == charPersonName2_id:
	~return charPersonName2_fight_target2
	//*/
-else:
	~return TARGET_NONE
}



=== function getBeingTargettedCount(charId)
~temp count=0
{
	///* utest player
- charPersonName_fight_target == charId: 
	~count= count + 1
	//*/
	///* utest
- charPersonName2_fight_target == charId: 
	~count= count + 1
	//*/
-else:
	~elseResulted = 1
}
~return count

=== function getBeingTargettedCountByAtLeast(charId, atLeast)
~temp count=0
{
	///* utest player
- charPersonName_fight_target == charId: 
	~count= count + 1
	{
		- count >= atLeast: 
			~return 1
	}
	//*/
	///* utest
- charPersonName2_fight_target == charId: 
	~count= count + 1
	{
		- count >= atLeast: 
			~return 1
	}
	//*/
-else:
	~elseResulted = 1
}
~return 0


=== function charTargetedBy(charId, byId)
{
	///* utest player
- byId == charPersonName_id: 
	~return charPersonName_fight_target==charId
//*/
	///* utest
- byId == charPersonName2_id:
	~return charPersonName2_fight_target==charId
	//*/
-else:
	~elseResulted = 1
}
~return 0



// note: doesn't take into account cautiousLocked case
=== function setOrientationInitiative(ref fromInitiative, fromOrientation, toOrientation) 
// todo consider: cautious from outside to here....???
{ 
	-fromOrientation == ORIENTATION_CAUTIOUS && toOrientation == ORIENTATION_CAUTIOUS: 
	//THis shoudln't happen ORIETANTION cautious
		~return
}
{
- fromOrientation >= toOrientation && fromOrientation!=ORIENTATION_DEFENSIVE:
	~fromInitiative = 1
	//setting intiaitive to 1
- else:
	~fromInitiative = 0
	//setting initaitive to 0
}



=== function fight_resolve_initiative(fromId, targetId, gainedInitiative )
{
///* utest player
- fromId == charPersonName_id: 
	{
		-gainedInitiative>0: 
			~charPersonName_fight_initiative = 1
		-else:
			~charPersonName_fight_initiative = 0
	}
	~charPersonName_fight_cautiousLock = RESOLVED_LOCKED	
	//*/
	///* utest
- fromId == charPersonName2_id:
	{
		-gainedInitiative>0: 
			~charPersonName2_fight_initiative = 1
		-else:	
			~charPersonName2_fight_initiative = 0
	}
	~charPersonName2_fight_cautiousLock = RESOLVED_LOCKED
//*/
-else:
	~elseResulted = 1
}
{
///* utest player
- targetId == charPersonName_id:
	{
		-gainedInitiative<=0: 
			~charPersonName_fight_initiative = 1
		-else:	
			~charPersonName_fight_initiative = 0
			
	}
	~charPersonName_fight_cautiousLock = RESOLVED_LOCKED
//*/
///* utest
- targetId == charPersonName2_id:
	{
		-gainedInitiative<=0: 
			~charPersonName2_fight_initiative = 1
		-else:	
			~charPersonName2_fight_initiative = 0
	}
	~charPersonName2_fight_cautiousLock = RESOLVED_LOCKED
//*/
-else:
	~elseResulted = 1
}

=== function fight_cancelBothInitiatives(fromId, targetId )
{
///* utest player
- fromId == charPersonName_id: 
	~charPersonName_fight_initiative = 0
	~charPersonName_fight_cautiousLock = RESOLVED_LOCKED	
//*/	
///* utest
- fromId == charPersonName2_id:
	~charPersonName2_fight_initiative = 0
	~charPersonName2_fight_cautiousLock = RESOLVED_LOCKED
//*/
-else:
	~elseResulted = 1
}
{
///* utest player
- targetId == charPersonName_id:
	~charPersonName_fight_initiative = 0
	~charPersonName_fight_cautiousLock = RESOLVED_LOCKED
//*/	
///* utest
- targetId == charPersonName2_id:
	~charPersonName2_fight_initiative = 0
	~charPersonName2_fight_cautiousLock = RESOLVED_LOCKED
//*/
-else:
	~elseResulted = 1
}

=== function fight_set_cautiousStates(fromId, targetId ) 
{
///* utest player
- fromId == charPersonName_id:
	~charPersonName_fight_cautiousLock = 1 
//*/
///* utest
- fromId == charPersonName2_id:
	~charPersonName2_fight_cautiousLock = 1
//*/
-else:
	~elseResulted = 1
}
{
///* utest player
- targetId == charPersonName_id:
	~charPersonName_fight_cautiousLock = 1
	~charPersonName_fight_target = fromId
//*/
///* utest
- targetId == charPersonName2_id:
	~charPersonName2_fight_cautiousLock = 1
	~charPersonName2_fight_target = fromId
//*/
-else:
	~elseResulted = 1
}

=== function getNameOfChar(charId)
{
	///* player
	- charId == charPersonName_id:
		~return charPersonName_label
	//*/
	///* utest
	- charId == charPersonName2_id:
		~return charPersonName2_label
	//*/
	-else:
	~elseResulted = 1
}

=== function getDescribeLabelOfCharCapital(charId)
{
	///* utest player
	- charId == charPersonName_id:
		~return "You"
	//*/
	///* utest
	- charId == charPersonName2_id:
		~return charPersonName2_label
	//*/
	-else:
	~elseResulted = 1
}

=== function getDescribeLabelOfChar(charId)
{
	///* utest player
	- charId == charPersonName_id:
		~return "you"
	//*/
	///* utest
	- charId == charPersonName2_id:
		~return charPersonName2_label
	//*/
	-else:
	~elseResulted = 1

}




=== function pickTarget(fromId, fromOrientation, targetId, ref targetTarget, targetOrientation)
{
	///* utest player
	- fromId == charPersonName_id:
		~charPersonName_fight_target = targetId
	//*/
	///* utest
	- fromId == charPersonName2_id:
		~charPersonName2_fight_target = targetId
	//*/
	-else:
	~elseResulted = 1
}
//{getOrientationLabel(targetOrientation)} :: {targetOrientation} :: {targetTarget} :: {targetOrientation == ORIENTATION_CAUTIOUS : Yes}  {targetTarget==TARGET_NONE: Yes}
{ 
  - targetOrientation == ORIENTATION_CAUTIOUS && targetTarget==TARGET_NONE: 
		~targetTarget = fromId
		{
		- fromOrientation == ORIENTATION_CAUTIOUS:	
			{fight_set_cautiousStates(fromId, targetId)}
		}
	~return 1 
}
~return 0


=== function pickResetCharactersAll()
///* utest player
~charPersonName_picked = 0
~charPersonName_visited = 0
~charPersonName_avail = 0
//*/
///* utest 
~charPersonName2_picked = 0
~charPersonName2_visited = 0
~charPersonName2_avail = 0
//*/

=== function repickingCharacters()
///* utest player
~charPersonName_picked = 0
~charPersonName_avail = 0
//*/
///* utest 
~charPersonName2_picked = 0
~charPersonName2_avail = 0
//*/


VAR juncture = 0

=== PickCharactersWithAttributeVal(attr, isDescending, ->callback)
~pickResetCharactersAll()
~juncture = 0
~temp curAvailability = 0

-> GotoLoop

= GotoLoop
~repickingCharacters()
{
	- curAvailability > 1:
	 ~curAvailability = 0
	 ~juncture = juncture -1
}
{
	- isDescending:
		-> LoopDescend
	- else:
		-> LoopAscend
}


= LoopAscend
{
	-juncture < 1:
		~juncture = 1
		->PickCharWithAttrVal(0,  1, ->GotoLoop)
}
{
	-juncture < 2:
		~juncture = 2
		->PickCharWithAttrVal(0,  2, ->GotoLoop)
}
{
	-juncture < 3:
		~juncture = 3
		->PickCharWithAttrVal(0,  3, ->GotoLoop)
}
{
	-juncture < 4:
		~juncture = 4
		->PickCharWithAttrVal(0,  4,  ->GotoLoop)
}
{
	-juncture < 5:
		~juncture = 5
		->PickCharWithAttrVal(0,  5,  ->GotoLoop)
}
{
	-juncture < 6:
		~juncture = 6
		->PickCharWithAttrVal(0,  6,  ->GotoLoop)
}
{
	-juncture < 7:
		~juncture = 7
		->PickCharWithAttrVal(0,  7,  ->GotoLoop)
}
{
	-juncture < 8:
		~juncture = 8
		->PickCharWithAttrVal(0,  8,  ->GotoLoop)
}
{
	-juncture < 9:
		~juncture = 9
		->PickCharWithAttrVal(0,  9,  ->GotoLoop)
}
{
	-juncture < 10:
		~juncture = 10
		->PickCharWithAttrVal(0,  10,  ->GotoLoop)
}
->callback


= LoopDescend
{
	-juncture < 1:
		~juncture = 1
		->PickCharWithAttrVal(0,  10,  ->GotoLoop)
}
{
	-juncture < 2:
		~juncture = 2
		->PickCharWithAttrVal(0,  9,  ->GotoLoop)
}
{
	-juncture < 3:
		~juncture = 3
		->PickCharWithAttrVal(0,  8,  ->GotoLoop)
}
{
	-juncture < 4:
		~juncture = 4
		->PickCharWithAttrVal(0,  7,  ->GotoLoop)
}
{
	-juncture < 5:
		~juncture = 5
		->PickCharWithAttrVal(0,  6,  ->GotoLoop)
}
{
	-juncture < 6:
		~juncture = 6
		->PickCharWithAttrVal(0,  5,  ->GotoLoop)
}
{
	-juncture < 7:
		~juncture = 7
		->PickCharWithAttrVal(0,  4,  ->GotoLoop)
}
{
	-juncture < 8:
		~juncture = 8
		->PickCharWithAttrVal(0,  3,  ->GotoLoop)
}
{
	-juncture < 9:
		~juncture = 9
		->PickCharWithAttrVal(0,  2,  ->GotoLoop)
}
{
	-juncture < 10:
		~juncture = 10
		->PickCharWithAttrVal(0,  1,  ->GotoLoop)
}
-> callback


= PickCharWithAttrVal(pickResult, val,  ->noCandidateCallback )
~temp pickAvailabilityCount = 0
//Attempting pick at {attr}={val} ..Confirming? {pickResult}
{

- attr == "reflex":
	///* utest all
	{
		- pickResult == 0:	
			{
			- charPersonName_visited==0 && charPersonName_reflex == val:
				~charPersonName_avail = 1
				~pickAvailabilityCount = pickAvailabilityCount +1
			}
		-else:
			{
			-charPersonName_avail:
				~pickAvailabilityCount = pickAvailabilityCount +1
				{
					- pickAvailabilityCount >= pickResult:
						~charPersonName_picked = 1
						~charPersonName_visited = 1
						->callback
				}
			}
	}
	{
		- pickResult == 0:	
			{
			- charPersonName2_visited== 0 && charPersonName2_reflex == val:
				~charPersonName2_avail = 1
				~pickAvailabilityCount = pickAvailabilityCount +1
			}
		-else:
			{
			-charPersonName2_avail:
				~pickAvailabilityCount = pickAvailabilityCount +1
				{
					- pickAvailabilityCount >= pickResult:
						~charPersonName2_picked = 1
						~charPersonName2_visited = 1
						->callback
				}
			}
	}
	//*/
- attr == "perception":
	///* utest all
	{
		- pickResult == 0:	
			{
			- charPersonName_visited==0 && charPersonName_perception == val:
				~charPersonName_avail = 1
				~pickAvailabilityCount = pickAvailabilityCount +1
			}
		-else:
			{
			-charPersonName_avail:
				~pickAvailabilityCount = pickAvailabilityCount +1
				{
					- pickAvailabilityCount >= pickResult:
						~charPersonName_picked = 1
						~charPersonName_visited = 1
						->callback
				}
			}
	}
	{
		- pickResult == 0:	
			{
			- charPersonName2_visited== 0 && charPersonName2_perception == val:
				~charPersonName2_avail = 1
				~pickAvailabilityCount = pickAvailabilityCount +1
			}
		-else:
			{
			-charPersonName2_avail:
				~pickAvailabilityCount = pickAvailabilityCount +1
				{
					- pickAvailabilityCount >= pickResult:
						~charPersonName2_picked = 1
						~charPersonName2_visited = 1
						->callback
				}
			}
	}
	//*/
- attr == "mobility":
	///* utest all
	{
		- pickResult == 0:	
			{
			- charPersonName_visited==0 && charPersonName_mobility == val:
				~charPersonName_avail = 1
				~pickAvailabilityCount = pickAvailabilityCount +1
			}
		-else:
			{
			-charPersonName_avail:
				~pickAvailabilityCount = pickAvailabilityCount +1
				{
					- pickAvailabilityCount >= pickResult:
						~charPersonName_picked = 1
						~charPersonName_visited = 1
						->callback
				}
			}
	}
	{
		- pickResult == 0:	
			{
			- charPersonName2_visited== 0 && charPersonName2_reflex == val:
				~charPersonName2_avail = 1
				~pickAvailabilityCount = pickAvailabilityCount +1
			}
		-else:
			{
			-charPersonName2_avail:
				~pickAvailabilityCount = pickAvailabilityCount +1
				{
					- pickAvailabilityCount >= pickResult:
						~charPersonName2_picked = 1
						~charPersonName2_visited = 1
						->callback
				}
			}
	}
	//*/
- else:
	 Exception::: Sorry, pick attribute: {attr} not supported! No one will be picked!
}
{
	-pickResult:
		->PickCharWithAttrValLooseEndException
}
~curAvailability = pickAvailabilityCount
{
	- pickResult == 0:
		{
			- pickAvailabilityCount > 1:
				->PickCharWithAttrVal( rollNSided(pickAvailabilityCount),  val,  noCandidateCallback )
			- pickAvailabilityCount:
				->PickCharWithAttrVal(1,  val,  noCandidateCallback )
			-else: 
				->noCandidateCallback
		}
	-else:
		->noCandidateCallback
}
->noCandidateCallback

= PickCharWithAttrValLooseEndException
Exception found PickCharWithAttrValLooseEndException!
->DONE