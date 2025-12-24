# ============================================
# entities/enemy.gd (REFATORADO COM IA)
# ============================================
class_name Enemy
extends CharacterBody2D

# Componentes básicos
var health: HealthComponent
var feedback: DamageFeedbackComponent
var contact: ContactDamageComponent
var contact_area: Area2D

# Componentes de IA
var ai_state: AIStateComponent
var patrol: PatrolComponent
var chase: ChaseComponent
var shooter: ShootComponent
var weapon: WeaponComponent
var ammo: AmmoComponent

@export_group("Health")
@export var max_hp: float = 100.0
@export var health_bar: HealthBar

@export_group("Contact Damage")
@export var contact_damage: float = 10.0
@export var damage_cooldown: float = 1.0
@export var contact_radius: float = 75.0
@export var enable_contact: bool = true

@export_group("AI Behavior")
@export var ai_enabled: bool = true
@export var initial_state: AIStateComponent.State = AIStateComponent.State.PATROL

@export_group("Patrol")
@export var patrol_speed: float = 100.0
@export var patrol_points: Array[Vector2] = []
@export var patrol_loop: bool = true

@export_group("Chase")
@export var chase_speed: float = 150.0
@export var detection_range: float = 300.0
@export var lose_range: float = 500.0
@export var min_chase_distance: float = 100.0

@export_group("Weapon")
@export var can_shoot: bool = true
@export var weapon_damage: float = 15.0
@export var bullet_speed: float = 400.0
@export var bullet_range: float = 800.0
@export var fire_rate: float = 1.0
@export var shoot_range: float = 400.0
@export var aim_precision: float = 0.2  # 0 = perfeito, 1 = muito impreciso
@export var bullet_scene: PackedScene
@export var spawn_point: Node2D

@export_group("Ammo")
@export var max_ammo: int = 50
@export var ammo_per_shot: int = 1
@export var infinite_ammo: bool = true

var target: Node2D  # Referência ao player

func _ready():
	_init_components()
	_init_contact_area()
	_init_ai()
	_connect()

func _init_components():
	health = HealthComponent.new(max_hp)
	feedback = DamageFeedbackComponent.new(self)
	contact = ContactDamageComponent.new(self, contact_damage, damage_cooldown)
	
	if health_bar:
		health_bar.initialize(health)

func _init_contact_area():
	contact_area = Area2D.new()
	add_child(contact_area)
	
	var shape = CircleShape2D.new()
	shape.radius = contact_radius
	
	var collision = CollisionShape2D.new()
	collision.shape = shape
	contact_area.add_child(collision)
	
	contact_area.collision_layer = 0
	contact_area.collision_mask = 1

func _init_ai():
	if not ai_enabled:
		return
	
	ai_state = AIStateComponent.new(self, initial_state)
	patrol = PatrolComponent.new(self, patrol_speed, 10.0, patrol_loop)
	chase = ChaseComponent.new(self, chase_speed, detection_range, lose_range, min_chase_distance)
	
	# Configura pontos de patrulha
	if not patrol_points.is_empty():
		patrol.set_points(patrol_points)
	else:
		# Patrulha em quadrado se não houver pontos
		var start = global_position
		patrol.add_point(start + Vector2(200, 0))
		patrol.add_point(start + Vector2(200, 200))
		patrol.add_point(start + Vector2(0, 200))
		patrol.add_point(start)
	
	# Configura sistema de tiro
	if can_shoot and bullet_scene:
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
		shooter = ShootComponent.new(self, weapon, shoot_range, aim_precision)
	
	# Encontra o player
	_find_target()

func _find_target():
	# Busca o Hero na cena
	var root = get_tree().root
	target = _find_hero(root)
	
	if target:
		chase.set_target(target)
		if shooter:
			shooter.set_target(target)

func _find_hero(node: Node) -> Node2D:
	if node is Hero:
		return node
	
	for child in node.get_children():
		var result = _find_hero(child)
		if result:
			return result
	
	return null

