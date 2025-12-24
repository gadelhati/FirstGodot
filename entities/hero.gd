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
@export var base_speed: float = 300.0
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

func _ready():
	_init_components()
	_find_mobile_controls()
	_connect()

func _init_components():
	health = HealthComponent.new(max_hp)
	movement = MovementComponent.new(base_speed)
	inventory = InventoryComponent.new(max_weapons)
	feedback = DamageFeedbackComponent.new(self)
	
	# Arma inicial
	if not starting_weapon:
		starting_weapon = WeaponData.create_pistol()
	
	starting_weapon.bullet_scene = bullet_scene
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
	
	# Cria novo ammo e weapon
	ammo = AmmoComponent.new(weapon_data.max_ammo, false)
	weapon = WeaponComponent.new(
		weapon_data.bullet_scene,
		weapon_data.damage + damage_boost,
		weapon_data.bullet_speed,
		weapon_data.bullet_range,
		weapon_data.fire_rate,
		spawn_point if spawn_point else self,
		ammo,
		weapon_data.ammo_per_shot
	)
	
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

func _physics_process(delta):
	_update_boosts(delta)
	_move()
	_shoot()
	_check_reload()
	_check_weapon_switch()

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
	print("🏥 Hero.heal() - Curando: ", amount)
	print("   HP antes: ", health.get_current_hp(), "/", health.get_max_hp())
	health.heal(amount)
	print("   HP depois: ", health.get_current_hp(), "/", health.get_max_hp())

func add_ammo(amount: int):
	print("🔫 Hero.add_ammo() - Adicionando: ", amount)
	if ammo:
		print("   Munição antes: ", ammo.get_current(), "/", ammo.get_max())
		ammo.reload(amount)
		print("   Munição depois: ", ammo.get_current(), "/", ammo.get_max())
	else:
		print("   ❌ Ammo component não existe!")

func change_weapon(index: int):
	print("🔄 Hero.change_weapon() - Index: ", index)
	if inventory.change_weapon(index):
		_equip_current_weapon()
		print("   ✅ Arma trocada")
	else:
		print("   ❌ Índice inválido")

func add_weapon(weapon_data: WeaponData):
	print("➕ Hero.add_weapon() - Arma: ", weapon_data.weapon_name)
	weapon_data.bullet_scene = bullet_scene
	inventory.add_weapon(weapon_data)
	# Equipa automaticamente se for a primeira arma
	if inventory.get_weapon_count() == 1:
		_equip_current_weapon()
	print("   ✅ Arma adicionada. Total: ", inventory.get_weapon_count())

func apply_speed_boost(boost: float, duration: float):
	print("⚡ Hero.apply_speed_boost() - Boost: ", boost, " Duração: ", duration, "s")
	print("   Velocidade antes: ", movement.speed)
	speed_boost = boost
	speed_boost_timer = duration
	movement.set_speed(base_speed + boost)
	print("   Velocidade depois: ", movement.speed)

func apply_damage_boost(boost: float, duration: float):
	print("💥 Hero.apply_damage_boost() - Boost: ", boost, " Duração: ", duration, "s")
	damage_boost = boost
	damage_boost_timer = duration
	# Atualiza dano da arma atual
	if weapon:
		var weapon_data = inventory.get_current_weapon()
		var old_damage = weapon.damage
		weapon.damage = weapon_data.damage + damage_boost
		print("   Dano antes: ", old_damage)
		print("   Dano depois: ", weapon.damage)

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
