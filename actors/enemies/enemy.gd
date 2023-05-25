class_name Enemy
extends CharacterBody3D


enum SPRITES {
	ANGRY,
	COOL,
	HAPPY,
	SAD
}

const DEATH_TIME = 3

@export var enemy_name: String = "Devilman"
@export var hit_sound: Global.SFX = Global.SFX.BLIP
@export var death_sound: Global.SFX = Global.SFX.BLIP
@export var needs_los: bool = false
@export_range(0.1, 0.5, 0.05) var invincibility_time: float = 0.2

var direction: Vector3
var can_see_player: bool : set = set_can_see_player
var defeated: bool = false

var _player: Node3D

@onready var _health_component: HealthComponent = $HealthComponent
@onready var _hurtbox_component: HurtboxComponent3D = $HurtboxComponent
@onready var _hitbox_component: HitboxComponent3D = $HitboxComponent
@onready var _movement_component: MovementComponent3D = $MovementComponent
@onready var _navigation_component: NavigationComponent3D = $NavigationComponent
@onready var _mesh_component: MeshComponent = $MeshComponent
@onready var _vision_area: PlayerDetector = $VisionArea
#@onready var _angry_sprite := $AngrySprite


func _ready() -> void:
	_player = get_tree().get_nodes_in_group("player")[0]
	_connect_signals()
	
	if not needs_los:
		can_see_player = true


func take_hit() -> void:
	if _health_component.invincible:
		return
	
	_movement_component.stop()
	SoundManager.play_sfx(hit_sound, randf_range(0.9, 1.1))
	_health_component.invincible = true
	_mesh_component.flash(invincibility_time)


func set_can_see_player(new_can_see_player: bool) -> void:
	can_see_player = new_can_see_player
	
	if not can_see_player:
		_navigation_component.target_node = null
		return
	
	_navigation_component.target_node = _player


func die() -> void:
	SoundManager.play_sfx(death_sound, randf_range(0.9, 1.1))
	SignalManager.enemy_died.emit(enemy_name)
#	SignalManager.emit_signal(
#		"instance_needed",
#		ResourceManager.get_particle_packed_scene(Global.PARTICLES.DUST),
#		global_transform.origin
#	)
	_disable()
	SignalManager.call_delayed.emit(queue_free, DEATH_TIME)
	defeated = true


func _disable() -> void:
	hide()
	collision_layer = 0
	collision_mask = 0
	_hurtbox_component.enabled = false
	_hitbox_component.enabled = false
	_movement_component.stop(DEATH_TIME)


func _connect_signals() -> void:
	_health_component.health_changed.connect(_on_health_changed)
	_health_component.health_reached_zero.connect(die)
	_mesh_component.flashing_finished.connect(_on_flashing_finished)
	_hurtbox_component.hit_taken.connect(_on_hit_taken)
	
	if needs_los:
		_vision_area.player_entered.connect(_on_vision_area_player_entered)
		_vision_area.player_exited.connect(_on_vision_area_player_exited)


func _on_health_changed(health: int, max_health: int) -> void:
	SignalManager.enemy_health_changed.emit(enemy_name, health, max_health)


func _on_vision_area_player_entered() -> void:
	set_can_see_player(true)


func _on_vision_area_player_exited() -> void:
	set_can_see_player(false)


func _on_flashing_finished() -> void:
	if _health_component.invincible:
		_health_component.invincible = false
	_hurtbox_component.check_for_damage()


func _on_hit_taken() -> void:
	take_hit()
