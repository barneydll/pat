# Prop Accuracy Trainer
PropKill script for training prop accuracy.

# How to use
1. Use the command `pat_createseed` to place "seeds". Seeds are the starting point for generating possible spawn positions of the target.
2. Use the command `pat_createpoints` to scan the map for spawn positions, this will cause your game to freeze for a moment. The target will spawn automatically after generating the points.
3. **Practice!**

# CVars
| Name and Values | Description |
| --- | --- |
|`pat_cheatcompatibility 0/1`|Disables target rendering if your cheat supports PAT.|
|`pat_dodge 0/1`|Make the target fly away from props.|
|`pat_dodgereactiontime 0-1000`|How long before the target starts dodging (in milliseconds).|
|`pat_iterations 2-inf`|Amount of iterations when generating points. Very laggy at high numbers!|
|`pat_maxheadingdiff 0-360`|Max angle change per frame.|
|`pat_pitchloss 0-1`|Percentage of pitch kept per frame.|
|`pat_respawntime 0-inf`|Time before the target automatically respawns.|
|`pat_showscore 0/1`|Show score on the right side of the screen.|
|`pat_skybox 0/1`|Make skybox gray.|
|`pat_spheresize 1-100`|Target size.|
|`pat_spherespeed 0-inf`|Target speed.|
|`pat_sphereresolution 1-inf`|Sphere resolution.|
|`pat_wallcompensation 0-inf`|Maximum distance to a wall to reverse direction.|

# ConCommands
| Name | Description |
| --- | --- |
|`pat_clearpoints`|Clears all points and removes the target.|
|`pat_createpoints`|Generates the spawn positions.|
|`pat_createseed`|Creates a seed at your head's position.|
|`pat_pointesp`|Toggles ESP for points. Red = Scanned Positions, Blue = Spawn Positions.|
|`pat_resetdbporder`|Resets the order of the DrawPhysgunBeam hooks, ensuring PAT's hook runs first.|
|`pat_resetscore`|Resets your score.|
|`pat_seedesp`|Toggles ESP for seeds.|

# Adding Cheat Compatibility
**This will require you to edit the script's code! If it's not yours, make sure it's not obfuscated.**<br />
You can use `_G.PAT_FakeProp` to get the target's entity.<br />
Beware! `_G.PAT_FakeProp` is not always an entity, or valid. Make sure to use something like `if _G.PAT_FakeProp and _G.PAT_FakeProp:IsValid() then [code] end` to prevent errors.<br />