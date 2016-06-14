// Unit tests

=== testing_inflictWoundOn
{inflictWoundOn(charPersonName_id, "bodyPartName2", 3)}
{inflictWoundOn(charPersonName_id, "bodyPartName2", 2)}
{inflictWoundOn(charPersonName2_id, "bodyPartName", 4)}
testing_inflictWoundOn person1 {charPersonName_wound_bodyPartName}  {charPersonName_wound_bodyPartName2}
testing_inflictWoundOn person2 {charPersonName2_wound_bodyPartName}  {charPersonName2_wound_bodyPartName2}
-> DONE

=== testing_rollNumSuccesses
{rollNumSuccesses(7,5,0)}
-> DONE

=== testing_fight_resolve_initiative
~temp roll = rollNumSuccesses(5,5,0)
~temp roll2 = rollNumSuccesses(5,5,0)
using temporary var roll: {roll} {roll2}
// resulter uses embedded two rollD10() calls within main primary function
~temp whoWins =  breakTie( rollNumSuccesses(charPersonName_reflex,5,0), rollNumSuccesses(getReflexByCharId(1),5,0))
{fight_resolve_initiative(charPersonName_id,charPersonName2_id, whoWins ) }
initiiatives: {charPersonName_fight_initiative} {charPersonName2_fight_initiative}
-> DONE

=== testing_ChooseManueverForChar
{charPersonName_id}
{refreshCombatPool(charPersonName_cp, charPersonName_usingProfeciencyLevel, charPersonName_reflex, charPersonName_totalPain, charPersonName_carryOverShock, charPersonName_health )}
{refreshCombatPool(charPersonName2_cp, charPersonName2_usingProfeciencyLevel, charPersonName2_reflex, charPersonName2_totalPain, charPersonName2_carryOverShock, charPersonName2_health )}
-> ChooseManueverForChar( charPersonName_id, charPersonName2_id, ->TestDone, charPersonName_manuever, charPersonName_manueverCost, charPersonName_manueverTN, charPersonName_manueverAttackType, charPersonName_manueverDamageType, charPersonName_manueverNeedBodyAim)

=== testing_ChooseManueverListAtk
-> ChooseManueverListAtk("massweapons", 5, 14, ORIENTATION_AGGRESSIVE,   6,7,4,5, 1, 0,    0,0, ->TestDone)


//=== testing_ChooseManueverListDef
//=== ChooseManueverListDef(profeciencyType, profeciencyLevel, diceAvailable, orientation, lastAttacked, hasShield, enemyDiceRolled, enemyTargetZone, enemyManueverType, DTN, DTNt, DTN_off, DTNt_off ) 
//-> ChooseManueverListDef("massweapons", 5, 14, ORIENTATION_CAUTIOUS,  0,1   ,5,5, 0,    7,7,6,7 ,    0  )


=== TestDone
Test Completed!
->DONE