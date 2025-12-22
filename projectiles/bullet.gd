# ============================================
# PROJÉTEIS (projectiles/bullet.gd)
# ============================================
class_name Bullet
extends Area2D

var projectile: ProjectileComponent
var dealer: DamageDealerComponent

@export var destroy_on_hit: bool = true
@export var pierce: bool = false
@export var sprite: Sprite2D
@export var trail: Line2D

func setup(dir: Vector2, speed: float, range: float, damage: float):
	_init_components(dir, speed, range, damage)
	rotation = projectile.get_rotation()
	_connect_signals()

func _init_components(dir: Vector2, speed: float, range: float, damage: float):
	projectile = ProjectileComponent.new(dir, speed, range)
	dealer = DamageDealerComponent.new(damage, pierce)

func _connect_signals():
	if not body_entered.is_connected(_on_body_hit):
		body_entered.connect(_on_body_hit)
	if not area_entered.is_connected(_on_area_hit):
		area_entered.connect(_on_area_hit)

func _physics_process(delta):
	position += projectile.move(delta)
	
	if trail:
		_update_trail()
	
	if projectile.is_expired():
		_destroy()

func _update_trail():
	if trail.get_point_count() > 20:
		trail.remove_point(0)
	trail.add_point(Vector2.ZERO)

func _on_body_hit(body: Node2D):
	dealer.try_damage(body)
	if destroy_on_hit:
		_destroy()

func _on_area_hit(_area: Area2D):
	if destroy_on_hit:
		_destroy()

func _destroy():
	queue_free()

# API Pública
func get_damage() -> float:
	return dealer.damage

func set_damage(value: float):
	dealer.damage = value
