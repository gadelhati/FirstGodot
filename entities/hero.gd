# ============================================
# entities/hero.gd (ATUALIZADO)
# ============================================
class_name Hero
extends CharacterBody2D

var health: HealthComponent
var movement: MovementComponent
var weapon: WeaponComponent
var feedback: DamageFeedbackComponent
var ammo: AmmoComponent

@export_group("Stats")
@export var speed: float = 300.0
@export var max_hp: float = 100.0

@export_group("Weapon")
@export var weapon_damage: float = 25.0
@export var bullet_speed: float = 500.0
@export var bullet_range: float = 1000.0
@export var fire_rate: float = 0.2
@export var bullet_scene: PackedScene

@export_group("Ammo")
@export var max_ammo: int = 30
@export var ammo_per_shot: int = 1
@export var infinite_ammo: bool = false

@export_group("UI")
@export var health_bar: HealthBar
@export var ammo_bar: AmmoBar
@export var spawn_point: Node2D

func _ready():
	_init_components()
	_find_mobile_controls()
	_connect()

func _init_components():
	health = HealthComponent.new(max_hp)
	movement = MovementComponent.new(speed)
	ammo = AmmoComponent.new(max_ammo, infinite_ammo)
	weapon = WeaponComponent.new(
		bullet_scene,
		weapon_damage,
		bullet_speed,
		bullet_range,
		fire_rate,
		spawn_point if spawn_point else self,
		ammo,
		ammo_per_shot
	)
	feedback = DamageFeedbackComponent.new(self)
	
	if health_bar:
		health_bar.initialize(health)
	
	if ammo_bar:
		ammo_bar.initialize(ammo)

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
	weapon.shot_failed.connect(_on_shot_failed)

func _physics_process(_delta):
	_move()
	_shoot()
	_check_reload()

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

func _check_reload():
	# Tecla R para recarregar
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_R):
		weapon.reload()

# API Pública
func take_damage(amount: float):
	health.take_damage(amount)
	feedback.play()

func heal(amount: float):
	health.heal(amount)

func reload():
	weapon.reload()

func add_ammo(amount: int):
	ammo.reload(amount)

# Callbacks
func _on_health_changed(_current: float, _max: float):
	pass

func _on_death():
	movement.disable()
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func _on_shot_failed():
	# Feedback visual/sonoro de sem munição
	print("Sem munição!")
