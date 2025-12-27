# ============================================
# entities/hero.gd
# ============================================
class_name Hero
extends CharacterBody2D

var health: HealthComponent
var movement: MovementComponent
var weapon: WeaponComponent
var feedback: DamageFeedbackComponent
var ammo: AmmoComponent
var inventory: InventoryComponent

# Boosts temporários
var speed_boost: float = 0.0
var speed_boost_timer: float = 0.0
var damage_boost: float = 0.0
var damage_boost_timer: float = 0.0

@export_group("Stats")
@export var base_speed: float = 100.0
@export var max_hp: float = 100.0

@export_group("Starting Weapon")
@export var starting_weapon: WeaponData
@export var bullet_scene: PackedScene

@export_group("Inventory")
@export var max_weapons: int = 4

@export_group("UI")
@export var health_bar: HealthBar
@export var ammo_bar: AmmoBar
@export var weapon_label: Label
@export var spawn_point: Node2D

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	_init_components()
	_find_mobile_controls()
	_connect()

func _init_components():
	health = HealthComponent.new(max_hp)
	movement = MovementComponent.new(base_speed)
	inventory = InventoryComponent.new(max_weapons)
	feedback = DamageFeedbackComponent.new(self)
	
	if not starting_weapon:
		starting_weapon = WeaponData.pistol()
	
	starting_weapon.scene = bullet_scene
	inventory.add_weapon(starting_weapon)
	_equip_current_weapon()
	
	if health_bar:
		health_bar.initialize(health)
	
	if ammo_bar:
		ammo_bar.initialize(ammo)
	
	_update_weapon_ui()

func _equip_current_weapon():
	var weapon_data = inventory.get_current_weapon()
	if not weapon_data:
		return
	
	ammo = AmmoComponent.new(weapon_data.max_ammo, false)
	weapon = WeaponComponent.new(
		weapon_data.scene,
		weapon_data.damage + damage_boost,
		weapon_data.speed,
		weapon_data.max_range,
		weapon_data.rate,
		spawn_point if spawn_point else self,
		ammo,
		weapon_data.cost
	)
	
	if ammo_bar:
		ammo_bar.initialize(ammo)
	
	_update_weapon_ui()
	
	# Atualiza UI da munição (initialize já cuida da reconexão)
	if ammo_bar:
		ammo_bar.initialize(ammo)
	
	_update_weapon_ui()

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
	inventory.weapon_changed.connect(_on_weapon_changed)

func _physics_process(delta:float):
	_isometic(delta)
	_update_boosts(delta)
	_move()
	_shoot()
	_check_reload()
	_check_weapon_switch()

func _isometic(delta):
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction != Vector2.ZERO:
		velocity = direction * 16.0
	else:
		velocity = Vector2.ZERO
	move_and_slide()

func _update_boosts(delta):
	# Speed boost
	if speed_boost_timer > 0:
		speed_boost_timer -= delta
		if speed_boost_timer <= 0:
			speed_boost = 0.0
			movement.set_speed(base_speed)
	
	# Damage boost
	if damage_boost_timer > 0:
		damage_boost_timer -= delta
		if damage_boost_timer <= 0:
			damage_boost = 0.0

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
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_R):
		weapon.reload()

func _check_weapon_switch():
	# Scroll do mouse ou teclas numéricas
	if Input.is_action_just_pressed("ui_page_up"):
		inventory.next_weapon()
	elif Input.is_action_just_pressed("ui_page_down"):
		inventory.previous_weapon()
	
	# Teclas 1-4 para trocar diretamente
	for i in range(1, 5):
		if Input.is_key_pressed(KEY_1 + i - 1):
			change_weapon(i - 1)

func _update_weapon_ui():
	if weapon_label:
		var weapon_data = inventory.get_current_weapon()
		if weapon_data:
			weapon_label.text = "%s (%d/%d)" % [
				weapon_data.weapon_name,
				inventory.current_index + 1,
				inventory.get_weapon_count()
			]

# API Pública - Power-Ups
func heal(amount: float):
	health.heal(amount)

func add_ammo(amount: int):
	if ammo:
		ammo.reload(amount)

func change_weapon(index: int):
	if inventory.change_weapon(index):
		_equip_current_weapon()

func add_weapon(weapon_data: WeaponData):
	weapon_data.scene = bullet_scene
	inventory.add_weapon(weapon_data)
	if inventory.get_weapon_count() == 1:
		_equip_current_weapon()

func apply_speed_boost(boost: float, time: float):
	speed_boost = boost
	speed_boost_timer = time
	movement.set_speed(base_speed + boost)

func apply_damage_boost(boost: float, time: float):
	damage_boost = boost
	damage_boost_timer = time
	if weapon:
		var weapon_data = inventory.get_current_weapon()
		weapon.damage = weapon_data.damage + damage_boost

# Outros métodos
func take_damage(amount: float):
	health.take_damage(amount)
	feedback.play()

func reload():
	weapon.reload()

# Callbacks
func _on_health_changed(_current: float, _max: float):
	pass

func _on_death():
	movement.disable()
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

func _on_shot_failed():
	print("Sem munição!")

func _on_weapon_changed():
	_equip_current_weapon()
