# Known Issues
#### Project related
- Hellbound AI navigation can be messy, Based on routes, hard to deal with 
- `SetRelativeRouteNode` Not being used, Currently its unknown what it does and how it works
- Sahelanthropus and enemy vehicles share roads in their paths, sometimes Sahelanthropus will either damage or destroy some vehicles
- Sahelanthropus left sword fails to attach to the left hand in Hybrid mode (.mtar issue)
- Dominion AI navigation can be messy, i edited soldier nav2s and allowed Sahelanthropus to go anywhere on them, not optimal for pathfinding
- Sahelanthropus will sometimes destroy a watch tower
- Some Areas hit and may go above the nav2 load limit causing some nav2 blocks to not be loaded


#### Hardcoded Behaviour (Cant Fix)
- Starts on "Alert" mode after being activated
- While using Hellbound AI, both railgun and loader meshes and collision are disabled
- No collision and/or behaviour with many other GameObjects and Static Objects
- Other GameObjects (Soldier2 for example) do not "see" or interact with MG Sahelanthropus
- Both Sahelanthropus and animals are not programmed to be aware of eachother resulting in their deaths
- If Sahelanthropus uses a grenade while nearby vehicles are been driven by enemies, said vehicles become invincible
