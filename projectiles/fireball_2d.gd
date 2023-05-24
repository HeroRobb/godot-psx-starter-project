extends Projectile2D


@onready var _sprite: Sprite2D = $Sprite2D
@onready var _flame_particles: GPUParticles2D = $FlameParticles
@onready var _explosion_particles: GPUParticles2D = $ExplosionParticles


func _ready():
	super()
	_explosion_particles.emitting = true


func _process(delta):
	$Sprite2D.rotation += delta * 0.25


func remove() -> void:
	_sprite.hide()
	_flame_particles.emitting = false
	super()
