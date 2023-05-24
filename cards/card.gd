class_name Card
extends Node2D

const BLUE_BACKGROUND_REGION: Rect2i = Rect2i(14, 4, 100, 128)
const RED_BACKGROUND_REGION: Rect2i = Rect2i(133, 4, 100, 128)
const GRAY_BACKGROUND_REGION: Rect2i = Rect2i(251, 4, 100, 128)
const GREEN_BACKGROUND_REGION: Rect2i = Rect2i(366, 4, 100, 128)
const YELLOW_BACKGROUND_REGION: Rect2i = Rect2i(481, 4, 100, 128)
const PURPLE_BACKGROUND_REGION: Rect2i = Rect2i(332, 337, 100, 128)
const WOOD_RARITY_FRAME: Rect2i = Rect2i(14, 337, 100, 128)
const SILVER_RARITY_FRAME: Rect2i = Rect2i(120, 337, 100, 128)
const GOLD_RARITY_FRAME: Rect2i = Rect2i(226, 337, 100, 128)
const WOOD_TITLE_BORDER: Rect2i = Rect2i(16, 223, 96, 30)
const SILVER_TITLE_BORDER: Rect2i = Rect2i(135, 223, 96, 30)
const GOLD_TITLE_BORDER: Rect2i = Rect2i(252, 223, 96, 30)

@export var card_data: CardData
@export var front_texture: Texture
@export var image_texture: Texture

@onready var _card_front: Node2D = $CardFront
@onready var _card_back: Node2D = $CardBack
@onready var _card_background: Sprite2D = $CardFront/CardBackground
@onready var _card_rarity_frame: Sprite2D = $CardFront/CardRarityFrame
@onready var _title_border: Sprite2D = $CardFront/TitleBorder
@onready var _title_label: Label = $CardFront/TitleBorder/Label
@onready var _image: Sprite2D = $CardFront/Image
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _particles: GPUParticles2D = $GPUParticles2D



func _ready() -> void:
	update_card_visuals()
	show_back()
	shake()
	await(_animation_player.animation_finished)
	flip_to_front()
	await(_animation_player.animation_finished)
	_particles.emitting = true


func get_type() -> Global.CARD_TYPES:
	return card_data.card_type


func update_card_visuals() -> void:
	if not card_data:
		return
	
	_set_background_color()
	_set_rarity_frame()
	_set_title()
	_set_image()


func flip_to_front() -> void:
	_animation_player.play("flip_to_front")


func flip_to_back() -> void:
	_animation_player.play("flip_to_back")


func show_back() -> void:
	_card_back.show()
	_card_front.hide()


func show_front() -> void:
	_card_front.show()
	_card_back.hide()


func shake() -> void:
	_animation_player.play("shake")


func _set_background_color() -> void:
	if not front_texture:
		return
	
	var background_texture: AtlasTexture = AtlasTexture.new()
	background_texture.atlas = front_texture
	
	match card_data.card_type:
		Global.CARD_TYPES.PLAYER_MODIFIER:
			background_texture.region = BLUE_BACKGROUND_REGION
		Global.CARD_TYPES.TOOL:
			background_texture.region = RED_BACKGROUND_REGION
		Global.CARD_TYPES.TOOL_MODIFIER:
			background_texture.region = GREEN_BACKGROUND_REGION
	
	_card_background.texture = background_texture


func _set_rarity_frame() -> void:
	if not front_texture:
		return
	
	var frame_texture: AtlasTexture = AtlasTexture.new()
	frame_texture.atlas = front_texture
	
	match card_data.card_rarity:
		Global.CARD_RARITIES.COMMON:
			frame_texture.region = WOOD_RARITY_FRAME
		Global.CARD_RARITIES.UNCOMMON:
			frame_texture.region = SILVER_RARITY_FRAME
		Global.CARD_RARITIES.RARE:
			frame_texture.region = GOLD_RARITY_FRAME
	
	_card_rarity_frame.texture = frame_texture


func _set_title() -> void:
	_title_label.text = card_data.card_name
	
	match card_data.card_rarity:
		Global.CARD_RARITIES.COMMON:
			_title_border.texture.region = WOOD_TITLE_BORDER
		Global.CARD_RARITIES.UNCOMMON:
			_title_border.texture.region = SILVER_TITLE_BORDER
		Global.CARD_RARITIES.RARE:
			_title_border.texture.region = GOLD_TITLE_BORDER


func _set_image() -> void:
	if not front_texture:
		return
	
	var icon_texture: AtlasTexture = AtlasTexture.new()
	icon_texture.atlas = image_texture
	icon_texture.region = card_data.image_region
	
	_image.texture = icon_texture
