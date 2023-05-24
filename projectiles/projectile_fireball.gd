extends Projectile3D


@onready var _flame_particles: GPUParticles3D = $FlameParticles
@onready var _smoke_particles: GPUParticles3D = $SmokeParticles


func remove() -> void:
	_flame_particles.emitting = false
	_smoke_particles.emitting = false
	super()
