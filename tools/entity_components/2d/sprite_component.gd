@tool
class_name SpriteComponent
extends Node2D


enum ANIMATIONS {IDLE, WALK, ATTACK, TAKE_HIT, DIE, SKITTER}

signal flashing_finished()
signal facing_changed()
signal animation_finished(animation_name: String)

const FLASH_LENGTH: float = 0.05
const FLASH_COLOR: Color = Color(10, 10, 10)

@export var body_texture: Texture : set = set_body_texture, get = get_body_texture
@export var _move_animation: ANIMATIONS = ANIMATIONS.WALK

var moving: bool = false: set = set_moving

var _animation_tweens: Array

@onready var _body_sprite: Sprite2D = $BodySprite
@onready var _flash_timer: Timer = $FlashTimer
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	if body_texture:
		_body_sprite.texture = body_texture
	
	_animation_player.animation_finished.connect(_on_animation_finished)


func flash(flash_time: float) -> void:
	while flash_time > FLASH_LENGTH * 2:
		_individual_flash()
		_flash_timer.start(FLASH_LENGTH)
		flash_time -= FLASH_LENGTH
		await(_flash_timer.timeout)
	
	_flash_timer.start(FLASH_LENGTH * 2)
	_body_sprite.modulate = FLASH_COLOR
	await(_flash_timer.timeout)
	_body_sprite.modulate = Color.WHITE
	flashing_finished.emit()


func face(direction: Vector2) -> void:
	var move_sign: float = signf(direction.x)
	if move_sign == 0:
		return
	scale.x = move_sign


func set_moving(new_moving: bool) -> void:
	if moving == new_moving:
		return
	
	moving = new_moving
	
	if moving:
		play_animation(_move_animation)
		return
	
	play_animation(ANIMATIONS.IDLE)


func play_animation(animation: ANIMATIONS) -> void:
	var animation_name: String = ANIMATIONS.keys()[animation]
	animation_name = animation_name.to_lower()
	_animation_player.play(animation_name)


func _individual_flash() -> void:
	if _body_sprite.modulate == Color.WHITE:
		_body_sprite.modulate = FLASH_COLOR
		return
	
	_body_sprite.modulate = Color.WHITE


func set_body_texture(new_texture: Texture) -> void:
	body_texture = new_texture
	
	if _body_sprite:
		_body_sprite.texture = body_texture


func get_body_texture() -> Texture2D:
	return body_texture.duplicate()


func _on_animation_finished(animation_name: String) -> void:
	animation_finished.emit(animation_name)
