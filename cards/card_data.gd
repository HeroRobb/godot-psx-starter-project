class_name CardData
extends Resource


@export var card_name: String = "Card Name"
@export var card_type: Global.CARD_TYPES = Global.CARD_TYPES.TOOL
@export var card_rarity: Global.CARD_RARITIES = Global.CARD_RARITIES.COMMON
@export var image_region: Rect2i
@export_multiline var description: String
@export_category("Player Effects")
@export_range(-6.0, 15.0, 0.25) var player_max_speed_modifier: float = 0.0
@export_range(-6, 15, 0.25) var player_acceleration_modifier: float = 0.0
@export_range(-6, 15, 0.25) var player_friction_modifier: float = 0.0
@export_range(-6, 15, 0.25) var player_max_health_modifier: float = 0.0
@export_category("Projectiles")
@export var tool_type: Global.PROJECTILES = Global.PROJECTILES.NONE
@export_category("Projectile Effects")
@export_range(-50.0, 50.0, 0.5) var projectile_max_speed_modifier: float = 0.0
@export_range(-20.0, 20.0, 0.1) var projectile_acceleration_modifier: float = 0.0
@export_range(-20.0, 20.0, 0.5) var projectile_friction_modifier: float = 0.0
@export_range(-1000, 1000) var projectile_damage_amount_modifier: int = 0
@export_range(-5, 5) var projectile_max_hits_modifier: int = 0
@export var projectile_added_damage_types: Array[Global.DAMAGE_TYPES] = []
@export var projectile_removed_damage_types: Array[Global.DAMAGE_TYPES] = []
