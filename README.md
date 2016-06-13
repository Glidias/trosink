This is a "challenge-attempt" to code Riddle of Steel/Song of Sword's tactical combat system entirely in INK script format for INK's purely text-based adventure engine. This would be an attempt to create the world's first highly (possibly most)simulative/complex tactical melee combat simulator within a text-based adventure DSL itself. As such, it can be considered a "non-traditional" use of INK.

https://github.com/inkle/ink
As of now, INK doesn't have data structures, arrays, and such. So, one has to come up with other ways/workarounds outside of the regular typical dynamic OO, data composition, etc. style of programmming found in other languages.

Riddle of Steel/Song of Swords, and various other spinoff games like Blade of the Iron Throne, etc. are a category of tabletop RPGs with highly detailed realistic medieval combat combat: with details involving actual historical swordfighting/combat manuevers, locational damage, wounds/blood-lost, etc. running on top of a narrative (traditionally gamemastered) experience among groups of live players.

TROSInk, will attempt to create a similar experience (albeit more inline with a 'gamebook'), while trying to work around with the limitations of the INK format/engine by starting first with "fixed" procedurally generated TROS ink files for each bout encounter between different enemy sides. Hopefully, people can extend the codebase to allow injecting their own handwritten/procedurally-generated/picked "flowery" descriptions into each bout. The planned format involves being allowed to set up your at least 2 sides to battle against each other, and let it run within an INK player (most likely running through a codebase like Unity3D as of now) via a dynamically generated TROS ink script (a script that is tailored to handle a fixed set of combatants) for each encounter. 

Unlike other games that often do combat sequences outside of the text-based adventure itself (eg. Lone Wolf or Sorcery https://itunes.apple.com/sg/app/sorcery!/id627879091?mt=8) using a seperate codebase, this is an attempt to do it in "reverse", the combat works under the text-based adventure engine itself.

At the very least, this can serve purely as a step-by-step text-only simulation/tutorial to introduce players to a typical "TROS-like" RPG combat system.