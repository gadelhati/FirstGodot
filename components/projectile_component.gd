# ============================================
# COMPONENTES COMPARTILHADOS (components/projectile_component.gd)
# ============================================
class_name ProjectileComponent
extends RefCounted

signal target_hit(target: Node)

var direction: Vector2
var speed: float
var max_distance: float
var traveled_distance: float = 0.0

func _init(p_direction: Vector2, p_speed: float, p_max_distance: float):
	direction = p_direction.normalized()
	speed = p_speed
	max_distance = p_max_distance
	traveled_distance = 0.0

func move(delta: float) -> Vector2:
	var movement = direction * speed * delta
	traveled_distance += movement.length()
	return movement

func should_destroy() -> bool:
	return traveled_distance >= max_distance

func get_rotation() -> float:
	return direction.angle()

func get_traveled_percentage() -> float:
	return (traveled_distance / max_distance) * 100.0 if max_distance > 0 else 100.0
