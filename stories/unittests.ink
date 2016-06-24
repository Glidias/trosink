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
~charPersonName_fight_orientation = ORIENTATION_AGGRESSIVE
~charPersonName_fight_target = charPersonName2_id
{refreshCombatPool(charPersonName_cp, charPersonName_usingProfeciencyLevel, charPersonName_reflex, charPersonName_totalPain, charPersonName_carryOverShock, charPersonName_health )}
{refreshCombatPool(charPersonName2_cp, charPersonName2_usingProfeciencyLevel, charPersonName2_reflex, charPersonName2_totalPain, charPersonName2_carryOverShock, charPersonName2_health )}
-> ChooseManueverForChar(1, charPersonName_id, charPersonName2_id, 0,0, charPersonName_cp, ->TestDone, charPersonName_manuever, charPersonName_manueverCost, charPersonName_manueverTN, charPersonName_manueverAttackType, charPersonName_manueverDamageType, charPersonName_manueverNeedBodyAim, charPersonName_manuever_attacking, charPersonName_manueverUsingHands, charPersonName_manuever_CP, charPersonName_manuever_targetZone)

=== testing_ChooseManueverForCharDef
~charPersonName_fight_orientation = ORIENTATION_CAUTIOUS
~charPersonName_fight_target = charPersonName2_id
~charPersonName_fight_initiative = 0
{refreshCombatPool(charPersonName_cp, charPersonName_usingProfeciencyLevel, charPersonName_reflex, charPersonName_totalPain, charPersonName_carryOverShock, charPersonName_health )}
{refreshCombatPool(charPersonName2_cp, charPersonName2_usingProfeciencyLevel, charPersonName2_reflex, charPersonName2_totalPain, charPersonName2_carryOverShock, charPersonName2_health )}
-> ChooseManueverForChar(1, charPersonName_id, charPersonName2_id, 0,0, charPersonName_cp, ->TestDone, charPersonName_manuever, charPersonName_manueverCost, charPersonName_manueverTN, charPersonName_manueverAttackType, charPersonName_manueverDamageType, charPersonName_manueverNeedBodyAim, charPersonName_manuever_attacking, charPersonName_manueverUsingHands, charPersonName_manuever_CP, charPersonName_manuever_targetZone)


=== testing_ChooseManueverForAIDef
~charPersonName2_fight_orientation = ORIENTATION_CAUTIOUS
~charPersonName2_fight_target = charPersonName_id
~charPersonName2_fight_initiative = 0
{refreshCombatPool(charPersonName_cp, charPersonName_usingProfeciencyLevel, charPersonName_reflex, charPersonName_totalPain, charPersonName_carryOverShock, charPersonName_health )}
{refreshCombatPool(charPersonName2_cp, charPersonName2_usingProfeciencyLevel, charPersonName2_reflex, charPersonName2_totalPain, charPersonName2_carryOverShock, charPersonName2_health )}
-> ChooseManueverForChar(1, charPersonName2_id, charPersonName_id, 0,0, charPersonName2_cp, ->TestDone, charPersonName2_manuever, charPersonName2_manueverCost, charPersonName2_manueverTN, charPersonName2_manueverAttackType, charPersonName2_manueverDamageType, charPersonName2_manueverNeedBodyAim, charPersonName2_manuever_attacking, charPersonName2_manueverUsingHands, charPersonName2_manuever_CP, charPersonName2_manuever_targetZone)

=== testing_ChooseManueverForAIAtk
~charPersonName2_fight_orientation = ORIENTATION_AGGRESSIVE
~charPersonName2_fight_target = charPersonName_id
~charPersonName2_fight_initiative = 1
//~charPersonName2_AI = 0
~charPersonName_fight_initiative =  0
{refreshCombatPool(charPersonName_cp, charPersonName_usingProfeciencyLevel, charPersonName_reflex, charPersonName_totalPain, charPersonName_carryOverShock, charPersonName_health )}
{refreshCombatPool(charPersonName2_cp, charPersonName2_usingProfeciencyLevel, charPersonName2_reflex, charPersonName2_totalPain, charPersonName2_carryOverShock, charPersonName2_health )}
-> ChooseManueverForChar(1, charPersonName2_id, charPersonName_id, 0,0, charPersonName2_cp, ->TestDone, charPersonName2_manuever, charPersonName2_manueverCost, charPersonName2_manueverTN, charPersonName2_manueverAttackType, charPersonName2_manueverDamageType, charPersonName2_manueverNeedBodyAim, charPersonName2_manuever_attacking, charPersonName2_manueverUsingHands, charPersonName2_manuever_CP, charPersonName2_manuever_targetZone)

=== test_ConsiderCharacters
considering chars stat order....
-> PickCharactersWithAttributeVal("reflex", 0, ->pickList)

