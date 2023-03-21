# Hero Robb's Godot PSX Starter Project
# (HR PSX)
A base project for creating retro psx style games in the godot engine.

## Attribution
Many of the shaders used are from [MenacingMecha's godot psx style demo](https://github.com/MenacingMecha/godot-psx-style-demo/tree/master/shaders), [AesthicalZ's Godot PSX](https://github.com/AestheticalZ/godot-psx), and [Ahopness' GodotRetro](https://github.com/Ahopness/GodotRetro) so thank them if you use this because it would have never been possible without them.
I also used/changed/stole/learned from tons of things from tons of different programmers and developers. I couldn't possibly list them all.
You can attribute me for using this by keeping the default attribution in the intro if you want.

## Screenshots
![screenshot1](readme_screenshots/Screenshot1.png?raw=true)
![screenshot2](readme_screenshots/Screenshot2.png?raw=true)
![screenshot3 lol this one has a screen capture notification](readme_screenshots/Screenshot3.png?raw=true)

## how to use this project

### Quickstart
1. Download all the code in the latest [release](https://github.com/HeroRobb/godot-psx-starter-project/releases) and unzip it where you want your new project to be.
2. Open Godot and click import, find the godot-psx-starter-project folder you got from unzipping and select the project.godot file inside it. You should be able to run the game using F5 to see a very short example/demo that will give you an idea of what can be done.
3. Edit management/global.gd to add to the enums for your game (eg fill LEVELS with your level names, MUSIC with the names of the music you're using). Then you should probably save and click project -> reload current project because sometimes this can cause problems with exported members that rely on these enums, so it's best to be safe.
4. Open management/resource_manager.tscn and edit the exported arrays (level_data, music_data, sfx_data, and ambience_data) for various data for your game, you should only have to add an
entry to the array by creating a new resource_data type (eg level_data, music_data) and giving it an ID you set in step 3 and a path to the actual file (eg the .tscn file for level_data or the .ogg file for music_data).
5. Make sure management/game_manager.tscn is the main scene in your project and open it to edit the exported variables for the GameManager and Launcher. Keep in mind GameManager has the array for default shaders and Launcher has a member for what scene it should transition to afterwards. If you're messing with stuff or trying to add this to an existing project, make sure the autoload singletons in Project->project settings->autoload for SoundManager and ResourceManager are the .tscn files and not just the .gd files.
6. Most of how you should interact with the various scripts and nodes here in your game should be through the use of the signals in the SignalManager singleton (eg SignalManager.change_scene_needed.emit(Global.LEVELS.THE_SCENE_YOU_ADDED_IN_STEP_3).


A lot of the scripts have formatted documentation so you can see the autodocs by going to the script tab in Godot, clicking "search help" in the upper right corner and typing the class name from the top of the script or the name of the .gd file (eg: debug_menu). There is a problem with Godot where sometimes the custom classes get removed from the "search help" menu, which is annoying. To fix this bug, simply erase a bit of the documentation comments, save the script, undo the erase, save the script again, and it will show up. *shrugs*


### GameManager
Make sure GameManager.tscn is the main scene in your project. Open GameManager.tscn in the editor and select the Launcher, the path to it should be GameManager/PPDitherContainer/SubViewport/LevelContainer/Launcher. There are some values you can change in the editor.

# TODO: the rest of the readme lol
