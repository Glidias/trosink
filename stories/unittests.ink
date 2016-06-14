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
{refreshCombatPool(charPersonName_cp, charPersonName_usingProfeciencyLevel, charPersonName_reflex, charPersonName_totalPain, charPersonName_carryOverShock, charPersonName_health )}
{refreshCombatPool(charPersonName2_cp, charPersonName2_usingProfeciencyLevel, charPersonName2_reflex, charPersonName2_totalPain, charPersonName2_carryOverShock, charPersonName2_health )}
-> ChooseManueverForChar( charPersonName_id, charPersonName2_id, ->TestDone, charPersonName_manuever, charPersonName_manueverCost, charPersonName_manueverTN, charPersonName_manueverAttackType, charPersonName_manueverDamageType, charPersonName_manueverNeedBodyAim)

=== testing_ChooseManueverForCharDef
~charPersonName_fight_orientation = ORIENTATION_CAUTIOUS
~charPersonName_fight_initiative = 0
{refreshCombatPool(charPersonName_cp, charPersonName_usingProfeciencyLevel, charPersonName_reflex, charPersonName_totalPain, charPersonName_carryOverShock, charPersonName_health )}
{refreshCombatPool(charPersonName2_cp, charPersonName2_usingProfeciencyLevel, charPersonName2_reflex, charPersonName2_totalPain, charPersonName2_carryOverShock, charPersonName2_health )}
-> ChooseManueverForChar( charPersonName_id, charPersonName2_id, ->TestDone, charPersonName_manuever, charPersonName_manueverCost, charPersonName_manueverTN, charPersonName_manueverAttackType, charPersonName_manueverDamageType, charPersonName_manueverNeedBodyAim)


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