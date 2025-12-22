# ============================================
# ENTIDADES (Entities/enemy.gd)
# ============================================
class_name Enemy
extends CharacterBody2D

var health: HealthComponent
var feedback: DamageFeedbackComponent
var contact: ContactDamageComponent
var contact_area: Area2D

@export_group("Health")
@export var max_hp: float = 100.0
@export var health_bar: HealthBar

@export_group("Contact Damage")
@export var contact_damage: float = 10.0
@export var damage_cooldown: float = 1.0
@export var contact_radius: float = 75.0
@export var enable_contact: bool = true

func _ready():
	_init_components()
	_init_contact_area()
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

func _connect():
	health.health_changed.connect(_on_health_changed)
	health.death.connect(_on_death)
	contact_area.body_entered.connect(_on_body_entered)

func _physics_process(_delta):
	if enable_contact:
		_check_contacts()

func _check_contacts():
	# Verifica colisões de movimento
	for i in get_slide_collision_count():
		var body = get_slide_collision(i).get_collider()
		contact.try_damage(body)
	
	# Verifica corpos dentro da área
	for body in contact_area.get_overlapping_bodies():
		contact.try_damage(body)

func _on_body_entered(body: Node2D):
	if enable_contact:
		contact.try_damage(body)

# API Pública
func take_damage(amount: float):
	health.take_damage(amount)

func heal(amount: float):
	health.heal(amount)

# Callbacks
func _on_health_changed(_current: float, _max: float):
	feedback.play()

func _on_death():
	enable_contact = false
	queue_free()
