// Common globals
VAR boutRounds=1	
VAR boutExchange=1
VAR boutStep=-1
VAR elseResulted = 0

// Common Functions  (usually stateful, game-specific)
=== function showCombatStatus()
~ return "Round "+boutRounds+" - Exchange: "+boutExchange+"/2"


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
{inCritical: useReflex = 1}
~temp result = profeciencyLevel + useReflex -MathMax(carryOverShock, totalPain)
{inCritical: result = result/2}
{result < 0: result = 0}
~cp = result


// FOR COMBAT... (scenerio specific)
VAR numEnemies = 1
VAR numCombatants = 2

// CharacterMetaData
// relative client metaData
///* player
CONST charPersonName_AI = 0
CONST charPersonName_isENEMY = 0
CONST charPersonName_isYOU = 1
//*/
///* utest
VAR charPersonName2_AI = 1
CONST charPersonName2_isENEMY = 1
CONST charPersonName2_isYOU = 0
//*/

// CharacterSheet 
// for each char (tag charPersonName)
///* player
CONST charPersonName_id = 1
VAR charPersonName_label = "CharPersonName"
CONST charPersonName_reflex = 5
CONST charPersonName_mobility = 5
VAR charPersonName_usingProfeciency ="swordandshield"
VAR charPersonName_usingProfeciencyLevel = 15
VAR charPersonName_carryOverShock = 0
VAR charPersonName_cp = 0
VAR charPersonName_totalPain = 0
VAR charPersonName_health = 5
VAR charPersonName_equipOffhand = "gladius"
VAR charPersonName_equipMasterhand = "gladius"

//*/
///* utest
CONST charPersonName2_id = 2
VAR charPersonName2_label = "CharPersonName2"
CONST charPersonName2_reflex = 3
CONST charPersonName2_mobility = 4
VAR charPersonName2_usingProfeciency = "massweapons"
VAR charPersonName2_usingProfeciencyLevel = 8
VAR charPersonName2_carryOverShock = 0
VAR charPersonName2_cp = 0
VAR charPersonName2_totalPain = 0
VAR charPersonName2_health = 5
VAR charPersonName2_equipOffhand = "shield"
VAR charPersonName2_equipMasterhand = "mace"

//*/
// for each char.body... parts... (tag bodyPartName)
VAR charPersonName_wound_bodyPartName = 0
///* utest 
VAR charPersonName_wound_bodyPartName2 = 0
VAR charPersonName2_wound_bodyPartName = 0
VAR charPersonName2_wound_bodyPartName2 = 0

//*/