= pickList
///* utest all
{	charPersonName_picked:
	person #1 is picked!
	->PickCharactersWithAttributeVal.GotoLoop
}
{	charPersonName2_picked:
	person #2 is picked!
	->PickCharactersWithAttributeVal.GotoLoop
}
->TestDone


=== test_func_MathExp
3^7= {MathExp(3,7)} == 2187
3^8= {MathExp(3,8)} == 6561
2^3= {MathExp(2,3)} == 8
->TestDone

=== test_func_XOR2Bits
0 XOR 0= {XOR_2Bits(0,0)} == 0
0 XOR 1= {XOR_2Bits(0,1)} == 1
0 XOR 2= {XOR_2Bits(0,2)} == 2
0 XOR 3= {XOR_2Bits(0,3)} == 3
1 XOR 0= {XOR_2Bits(1,0)} == 1
1 XOR 1= {XOR_2Bits(1,1)} == 0
1 XOR 2= {XOR_2Bits(1,2)} == 3
1 XOR 3= {XOR_2Bits(1,3)} == 2 
2 XOR 0= {XOR_2Bits(2,0)} == 2
2 XOR 1= {XOR_2Bits(2,1)} == 3
2 XOR 2= {XOR_2Bits(2,2)} == 0
2 XOR 3= {XOR_2Bits(2,3)} == 1
3 XOR 0= {XOR_2Bits(3,0)} == 3
3 XOR 1= {XOR_2Bits(3,1)} == 2
3 XOR 2= {XOR_2Bits(3,2)} == 1
3 XOR 3= {XOR_2Bits(3,3)} == 0
->TestDone

=== test_func_OR2Bits
0 OR 0= {OR_2Bits(0,0)} == 0
0 OR 1= {OR_2Bits(0,1)} == 1
0 OR 2= {OR_2Bits(0,2)} == 2
0 OR 3= {OR_2Bits(0,3)} == 3
1 OR 0= {OR_2Bits(1,0)} == 1
1 OR 1= {OR_2Bits(1,1)} == 1
1 OR 2= {OR_2Bits(1,2)} == 3
1 OR 3= {OR_2Bits(1,3)} == 3 
2 OR 0= {OR_2Bits(2,0)} == 2
2 OR 1= {OR_2Bits(2,1)} == 3
2 OR 2= {OR_2Bits(2,2)} == 2
2 OR 3= {OR_2Bits(2,3)} == 3
3 OR 0= {OR_2Bits(3,0)} == 3
3 OR 1= {OR_2Bits(3,1)} == 3
3 OR 2= {OR_2Bits(3,2)} == 3
3 OR 3= {OR_2Bits(3,3)} == 3
->TestDone




// -- Inkle engine specific tests below
// --------------------------------

// This test is ok..

=== test_funcParamScope
~temp withinScopeOfKnot = 0
{testFuncParamScope()}
assert (withinScopeOfKnot == 0 ) (still remains as zero?)
withinScopeOfKnot =  {withinScopeOfKnot}
-> TestDone

=== function testFuncParamScope()
~temp withinThisFunc = 1
{testFuncParamScope2(withinThisFunc)}
new value within testFuncParamScope() == 3 assert: {withinThisFunc}

=== function testFuncParamScope2(ref withinScopeOfKnot)
~withinScopeOfKnot = 3


// --------------------------------

// Test that passed pointer is correct and doesn't conflict with Knot scope
// This test fails..

=== adv_test_funcParamScope
~temp withinScopeOfKnot = 0

Value is {withinScopeOfKnot} at the moment.

{adv_testFuncParamScope(withinScopeOfKnot)}
Is Value 1? Value = {withinScopeOfKnot}

-> TestDone

=== function adv_testFuncParamScope(ref withinScopeOfKnot)
~temp x
~withinScopeOfKnot=1
{adv_testFuncParamScope2(x)}
assert pointer changed: x == 3: x = {x}


=== function adv_testFuncParamScope2(ref withinScopeOfKnot)
~withinScopeOfKnot = 3
// the above should not affect the main Knot despite having similar name, since the `~temp x` pointer was passed in!


// --------------------------------------------------------------------

// Test passed (if ref x isn't accessed set)
=== adv_test_funcParamScope2
~temp x = 0

Value is {x} at the moment.

{adv_testFuncParamScopeXXX(x)}
knot x remains the same as zero?: = {x}

->TestDone

=== function adv_testFuncParamScopeXXX(ref x)
~temp y
// It seems, any pointer value set operation below at ~x=0 on the parameter will trigger the issue !
// Would need to set ~x only after recursive function calls are made!
~x = 0  
{adv_testFuncParamScopeXXX2(y)}
assert pointer changed:  == 3:  = {y}

=== function adv_testFuncParamScopeXXX2(ref x)
~x = 3


// --------------------------------------------------------------------

=== TestDone
Test Completed!
->DONE