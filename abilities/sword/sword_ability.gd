class_name SwordAbility
extends Node2D


@onready var _hitbox_component: HitboxComponent2D = $HitboxComponent2D


func set_damage_source(damage_source: DamageSource) -> void:
	_hitbox_component.damage_source = damage_source


func add_hits(extra_hits: int) -> void:
	_hitbox_component.max_hits += extra_hits
