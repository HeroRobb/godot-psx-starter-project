@tool
class_name SpriteComponent
extends Node2D


signal flashing_finished()

enum FACING_DIRECTIONS {RIGHT, DOWN, LEFT, UP}

const FLASH_LENGTH: float = 0.05

@export var body_texture: Texture
@export var texture_offset: Vector2 = Vector2.ZERO : set = set_texture_offset
@export_range(2.0, 10.0, 0.25) var angular_acceleration: float = 4.0
@export var start_facing: FACING_DIRECTIONS = FACING_DIRECTIONS.DOWN
@export var body_sprite_down_frame: int = 0
@export var body_sprite_right_frame: int = 0
@export var body_sprite_up_frame: int = 0
@export var body_sprite_left_frame: int = 0
@export var walking_frame_amount: int = 1

var facing_direction: FACING_DIRECTIONS
var moving: bool = false: set = set_moving

var _animation_tweens: Array
var _animation_state_machine: AnimationNodeStateMachinePlayback

@onready var _body_sprite: Sprite2D = $BodySprite
@onready var _flash_timer: Timer = $FlashTimer
@onready var _animation_tree: AnimationTree = $AnimationTree
@onready var _starting_frames: Dictionary = {
	FACING_DIRECTIONS.RIGHT:
		body_sprite_right_frame,
	FACING_DIRECTIONS.DOWN:
		body_sprite_down_frame,
	FACING_DIRECTIONS.LEFT:
		body_sprite_left_frame,
	FACING_DIRECTIONS.UP:
		body_sprite_up_frame,
}


func _ready():
	if body_texture:
		_body_sprite.texture = body_texture
	
	_animation_state_machine = _animation_tree.get("parameters/playback")


func turn(velocity: Vector2, delta: float) -> void:
	if velocity.length_squared() > 0.01:
		rotation = lerp_angle(rotation, atan2(-velocity.x, -velocity.y), delta * angular_acceleration)


func flash(flash_time: float, bright_flash: bool = true) -> void:
	while flash_time > FLASH_LENGTH * 2:
		visible = not visible
		_flash_timer.start(FLASH_LENGTH)
		flash_time -= FLASH_LENGTH
		await(_flash_timer.timeout)
	
	_flash_timer.start(FLASH_LENGTH * 2)
	visible = false
	await(_flash_timer.timeout)
	visible = true
	flashing_finished.emit()


func face(direction: Vector2) -> void:
	_animation_tree.set("parameters/Idle/blend_position", direction)
	_animation_tree.set("parameters/Walking/blend_position", direction)
	
#	if not _body_sprite or direction.length_squared() < 0.01:
#		return
#
#	var angle: float = direction.angle()
#	angle = snapped(angle, PI/2)
#	if angle == 0:
#		facing_direction = FACING_DIRECTIONS.RIGHT
#	elif angle == PI/2:
#		facing_direction = FACING_DIRECTIONS.DOWN
#	elif abs(angle) == PI:
#		facing_direction = FACING_DIRECTIONS.LEFT
#	else:
#		facing_direction = FACING_DIRECTIONS.UP


func set_moving(new_moving: bool) -> void:
	if moving == new_moving:
		return
	
	moving = new_moving
	
	if moving:
		_animation_state_machine.travel("Walking")
		return
	
	_animation_state_machine.travel("Idle")
	
#	var first_animation_frame: int = _starting_frames[facing_direction]
#	_body_sprite.frame = first_animation_frame
#
#	if not moving:
#		for node in _animation_tweens:
#			node.kill()
#		return
#
#	var tween = create_tween()
#	var last_animation_frame: int = _starting_frames[facing_direction] + walking_frame_amount - 1
#	tween.tween_property(_body_sprite, "frame", last_animation_frame, 1.0)
#	tween.set_loops()

#func rotate_degrees(rotation_degree_vector: Vector3, delta: float) -> void:
#	rotation += rotation_degree_vector * delta


func set_texture_offset(new_offset: Vector2) -> void:
	texture_offset = new_offset
	
	
	if not _body_sprite:
		return
	
	texture_offset = new_offset
	_body_sprite.offset = texture_offset
