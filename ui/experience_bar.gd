extends CanvasLayer


@export var _experience_manager: ExperienceManager

@onready var _experience_bar = %ExperienceBar


func _ready():
	assert(_experience_manager, "ExperienceBar has no ExperienceManager set.")
	
	_experience_manager.experience_changed.connect(_on_experience_changed)


func _on_experience_changed(current_experience: int, experience_to_next_level: int) -> void:
	if experience_to_next_level <= 0: return
	
	# float_current_experience is so experience fraction isn't zero from dividing two integers
	var float_current_experience: float = float(current_experience)
	var experience_fraction: float = float_current_experience / experience_to_next_level
	_experience_bar.value = experience_fraction
