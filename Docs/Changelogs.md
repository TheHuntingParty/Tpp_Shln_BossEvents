# Changelogs

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