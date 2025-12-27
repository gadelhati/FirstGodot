# ============================================
# components/projectile_component.gd
# ============================================
class_name ProjectileComponent
extends RefCounted

var direction: Vector2
var speed: float
var max_range: float
var distance: float = 0.0

func _init(dir: Vector2, spd: float, rng: float):
	direction = dir.normalized()
	speed = spd
	max_range = rng

func move(delta: float) -> Vector2:
	var movement = direction * speed * delta
	distance += movement.length()
	return movement

func is_expired() -> bool:
	return distance >= max_range

func get_rotation() -> float:
	return direction.angle()

func get_progress() -> float:
	return (distance / max_range) * 100.0 if max_range > 0 else 100.0
