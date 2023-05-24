class_name Projectile2D
extends CharacterBody2D


enum MOTION_TYPES {
	LINEAR,
	WAVE,
}

const WAVE_SPEED_MULTIPLIER: float = 3.0

@export_category("Motion")
@export var motion_type: MOTION_TYPES = MOTION_TYPES.LINEAR : set = set_motion_type
@export_range(0.05, 2000.0, 0.05) var wave_amplitude_motion: float = 0.05
@export_range(0.05, 2.0, 0.05) var wave_length_motion: float = 0.1
@export_range(0.01, 0.05, 0.01) var wave_growth: float = 0.01

@export_category("Collision")
@export var can_damage: HitboxComponent2D.HURTBOX_TYPES = HitboxComponent2D.HURTBOX_TYPES.NEITHER
@export_file("*.tscn") var explosion_scene: String

@export_category("Sounds")
@export var spawn_sound: Global.SFX = Global.SFX.BLIP
@export_range(-20.0, 20.0, 0.5) var spawn_sound_db: float = 0.0
@export_range(0.1, 2.0, 0.1) var spawn_sound_pitch: float = 1.0
@export var hit_sound: Global.SFX = Global.SFX.BLIP
@export_range(-20.0, 20.0, 0.5) var hit_sound_db: float = 0.0
@export_range(0.1, 2.0, 0.1) var hit_sound_pitch: float = 1.0


@export_category("Other")
@export var destroy_offscreen: bool = true : set = set_destroy_offscreen
@export_range(0.0, 10.0, 0.5) var offscreen_time_limit: float = 2.0
@export_range(0.0, 10.0, 0.5) var hide_to_remove_seconds: float = 1.0

var forward_direction: Vector2 = Vector2.RIGHT
var direction: Vector2 = Vector2.RIGHT

var _readied: bool = false
var _time_at_ready: float
var _previous_wave_tangent: Vector2 = Vector2.ZERO

@onready var _movement_component: MovementComponent2D = $MovementComponent2D
#@onready var _mesh_component: MeshComponent = $MeshComponent
@onready var _hitbox: HitboxComponent2D = $HitboxComponent2D
@onready var _visibility_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var _offscreen_timer: Timer = $OffScreenTimer
@onready var _remove_timer: Timer = $RemoveTimer


func _ready() -> void:
	set_destroy_offscreen(destroy_offscreen)
	_hitbox.can_damage = can_damage
	_hitbox.hit_limit_reached.connect(_on_hit_limit_reached)
	top_level = true
	direction = direction.normalized()
	_time_at_ready = ResourceManager.time_since_launch
	_readied = true
	SoundManager.play_sfx(spawn_sound, spawn_sound_db, spawn_sound_pitch)



func _physics_process(delta: float) -> void:
	var collision: KinematicCollision2D
	update_direction(delta)
	collision = _movement_component.move(direction, delta)
	
	if not collision or not collision.get_collider():
		return
	
	var collider: Object = collision.get_collider()
	
	if explosion_scene:
		_spawn_explosion()
	
	remove()


func update_direction(delta: float) -> void:
	match motion_type:
		MOTION_TYPES.LINEAR:
			_get_forward_direction(delta)
		MOTION_TYPES.WAVE:
			_get_forward_direction(delta)
#			_calculate_tangent_wave_velocity(delta)
			_get_tangent_wave_direction(delta)
	direction = direction.normalized()


func set_destroy_offscreen(new_destroy_offscreen: bool) -> void:
	destroy_offscreen = new_destroy_offscreen
	
	if not _offscreen_timer:
		return
	
	if destroy_offscreen:
		_offscreen_timer.wait_time = offscreen_time_limit
		_visibility_notifier.screen_exited.connect(_on_visibility_notifier_screen_exited)


