class_name PlayerTopDown2D
extends CharacterBody2D


enum DIRECTIONS {BOTTOM, RIGHT, TOP, LEFT}

const CAMERA_ANGULAR_ACCELERATION = 4.0
const CAMERA_POSITION_ACCELERATION = 3.0
const FLASH_TIME: float = 1.0

@export var _camera: Camera2D

var playable := true
var just_died := false : set = set_just_died

#var _suit: Suit = null
var _last_known_ground_position: Vector2
var _show_souls := false : set = set_show_souls
var _paused := false : set = set_paused
var _camera_position: int = DIRECTIONS.BOTTOM
var _current_anim: int = -1
var _zoom_level: int = 0
var _flash_amount := 0
var _collision_enabled := true
var _direction: Vector2 = Vector2.ZERO

@onready var _sprite_component: SpriteComponent = $SpriteComponent
@onready var _movement_component: MovementComponent2D = $MovementComponent2D
@onready var _health_component: HealthComponent = $HealthComponent
@onready var _hurtbox_component: HurtboxComponent2D = $HurtboxComponent2D
@onready var _ability_launchers: Node = $AbilityLaunchers
#@onready var _debug_timer := $DebugTimer
#@onready var _orbit_point := $OrbitPoint
@onready var _camera_positions := {
	DIRECTIONS.TOP: $CameraPositions/TopPosition,
	DIRECTIONS.RIGHT: $CameraPositions/RightPosition,
	DIRECTIONS.BOTTOM: $CameraPositions/BottomPosition,
	DIRECTIONS.LEFT: $CameraPositions/LeftPosition,
}


func _ready() -> void:
	assert(_camera, "No player camera found.")
#	_camera_positions[DIRECTIONS.BOTTOM].transform.origin -= Vector3(0, -0.5, 0)
	_connect_signals()
	_debug_setup()
	_update_last_known_ground_position()
	_health_component.update_health()


func _process(delta: float) -> void:
	if not playable:
		return
	
	_get_move_input()


func _physics_process(delta: float) -> void:
	if not _paused:
		var pos: Vector2 = global_position
		var move_target: Vector2 = global_position + _direction
		_movement_component.move_to(move_target, delta)
	
	_update_camera_rotation(delta)


func _input(event: InputEvent) -> void:
	if not playable:
		return
	
	if _paused:
		return
	
#	elif event.is_action_pressed("rotate_camera_right"):
#		_rotate_camera_right()
#
#	elif event.is_action_pressed("rotate_camera_left"):
#		_rotate_camera_left()


func attack() -> void:
	velocity = Vector2.ZERO
#	_current_anim = _character_mesh.play_anim(Global.HUMANOID_ANIMATIONS.MELEE)


func set_camera_position(new_camera_position: int) -> void:
	if new_camera_position >= _camera_positions.size():
		_camera_position = 0
	elif new_camera_position < 0:
		_camera_position = _camera_positions.size() - 1
	else:
		_camera_position = new_camera_position


func die() -> void:
	just_died = true
	
	SignalManager.time_scale_change_requested.emit(0.1, 0)
	
	SignalManager.player_died.emit()


func get_camera_2d() -> Camera2D:
	return _camera


func set_show_souls(new_show_souls: bool) -> void:
	_show_souls = new_show_souls
	
#	_orbit_point.visible = _show_souls


## This should only be called by the GameStateSaver when the player is loaded
## in after dying. It will prevent an infinite loop of having the
## GameStateSaver restore the player's health to 0 and reloading the scene.
func set_just_died(new_just_died: bool) -> void:
#	if new_just_died:
#		fully_heal()
	
	just_died = new_just_died


func set_paused(new_paused: bool) -> void:
	_paused = new_paused
	
#	if _paused:
#		_character_mesh.play_anim(Global.HUMANOID_ANIMATIONS.IDLE)


func return_to_last_known_ground_position(damage_amount: int = 0) -> void:
	global_position = _last_known_ground_position
#	_health_component.take_damage(damage_amount)


