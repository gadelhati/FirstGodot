# ============================================
# components/shoot_component.gd
# ============================================
class_name ShootComponent
extends RefCounted

signal shot_fired(pos: Vector2, dir: Vector2)

var owner: Node2D
var weapon: WeaponComponent
var target: Node2D
var shoot_range: float
var aim_offset: float  # Imprecisão da mira

func _init(
	p_owner: Node2D,
	p_weapon: WeaponComponent,
	p_range: float = 400.0,
	p_aim_offset: float = 0.1
):
	owner = p_owner
	weapon = p_weapon
	shoot_range = p_range
	aim_offset = p_aim_offset

func set_target(p_target: Node2D):
	target = p_target

func can_shoot() -> bool:
	if not target or not weapon:
		return false
	
	var distance = owner.global_position.distance_to(target.global_position)
	return distance <= shoot_range and weapon.is_ready()

func try_shoot(parent: Node) -> bool:
	if not can_shoot():
		return false
	
	var origin = weapon.get_spawn_position()
	var target_pos = _get_aim_position()
	
	var success = weapon.try_shoot(origin, target_pos, parent)
	if success:
		var direction = (target_pos - origin).normalized()
		shot_fired.emit(origin, direction)
	
	return success

func _get_aim_position() -> Vector2:
	if not target:
		return owner.global_position + Vector2.RIGHT * 100
	
	# Adiciona imprecisão à mira
	var base_pos = target.global_position
	var offset = Vector2(
		randf_range(-aim_offset, aim_offset),
		randf_range(-aim_offset, aim_offset)
	) * 100.0
	
	return base_pos + offset

func get_distance_to_target() -> float:
	if not target:
		return INF
	return owner.global_position.distance_to(target.global_position)

func is_in_range() -> bool:
	if not target:
		return false
	return get_distance_to_target() <= shoot_range
