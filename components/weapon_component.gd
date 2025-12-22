# ============================================
# COMPONENTES COMPARTILHADOS (components/weapon_component.gd)
# ============================================
class_name WeaponComponent
extends RefCounted

signal shot_fired(pos: Vector2, dir: Vector2)

var bullet_scene: PackedScene
var speed: float
var max_range: float
var fire_rate: float
var spawn: Node2D
var ready: bool = true

func _init(scene: PackedScene, spd: float, rng: float, rate: float, spawn_node: Node2D):
	bullet_scene = scene
	speed = spd
	max_range = rng
	fire_rate = rate
	spawn = spawn_node

func get_spawn_position() -> Vector2:
	return spawn.global_position

func try_shoot(origin: Vector2, target: Vector2, parent: Node) -> bool:
	if not ready or not bullet_scene:
		return false
	
	ready = false
	var direction = (target - origin).normalized()
	_spawn_bullet(origin, direction, parent)
	_start_cooldown(parent)
	
	shot_fired.emit(origin, direction)
	return true

func is_ready() -> bool:
	return ready

func _spawn_bullet(origin: Vector2, direction: Vector2, parent: Node):
	var spawn_offset = 80.0
	var spawn_pos = origin + (direction * spawn_offset)
	
	var bullet = bullet_scene.instantiate()
	parent.add_child(bullet)
	bullet.global_position = spawn_pos
	bullet.setup(direction, speed, max_range)

func _start_cooldown(node: Node):
	await node.get_tree().create_timer(fire_rate).timeout
	ready = true
