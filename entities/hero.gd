# ============================================
# entities/hero.gd (ATUALIZADO)
# ============================================
class_name Hero
extends CharacterBody2D

var health: HealthComponent
var movement: MovementComponent
var weapon: WeaponComponent
var feedback: DamageFeedbackComponent

@export_group("Stats")
@export var speed: float = 300.0
@export var max_hp: float = 100.0

@export_group("Weapon")
@export var bullet_speed: float = 500.0
@export var bullet_range: float = 1000.0
@export var fire_rate: float = 0.2
@export var bullet_scene: PackedScene

@export_group("UI")
@export var health_bar: HealthBar
@export var spawn_point: Node2D

func _ready():
	_init_components()
	_find_mobile_controls()
	_connect()

func _init_components():
	health = HealthComponent.new(max_hp)
	movement = MovementComponent.new(speed)
	weapon = WeaponComponent.new(
		bullet_scene,
		bullet_speed,
		bullet_range,
		fire_rate,
		spawn_point if spawn_point else self
	)
	feedback = DamageFeedbackComponent.new(self)
	
	if health_bar:
		health_bar.initialize(health)

func _find_mobile_controls():
	var root = get_tree().root
	var joystick = _find_script(root, "virtual_joystick.gd")
	var button = _find_script(root, "fire_button.gd")
	
	if joystick and button:
		movement.set_virtual_controls(joystick, button)

func _find_script(node: Node, script_name: String):
	var script = node.get_script()
	if script and script.resource_path.ends_with(script_name):
		return node
	
	for child in node.get_children():
		var result = _find_script(child, script_name)
		if result:
			return result
	
	return null

func _connect():
	health.health_changed.connect(_on_health_changed)
	health.death.connect(_on_death)

func _physics_process(_delta):
	_move()
	_shoot()

func _move():
	var input = movement.get_input_vector()
	velocity = movement.calculate_velocity(input)
	move_and_slide()

func _shoot():
	var input_mgr = movement.get_input_manager()
	
	if input_mgr.is_shooting():
		var origin = weapon.get_spawn_position()
		var target = input_mgr.get_aim_target(global_position)
		weapon.try_shoot(origin, target, get_parent())

# API Pública
func take_damage(amount: float):
	health.take_damage(amount)
	feedback.play()

func heal(amount: float):
	health.heal(amount)

# Callbacks
func _on_health_changed(_current: float, _max: float):
	pass  # Health bar já conectada

func _on_death():
	movement.disable_input()
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