func _connect():
	health.health_changed.connect(_on_health_changed)
	health.death.connect(_on_death)
	contact_area.body_entered.connect(_on_body_entered)
	
	if ai_state:
		ai_state.state_changed.connect(_on_state_changed)

func _physics_process(delta):
	if enable_contact:
		_check_contacts()
	
	if ai_enabled:
		_update_ai(delta)

func _check_contacts():
	for i in get_slide_collision_count():
		var body = get_slide_collision(i).get_collider()
		contact.try_damage(body)
	
	for body in contact_area.get_overlapping_bodies():
		contact.try_damage(body)

func _update_ai(delta):
	match ai_state.current():
		AIStateComponent.State.IDLE:
			_ai_idle(delta)
		AIStateComponent.State.PATROL:
			_ai_patrol(delta)
		AIStateComponent.State.CHASE:
			_ai_chase(delta)
		AIStateComponent.State.ATTACK:
			_ai_attack(delta)

func _ai_idle(_delta):
	velocity = Vector2.ZERO
	if chase.can_see_target():
		ai_state.change(AIStateComponent.State.CHASE)

func _ai_patrol(_delta):
	velocity = patrol.update(_delta)
	move_and_slide()
	if chase.can_see_target():
		ai_state.change(AIStateComponent.State.CHASE)

func _ai_chase(delta):
	# Verifica se perdeu o player
	if chase.lost_target():
		ai_state.change(AIStateComponent.State.PATROL)
		return
	
	# Verifica se está em range de ataque
	if shooter and shooter.is_in_range():
		ai_state.change(AIStateComponent.State.ATTACK)
		return
	
	# Persegue
	velocity = chase.update(delta)
	move_and_slide()

func _ai_attack(delta):
	# Para de se mover
	velocity = Vector2.ZERO
	
	# Verifica se ainda está em range
	if not shooter.is_in_range():
		ai_state.change(AIStateComponent.State.CHASE)
		return
	
	# Verifica se perdeu o alvo
	if chase.lost_target():
		ai_state.change(AIStateComponent.State.PATROL)
		return
	
	# Atira
	if shooter and shooter.can_shoot():
		shooter.try_shoot(get_parent())

func _on_body_entered(body: Node2D):
	if enable_contact:
		contact.try_damage(body)

# API Pública
func take_damage(amount: float):
	health.take_damage(amount)

func heal(amount: float):
	health.heal(amount)

func set_target(new_target: Node2D):
	target = new_target
	if chase:
		chase.set_target(target)
	if shooter:
		shooter.set_target(target)

# API Pública - Power-Ups
func add_ammo(amount: int):
	if ammo:
		ammo.reload(amount)

func change_weapon(_index: int):
	pass  # Enemy não troca arma

func add_weapon(weapon_data: WeaponData):
	if not (weapon and ammo):
		return
	
	ammo = AmmoComponent.new(weapon_data.max_ammo, infinite_ammo)
	weapon = WeaponComponent.new(
		weapon_data.bullet_scene,
		weapon_data.damage,
		weapon_data.bullet_speed,
		weapon_data.bullet_range,
		weapon_data.fire_rate,
		spawn_point if spawn_point else self,
		ammo,
		weapon_data.ammo_per_shot
	)
	if shooter:
		shooter.weapon = weapon

func apply_speed_boost(boost: float, time: float):
	if patrol:
		patrol.speed += boost
	if chase:
		chase.speed += boost
	
	if time > 0:
		await get_tree().create_timer(time).timeout
		if patrol:
			patrol.speed -= boost
		if chase:
			chase.speed -= boost

func apply_damage_boost(boost: float, time: float):
	if not weapon:
		return
	
	weapon.damage += boost
	
	if time > 0:
		await get_tree().create_timer(time).timeout
		weapon.damage -= boost

# Callbacks
func _on_health_changed(_current: float, _max: float):
	feedback.play()

func _on_death():
	enable_contact = false
	ai_enabled = false
	queue_free()

func _on_state_changed(old_state: String, new_state: String):
	print("%s: %s -> %s" % [name, old_state, new_state])
