extends Node2D


@export var _sprite_component: SpriteComponent

@onready var _particles: GPUParticles2D = $GPUParticles2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_sprite_component.animation_finished.connect(_on_animation_finished)
	var particles_texture: AtlasTexture = _particles.texture
	particles_texture.atlas = _sprite_component.body_texture


func _perform_death_effect() -> void:
	if not owner or not owner is Node2D:
		return
	
	var parent_node: Node2D = owner
	var spawn_position: Vector2 = parent_node.global_position
	var entity_container: Node2D = get_tree().get_first_node_in_group("entity_container")
	get_parent().remove_child(self)
	entity_container.add_child(self)
	global_position = spawn_position
	_animation_player.play("die")


func _on_animation_finished(animation_name: String) -> void:
	if not animation_name == "die": return
	
	_perform_death_effect()
