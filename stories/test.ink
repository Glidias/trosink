CONST INITIATIVE_GOT = 1

VAR personA_CP = 10
VAR personB_CP = 9
VAR personC_CP = 8
VAR rolledSuccesses = 0

VAR initiative = INITIATIVE_GOT
VAR boutFlow = 0

{ shuffle: 
	- ~initiative=1
	- ~initiative=2
	- ~initiative=3
	- ~initiative=4
}

Welcome. The initiative is: {initiative}
->cycling_new

=== EveryoneAssumesStance
For those that can, declare an assumed stance in order from (lowest to highest stat)

=== EveryoneChoosesOrientation
For those that need to, secretly choose orientation.
Then, everyone reveals it at the same time.

=== EveryoneChooseTarget
For those that need to, or are able to, secretly choose (for those that gained initiative first over someone first, then for those from highest to lowest stat based off groupings)
=== EveryoneGainedInitiativeChooseTarget
...
=== EveryoneAggressiveChooseTarget
...
=== EveryoneCautiousChooseTarget
...
=== EveryoneDefensiveChooseTarget
...

=== EveryoneDeclaresMobilityManuever
For those that wish to...

=== EveryoneDeclaresManuever
In order of those from lowest to highest stat, taking into account

=== AssumeStance
    * Offensive
    * Neutral
    * Defensive
=== ChooseOrientation
    * Aggressive
    * Cautious
    * Defensive
=== ChooseTarget
    Choosing target, whichever is valid.
=== MakeMobilityManuever
    Making Mobility manuever, whichever is valid.
=== MakeCombatManuever
    Making Combat manuever, whichever is valid
=== VSTarget
    against a certain target.
=== AmountToSpend
    Choosing amount to spend for manuever
=== ChooseBodyZone
    Choosing body zone to aim at.


=== cycling_new
{ cycle:
    - ->personC_turn
    - ->personB_turn
    - ->personA_turn
    - {~->r_successes_10|->r_successes_9}
}
=== personC_turn
    It is person C 
    + Continue
        -> cycling_new
=== personB_turn
    It is person B
    + Continue
        -> cycling_new
=== personA_turn
    It is person A
     + Continue
        -> cycling_new
=== r_successes_10
    ~ rolledSuccesses = 10
    Rolled 10.
    -> cycling_new
=== r_successes_9
    ~ rolledSuccesses = 9
    Rolled 9.
    -> cycling_new
=== done
Done!
-> END


/*
Exploration Conventions:


In passage, only list the following navigable/visible locations in order of the priority groups below, from furthest to nearest within each group:
---------------------
Visible landmarks that aren't reachable within a moment
Visible key areas that aren't reachable within the moment
Visible key areas that are reachable within the moment
Visible landmarks that are reachable within the moment
Non-Visible key areas that are reachable within the moment

___________

In "Going somewhere" choices, list locations in the above order from nearest to furthest. (ie. reverse order from passage). 
In "Going somewhere else...", list expands to all areas within a certain distance...and involves a different thread.


Visibility/clearness doesn't matter, but can be marked individually to indicate if you can/cannot see the destination from your current location.

Going to location....
 (can see/know path to visible location ? Make your way there continually if required...
  else attempt to heristically go to visible location on a step-by-step basis)
  - choices
  ...
)

*/