// Fight
// targeting
CONST TARGET_NONE = -1
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
VAR charPersonName_fight_cautiousLock = 0
VAR charPersonName_fight_lastAttacked = 0
VAR charPersonName_manuever = 0
VAR charPersonName_manuever_CP = 0
VAR charPersonName_manuever_targetZone = 0
VAR charPersonName_manueverCost= 0
VAR charPersonName_manueverTN= 0
VAR charPersonName_manueverAttackType= 0
VAR charPersonName_manueverDamageType= 0
VAR charPersonName_manueverNeedBodyAim= 0
VAR charPersonName_manuever_rollAmount = 0
VAR charPersonName_manuever_attacking = 0
VAR charPersonName_manueverUsingHands = 0
VAR charPersonName_manuever2 = 0
VAR charPersonName_manuever2_CP = 0
VAR charPersonName_manuever2_targetZone = 0
VAR charPersonName_manuever2Cost= 0
VAR charPersonName_manuever2TN= 0
VAR charPersonName_manuever2AttackType= 0
VAR charPersonName_manuever2DamageType= 0
VAR charPersonName_manuever2NeedBodyAim= 0
VAR charPersonName_manuever2_rollAmount = 0
VAR charPersonName_manuever2_attacking = 0
VAR charPersonName_manuever2UsingHands = 0
VAR charPersonName_manuever3 = 0
VAR charPersonName_manuever3_CP = 0
VAR charPersonName_manuever3_targetZone = 0
VAR charPersonName_manuever3Cost= 0
VAR charPersonName_manuever3TN= 0
VAR charPersonName_manuever3AttackType= 0
VAR charPersonName_manuever3DamageType= 0
VAR charPersonName_manuever3NeedBodyAim= 0
VAR charPersonName_manuever3_rollAmount = 0
VAR charPersonName_manuever3_attacking = 0
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
VAR charPersonName2_fight_cautiousLock = 0
VAR charPersonName2_fight_lastAttacked = 0
VAR charPersonName2_manuever = 0
VAR charPersonName2_manuever_CP = 0
VAR charPersonName2_manuever_targetZone = 0
VAR charPersonName2_manueverCost= 0
VAR charPersonName2_manueverTN= 0
VAR charPersonName2_manueverAttackType= 0
VAR charPersonName2_manueverDamageType= 0
VAR charPersonName2_manueverNeedBodyAim= 0
VAR charPersonName2_manuever_rollAmount = 0
VAR charPersonName2_manuever_attacking = 0
VAR charPersonName2_manueverUsingHands = 0
VAR charPersonName2_manuever2 = 0
VAR charPersonName2_manuever2_CP = 0
VAR charPersonName2_manuever2_targetZone = 0
VAR charPersonName2_manuever2Cost= 0
VAR charPersonName2_manuever2TN= 0
VAR charPersonName2_manuever2AttackType= 0
VAR charPersonName2_manuever2DamageType= 0
VAR charPersonName2_manuever2NeedBodyAim= 0
VAR charPersonName2_manuever2_rollAmount = 0
VAR charPersonName2_manuever2_attacking = 0
VAR charPersonName2_manuever2UsingHands = 0
VAR charPersonName2_manuever3 = 0
VAR charPersonName2_manuever3_CP = 0
VAR charPersonName2_manuever3_targetZone = 0
VAR charPersonName2_manuever3Cost= 0
VAR charPersonName2_manuever3TN= 0
VAR charPersonName2_manuever3AttackType= 0
VAR charPersonName2_manuever3DamageType= 0
VAR charPersonName2_manuever3NeedBodyAim= 0
VAR charPersonName2_manuever3_rollAmount = 0
VAR charPersonName2_manuever3_attacking = 0
VAR charPersonName2_manuever3UsingHands = 0
VAR charPersonName2_fight_paused = 1
//*/

// for each char (advanced) TBC
VAR shortRangeAdvantage = 0
//VAR lastHadInitiative

CONST RESOLVED_LOCKED = -1


// Current combat functions
=== function showPlayerInitiativeState()
///* player
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
	///* utest all
- attacker == charPersonName_id: 
	{
		- (charPersonName_fight_target == charIdToCheck && charPersonName_manuever_attacking) || (considerSecondaryManuever && charPersonName_fight_target2 == charIdToCheck && charPersonName_manuever2_attacking):
			~return 1
	}
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
///* utest all
- charId == charPersonName_id: 
	~label = charPersonName_label
	~isAI = charPersonName_AI
	~isEnemy = charPersonName_isENEMY
	~isYou = charPersonName_isYOU
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
	///* utest all
- charId == charPersonName_id: 
	~return charPersonName_mobility
- charId == charPersonName2_id:
	~return charPersonName2_mobility
	//*/
-else:
	~elseResulted = 1
}

=== function getReflexByCharId(charId)
{
	///* utest all
- charId == charPersonName_id: 
	~return charPersonName_reflex
- charId == charPersonName2_id:
	~return charPersonName2_reflex
	//*/
-else:
	~elseResulted = 1
}

// note: this method might depciiate
=== function getOrientationByCharId(charId)
{
	///* utest all
- charId == charPersonName_id: 
	~return charPersonName_fight_orientation
- charId == charPersonName2_id:
	~return charPersonName2_fight_orientation
	//*/
-else:
	~elseResulted = 1
}

// note: this method might depciiate
=== function getInitiativeByCharId(charId)
{
	///* utest all
- charId == charPersonName_id: 
	~return charPersonName_fight_initiative
- charId == charPersonName2_id:
	~return charPersonName2_fight_initiative
	//*/
-else:
	~elseResulted = 1
}

