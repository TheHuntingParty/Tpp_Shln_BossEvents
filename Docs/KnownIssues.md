# Known Issues
#### Project related
- Search Missiles not being setup -- This is intended for now
- Hellbound AI navigation can be messy -- Based on routes, hard to deal with 
- `SetRelativeRouteNode` Not being used -- Currently its unknown what it does and how it works
- Sahelanthropus and enemy vehicles share roads in their paths, sometimes Sahelanthropus will either damage or destroy some vehicles

#### Hardcoded Behaviour
- Starts on "Alert" mode after being activated
- While using Hellbound AI, both railgun and loader meshes and collision are disabled
- No collision and/or behaviour with many other GameObjects and Static Objects
- Other GameObjects (Soldier2 for example) do not "see" or interact with MG Sahelanthropus
- Both Sahelanthropus and animals are not programmed to be aware of eachother resulting in their deaths
