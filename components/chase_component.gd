# ============================================
# components/chase_component.gd
# ============================================
class_name ChaseComponent
extends RefCounted

var owner: CharacterBody2D
var target: Node2D
var speed: float
var detection_range: float
var lose_range: float
var min_distance: float

func _init(
	p_owner: CharacterBody2D,
	p_speed: float = 150.0,
	p_detection: float = 300.0,
	p_lose: float = 500.0,
	p_min_dist: float = 50.0
):
	owner = p_owner
	speed = p_speed
	detection_range = p_detection
	lose_range = p_lose
	min_distance = p_min_dist

func set_target(p_target: Node2D):
	target = p_target

func can_see_target() -> bool:
	if not target:
		return false
	
	var distance = owner.global_position.distance_to(target.global_position)
	return distance <= detection_range

func lost_target() -> bool:
	if not target:
		return true
	
	var distance = owner.global_position.distance_to(target.global_position)
	return distance > lose_range

func is_in_range() -> bool:
	if not target:
		return false
	
	var distance = owner.global_position.distance_to(target.global_position)
	return distance <= detection_range

func update(delta: float) -> Vector2:
	if not target:
		return Vector2.ZERO
	
	var distance = owner.global_position.distance_to(target.global_position)
	
	# Mantém distância mínima
	if distance < min_distance:
		return Vector2.ZERO
	
	var direction = (target.global_position - owner.global_position).normalized()
	return direction * speed

func get_distance_to_target() -> float:
	if not target:
		return INF
	return owner.global_position.distance_to(target.global_position)

func get_direction_to_target() -> Vector2:
	if not target:
		return Vector2.ZERO
	return (target.global_position - owner.global_position).normalized()
