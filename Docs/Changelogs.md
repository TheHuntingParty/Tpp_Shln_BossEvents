# Changelogs

#### r10a
- Added the missing route `rt_shlnArea9_b_DominionOutOfBounds` to the Guantanamo Area0 pack, it was causing a game crash


#### r10
- Added full support of both AI modes to US Naval Prison Facility (gntn)
- Removed message table for Hybrid AI
- Removed Hybrid AI packages
- Changed the name of the AI packages (`shln_hellbound_cmn` -> `shln_0_cmn`, `shln_dominion_cmn` -> `shln_1_cmn`)
- Added a time based trigger, courtesy of amars464


#### r9
- Added 1 skin, inspired by Shagohod from MGS3
- Added a difficulty system with 4 options
- Reworked the rewards system, big thanks to yazed for giving me all the info in `ShowAnnounceLog` stuff and Hero points
- Fixed a issue with `CPPhaseSwitchCount`
- Added Docs/DifficultyOptions.md

#### r8
- Updated KnownIssues.md
- Added a option to turn the active area into a random one, only implemented for Dominion AI for now
- Changed the name of the Infinite Heaven menu to `Sahelanthropus Boss Events`
- Added a option to choose what model Sahelanthropus uses
- Added 5 options for Sahelanthropus model
- Added a switch to the Sahelanthropus health bar, the user can now select if its loaded or not
- Partially restored the shield, its now visible with collision
- Added 25k health points to the shield

#### r7
- Fixed the rewards after beating Sahelanthropus, it was rewarding a skull parasite instead of Nuclear Waste
- Adds TppHidePointData entities across most areas of the Afghanistan map

#### r6 (Initial Nexus Release)
- Added TppHidePointData entries for Afghanistan
- Added `DisableSetUpSupportHeli` function
- Adjusted Health Points
- Added Rewards for beating sahelanthropus

#### r5
- Updated the README file
- Adjusted all routesets
- Added `SetUpSahelanAfghDominionAI` funtion
- Added a MessageTable for Dominion AI
- Added `ChangeCommandPostPhase` function
- Added Sahelanthropus Dominion mode packages (.fpk/.fpkd/.pftxs)
- Removed temporary Rex points
- Added out of bounds base route for Dominion AI
- Added all required functions for support heli anti sahelan sequence
- Added a temporary SeachMissile Dataset for each area

#### r4
- Added Sahelanthropus Hybrid mode packages (.fpk/.fpkd/.pftxs)
- Added sahelan navmesh for `afgh`, optional install (~20 Minutes of install time in a clean modlist)
- Added a temporary `rex_points` dataset
- Updated Mantis GameObject Locator name to `Mantis`
- Added a MessageTable for Hybrid AI
- Added functions to start and stop the red fog
- Added `CallSupportAttack` function
- Added `StartHeliAntiSahelan` function
- `SetUpSahelanAfgh` is now split in 2: `SetUpSahelanAfghHellboundAI` and `SetUpSahelanAfghDominionAI`
- Changed total health points to 100k and each part health points to 3k
- Function `SetSahelanType` is now called `SetSahelanTypeHellboundAI`
- Added `SetSahelanTypeDominionAIExtreme` function

#### r3
- Updated KnownIssues.md
- Added a defaukt Caution and Sneak route for Mountain Relay Base area
- Added Search Missiles for Mountain Relay Base CP area

#### r2
- Added Changelogs.md
- Sahelanthropus Search Missiles during Hellbound AI stage now work correctly
- Added `this.setOnBootSneakRoutes` and `this.setOnBootCautionRoutes`, used to set both initial Sneak and Caution routes
- Game will no longer crash after Sahelanthropus goes into Sneak phase in some cases

#### r1
- Initial Release