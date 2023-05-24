class_name ProjectileLauncher
extends RayCast3D


enum AUTO_FIRE_MODES {
	NONE,
	TIMED,
	DETECTION
}

signal body_entered(body: CollisionObject3D)
signal body_exited(body: CollisionObject3D)

@export_file("*.tscn") var projectile_scene_path: String
@export var physics_parent_path: NodePath
@export var cooldown_seconds: float = 1.0
## 0 is no randomness, 1 means the cooldown can range from 0 seconds to double the value in
## cooldown_seconds
@export_range(0.0, 1.0, 0.05) var cooldown_random_ratio: float = 0.0
@export var auto_fire_mode: AUTO_FIRE_MODES = AUTO_FIRE_MODES.TIMED
@export var will_override_projectile_motion: bool = false
@export var override_projectile_motion: Projectile.MOTION_TYPES = Projectile.MOTION_TYPES.LINEAR
@export_category("Projectile modifiers")
@export_range(-50.0, 50.0, 0.5) var projectile_max_speed_modifier: float = 0.0
@export_range(-20.0, 20.0, 0.1) var projectile_acceleration_modifier: float = 0.0
@export_range(-20.0, 20.0, 0.5) var projectile_friction_modifier: float = 0.0
@export_range(-1000, 1000) var projectile_damage_amount_modifier: int = 0
@export_range(-10, 10) var projectile_max_hits_modifier: int = 0
@export var projectile_added_damage_types: Array[Global.DAMAGE_TYPES] = []
@export var projectile_removed_damage_types: Array[Global.DAMAGE_TYPES] = []

@onready var _cooldown_timer: Timer = $CooldownTimer

var _projectile_scene: PackedScene
var _physics_parent: PhysicsBody3D
var _on_cooldown: bool = false
var _previous_collider: CollisionObject3D


func _ready() -> void:
	assert(projectile_scene_path)
	
	_connect_signals()
	
	if physics_parent_path:
		_physics_parent = get_node(physics_parent_path)
	_projectile_scene = load(projectile_scene_path)
	_cooldown_timer.wait_time = cooldown_seconds
	
	if auto_fire_mode == AUTO_FIRE_MODES.TIMED:
		_cooldown_timer.start()


func _physics_process(delta: float) -> void:
	if not is_colliding():
		_update_previous_collider()
		return
	
	var collider: Object = get_collider()
	if collider == _previous_collider:
		return
	
	if _previous_collider:
		body_exited.emit(_previous_collider)
	
	_previous_collider = collider
	body_entered.emit(collider)


func fire() -> void:
	if not _projectile_scene or _on_cooldown:
		return
	
	var new_projectile: Projectile = _projectile_scene.instantiate()
	new_projectile.position = Vector3.ZERO
	new_projectile.forward_direction =  Vector3.FORWARD.rotated(Vector3.UP, global_rotation.y)
	
	if _physics_parent:
		new_projectile.add_collision_exception_with(_physics_parent)
	add_exception(new_projectile)
	add_child(new_projectile)
	
	new_projectile.modify_max_speed(projectile_max_speed_modifier)
	new_projectile.modify_acceleration(projectile_acceleration_modifier)
	new_projectile.modify_friction(projectile_friction_modifier)
	new_projectile.modify_damage_amount(projectile_damage_amount_modifier)
	new_projectile.modify_max_hits(projectile_max_hits_modifier)
	new_projectile.add_damage_types(projectile_added_damage_types)
	if will_override_projectile_motion:
		new_projectile.motion_type = override_projectile_motion
	
	_cooldown_timer.start()
	_on_cooldown = true


func _update_previous_collider() -> void:
	if _previous_collider:
		body_exited.emit(_previous_collider)
		_previous_collider = null


func _connect_signals() -> void:
	_cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)


func _on_cooldown_timer_timeout() -> void:
	_on_cooldown = false
	
	if not auto_fire_mode == AUTO_FIRE_MODES.TIMED:
		return
	
	if cooldown_random_ratio > 0.0:
		var cooldown_minimum: float = cooldown_seconds * (1 - cooldown_random_ratio)
		var cooldown_maximum: float = cooldown_seconds * (1 + cooldown_random_ratio)
		_cooldown_timer.wait_time = randf_range(cooldown_minimum, cooldown_maximum)
	fire()
