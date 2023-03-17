extends Node3D

## This script is just so that I could see the inside of the level in the
## editor and then show the ceiling when the game is running.


func _ready() -> void:
	$Ceiling.show()
