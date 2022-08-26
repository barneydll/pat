# Prop Accuracy Trainer
PropKill script for training prop accuracy.

# How to use
1. Use the command `pat_createseed` to place "seeds". Seeds are the starting point for generating possible spawn positions of the target.<br />
2. Use the command `pat_createpoints` to scan the map for spawn positions, this will cause your game to freeze for a moment. The target will spawn automatically after generating the points.
3. **Practice!**

# CVars
| Name and Values | Description |
| --- | --- |
|`pat_iterations 2-inf`|Amount of iterations when generating points. Very laggy at high numbers!|
|`pat_maxheadingdiff 0-360`|Max angle change per frame.|
|`pat_respawntim  e 0-inf`|Time before the target automatically respawns.|
|`pat_showscore 0/1`|Show score on the right side of the screen.|
|`pat_skybox 0/1`|Make skybox gray.|
|`pat_spheresize 1-100`|Target size.|
|`pat_spherespeed 0-inf`|Target speed.|
|`pat_wallcompensation 0-inf`|Maximum distance to a wall to reverse direction.|

# ConCommands
| Name | Description |
| --- | --- |
|`pat_clearpoints`|Clears all points and removes the target.|
|`pat_createpoints`|Generates the spawn positions.|
|`pat_createseed`|Creates a seed at your head's position.|
|`pat_pointesp`|Toggles ESP for points. Red = Scanned Positions, Blue = Spawn Positions.|
|`pat_resetscore`|Resets your score.|
|`pat_seedesp`|Toggles ESP for seeds.|