func set_motion_type(new_motion_type: MOTION_TYPES) -> void:
	if not _readied:
		await(ready)
	
	var previous_motion_type: MOTION_TYPES = motion_type
	motion_type = new_motion_type
	
	match motion_type:
		MOTION_TYPES.WAVE:
			if not previous_motion_type == MOTION_TYPES.LINEAR:
				return
			_movement_component.max_speed *= WAVE_SPEED_MULTIPLIER
		MOTION_TYPES.LINEAR:
			if not previous_motion_type == MOTION_TYPES.WAVE:
				return
			_movement_component.max_speed /= WAVE_SPEED_MULTIPLIER


func _get_forward_direction(delta: float) -> void:
	direction = forward_direction


func _get_tangent_wave_direction(delta: float) -> void:
	var tangent_vector: Vector2
	var time_elapsed: float = ResourceManager.time_since_launch - _time_at_ready
	tangent_vector.x = sin(time_elapsed / wave_length_motion) * wave_amplitude_motion
	
	var tangent_normalized: Vector2 = tangent_vector.normalized()
#	var direction_perpendicular: Vector2 = _get_perpendicular_vector(forward_direction.normalized())
	var direction_perpendicular: Vector2 = forward_direction.normalized().orthogonal()
	var dot_product_to_perpendicular: float = tangent_normalized.dot(direction_perpendicular)
	var angle = acos(dot_product_to_perpendicular)
	if _angle_is_relavent(angle):
		tangent_vector = tangent_vector.rotated(angle)
	var new_modified_tangent: Vector2 = tangent_vector - _previous_wave_tangent
	_previous_wave_tangent = tangent_vector
	direction = new_modified_tangent * 2 + forward_direction
	wave_length_motion *= (1 + wave_growth * delta)
	wave_amplitude_motion *= (1 - wave_growth * delta)


func remove() -> void:
	set_physics_process(false)
	_hitbox.enabled = false
#	_mesh_component.hide()
	SoundManager.play_sfx(hit_sound, hit_sound_db, hit_sound_pitch)
	
	_remove_timer.start(hide_to_remove_seconds)
	await _remove_timer.timeout
	queue_free()


func modify_max_speed(max_speed_modifier: float) -> void:
	_movement_component.max_speed += max_speed_modifier


func modify_acceleration(acceleration_modifier: float) -> void:
	_movement_component.acceleration += acceleration_modifier


func modify_friction(friction_modifier: float) -> void:
	_movement_component.friction += friction_modifier


func modify_damage_amount(damage_modifier: int) -> void:
	_hitbox.damage_source.damage += damage_modifier


func modify_max_hits(max_hits_modifier: int) -> void:
	_hitbox.max_hits += max_hits_modifier


func add_damage_types(new_damage_types: Array[Global.DAMAGE_TYPES]) -> void:
	_hitbox.damage_source.add_damage_types(new_damage_types)


func remove_damage_types(removed_damage_types: Array[Global.DAMAGE_TYPES]) -> void:
	_hitbox.damage_source.remove_damage_types(removed_damage_types)


func _angle_is_relavent(angle: float) -> bool:
	if angle > -0.05 and angle < 0.05:
		return false
	if angle > 3.135 and angle < 3.145:
		return false
	return true


func _spawn_explosion() -> void:
	var explosion_packed_scene: PackedScene = load(explosion_scene)
	var explosion_instance: Node2D = explosion_packed_scene.instantiate()
	explosion_instance.global_position = global_position
	explosion_instance.global_rotation = global_rotation
	get_parent().add_child(explosion_instance)


#func _get_perpendicular_vector(from_vector: Vector2) -> Vector2:
#	var perpendicular_vector: Vector3 = Vector3(-from_vector.z, from_vector.y, from_vector.x)
#
#	return perpendicular_vector


func _on_visibility_notifier_screen_exited() -> void:
	_offscreen_timer.start(offscreen_time_limit)
	await _offscreen_timer.timeout
	if _visibility_notifier.is_on_screen():
		return
	remove()


func _on_hit_limit_reached() -> void:
	if explosion_scene:
		_spawn_explosion()
	remove()
