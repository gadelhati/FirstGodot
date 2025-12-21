# ============================================
# enemy.gd
# ============================================
class_name Enemy
extends CharacterBody2D

# Componentes
var health_component: HealthComponent
var damage_feedback: DamageFeedbackComponent

# Configurações
@export var max_hp: float = 100.0
@export var health_bar: HealthBar

func _ready():
	_initialize_components()
	_connect_signals()

func _initialize_components():
	health_component = HealthComponent.new(max_hp)
	damage_feedback = DamageFeedbackComponent.new(self)
	
	# Inicializa health bar se existir
	if health_bar:
		health_bar.initialize(health_component)

func _connect_signals():
	health_component.damage_taken.connect(_on_damage_taken)
	health_component.death.connect(_on_death)

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
func _on_damage_taken(damage: float, current: float):
	damage_feedback.play_feedback()

func _on_death():
	# Animação de morte ou efeitos podem ser adicionados aqui
	queue_free()
