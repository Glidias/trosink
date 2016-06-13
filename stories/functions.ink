// Common globals
VAR boutRounds=1	
VAR boutExchange=1
VAR boutStep=-1

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


=== function rollD6() 
{ shuffle:
 	- ~return 1
 	- ~return 2
 	- ~return 3
 	- ~return 4
 	- ~return 5
 	- ~return 6
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
CONST charPersonName2_AI = 1
CONST charPersonName2_isENEMY = 1
CONST charPersonName2_isYOU = 0
//*/

// CharacterSheet (id==0 implicit Main Character "You")
// for each char (tag charPersonName)
///* player
CONST charPersonName_id = 0
CONST charPersonName_label = "CharPersonName"
CONST charPersonName_reflex = 5
CONST charPersonName_mobility = 5
//*/
///* utest
CONST charPersonName2_id = 1
CONST charPersonName2_label = "CharPersonName2"
CONST charPersonName2_reflex = 3
CONST charPersonName2_mobility = 4
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
VAR charPersonName_manuever = 0
VAR charPersonName_manuever_CP = 0
VAR charPersonName_manuever_targetZone = 0
VAR charPersonName_manueverCost= 0
VAR charPersonName_manueverTN= 0
VAR charPersonName_manueverAttackType= 0
VAR charPersonName_manueverDamageType= 0
VAR charPersonName_manueverNeedBodyAim= 0
VAR charPersonName_manuever2 = 0
VAR charPersonName_manuever2_CP = 0
VAR charPersonName_manuever2_targetZone = 0
VAR charPersonName_manuever2Cost= 0
VAR charPersonName_manuever2TN= 0
VAR charPersonName_manuever2AttackType= 0
VAR charPersonName_manuever2DamageType= 0
VAR charPersonName_manuever2NeedBodyAim= 0
VAR charPersonName_manuever3 = 0
VAR charPersonName_manuever3_CP = 0
VAR charPersonName_manuever3_targetZone = 0
VAR charPersonName_manuever3Cost= 0
VAR charPersonName_manuever3TN= 0
VAR charPersonName_manuever3AttackType= 0
VAR charPersonName_manuever3DamageType= 0
VAR charPersonName_manuever3NeedBodyAim= 0

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
VAR charPersonName2_manuever = 0
VAR charPersonName2_manuever_CP = 0
VAR charPersonName2_manuever_targetZone = 0
VAR charPersonName2_manueverCost= 0
VAR charPersonName2_manueverTN= 0
VAR charPersonName2_manueverAttackType= 0
VAR charPersonName2_manueverDamageType= 0
VAR charPersonName2_manueverNeedBodyAim= 0
VAR charPersonName2_manuever2 = 0
VAR charPersonName2_manuever2_CP = 0
VAR charPersonName2_manuever2_targetZone = 0
VAR charPersonName2_manuever2Cost= 0
VAR charPersonName2_manuever2TN= 0
VAR charPersonName2_manuever2AttackType= 0
VAR charPersonName2_manuever2DamageType= 0
VAR charPersonName2_manuever2NeedBodyAim= 0
VAR charPersonName2_manuever3 = 0
VAR charPersonName2_manuever3_CP = 0
VAR charPersonName2_manuever3_targetZone = 0
VAR charPersonName2_manuever3Cost= 0
VAR charPersonName2_manuever3TN= 0
VAR charPersonName2_manuever3AttackType= 0
VAR charPersonName2_manuever3DamageType= 0
VAR charPersonName2_manuever3NeedBodyAim= 0
VAR charPersonName2_fight_paused = 1
//*/

// for each char (advanced) TBC
VAR charPersonName_lastAttacking = 0
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



=== function getMobilityByCharId(charId)
{
	///* utest all
- charId == charPersonName_id: 
	~return charPersonName_mobility
- charId == charPersonName2_id:
	~return charPersonName2_mobility
	//*/
}

=== function getReflexByCharId(charId)
{
	///* utest all
- charId == charPersonName_id: 
	~return charPersonName_reflex
- charId == charPersonName2_id:
	~return charPersonName2_reflex
	//*/
}

=== function getOrientationByCharId(charId)
{
	///* utest all
- charId == charPersonName_id: 
	~return charPersonName_fight_orientation
- charId == charPersonName2_id:
	~return charPersonName2_fight_orientation
	//*/
}

=== function getInitiativeByCharId(charId)
{
	///* utest all
- charId == charPersonName_id: 
	~return charPersonName_fight_initiative
- charId == charPersonName2_id:
	~return charPersonName2_fight_initiative
	//*/
}

=== function getTargetByCharId(charId)
{
	///* utest all
- charId == charPersonName_id: 
	~return charPersonName_fight_target
- charId == charPersonName2_id:
	~return charPersonName2_fight_target
	//*/
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
}

=== function fight_set_cautiousStates(fromId, targetId ) 
{
///* utest all
- fromId == charPersonName_id:
	~charPersonName_fight_cautiousLock = 1 
- fromId == charPersonName2_id:
	~charPersonName2_fight_cautiousLock = 1
//*/
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
}

=== function setManuever(srcId, diceToRoll, targetId, targetZone)
~return