// temporary fix with to prevent naming conflicts with knot 't_' prefix...
=== function getTargetInitiativeStatesByCharId(charId, ref t_initiative, ref t_orientation, ref t_paused, ref t_lastAttacked, ref t_target, ref t_target2)
{
	///* utest 	all
- charId == charPersonName_id: 
	~t_initiative = charPersonName_fight_initiative
	~t_orientation = charPersonName_fight_orientation
	~t_target = charPersonName_fight_target
	~t_target2 = charPersonName_fight_target2
	~t_lastAttacked = charPersonName_fight_lastAttacked
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
	///* utest all
- charId == charPersonName_id: 
	~return charPersonName_fight_target
- charId == charPersonName2_id:
	~return charPersonName2_fight_target
	//*/
-else:
	~elseResulted = 1
}

// NOTE, this method might depreciate
=== function getTarget2ByCharId(charId)
{
	///* utest all
- charId == charPersonName_id: 
	~return charPersonName_fight_target2
- charId == charPersonName2_id:
	~return charPersonName2_fight_target2
	//*/
-else:
	~elseResulted = 1
}



=== function getBeingTargettedCount(charId)
~temp count=0
{
	///* utest all
- charPersonName_fight_target == charId: 
	~count= count + 1
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
	///* utest all
- charPersonName_fight_target == charId: 
	~count= count + 1
	{
		- count >= atLeast: 
			~return 1
	}
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
	///* utest all
- byId == charPersonName_id: 
	~return charPersonName_fight_target==charId
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
///* utest all
- fromId == charPersonName_id: 
	{
		-gainedInitiative>0: 
			~charPersonName_fight_initiative = 1
		-else:
			~charPersonName_fight_initiative = 0
	}
	~charPersonName_fight_cautiousLock = RESOLVED_LOCKED	
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
///* utest all
- targetId == charPersonName_id:
	{
		-gainedInitiative<=0: 
			~charPersonName_fight_initiative = 1
		-else:	
			~charPersonName_fight_initiative = 0
			
	}
	~charPersonName_fight_cautiousLock = RESOLVED_LOCKED

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
///* utest all
- fromId == charPersonName_id: 
	~charPersonName_fight_initiative = 0
	~charPersonName_fight_cautiousLock = RESOLVED_LOCKED	
- fromId == charPersonName2_id:
	~charPersonName2_fight_initiative = 0
	~charPersonName2_fight_cautiousLock = RESOLVED_LOCKED
//*/
-else:
	~elseResulted = 1
}
{
///* utest all
- targetId == charPersonName_id:
	~charPersonName_fight_initiative = 0
	~charPersonName_fight_cautiousLock = RESOLVED_LOCKED
- targetId == charPersonName2_id:
	~charPersonName2_fight_initiative = 0
	~charPersonName2_fight_cautiousLock = RESOLVED_LOCKED
//*/
-else:
	~elseResulted = 1
}

=== function fight_set_cautiousStates(fromId, targetId ) 
{
///* utest all
- fromId == charPersonName_id:
	~charPersonName_fight_cautiousLock = 1 
- fromId == charPersonName2_id:
	~charPersonName2_fight_cautiousLock = 1
//*/
-else:
	~elseResulted = 1
}
{
///* utest all
- targetId == charPersonName_id:
	~charPersonName_fight_cautiousLock = 1
	~charPersonName_fight_target = fromId
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
	///* player
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
	///* player
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
	///* player
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


=== function inflictWoundOn(targetId, targetPart, woundLevel)
{ 
- targetId == charPersonName_id: 
 	{
///* player
	- targetPart == "bodyPartName": 
		~charPersonName_wound_bodyPartName=MathMax(woundLevel,charPersonName_wound_bodyPartName)
	- targetPart == "bodyPartName2":
		 ~charPersonName_wound_bodyPartName2=MathMax(woundLevel,charPersonName_wound_bodyPartName2)
	}
	//*/
///* utest
- targetId == charPersonName2_id: 
 	{
	- targetPart == "bodyPartName": 
		~charPersonName2_wound_bodyPartName=MathMax(woundLevel,charPersonName2_wound_bodyPartName)
	- targetPart == "bodyPartName2":
		 ~charPersonName2_wound_bodyPartName2=MathMax(woundLevel,charPersonName2_wound_bodyPartName2)
	}
//*/
-else:
	~elseResulted = 1
}

=== function setManuever(srcId, diceToRoll, targetId, targetZone)
~return