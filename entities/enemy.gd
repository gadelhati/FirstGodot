# ============================================
# ENTIDADES (Entities/enemy.gd)
# ============================================
class_name Enemy
extends CharacterBody2D

# Componentes
var health_component: HealthComponent
var damage_feedback: DamageFeedbackComponent
var contact_damage_component: ContactDamageComponent
var contact_area: Area2D  # Área para detectar contato

# Configurações
@export_group("Health")
@export var max_hp: float = 100.0
@export var health_bar: HealthBar

@export_group("Contact Damage")
@export var contact_damage: float = 10.0
@export var damage_cooldown: float = 1.0
@export var enable_contact_damage: bool = true
@export var contact_radius: float = 75.0  # Raio da área de contato

func _ready():
	_initialize_components()
	_setup_contact_area()
	_connect_signals()

func _initialize_components():
	health_component = HealthComponent.new(max_hp)
	damage_feedback = DamageFeedbackComponent.new(self)
	contact_damage_component = ContactDamageComponent.new(
		self,
		contact_damage,
		damage_cooldown
	)
	
	# Inicializa health bar se existir
	if health_bar:
		health_bar.initialize(health_component)

func _setup_contact_area():
	# Cria área de detecção de contato
	contact_area = Area2D.new()
	add_child(contact_area)
	
	# Configura collision shape
	var shape = CircleShape2D.new()
	shape.radius = contact_radius
	
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	contact_area.add_child(collision_shape)
	
	# Configura layers (mesma do Enemy)
	contact_area.collision_layer = 0  # Não colide com nada
	contact_area.collision_mask = 1   # Detecta apenas Hero (layer 1)
	
	# Conecta signals
	contact_area.body_entered.connect(_on_contact_area_body_entered)

func _connect_signals():
	health_component.damage_taken.connect(_on_damage_taken)
	health_component.death.connect(_on_death)
	contact_damage_component.damage_dealt.connect(_on_contact_damage_dealt)

func _physics_process(delta):
	if enable_contact_damage:
		# Verifica colisões de slide (quando se move)
		_check_slide_collisions()
		# Verifica corpos dentro da área (mesmo parados)
		_check_contact_area()

func _check_slide_collisions():
	# Verifica colisões durante o movimento
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		contact_damage_component.try_deal_contact_damage(collider)

func _check_contact_area():
	# Verifica todos os corpos que estão dentro da área de contato
	if contact_area:
		var overlapping_bodies = contact_area.get_overlapping_bodies()
		for body in overlapping_bodies:
			contact_damage_component.try_deal_contact_damage(body)

func _on_contact_area_body_entered(body: Node2D):
	# Detecta quando Hero entra na área
	if enable_contact_damage:
		contact_damage_component.try_deal_contact_damage(body)

# API Pública
func take_damage(damage: float):
	health_component.take_damage(damage)

func heal(amount: float):
	health_component.heal(amount)

func get_current_hp() -> float:
	return health_component.get_current_hp()

func get_max_hp() -> float:
	return health_component.get_max_hp()

func set_contact_damage_enabled(enabled: bool):
	enable_contact_damage = enabled

# Callbacks
func _on_damage_taken(_damage: float, _current: float):
	damage_feedback.play_feedback()

func _on_death():
	# Desabilita dano de contato ao morrer
	enable_contact_damage = false
	# Animação de morte ou efeitos podem ser adicionados aqui
	queue_free()

func _on_contact_damage_dealt(_target: Node, _damage: float):
	# Feedback visual ou sonoro quando causa dano por contato
	pass