func _play_swish() -> void:
	SoundManager.play_sfx(Global.SFX.BLIP, -5.0, randf_range(0.7, 0.9))


func _update_last_known_ground_position() -> void:
	if is_on_floor():
		_last_known_ground_position = global_position


func _debug_setup() -> void:
	var debug_category_name: String = "Player"
	DebugMenu.add_category("Player")
#	DebugMenu.add_option(debug_category_name, "restore health", fully_heal)
#	DebugMenu.add_option(debug_category_name, "toggle collision", _toggle_collision)
	DebugMenu.add_option(debug_category_name, "gain_rusty_sword", _debug_gain_rusty_sword)


func _get_move_input() -> void:
	_direction.x = Input.get_axis("move_left", "move_right")
	_direction.y = Input.get_axis("move_forward", "move_backward")
	_direction = _direction.rotated(-_camera.rotation).normalized()
	if _direction.length_squared() > 0.3:
		$ProjectileLauncher2D.target_position = _direction


func _update_camera_rotation(delta) -> void:
	_camera.rotation = lerp_angle(_camera.rotation, _camera_positions[_camera_position].rotation, delta * CAMERA_ANGULAR_ACCELERATION)
	_camera.global_position = _camera.global_position.lerp(_camera_positions[_camera_position].global_position, 1.0 - exp(-delta * CAMERA_POSITION_ACCELERATION))


func _rotate_camera_right() -> void:
	set_camera_position(_camera_position - 1)


func _rotate_camera_left() -> void:
	set_camera_position(_camera_position + 1)


func _debug_gain_rusty_sword() -> void:
	_debug_gain_item(Global.ITEMS.RUSTY_SWORD)


func _debug_gain_item(item_id: int) -> void:
	SignalManager.emit_signal("item_gained", item_id)


func _play_animation(new_animation: SpriteComponent.ANIMATIONS) -> void:
	_sprite_component.play_animation(new_animation)


func _connect_signals() -> void:
	SignalManager.paused_changed.connect(_on_game_paused_changed)
	_health_component.health_changed.connect(_on_health_changed)
	_health_component.damage_taken.connect(_on_damage_taken)
	_movement_component.is_moving_changed.connect(_on_is_moving_changed)
	_sprite_component.flashing_finished.connect(_on_flashing_finished)
	SignalManager.ability_upgrade_added.connect(_on_ability_upgrade_added)


func _on_game_paused_changed(new_game_paused: bool) -> void:
	set_paused(new_game_paused)


func _on_last_ground_position_timer_timeout() -> void:
	_update_last_known_ground_position()


func _on_health_changed(current_health: int, max_health: int) -> void:
	SignalManager.player_health_changed.emit(current_health, max_health)
	
	$ProgressBar.value = _health_component.get_health_ratio()
	
	if current_health <= 0:
		die()


func _on_flashing_finished() -> void:
	collision_mask = 1
	_hurtbox_component.check_for_damage()


func _on_is_moving_changed(new_is_moving: bool) -> void:
	if new_is_moving:
		_play_animation(_sprite_component.ANIMATIONS.WALK)
		return
	_play_animation(SpriteComponent.ANIMATIONS.IDLE)


func _on_damage_taken(damage_amount: int) -> void:
	if _health_component.invincible:
		return
	
	velocity = Vector2.ZERO
	SignalManager.screenshake_requested.emit(90, 32, 4)
	SoundManager.play_sfx(Global.SFX.BLIP, randf_range(1.1, 1.3))
	_health_component.invincible = true
	SignalManager.set_delayed.emit(_health_component, "invincible", false, FLASH_TIME)
	_sprite_component.flash(FLASH_TIME)
	collision_mask = 0
	
	if _health_component.current_health - damage_amount <= 0: return
	SignalManager.time_scale_change_requested.emit(0.1, 1.5)


func _on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if not upgrade is Ability: return
	
	var upgrade_ability: Ability = upgrade
	var new_launcher_instance: Node = upgrade_ability.ability_launcher_scene.instantiate()
	_ability_launchers.add_child(new_launcher_instance)
