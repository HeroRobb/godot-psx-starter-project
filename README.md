### godot-psx-starter-project
A base project for creating retro psx style games in the godot engine.

## how to use this project

# Quickstart
- Edit management/global.gd to add to the enums for your game.
- Open management/resource_manager.tscn and edit the exported arrays for various data for your game.
- Make sure management/game_manager.tscn is the main scene in your project and open it to edit the exported variables for the GameManager and Launcher.
- Make use of the signals in the SignalManager singleton to use the features of this project throughout your code.


# GameManager
Make sure GameManager.tscn is the main scene in your project. Open GameManager.tscn in the editor and select the Launcher, the path to it should be GameManager/PPDitherContainer/SubViewport/LevelContainer/Launcher. There are some values you can change in the editor.

## TODO: the rest of the readme lol