# ============================================
# components/patrol_component.gd
# ============================================
class_name PatrolComponent
extends RefCounted

var owner: CharacterBody2D
var points: Array[Vector2] = []
var current_index: int = 0
var speed: float
var reach_distance: float
var loop: bool

func _init(p_owner: CharacterBody2D, p_speed: float = 100.0, p_reach_distance: float = 10.0, p_loop: bool = true):
	owner = p_owner
	speed = p_speed
	reach_distance = p_reach_distance
	loop = p_loop

func set_points(p_points: Array[Vector2]):
	points = p_points
	current_index = 0

func add_point(point: Vector2):
	points.append(point)

func get_target() -> Vector2:
	if points.is_empty():
		return owner.global_position
	
	return points[current_index]

func update(_delta: float) -> Vector2:
	if points.is_empty():
		return Vector2.ZERO
	
	var target = get_target()
	var direction = (target - owner.global_position).normalized()
	
	# Verifica se chegou no ponto
	if owner.global_position.distance_to(target) < reach_distance:
		_next_point()
	
	return direction * speed

func _next_point():
	current_index += 1
	
	if current_index >= points.size():
		if loop:
			current_index = 0
		else:
			current_index = points.size() - 1

func get_progress() -> float:
	if points.is_empty():
		return 0.0
	return float(current_index) / float(points.size()) * 100.0

func reset():
	current_index = 0
