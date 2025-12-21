# ============================================
# COMPONENTES COMPARTILHADOS (components/weapon_component.gd)
# ============================================
class_name WeaponComponent
extends RefCounted

signal shot_fired(position: Vector2, direction: Vector2)
signal cooldown_started(duration: float)
signal cooldown_finished()

var bullet_scene: PackedScene
var bullet_speed: float
var max_bullet_distance: float
var fire_rate: float
var spawn_node: Node2D

var can_shoot: bool = true

func _init(
	p_bullet_scene: PackedScene,
	p_bullet_speed: float,
	p_max_distance: float,
	p_fire_rate: float,
	p_spawn_node: Node2D
):
	bullet_scene = p_bullet_scene
	bullet_speed = p_bullet_speed
	max_bullet_distance = p_max_distance
	fire_rate = p_fire_rate
	spawn_node = p_spawn_node

func get_spawn_position() -> Vector2:
	return spawn_node.global_position

func try_shoot(origin_pos: Vector2, target_pos: Vector2, parent_node: Node) -> bool:
	if not can_shoot or bullet_scene == null:
		return false
	
	can_shoot = false
	var direction = (target_pos - origin_pos).normalized()
	_spawn_bullet(origin_pos, direction, parent_node)
	_start_cooldown(parent_node)
	
	shot_fired.emit(origin_pos, direction)
	return true

func _spawn_bullet(origin_pos: Vector2, direction: Vector2, parent_node: Node):
	var spawn_distance = 80.0
	var spawn_position = origin_pos + (direction * spawn_distance)
	
	var bullet = bullet_scene.instantiate()
	parent_node.add_child(bullet)
	bullet.global_position = spawn_position
	bullet.setup(direction, bullet_speed, max_bullet_distance)

func _start_cooldown(node_with_tree: Node):
	cooldown_started.emit(fire_rate)
	await node_with_tree.get_tree().create_timer(fire_rate).timeout
	can_shoot = true
	cooldown_finished.emit()

func is_ready() -> bool:
	return can_shoot
