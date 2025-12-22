# ============================================
# COMPONENTES COMPARTILHADOS (components/weapon_component.gd)
# ============================================
class_name WeaponComponent
extends RefCounted

signal shot_fired(pos: Vector2, dir: Vector2)
signal shot_failed()  # Sem munição

var bullet_scene: PackedScene
var damage: float
var speed: float
var range: float
var fire_rate: float
var ammo_cost: int
var spawn: Node2D
var ammo: AmmoComponent
var ready: bool = true

func _init(
	scene: PackedScene,
	dmg: float,
	spd: float,
	rng: float,
	rate: float,
	spawn_node: Node2D,
	p_ammo: AmmoComponent,
	cost: int = 1
):
	bullet_scene = scene
	damage = dmg
	speed = spd
	range = rng
	fire_rate = rate
	spawn = spawn_node
	ammo = p_ammo
	ammo_cost = cost

func get_spawn_position() -> Vector2:
	return spawn.global_position

func try_shoot(origin: Vector2, target: Vector2, parent: Node) -> bool:
	if not ready or not bullet_scene:
		return false
	
	# Verifica munição
	if not ammo.can_shoot():
		shot_failed.emit()
		return false
	
	# Consome munição
	if not ammo.consume(ammo_cost):
		shot_failed.emit()
		return false
	
	ready = false
	var direction = (target - origin).normalized()
	_spawn_bullet(origin, direction, parent)
	_start_cooldown(parent)
	
	shot_fired.emit(origin, direction)
	return true

func is_ready() -> bool:
	return ready and ammo.can_shoot()

func reload():
	ammo.reload()

func get_ammo() -> AmmoComponent:
	return ammo

func _spawn_bullet(origin: Vector2, direction: Vector2, parent: Node):
	var spawn_offset = 80.0
	var spawn_pos = origin + (direction * spawn_offset)
	
	var bullet = bullet_scene.instantiate()
	parent.add_child(bullet)
	bullet.global_position = spawn_pos
	bullet.setup(direction, speed, range, damage)

func _start_cooldown(node: Node):
	await node.get_tree().create_timer(fire_rate).timeout
	ready = true
