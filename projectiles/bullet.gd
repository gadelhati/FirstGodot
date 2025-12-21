# ============================================
# PROJÉTEIS (projectiles/bullet.gd)
# ============================================
class_name Bullet
extends Area2D

# Componentes
var projectile_component: ProjectileComponent
var damage_dealer: DamageDealerComponent

# Configurações
@export var damage: float = 25.0
@export var destroy_on_hit: bool = true
@export var can_hit_multiple: bool = false

# Referências visuais (opcional)
@export var sprite: Sprite2D
@export var trail: Line2D

func setup(dir: Vector2, spd: float, max_dist: float):
	_initialize_components(dir, spd, max_dist)
	_connect_signals()
	_apply_visual_rotation()

func _initialize_components(dir: Vector2, spd: float, max_dist: float):
	projectile_component = ProjectileComponent.new(dir, spd, max_dist)
	damage_dealer = DamageDealerComponent.new(damage, can_hit_multiple)

func _connect_signals():
	projectile_component.max_distance_reached.connect(_on_max_distance_reached)
	damage_dealer.damage_dealt.connect(_on_damage_dealt)
	
	# Conecta sinais de colisão
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _apply_visual_rotation():
	rotation = projectile_component.get_rotation()

func _physics_process(delta):
	_handle_movement(delta)
	_check_destruction()

func _handle_movement(delta: float):
	var movement = projectile_component.move(delta)
	position += movement
	
	# Atualiza trail se existir
	if trail:
		_update_trail()

func _update_trail():
	# Adiciona ponto ao rastro
	if trail.get_point_count() > 20:
		trail.remove_point(0)
	trail.add_point(Vector2.ZERO)

func _check_destruction():
	if projectile_component.should_destroy():
		projectile_component.max_distance_reached.emit()

# Callbacks de colisão
func _on_body_entered(body: Node2D):
	var damage_applied = damage_dealer.try_deal_damage(body)
	
	if damage_applied and destroy_on_hit:
		_destroy_projectile()

func _on_area_entered(area: Area2D):
	# Colisão com paredes ou outras áreas
	_destroy_projectile()

func _on_max_distance_reached():
	_destroy_projectile()

func _on_damage_dealt(target: Node, damage_value: float):
	# Feedback visual ou sonoro pode ser adicionado aqui
	projectile_component.target_hit.emit(target)

func _destroy_projectile():
	# Efeito de destruição pode ser adicionado aqui
	queue_free()

# API Pública
func get_damage() -> float:
	return damage_dealer.damage

func set_damage(new_damage: float):
	damage_dealer.damage = new_damage

func get_traveled_distance() -> float:
	return projectile_component.traveled_distance

func get_direction() -> Vector2:
	return projectile_component.direction
