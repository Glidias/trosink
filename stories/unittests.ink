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