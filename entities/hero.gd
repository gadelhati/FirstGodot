# ============================================
# ENTIDADES (Entities/hero.gd)
# ============================================
class_name Hero
extends CharacterBody2D

# Componentes
var health_component: HealthComponent
var movement_component: MovementComponent
var weapon_component: WeaponComponent
var damage_feedback: DamageFeedbackComponent

# Configurações
@export_group("Movement")
@export var speed: float = 300.0

@export_group("Health")
@export var max_hp: float = 100.0
@export var health_bar: HealthBar

@export_group("Weapon")
@export var bullet_speed: float = 500.0
@export var max_bullet_distance: float = 500.0
@export var fire_rate: float = 0.2
@export var bullet_scene: PackedScene
@export var spawn_point: Node2D

func _ready():
	_initialize_components()
	_connect_signals()

func _initialize_components():
	health_component = HealthComponent.new(max_hp)
	movement_component = MovementComponent.new(speed)
	weapon_component = WeaponComponent.new(
		bullet_scene,
		bullet_speed,
		max_bullet_distance,
		fire_rate,
		spawn_point if spawn_point else self
	)
	damage_feedback = DamageFeedbackComponent.new(self)
	
	# Inicializa health bar se existir
	if health_bar:
		health_bar.initialize(health_component)

func _connect_signals():
	health_component.damage_taken.connect(_on_damage_taken)
	health_component.death.connect(_on_death)
	health_component.health_changed.connect(_on_health_changed)

func _physics_process(delta):
	_handle_movement(delta)
	_handle_shooting()

func _handle_movement(_delta: float):
	var input_vector = movement_component.get_input_vector()
	velocity = movement_component.calculate_velocity(input_vector)
	move_and_slide()

func _handle_shooting():
	if Input.is_action_pressed("shoot"):
		var origin_pos = weapon_component.get_spawn_position()
		var target_pos = get_global_mouse_position()
		weapon_component.try_shoot(origin_pos, target_pos, get_parent())

# API Pública
func take_damage(damage: float):
	health_component.take_damage(damage)

func heal(amount: float):
	health_component.heal(amount)

func get_current_hp() -> float:
	return health_component.get_current_hp()

func get_max_hp() -> float:
	return health_component.get_max_hp()

# Callbacks
func _on_damage_taken(_damage: float, _current: float):
	damage_feedback.play_feedback()

func _on_health_changed(_current: float, _maximum: float):
	pass  # Health bar já está conectada diretamente

func _on_death():
	print("Game Over!")
	movement_component.disable_input()
	# Aqui você pode adicionar animação de morte antes de recarregar
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
