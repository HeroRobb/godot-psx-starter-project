extends Node2D


@export var experience_value: int = 1

@onready var _area_scanner: Area2D = $AreaScanner


func _ready():
	_area_scanner.area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	SignalManager.experience_gained.emit(experience_value)
	queue_free()
